import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:devroute_ai_studio/features/grpc/data/grpc_unary_transport.dart';
import 'package:devroute_ai_studio/features/grpc/domain/grpc_descriptor_models.dart';
import 'package:devroute_ai_studio/features/grpc/domain/grpc_unary_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

import 'fixtures/grpc/generated/phase5_test_service.pbgrpc.dart';

void main() {
  late Server server;
  late _LoopbackService service;
  late GrpcUnaryTransport transport;

  setUp(() async {
    service = _LoopbackService();
    server = Server.create(services: <Service>[service]);
    await server.serve(
      address: InternetAddress.loopbackIPv4,
      port: 0,
      security: ServerLocalCredentials(),
    );
    transport = GrpcUnaryTransport.forChannel(
      ClientChannel(
        InternetAddress.loopbackIPv4.address,
        port: server.port!,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      ),
    );
  });

  tearDown(() async {
    await transport.shutdown();
    await server.shutdown();
  });

  test(
    'executes a generated unary fixture over native loopback gRPC',
    () async {
      final request = EchoRequest(message: 'hello', samples: <int>[2, 3]);
      final requestBytes = Uint8List.fromList(request.writeToBuffer());
      final originalBytes = Uint8List.fromList(requestBytes);

      final result = await transport
          .invoke(method: _echoMethod, request: requestBytes)
          .response;

      expect(EchoResponse.fromBuffer(result.message).message, 'hello:5');
      expect(requestBytes, originalBytes);
    },
  );

  test('preserves server status and safely redacts status trailers', () async {
    final call = transport.invoke(
      method: _echoMethod,
      request: EchoRequest(message: 'status').writeToBuffer(),
    );

    await expectLater(
      call.response,
      throwsA(
        isA<GrpcUnaryException>()
            .having((error) => error.statusCode, 'statusCode', 7)
            .having(
              (error) => error.statusName,
              'statusName',
              'PERMISSION_DENIED',
            )
            .having(
              (error) => error.trailers['authorization'],
              'safe trailer',
              '[REDACTED]',
            ),
      ),
    );
  });

  test('maps a native deadline to DEADLINE_EXCEEDED', () async {
    final call = transport.invoke(
      method: _echoMethod,
      request: EchoRequest(message: 'wait').writeToBuffer(),
      deadline: const Duration(milliseconds: 40),
    );

    await expectLater(
      call.response,
      throwsA(
        isA<GrpcUnaryException>().having(
          (error) => error.statusCode,
          'statusCode',
          StatusCode.deadlineExceeded,
        ),
      ),
    );
  });

  test('cancels an in-flight unary call', () async {
    final call = transport.invoke(
      method: _echoMethod,
      request: EchoRequest(message: 'wait').writeToBuffer(),
    );
    await service.started.future;

    await call.cancel();

    await expectLater(
      call.response,
      throwsA(
        isA<GrpcUnaryException>().having(
          (error) => error.statusCode,
          'statusCode',
          StatusCode.cancelled,
        ),
      ),
    );
  });

  test('sends metadata but exposes only redacted response metadata', () async {
    final result = await transport
        .invoke(
          method: _echoMethod,
          request: EchoRequest(message: 'metadata').writeToBuffer(),
          metadata: const <String, String>{
            'authorization': 'Bearer client-secret',
            'x-request-id': 'request-7',
          },
        )
        .response;

    expect(service.lastMetadata['authorization'], 'Bearer client-secret');
    expect(service.lastMetadata['x-request-id'], 'request-7');
    expect(result.headers['authorization'], '[REDACTED]');
    expect(result.headers['x-request-id'], 'request-7');
    expect(result.trailers['set-cookie'], '[REDACTED]');
  });

  test(
    'masks reflected runtime secrets in status and metadata values',
    () async {
      const runtimeSecret = 'resolved-runtime-secret';
      final metadataResult = await transport
          .invoke(
            method: _echoMethod,
            request: EchoRequest(message: 'reflected').writeToBuffer(),
            runtimeSecrets: const <String>[runtimeSecret],
          )
          .response;
      expect(metadataResult.headers['x-reflected-value'], '[REDACTED]');
      expect(metadataResult.trailers['x-reflected-value'], '[REDACTED]');

      await expectLater(
        transport
            .invoke(
              method: _echoMethod,
              request: EchoRequest(message: 'reflected-status').writeToBuffer(),
              runtimeSecrets: const <String>[runtimeSecret],
            )
            .response,
        throwsA(
          isA<GrpcUnaryException>().having(
            (error) => error.message,
            'message',
            'denied: [REDACTED]',
          ),
        ),
      );
    },
  );

  test('keeps concurrent unary calls isolated', () async {
    final responses = await Future.wait(
      <String>['first', 'second', 'third'].map(
        (message) => transport
            .invoke(
              method: _echoMethod,
              request: EchoRequest(
                message: message,
                samples: <int>[message.length],
              ).writeToBuffer(),
            )
            .response,
      ),
    );

    expect(
      responses
          .map((item) => EchoResponse.fromBuffer(item.message).message)
          .toList(),
      <String>['first:5', 'second:6', 'third:5'],
    );
  });

  test('validates endpoints and requires explicit plaintext opt-in', () async {
    for (final invalid in <({String host, int port})>[
      (host: '', port: 443),
      (host: 'https://localhost', port: 443),
      (host: 'localhost/path', port: 443),
      (host: 'localhost', port: 0),
      (host: 'localhost', port: 65536),
    ]) {
      expect(
        () =>
            GrpcUnaryTransport.connect(host: invalid.host, port: invalid.port),
        throwsArgumentError,
      );
    }

    final explicitPlaintext = GrpcUnaryTransport.connect(
      host: InternetAddress.loopbackIPv4.address,
      port: server.port!,
      allowPlaintext: true,
    );
    addTearDown(explicitPlaintext.shutdown);
    final result = await explicitPlaintext
        .invoke(
          method: _echoMethod,
          request: EchoRequest(message: 'explicit').writeToBuffer(),
        )
        .response;
    expect(EchoResponse.fromBuffer(result.message).message, 'explicit:0');
  });

  test('shutdown is idempotent and rejects later calls', () async {
    await transport.shutdown();
    await transport.shutdown();
    expect(
      () => transport.invoke(
        method: _echoMethod,
        request: EchoRequest(message: 'late').writeToBuffer(),
      ),
      throwsStateError,
    );
  });

  test('rejects streaming descriptors before opening a call', () {
    expect(
      () => transport.invoke(
        method: _serverStreamingMethod,
        request: Uint8List(0),
      ),
      throwsArgumentError,
    );
  });
}

