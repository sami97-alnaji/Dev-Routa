import 'dart:async';
import 'dart:io';

import 'package:devroute_ai_studio/features/grpc/application/grpc_dynamic_invocation_service.dart';
import 'package:devroute_ai_studio/features/grpc/application/grpc_dynamic_message_codec.dart';
import 'package:devroute_ai_studio/features/grpc/data/grpc_descriptor_loader.dart';
import 'package:devroute_ai_studio/features/grpc/data/grpc_streaming_transport.dart';
import 'package:devroute_ai_studio/features/grpc/data/grpc_unary_transport.dart';
import 'package:devroute_ai_studio/features/grpc/domain/grpc_descriptor_models.dart';
import 'package:devroute_ai_studio/features/grpc/domain/grpc_streaming_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

import 'fixtures/grpc/generated/phase5_test_service.pbgrpc.dart';

void main() {
  late Server server;
  late _StreamingFixtureService service;
  late GrpcStreamingTransport transport;
  late GrpcUnaryTransport unaryTransport;
  late GrpcDynamicInvocationService dynamicService;

  setUp(() async {
    service = _StreamingFixtureService();
    server = Server.create(services: <Service>[service]);
    await server.serve(
      address: InternetAddress.loopbackIPv4,
      port: 0,
      security: ServerLocalCredentials(),
    );
    transport = GrpcStreamingTransport.connect(
      host: InternetAddress.loopbackIPv4.address,
      port: server.port!,
      allowPlaintext: true,
    );
    unaryTransport = GrpcUnaryTransport.connect(
      host: InternetAddress.loopbackIPv4.address,
      port: server.port!,
      allowPlaintext: true,
    );
    final registry = const GrpcDescriptorLoader()
        .load(
          File(
            'test/fixtures/grpc/generated/phase5_test_service.protoset',
          ).readAsBytesSync(),
        )
        .registry;
    dynamicService = GrpcDynamicInvocationService(
      codec: GrpcDynamicMessageCodec(registry),
      unaryTransport: unaryTransport,
      streamingTransport: transport,
    );
  });

  tearDown(() async {
    await transport.shutdown();
    await unaryTransport.shutdown();
    await server.shutdown();
  });

  test(
    'server stream preserves order, headers, trailers and completion',
    () async {
      final session = transport.startServerStreaming(
        method: _watchMethod,
        requestBytes: EchoRequest(
          message: 'watch',
          samples: <int>[3],
        ).writeToBuffer(),
        metadata: const <String, String>{'x-request-id': 'stream-1'},
      );

      await session.result;
      final received = session.timeline
          .where(
            (event) => event.direction == GrpcStreamEventDirection.received,
          )
          .map((event) => EchoResponse.fromBuffer(event.bytes!).message)
          .toList();
      expect(received, <String>['watch:0', 'watch:1', 'watch:2']);
      expect(
        session.timeline
            .where((event) => event.category == GrpcStreamEventCategory.headers)
            .single
            .metadata?['x-request-id'],
        'stream-1',
      );
      expect(
        session.timeline
            .where(
              (event) => event.category == GrpcStreamEventCategory.trailers,
            )
            .single
            .metadata?['x-finished'],
        'true',
      );
      expect(session.state, GrpcStreamingSessionState.serverCompleted);
    },
  );

  test(
    'server stream preserves partial messages before a typed failure',
    () async {
      final session = transport.startServerStreaming(
        method: _watchMethod,
        requestBytes: EchoRequest(message: 'partial-error').writeToBuffer(),
      );

      await expectLater(
        session.result,
        throwsA(
          isA<GrpcStreamingException>().having(
            (error) => error.statusCode,
            'status',
            StatusCode.aborted,
          ),
        ),
      );
      expect(
        session.timeline
            .where(
              (event) => event.direction == GrpcStreamEventDirection.received,
            )
            .length,
        1,
      );
    },
  );

  test(
    'server stream maps deadline and cancellation without late events',
    () async {
      final deadline = transport.startServerStreaming(
        method: _watchMethod,
        requestBytes: EchoRequest(message: 'blocked').writeToBuffer(),
        deadline: const Duration(milliseconds: 40),
      );
      await expectLater(
        deadline.result,
        throwsA(
          isA<GrpcStreamingException>().having(
            (error) => error.statusCode,
            'status',
            StatusCode.deadlineExceeded,
          ),
        ),
      );

      final cancelled = transport.startServerStreaming(
        method: _watchMethod,
        requestBytes: EchoRequest(message: 'blocked').writeToBuffer(),
      );
      await service.blockedStarted.future;
      await cancelled.cancel();
      await expectLater(
        cancelled.result,
        throwsA(isA<GrpcStreamingException>()),
      );
      final count = cancelled.timeline.length;
      service.releaseBlocked();
      await Future<void>.delayed(Duration.zero);
      expect(cancelled.timeline.length, count);
    },
  );

  test(
    'client stream aggregates, half-closes and rejects stale sends',
    () async {
      final session = transport.startClientStreaming(method: _collectMethod);
      session.send(
        EchoRequest(message: 'a', samples: <int>[1]).writeToBuffer(),
      );
      session.send(
        EchoRequest(message: 'b', samples: <int>[2]).writeToBuffer(),
      );
      await session.completeClientStream();
      await session.completeClientStream();

      final result = await session.result;
      expect(EchoResponse.fromBuffer(result.message).message, 'a,b:3');
      expect(
        () => session.send(EchoRequest(message: 'late').writeToBuffer()),
        throwsStateError,
      );
    },
  );

  test(
    'client stream supports empty input, cancellation and queue bounds',
    () async {
      final empty = transport.startClientStreaming(method: _collectMethod);
      await empty.completeClientStream();
      expect(
        EchoResponse.fromBuffer((await empty.result).message).message,
        ':0',
      );

      final bounded = transport.startClientStreaming(
        method: _collectMethod,
        maximumQueuedOutboundMessages: 1,
      );
      bounded.send(EchoRequest(message: 'first').writeToBuffer());
      expect(
        () => bounded.send(EchoRequest(message: 'overflow').writeToBuffer()),
        throwsStateError,
      );
      await bounded.cancel();
      await expectLater(bounded.result, throwsA(isA<GrpcStreamingException>()));
    },
  );

  test(
    'bidirectional stream interleaves and receives after half-close',
    () async {
      final session = transport.startBidirectionalStreaming(
        method: _chatMethod,
      );
      session.send(EchoRequest(message: 'one').writeToBuffer());
      session.send(EchoRequest(message: 'two').writeToBuffer());
      await session.completeClientStream();
      await session.result;

      expect(
        session.timeline
            .where(
              (event) => event.direction == GrpcStreamEventDirection.received,
            )
            .map((event) => EchoResponse.fromBuffer(event.bytes!).message)
            .toList(),
        <String>['echo:one', 'echo:two', 'after-half-close'],
      );
    },
  );

  test(
    'bidirectional server failure and server-first completion are terminal',
    () async {
      final failed = transport.startBidirectionalStreaming(method: _chatMethod);
      failed.send(EchoRequest(message: 'fail').writeToBuffer());
      await expectLater(
        failed.result,
        throwsA(
          isA<GrpcStreamingException>().having(
            (error) => error.statusCode,
            'status',
            StatusCode.dataLoss,
          ),
        ),
      );
      expect(
        () => failed.send(EchoRequest(message: 'late').writeToBuffer()),
        throwsStateError,
      );

      final serverFirst = transport.startBidirectionalStreaming(
        method: _chatMethod,
      );
      serverFirst.send(EchoRequest(message: 'server-complete').writeToBuffer());
      await serverFirst.result;
      expect(serverFirst.state, GrpcStreamingSessionState.serverCompleted);
    },
  );

  test('timeline applies event and byte bounds with a dropped count', () async {
    final session = transport.startServerStreaming(
      method: _watchMethod,
      requestBytes: EchoRequest(
        message: 'bounded',
        samples: <int>[10],
      ).writeToBuffer(),
      maximumRetainedEvents: 4,
      maximumRetainedBytes: 30,
    );
    await session.result;

    expect(session.timeline.length, lessThanOrEqualTo(4));
    expect(
      session.timeline.fold<int>(
        0,
        (total, event) => total + event.retainedBytes,
      ),
      lessThanOrEqualTo(30),
    );
    expect(session.droppedEventCount, greaterThan(0));
    expect(session.timeline.last.category, GrpcStreamEventCategory.status);
  });

  test(
    'runtime secrets are masked in streaming metadata and failures',
    () async {
      const secret = 'stream-runtime-secret';
      final metadata = transport.startServerStreaming(
        method: _watchMethod,
        requestBytes: EchoRequest(message: 'secret').writeToBuffer(),
        runtimeSecrets: const <String>[secret],
      );
      await metadata.result;
      expect(metadata.timeline.toString(), isNot(contains(secret)));
      expect(
        metadata.timeline
            .where((event) => event.category == GrpcStreamEventCategory.headers)
            .single
            .metadata?['x-reflected'],
        '[REDACTED]',
      );

      final failure = transport.startServerStreaming(
        method: _watchMethod,
        requestBytes: EchoRequest(message: 'secret-error').writeToBuffer(),
        runtimeSecrets: const <String>[secret],
      );
      await expectLater(
        failure.result,
        throwsA(
          isA<GrpcStreamingException>().having(
            (error) => error.toString(),
            'safe',
            isNot(contains(secret)),
          ),
        ),
      );
    },
  );

  test('concurrent sessions stay isolated and shutdown closes all', () async {
    final first = transport.startServerStreaming(
      method: _watchMethod,
      requestBytes: EchoRequest(
        message: 'first',
        samples: <int>[2],
      ).writeToBuffer(),
    );
    final second = transport.startServerStreaming(
      method: _watchMethod,
      requestBytes: EchoRequest(
        message: 'second',
        samples: <int>[3],
      ).writeToBuffer(),
    );
    await Future.wait(<Future<GrpcStreamingResult>>[
      first.result,
      second.result,
    ]);
    expect(first.sessionId, isNot(second.sessionId));
    expect(
      first.timeline
          .where(
            (event) => event.direction == GrpcStreamEventDirection.received,
          )
          .length,
      2,
    );
    expect(
      second.timeline
          .where(
            (event) => event.direction == GrpcStreamEventDirection.received,
          )
          .length,
      3,
    );
    await transport.shutdown();
    expect(
      () => transport.startServerStreaming(
        method: _watchMethod,
        requestBytes: EchoRequest().writeToBuffer(),
      ),
      throwsStateError,
    );
  });

  test('rejects descriptors for the wrong streaming mode', () {
    expect(
      () => transport.startServerStreaming(
        method: _collectMethod,
        requestBytes: EchoRequest().writeToBuffer(),
      ),
      throwsArgumentError,
    );
    expect(
      () => transport.startClientStreaming(method: _chatMethod),
      throwsArgumentError,
    );
    expect(
      () => transport.startBidirectionalStreaming(method: _watchMethod),
      throwsArgumentError,
    );
  });

  test(
    'dynamic unary and every stream mode use descriptor codec bytes',
    () async {
      final unary = await dynamicService.invokeUnary(
        method: _echoMethod,
        input: <String, Object?>{
          'message': 'dynamic',
          'samples': <int>[2, 4],
        },
      );
      expect(unary.payload, <String, Object?>{'message': 'dynamic'});

      final serverSession = dynamicService.startServerStreaming(
        method: _watchMethod,
        input: <String, Object?>{
          'message': 'dynamic-watch',
          'samples': <int>[2],
        },
      );
      final serverEvents = <Object?>[];
      final serverSubscription = serverSession.events.listen((event) {
        if (event.payload != null &&
            event.raw.direction == GrpcStreamEventDirection.received) {
          serverEvents.add(event.payload);
        }
      });
      await serverSession.result;
      await serverSubscription.cancel();
      expect(serverEvents, <Object?>[
        <String, Object?>{'message': 'dynamic-watch:0'},
        <String, Object?>{'message': 'dynamic-watch:1'},
      ]);

      final clientSession = dynamicService.startClientStreaming(
        method: _collectMethod,
      );
      clientSession.send(<String, Object?>{
        'message': 'one',
        'samples': <int>[1],
      });
      clientSession.send(<String, Object?>{
        'message': 'two',
        'samples': <int>[2],
      });
      await clientSession.completeClientStream();
      expect((await clientSession.result).payload, <String, Object?>{
        'message': 'one,two:3',
      });

      final bidiSession = dynamicService.startBidirectionalStreaming(
        method: _chatMethod,
      );
      final bidiEvents = <Object?>[];
      final bidiSubscription = bidiSession.events.listen((event) {
        if (event.payload != null &&
            event.raw.direction == GrpcStreamEventDirection.received) {
          bidiEvents.add(event.payload);
        }
      });
      bidiSession.send(<String, Object?>{'message': 'hello'});
      await bidiSession.completeClientStream();
      await bidiSession.result;
      await bidiSubscription.cancel();
      expect(bidiEvents, <Object?>[
        <String, Object?>{'message': 'echo:hello'},
        <String, Object?>{'message': 'after-half-close'},
      ]);
    },
  );

  test('dynamic decoded payload masks exact runtime secrets', () async {
    const secret = 'stream-runtime-secret';
    final session = dynamicService.startServerStreaming(
      method: _watchMethod,
      input: <String, Object?>{'message': 'decoded-secret'},
      runtimeSecrets: const <String>[secret],
    );
    final payloads = <Object?>[];
    final subscription = session.events.listen((event) {
      if (event.payload != null) payloads.add(event.payload);
    });
    await session.result;
    await subscription.cancel();
    expect(payloads.toString(), isNot(contains(secret)));
    expect(payloads, <Object?>[
      <String, Object?>{'message': '[REDACTED]'},
    ]);
  });
}

