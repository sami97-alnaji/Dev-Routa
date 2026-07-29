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
  _FakeTransport({this.closeStreams = true});

  final List<StreamController<TransportMessage>> controllers = [];
  final List<int> closeCounts = [];
  final List<Object> sent = [];
  final bool closeStreams;
  final Map<int, Completer<void>> _connectionMilestones =
      <int, Completer<void>>{};
  var connections = 0;

  Future<void> waitForConnections(int count) {
    if (connections >= count) return Future<void>.value();
    return _connectionMilestones.putIfAbsent(count, Completer<void>.new).future;
  }

  @override
  Future<RealtimeTransportConnection> connect(
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    connections++;
    for (final entry in _connectionMilestones.entries) {
      if (connections >= entry.key && !entry.value.isCompleted) {
        entry.value.complete();
      }
    }
    final controller = StreamController<TransportMessage>();
    controllers.add(controller);
    closeCounts.add(0);
    final index = controllers.length - 1;
    return RealtimeTransportConnection(
      messages: controller.stream,
      send: (message) async => sent.add(message),
      close: () async {
        closeCounts[index]++;
        if (closeStreams && !controller.isClosed) await controller.close();
      },
    );
  }
}

const _reconnectingConfig = RealtimeSessionConfig(
  id: 'reconnecting',
  protocol: RealtimeProtocolType.webSocket,
  url: 'ws://localhost',
  reconnectPolicy: ReconnectPolicy(
    enabled: true,
    maxAttempts: 1,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 1),
  ),
);

Future<void> _waitForState(
  RealtimeSessionCubit cubit,
  bool Function(RealtimeSessionState state) predicate,
) async {
  if (predicate(cubit.state)) return;
  await cubit.stream.firstWhere(predicate);
}

void main() {
  test('cancel during reconnect delay prevents a second connection', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final reconnectGate = Completer<void>();
    final transport = _FakeTransport();
    final cubit = RealtimeSessionCubit(
      transport,
      RealtimeRepository(database),
      reconnectDelay: (_) => reconnectGate.future,
    );
    addTearDown(cubit.close);

    await cubit.connect(_reconnectingConfig);
    final reconnecting = _waitForState(
      cubit,
      (state) => state.status == RealtimeConnectionStatus.reconnecting,
    );
    transport.controllers.single.addError(const SocketException('offline'));
    await reconnecting;
    await cubit.cancel();
    reconnectGate.complete();
    await reconnectGate.future;

    expect(transport.connections, 1);
    expect(transport.closeCounts, <int>[1]);
    expect(cubit.state.status, RealtimeConnectionStatus.cancelled);
  });

  test(
    'stale old connection messages and onDone cannot affect replacement',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final reconnectGate = Completer<void>();
      final transport = _FakeTransport(closeStreams: false);
      final cubit = RealtimeSessionCubit(
        transport,
        RealtimeRepository(database),
        reconnectDelay: (_) => reconnectGate.future,
      );
      addTearDown(cubit.close);

      await cubit.connect(_reconnectingConfig);
      final reconnecting = _waitForState(
        cubit,
        (state) => state.status == RealtimeConnectionStatus.reconnecting,
      );
      transport.controllers.first.addError(const SocketException('offline'));
      await reconnecting;
      final replacement = transport.waitForConnections(2);
      reconnectGate.complete();
      await replacement;

      transport.controllers.first
        ..add(
          const TransportMessage(
            type: RealtimePayloadType.text,
            content: 'stale message',
          ),
        )
        ..close();
      final received = _waitForState(
        cubit,
        (state) =>
            state.messages.any((message) => message.content == 'current'),
      );
      transport.controllers.last.add(
        const TransportMessage(
          type: RealtimePayloadType.text,
          content: 'current',
        ),
      );
      await received;

      expect(cubit.state.status, RealtimeConnectionStatus.connected);
      expect(
        cubit.state.messages.map((message) => message.content),
        isNot(contains('stale message')),
      );
    },
  );

  test(
    'one failed generation reconnects once and closes each connection once',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final reconnectGate = Completer<void>();
      final transport = _FakeTransport();
      final cubit = RealtimeSessionCubit(
        transport,
        RealtimeRepository(database),
        reconnectDelay: (_) => reconnectGate.future,
      );
      addTearDown(cubit.close);

      await cubit.connect(_reconnectingConfig);
      final reconnecting = _waitForState(
        cubit,
        (state) => state.status == RealtimeConnectionStatus.reconnecting,
      );
      transport.controllers.first.addError(const SocketException('offline'));
      await reconnecting;
      expect(transport.closeCounts, <int>[1]);

      final replacement = transport.waitForConnections(2);
      reconnectGate.complete();
      await replacement;
      expect(transport.connections, 2);
      expect(cubit.state.metrics.reconnectAttempts, 1);

      await cubit.cancel();
      expect(transport.closeCounts, <int>[1, 1]);
    },
  );

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

      final secondConnection = transport
          .waitForConnections(2)
          .timeout(const Duration(seconds: 2));
      final reconnectedState = _waitForState(
        cubit,
        (state) =>
            state.status == RealtimeConnectionStatus.connected &&
            state.metrics.reconnectAttempts == 1,
      ).timeout(const Duration(seconds: 2));
      transport.controllers.first.addError(const SocketException('offline'));
      await secondConnection;
      await reconnectedState;
      expect(transport.connections, 2);
      expect(cubit.state.status, RealtimeConnectionStatus.connected);
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
      final settledState = cubit.stream
          .firstWhere(
            (state) =>
                state.messages.length == 2 &&
                state.messages.last.content == 'chunk-4' &&
                state.droppedMessages == 3,
          )
          .timeout(const Duration(seconds: 2));
      for (var index = 0; index < 5; index++) {
        transport.controllers.single.add(
          TransportMessage(
            type: RealtimePayloadType.chunk,
            content: 'chunk-$index',
          ),
        );
      }
      await settledState;
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