const _echoMethod = GrpcMethodDescriptor(
  name: 'Echo',
  serviceFullName: 'devroute.phase5.test.Phase5TestService',
  inputType: '.devroute.phase5.test.EchoRequest',
  outputType: '.devroute.phase5.test.EchoResponse',
  streamingKind: GrpcStreamingKind.unary,
);

const _serverStreamingMethod = GrpcMethodDescriptor(
  name: 'Watch',
  serviceFullName: 'devroute.phase5.test.Phase5TestService',
  inputType: '.devroute.phase5.test.EchoRequest',
  outputType: '.devroute.phase5.test.EchoResponse',
  streamingKind: GrpcStreamingKind.serverStreaming,
);

class _LoopbackService extends Phase5TestServiceBase {
  final Completer<void> started = Completer<void>();
  Map<String, String> lastMetadata = const <String, String>{};

  @override
  Future<EchoResponse> echo(ServiceCall call, EchoRequest request) async {
    lastMetadata = Map<String, String>.from(call.clientMetadata ?? const {});
    if (request.message == 'status') {
      throw GrpcError.custom(
        StatusCode.permissionDenied,
        'denied',
        null,
        null,
        const <String, String>{'authorization': 'server-secret'},
      );
    }
    if (request.message == 'wait') {
      if (!started.isCompleted) started.complete();
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    if (request.message == 'metadata') {
      call.headers!.addAll(<String, String>{
        'authorization': 'server-secret',
        'x-request-id': lastMetadata['x-request-id']!,
      });
      call.trailers!['set-cookie'] = 'session-secret';
    }
    if (request.message == 'reflected') {
      call.headers!['x-reflected-value'] = 'resolved-runtime-secret';
      call.trailers!['x-reflected-value'] = 'resolved-runtime-secret';
    }
    if (request.message == 'reflected-status') {
      throw GrpcError.permissionDenied('denied: resolved-runtime-secret');
    }
    final total = request.samples.fold<int>(0, (sum, value) => sum + value);
    return EchoResponse(message: '${request.message}:$total');
  }
}