const _echoMethod = GrpcMethodDescriptor(
  name: 'Echo',
  serviceFullName: 'devroute.phase5.test.Phase5TestService',
  inputType: '.devroute.phase5.test.EchoRequest',
  outputType: '.devroute.phase5.test.EchoResponse',
  streamingKind: GrpcStreamingKind.unary,
);
const _watchMethod = GrpcMethodDescriptor(
  name: 'Watch',
  serviceFullName: 'devroute.phase5.test.Phase5TestService',
  inputType: '.devroute.phase5.test.EchoRequest',
  outputType: '.devroute.phase5.test.EchoResponse',
  streamingKind: GrpcStreamingKind.serverStreaming,
);
const _collectMethod = GrpcMethodDescriptor(
  name: 'Collect',
  serviceFullName: 'devroute.phase5.test.Phase5TestService',
  inputType: '.devroute.phase5.test.EchoRequest',
  outputType: '.devroute.phase5.test.EchoResponse',
  streamingKind: GrpcStreamingKind.clientStreaming,
);
const _chatMethod = GrpcMethodDescriptor(
  name: 'Chat',
  serviceFullName: 'devroute.phase5.test.Phase5TestService',
  inputType: '.devroute.phase5.test.EchoRequest',
  outputType: '.devroute.phase5.test.EchoResponse',
  streamingKind: GrpcStreamingKind.bidirectionalStreaming,
);

