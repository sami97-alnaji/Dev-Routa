import 'dart:async';
import 'dart:io';

import 'package:devroute_ai_studio/features/grpc/application/grpc_reflection_service.dart';
import 'package:devroute_ai_studio/features/grpc/data/generated/google/protobuf/descriptor.pb.dart'
    as descriptor;
import 'package:devroute_ai_studio/features/grpc/data/generated/reflection/grpc/reflection/v1/reflection.pb.dart'
    as reflection;
import 'package:devroute_ai_studio/features/grpc/data/generated/reflection/grpc/reflection/v1/reflection.pbgrpc.dart'
    as reflection_grpc;
import 'package:devroute_ai_studio/features/grpc/domain/grpc_reflection_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  late descriptor.FileDescriptorSet fixtureSet;

  setUpAll(() {
    fixtureSet = descriptor.FileDescriptorSet.fromBuffer(
      File(
        'test/fixtures/grpc/generated/phase5_test_service.protoset',
      ).readAsBytesSync(),
    );
  });

  test(
    'lists services and recursively resolves deterministic descriptors',
    () async {
      final fixture = _ReflectionFixture(fixtureSet);
      final server = await _serve(fixture);
      final service = _connect(server);
      addTearDown(() async {
        await service.shutdown();
        await server.shutdown();
      });

      final first = await service.discover().result;
      expect(first.services, <String>[
        'devroute.phase5.test.Phase5TestService',
      ]);
      final snapshot = first.snapshot;
      expect(
        snapshot.registry.service('devroute.phase5.test.Phase5TestService'),
        isNotNull,
      );
      expect(
        snapshot.registry.files.map((file) => file.name),
        containsAll(<String>[
          'phase5_test_service.proto',
          'google/protobuf/timestamp.proto',
          'google/protobuf/struct.proto',
        ]),
      );
      await service.shutdown();

      final secondService = _connect(server);
      addTearDown(secondService.shutdown);
      final second = await secondService.discover().result;
      expect(second.snapshot.sha256, snapshot.sha256);
      expect(fixture.filenameRequests, isNotEmpty);
    },
  );

  test('reports reflection-disabled as a typed failure', () async {
    final server = await _serve(null);
    final service = _connect(server);
    addTearDown(() async {
      await service.shutdown();
      await server.shutdown();
    });

    await expectLater(
      service.discover().result,
      throwsA(
        isA<GrpcReflectionException>().having(
          (error) => error.category,
          'category',
          GrpcReflectionFailureCategory.reflectionDisabled,
        ),
      ),
    );
  });

  test('maps permission errors and masks reflected runtime secrets', () async {
    const secret = 'reflection-runtime-secret';
    final server = await _serve(
      _ReflectionFixture(
        fixtureSet,
        protocolError: reflection.ErrorResponse(
          errorCode: StatusCode.permissionDenied,
          errorMessage: 'denied $secret',
        ),
      ),
    );
    final service = _connect(server);
    addTearDown(() async {
      await service.shutdown();
      await server.shutdown();
    });

    await expectLater(
      service.discover(runtimeSecrets: const <String>[secret]).result,
      throwsA(
        isA<GrpcReflectionException>()
            .having(
              (error) => error.category,
              'category',
              GrpcReflectionFailureCategory.permissionDenied,
            )
            .having(
              (error) => error.toString(),
              'safe',
              isNot(contains(secret)),
            ),
      ),
    );
  });

  test('maps deadline and explicit cancellation', () async {
    final deadlineFixture = _ReflectionFixture(fixtureSet, block: true);
    final deadlineServer = await _serve(deadlineFixture);
    final deadlineService = _connect(deadlineServer);
    addTearDown(() async {
      await deadlineService.shutdown();
      await deadlineServer.shutdown();
    });
    await expectLater(
      deadlineService
          .discover(deadline: const Duration(milliseconds: 40))
          .result,
      throwsA(
        isA<GrpcReflectionException>().having(
          (error) => error.category,
          'deadline',
          GrpcReflectionFailureCategory.deadlineExceeded,
        ),
      ),
    );
    deadlineFixture.release();
    await deadlineService.shutdown();
    await deadlineServer.shutdown();

    final cancellationFixture = _ReflectionFixture(fixtureSet, block: true);
    final cancellationServer = await _serve(cancellationFixture);
    final cancellationService = _connect(cancellationServer);
    addTearDown(() async {
      await cancellationService.shutdown();
      await cancellationServer.shutdown();
    });
    final operation = cancellationService.discover();
    await cancellationFixture.started.future;
    final cancellationExpectation = expectLater(
      operation.result,
      throwsA(
        isA<GrpcReflectionException>().having(
          (error) => error.category,
          'cancelled',
          GrpcReflectionFailureCategory.cancelled,
        ),
      ),
    );
    await operation.cancel();
    cancellationFixture.release();
    await cancellationExpectation;
  });

  test(
    'rejects conflicting descriptor filenames and response limits',
    () async {
      final conflictServer = await _serve(
        _ReflectionFixture(fixtureSet, conflict: true),
      );
      final conflictService = _connect(conflictServer);
      addTearDown(() async {
        await conflictService.shutdown();
        await conflictServer.shutdown();
      });
      await expectLater(
        conflictService.discover().result,
        throwsA(
          isA<GrpcReflectionException>().having(
            (error) => error.category,
            'conflict',
            GrpcReflectionFailureCategory.descriptorConflict,
          ),
        ),
      );

      final limitServer = await _serve(_ReflectionFixture(fixtureSet));
      final limitService = _connect(limitServer);
      addTearDown(() async {
        await limitService.shutdown();
        await limitServer.shutdown();
      });
      await expectLater(
        limitService.discover(maximumDescriptorBytes: 1).result,
        throwsA(
          isA<GrpcReflectionException>().having(
            (error) => error.category,
            'limit',
            GrpcReflectionFailureCategory.limitsExceeded,
          ),
        ),
      );
    },
  );

  test('operation cleanup allows a later explicit discovery', () async {
    final server = await _serve(_ReflectionFixture(fixtureSet));
    final service = _connect(server);
    addTearDown(() async {
      await service.shutdown();
      await server.shutdown();
    });
    await service.discover().result;
    await service.discover().result;
  });
}

