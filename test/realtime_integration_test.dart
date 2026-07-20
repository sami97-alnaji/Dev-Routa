import 'dart:convert';
import 'dart:io';

import 'package:devroute_ai_studio/features/realtime/data/realtime_transport.dart';
import 'package:devroute_ai_studio/features/realtime/domain/realtime_models.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:devroute_ai_studio/shared/services/service_interfaces.dart';
import 'package:flutter_test/flutter_test.dart';

class _Secrets implements SecureStorageService {
  final Map<String, String> values = <String, String>{};
  @override
  Future<void> deleteSecret(String key) async => values.remove(key);
  @override
  Future<String?> readSecret(String key) async => values[key];
  @override
  Future<void> writeSecret(String key, String value) async =>
      values[key] = value;
}

void main() {
  test(
    'local WebSocket server echoes text and binary deterministically',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        socket.listen((message) async {
          socket.add(message);
          await socket.close(1000, 'test complete');
        });
      });
      final connection = await RealtimeTransport().connect(
        RealtimeSessionConfig(
          id: 'ws',
          protocol: RealtimeProtocolType.webSocket,
          url: 'ws://${server.address.host}:${server.port}/echo',
        ),
        RealtimeValueResolver(null),
      );
      final first = connection.messages.first;
      await connection.send!('hello');
      expect((await first).content, 'hello');
      await connection.close();
    },
  );

  test(
    'local SSE preserves multiline, retry, comments and split UTF-8',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      String? receivedLastEventId;
      server.listen((request) async {
        receivedLastEventId = request.headers.value('Last-Event-ID');
        request.response.headers.contentType = ContentType(
          'text',
          'event-stream',
        );
        final bytes = utf8.encode(
          ': heartbeat\nevent: update\nid: 7\nretry: 25\ndata: مرحبا\ndata: second\n\n',
        );
        final split = bytes.indexOf(0xd8) + 1;
        request.response.add(bytes.sublist(0, split));
        await request.response.flush();
        request.response.add(bytes.sublist(split));
        await request.response.close();
      });
      final connection = await RealtimeTransport().connect(
        RealtimeSessionConfig(
          id: 'sse',
          protocol: RealtimeProtocolType.sse,
          url: 'http://${server.address.host}:${server.port}/events',
          lastEventId: 'previous-event',
        ),
        RealtimeValueResolver(null),
      );
      final messages = await connection.messages.toList();
      final event = messages.firstWhere(
        (item) => item.type == RealtimePayloadType.event,
      );
      expect(event.content, 'مرحبا\nsecond');
      expect(event.eventName, 'update');
      expect(event.eventId, '7');
      expect(event.retry, 25);
      expect(
        messages.any((item) => item.content.contains('heartbeat')),
        isTrue,
      );
      expect(receivedLastEventId, 'previous-event');
    },
  );

  test('abnormal WebSocket close is surfaced as a stream failure', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      await socket.close(1011, 'server failure');
    });
    final connection = await RealtimeTransport().connect(
      RealtimeSessionConfig(
        id: 'ws-failure',
        protocol: RealtimeProtocolType.webSocket,
        url: 'ws://${server.address.host}:${server.port}/failure',
      ),
      RealtimeValueResolver(null),
    );
    await expectLater(
      connection.messages.toList(),
      throwsA(isA<WebSocketException>()),
    );
  });

  test(
    'local HTTP NDJSON stream preserves split UTF-8 and malformed lines',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        final bytes = utf8.encode(
          '{"text":"مرحبا"}\nnot-json\n{"done":true}\n',
        );
        final split = bytes.indexOf(0xd8) + 1;
        request.response.add(bytes.sublist(0, split));
        await request.response.flush();
        request.response.add(bytes.sublist(split));
        await request.response.close();
      });
      final connection = await RealtimeTransport().connect(
        RealtimeSessionConfig(
          id: 'stream',
          protocol: RealtimeProtocolType.httpStream,
          streamMode: HttpStreamMode.ndjson,
          url: 'http://${server.address.host}:${server.port}/stream',
        ),
        RealtimeValueResolver(null),
      );
      final messages = await connection.messages.toList();
      expect(messages.first.content, contains('مرحبا'));
      expect(
        messages.where((item) => item.type == RealtimePayloadType.ndjson),
        hasLength(2),
      );
      expect(
        messages.where((item) => item.type == RealtimePayloadType.diagnostic),
        hasLength(1),
      );
    },
  );

  test('runtime secret resolution redacts reflected realtime values', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      request.response.write('token=${request.headers.value('x-token')}');
      await request.response.close();
    });
    final secrets = _Secrets()..values['token-ref'] = 'runtime-secret';
    final connection = await RealtimeTransport().connect(
      RealtimeSessionConfig(
        id: 'secret-stream',
        protocol: RealtimeProtocolType.httpStream,
        url: 'http://${server.address.host}:${server.port}/stream',
        headers: const <RequestHeaderModel>[
          RequestHeaderModel(
            key: 'x-token',
            value: '',
            isSecret: true,
            secretRef: 'token-ref',
          ),
        ],
      ),
      RealtimeValueResolver(secrets),
    );
    final messages = await connection.messages.toList();
    expect(messages.single.content, contains('[REDACTED]'));
    expect(messages.single.content, isNot(contains('runtime-secret')));
  });
}
