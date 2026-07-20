import 'dart:async';
import 'dart:io';

import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/features/realtime/data/realtime_repository.dart';
import 'package:devroute_ai_studio/features/realtime/data/realtime_transport.dart';
import 'package:devroute_ai_studio/features/realtime/domain/realtime_models.dart';
import 'package:devroute_ai_studio/features/realtime/presentation/realtime_session_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTransport extends RealtimeTransport {
  final List<StreamController<TransportMessage>> controllers = [];
  final List<Object> sent = [];
  var connections = 0;

  @override
  Future<RealtimeTransportConnection> connect(
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    connections++;
    final controller = StreamController<TransportMessage>();
    controllers.add(controller);
    return RealtimeTransportConnection(
      messages: controller.stream,
      send: (message) async => sent.add(message),
      close: () async {
        if (!controller.isClosed) await controller.close();
      },
    );
  }
}

void main() {
  test(
    'session transitions, send, receive, cancel and bounded reconnect',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final transport = _FakeTransport();
      final cubit = RealtimeSessionCubit(
        transport,
        RealtimeRepository(database),
      );
      addTearDown(cubit.close);
      const config = RealtimeSessionConfig(
        id: 'session',
        protocol: RealtimeProtocolType.webSocket,
        url: 'ws://localhost',
        reconnectPolicy: ReconnectPolicy(
          enabled: true,
          maxAttempts: 1,
          initialDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
      );
      await cubit.connect(config);
      expect(cubit.state.status, RealtimeConnectionStatus.connected);
      await cubit.sendText('hello');
      expect(transport.sent, ['hello']);
      transport.controllers.first.add(
        const TransportMessage(
          type: RealtimePayloadType.text,
          content: 'world',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        cubit.state.messages.map((item) => item.content),
        containsAll(['hello', 'world']),
      );

      transport.controllers.first.addError(const SocketException('offline'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(transport.connections, 2);
      expect(cubit.state.metrics.reconnectAttempts, 1);
      await cubit.cancel();
      expect(cubit.state.status, RealtimeConnectionStatus.cancelled);
    },
  );

  test(
    'HTTP stream batches updates and reports bounded retention drops',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final transport = _FakeTransport();
      final cubit = RealtimeSessionCubit(
        transport,
        RealtimeRepository(database),
      );
      addTearDown(cubit.close);
      await cubit.connect(
        const RealtimeSessionConfig(
          id: 'stream',
          protocol: RealtimeProtocolType.httpStream,
          url: 'http://localhost',
          maxEvents: 2,
        ),
      );
      for (var index = 0; index < 5; index++) {
        transport.controllers.single.add(
          TransportMessage(
            type: RealtimePayloadType.chunk,
            content: 'chunk-$index',
          ),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(cubit.state.messages, hasLength(2));
      expect(cubit.state.messages.last.content, 'chunk-4');
      expect(cubit.state.droppedMessages, 3);
    },
  );

  test('sibling realtime sessions keep state and events isolated', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final transport = _FakeTransport();
    final first = RealtimeSessionCubit(transport, RealtimeRepository(database));
    final second = first.createSibling();
    addTearDown(first.close);
    addTearDown(second.close);
    await first.connect(
      const RealtimeSessionConfig(
        id: 'first',
        protocol: RealtimeProtocolType.webSocket,
        url: 'ws://localhost/first',
      ),
    );
    await second.connect(
      const RealtimeSessionConfig(
        id: 'second',
        protocol: RealtimeProtocolType.webSocket,
        url: 'ws://localhost/second',
      ),
    );
    transport.controllers[0].add(
      const TransportMessage(type: RealtimePayloadType.text, content: 'one'),
    );
    transport.controllers[1].add(
      const TransportMessage(type: RealtimePayloadType.text, content: 'two'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(first.state.messages.single.content, 'one');
    expect(second.state.messages.single.content, 'two');
  });
}