class _StreamingFixtureService extends Phase5TestServiceBase {
  Completer<void> blockedStarted = Completer<void>();
  Completer<void> _blockedRelease = Completer<void>();

  void releaseBlocked() {
    if (!_blockedRelease.isCompleted) _blockedRelease.complete();
    blockedStarted = Completer<void>();
    _blockedRelease = Completer<void>();
  }

  @override
  Future<EchoResponse> echo(ServiceCall call, EchoRequest request) async =>
      EchoResponse(message: request.message);

  @override
  Stream<EchoResponse> watch(ServiceCall call, EchoRequest request) async* {
    if (request.message == 'blocked') {
      if (!blockedStarted.isCompleted) blockedStarted.complete();
      await _blockedRelease.future;
      yield EchoResponse(message: 'released');
      return;
    }
    if (request.message == 'partial-error') {
      yield EchoResponse(message: 'partial');
      throw GrpcError.aborted('partial failure');
    }
    if (request.message == 'secret-error') {
      throw GrpcError.permissionDenied('denied stream-runtime-secret');
    }
    if (request.message == 'secret') {
      call.headers!['x-reflected'] = 'stream-runtime-secret';
      call.trailers!['x-reflected'] = 'stream-runtime-secret';
    } else {
      call.headers!['x-request-id'] =
          call.clientMetadata?['x-request-id'] ?? '';
      call.trailers!['x-finished'] = 'true';
    }
    if (request.message == 'decoded-secret') {
      yield EchoResponse(message: 'stream-runtime-secret');
      return;
    }
    final count = request.samples.isEmpty ? 1 : request.samples.first;
    for (var index = 0; index < count; index++) {
      yield EchoResponse(message: '${request.message}:$index');
    }
  }

  @override
  Future<EchoResponse> collect(
    ServiceCall call,
    Stream<EchoRequest> request,
  ) async {
    final names = <String>[];
    var total = 0;
    await for (final item in request) {
      names.add(item.message);
      total += item.samples.fold<int>(0, (sum, value) => sum + value);
    }
    return EchoResponse(message: '${names.join(',')}:$total');
  }

  @override
  Stream<EchoResponse> chat(
    ServiceCall call,
    Stream<EchoRequest> request,
  ) async* {
    await for (final item in request) {
      if (item.message == 'fail') {
        throw GrpcError.dataLoss('chat failed');
      }
      if (item.message == 'server-complete') return;
      yield EchoResponse(message: 'echo:${item.message}');
    }
    yield EchoResponse(message: 'after-half-close');
  }
}