Future<Server> _serve(Service? service) async {
  final server = Server.create(
    services: service == null ? const <Service>[] : <Service>[service],
  );
  await server.serve(
    address: InternetAddress.loopbackIPv4,
    port: 0,
    security: ServerLocalCredentials(),
  );
  return server;
}

GrpcReflectionService _connect(Server server) => GrpcReflectionService.connect(
  host: InternetAddress.loopbackIPv4.address,
  port: server.port!,
  allowPlaintext: true,
);

class _ReflectionFixture extends reflection_grpc.ServerReflectionServiceBase {
  _ReflectionFixture(
    descriptor.FileDescriptorSet set, {
    this.protocolError,
    this.block = false,
    this.conflict = false,
  }) : _files = <String, descriptor.FileDescriptorProto>{
         for (final file in set.file) file.name: file,
       };

  final Map<String, descriptor.FileDescriptorProto> _files;
  final reflection.ErrorResponse? protocolError;
  final bool block;
  final bool conflict;
  final List<String> filenameRequests = <String>[];
  final Completer<void> started = Completer<void>();
  final Completer<void> _release = Completer<void>();

  void release() {
    if (!_release.isCompleted) _release.complete();
  }

  @override
  Stream<reflection.ServerReflectionResponse> serverReflectionInfo(
    ServiceCall call,
    Stream<reflection.ServerReflectionRequest> request,
  ) async* {
    await for (final item in request) {
      if (!started.isCompleted) started.complete();
      if (block) {
        await _release.future;
        if (call.isCanceled) return;
      }
      if (protocolError != null) {
        yield reflection.ServerReflectionResponse(
          originalRequest: item,
          errorResponse: protocolError,
        );
        continue;
      }
      if (item.hasListServices()) {
        yield reflection.ServerReflectionResponse(
          originalRequest: item,
          listServicesResponse: reflection.ListServiceResponse(
            service: <reflection.ServiceResponse>[
              reflection.ServiceResponse(
                name: 'grpc.reflection.v1.ServerReflection',
              ),
              reflection.ServiceResponse(
                name: 'devroute.phase5.test.Phase5TestService',
              ),
            ],
          ),
        );
        continue;
      }
      if (item.hasFileContainingSymbol()) {
        final main = _files['phase5_test_service.proto']!;
        final payloads = <List<int>>[main.writeToBuffer()];
        if (conflict) {
          payloads.add(
            (main.deepCopy()..package = 'conflicting.package').writeToBuffer(),
          );
        }
        yield reflection.ServerReflectionResponse(
          originalRequest: item,
          fileDescriptorResponse: reflection.FileDescriptorResponse(
            fileDescriptorProto: payloads,
          ),
        );
        continue;
      }
      if (item.hasFileByFilename()) {
        filenameRequests.add(item.fileByFilename);
        final file = _files[item.fileByFilename];
        if (file == null) {
          yield reflection.ServerReflectionResponse(
            originalRequest: item,
            errorResponse: reflection.ErrorResponse(
              errorCode: StatusCode.notFound,
              errorMessage: 'missing descriptor',
            ),
          );
        } else {
          yield reflection.ServerReflectionResponse(
            originalRequest: item,
            fileDescriptorResponse: reflection.FileDescriptorResponse(
              fileDescriptorProto: <List<int>>[file.writeToBuffer()],
            ),
          );
        }
      }
    }
  }
}
