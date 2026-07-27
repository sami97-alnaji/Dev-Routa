import 'dart:convert';
import 'dart:typed_data';

import 'package:devroute_ai_studio/features/grpc/application/grpc_proto_import_policy.dart';
import 'package:devroute_ai_studio/features/grpc/application/grpc_dynamic_message_validator.dart';
import 'package:devroute_ai_studio/features/grpc/data/generated/google/protobuf/descriptor.pb.dart'
    as descriptor;
import 'package:devroute_ai_studio/features/grpc/data/generated/google/protobuf/descriptor.pbenum.dart'
    as descriptor_enum;
import 'package:devroute_ai_studio/features/grpc/data/grpc_descriptor_loader.dart';
import 'package:devroute_ai_studio/features/grpc/domain/grpc_descriptor_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and indexes an included FileDescriptorSet deterministically', () {
    final set = descriptor.FileDescriptorSet(
      file: <descriptor.FileDescriptorProto>[
        descriptor.FileDescriptorProto(
          name: 'devroute/echo.proto',
          package: 'devroute.echo',
          messageType: <descriptor.DescriptorProto>[
            descriptor.DescriptorProto(
              name: 'EchoRequest',
              field: <descriptor.FieldDescriptorProto>[
                descriptor.FieldDescriptorProto(
                  name: 'message',
                  jsonName: 'message',
                  number: 1,
                  type: descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
                ),
                descriptor.FieldDescriptorProto(
                  name: 'samples',
                  jsonName: 'samples',
                  number: 2,
                  type: descriptor_enum.FieldDescriptorProto_Type.TYPE_INT32,
                  label:
                      descriptor_enum.FieldDescriptorProto_Label.LABEL_REPEATED,
                ),
              ],
            ),
            descriptor.DescriptorProto(name: 'EchoResponse'),
          ],
          service: <descriptor.ServiceDescriptorProto>[
            descriptor.ServiceDescriptorProto(
              name: 'EchoService',
              method: <descriptor.MethodDescriptorProto>[
                descriptor.MethodDescriptorProto(
                  name: 'Echo',
                  inputType: '.devroute.echo.EchoRequest',
                  outputType: '.devroute.echo.EchoResponse',
                ),
                descriptor.MethodDescriptorProto(
                  name: 'Upload',
                  inputType: '.devroute.echo.EchoRequest',
                  outputType: '.devroute.echo.EchoResponse',
                  clientStreaming: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final snapshot = const GrpcDescriptorLoader().load(
      Uint8List.fromList(set.writeToBuffer()),
    );

    expect(snapshot.sha256, hasLength(64));
    expect(snapshot.registry.files.single.name, 'devroute/echo.proto');
    expect(
      snapshot.registry.message('devroute.echo.EchoRequest')?.fields,
      hasLength(2),
    );
    final service = snapshot.registry.service('devroute.echo.EchoService');
    expect(service?.methods.first.path, '/devroute.echo.EchoService/Echo');
    expect(
      service?.methods.last.streamingKind,
      GrpcStreamingKind.clientStreaming,
    );
  });

  test('rejects malformed descriptor bytes and duplicate descriptor names', () {
    expect(
      () => const GrpcDescriptorLoader().load(Uint8List.fromList(<int>[255])),
      throwsA(isA<GrpcDescriptorException>()),
    );
    final duplicate = descriptor.FileDescriptorSet(
      file: <descriptor.FileDescriptorProto>[
        descriptor.FileDescriptorProto(name: 'same.proto'),
        descriptor.FileDescriptorProto(name: 'same.proto'),
      ],
    );
    expect(
      () => const GrpcDescriptorLoader().load(
        Uint8List.fromList(duplicate.writeToBuffer()),
      ),
      throwsA(isA<GrpcDescriptorException>()),
    );
  });

  test('rejects missing dependencies and produces a stable fingerprint', () {
    final valid = _foundationSet();
    final bytes = Uint8List.fromList(valid.writeToBuffer());
    expect(
      const GrpcDescriptorLoader().load(bytes).sha256,
      const GrpcDescriptorLoader().load(bytes).sha256,
    );
    final missing = descriptor.FileDescriptorSet(
      file: <descriptor.FileDescriptorProto>[
        descriptor.FileDescriptorProto(
          name: 'root.proto',
          dependency: <String>['missing.proto'],
        ),
      ],
    );
    expect(
      () => const GrpcDescriptorLoader().load(
        Uint8List.fromList(missing.writeToBuffer()),
      ),
      throwsA(isA<GrpcDescriptorException>()),
    );
  });

  test('classifies unary and every streaming method deterministically', () {
    final service = const GrpcDescriptorLoader()
        .load(Uint8List.fromList(_foundationSet().writeToBuffer()))
        .registry
        .service('test.Echo')!;
    expect(
      service.methods.map((method) => method.streamingKind),
      <GrpcStreamingKind>[
        GrpcStreamingKind.unary,
        GrpcStreamingKind.serverStreaming,
        GrpcStreamingKind.clientStreaming,
        GrpcStreamingKind.bidirectionalStreaming,
      ],
    );
  });

  test(
    'import policy rejects traversal, schemes and roots outside selection',
    () {
      const policy = GrpcProtoImportPolicy();
      expect(
        policy.resolveRootSource(
          sourcePath: r'C:\selected\api.proto',
          sourceRoot: r'C:\selected',
        ),
        r'C:\selected\api.proto',
      );
      expect(
        policy.resolveImport(
          importPath: 'common/types.proto',
          allowedRoots: <String>[r'C:\selected', r'C:\includes'],
        ),
        r'C:\selected\common\types.proto',
      );
      for (final value in <String>[
        '../secret.proto',
        r'..\secret.proto',
        'file:///secret.proto',
        'https://example.test/secret.proto',
        r'C:\secret.proto',
        r'C:drive-relative.proto',
        r'\\server\share\secret.proto',
        'common/types.json',
        'null\u0000.proto',
      ]) {
        expect(
          () => policy.resolveImport(
            importPath: value,
            allowedRoots: <String>[r'C:\selected'],
          ),
          throwsA(isA<GrpcDescriptorException>()),
        );
      }
      expect(
        policy.resolveImport(
          importPath: r'common\nested\types.proto',
          allowedRoots: <String>[r'C:\selected'],
        ),
        r'C:\selected\common\nested\types.proto',
      );
    },
  );

  test('enforces descriptor byte, file, symbol, and duplicate limits', () {
    final valid = _foundationSet();
    final bytes = Uint8List.fromList(valid.writeToBuffer());
    expect(
      () => const GrpcDescriptorLoader(maximumBytes: 1).load(bytes),
      throwsA(isA<GrpcDescriptorException>()),
    );
    expect(
      () => const GrpcDescriptorLoader(maximumFiles: 1).load(bytes),
      throwsA(isA<GrpcDescriptorException>()),
    );
    expect(
      () => const GrpcDescriptorLoader(maximumSymbols: 1).load(bytes),
      throwsA(isA<GrpcDescriptorException>()),
    );

    final duplicateSymbols = descriptor.FileDescriptorSet(
      file: <descriptor.FileDescriptorProto>[
        descriptor.FileDescriptorProto(
          name: 'first.proto',
          package: 'duplicate',
          messageType: <descriptor.DescriptorProto>[
            descriptor.DescriptorProto(name: 'Message'),
          ],
        ),
        descriptor.FileDescriptorProto(
          name: 'second.proto',
          package: 'duplicate',
          messageType: <descriptor.DescriptorProto>[
            descriptor.DescriptorProto(name: 'Message'),
          ],
        ),
      ],
    );
    expect(
      () => const GrpcDescriptorLoader().load(
        Uint8List.fromList(duplicateSymbols.writeToBuffer()),
      ),
      throwsA(isA<GrpcDescriptorException>()),
    );
  });

  test(
    'dynamic validation rejects unknown and mistyped values with a field path',
    () {
      final set = descriptor.FileDescriptorSet(
        file: <descriptor.FileDescriptorProto>[
          descriptor.FileDescriptorProto(
            name: 'request.proto',
            package: 'devroute.echo',
            messageType: <descriptor.DescriptorProto>[
              descriptor.DescriptorProto(
                name: 'Request',
                field: <descriptor.FieldDescriptorProto>[
                  descriptor.FieldDescriptorProto(
                    name: 'display_name',
                    jsonName: 'displayName',
                    number: 1,
                    type: descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
                  ),
                  descriptor.FieldDescriptorProto(
                    name: 'samples',
                    number: 2,
                    type: descriptor_enum.FieldDescriptorProto_Type.TYPE_INT32,
                    label: descriptor_enum
                        .FieldDescriptorProto_Label
                        .LABEL_REPEATED,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final registry = const GrpcDescriptorLoader()
          .load(Uint8List.fromList(set.writeToBuffer()))
          .registry;
      final validator = GrpcDynamicMessageValidator(registry);
      expect(
        validator.validate('devroute.echo.Request', <String, Object?>{
          'displayName': 'hello',
          'samples': <int>[1, 2],
        }),
        <String, Object?>{
          'displayName': 'hello',
          'samples': <int>[1, 2],
        },
      );
      expect(
        () => validator.validate('devroute.echo.Request', <String, Object?>{
          'samples': <Object?>[1, 'wrong'],
        }),
        throwsA(
          isA<GrpcDynamicValidationException>().having(
            (error) => error.path,
            'path',
            r'request.samples[1]',
          ),
        ),
      );
      expect(
        () => validator.validate('devroute.echo.Request', <String, Object?>{
          'unknown': true,
        }),
        throwsA(isA<GrpcDynamicValidationException>()),
      );
    },
  );

  test(
    'validates nested, map, enum, oneof and numeric boundaries immutably',
    () {
      final registry = const GrpcDescriptorLoader()
          .load(Uint8List.fromList(_foundationSet().writeToBuffer()))
          .registry;
      final validator = GrpcDynamicMessageValidator(registry);
      final input = <String, Object?>{
        'customer': <String, Object?>{
          'address': <String, Object?>{'zipCode': '11000'},
        },
        'items': <Object?>[
          <String, Object?>{'price': 12},
        ],
        'labels': <String, Object?>{'region': 'eu'},
        'mode': 'MODE_ACTIVE',
        'quantity': 4294967295,
        'first': 'only-one',
      };
      final original = jsonEncode(input);
      expect(validator.validate('test.Request', input), isNotEmpty);
      expect(jsonEncode(input), original);
      expect(
        () => validator.validate('test.Request', <String, Object?>{
          'customer': <String, Object?>{
            'address': <String, Object?>{'zipCode': 4},
          },
        }),
        throwsA(
          isA<GrpcDynamicValidationException>().having(
            (error) => error.path,
            'path',
            'request.customer.address.zipCode',
          ),
        ),
      );
      expect(
        () => validator.validate('test.Request', <String, Object?>{
          'items': <Object?>[
            <String, Object?>{'price': 1},
            <String, Object?>{'price': 'wrong'},
          ],
        }),
        throwsA(
          isA<GrpcDynamicValidationException>().having(
            (error) => error.path,
            'path',
            'request.items[1].price',
          ),
        ),
      );
      for (final invalid in <Map<String, Object?>>[
        <String, Object?>{'mode': 'UNKNOWN'},
        <String, Object?>{'quantity': -1},
        <String, Object?>{'first': 'a', 'second': 'b'},
        <String, Object?>{'unknown': true},
      ]) {
        expect(
          () => validator.validate('test.Request', invalid),
          throwsA(isA<GrpcDynamicValidationException>()),
        );
      }
      expect(
        () => validator.validate('test.Legacy', <String, Object?>{}),
        throwsA(isA<GrpcDynamicValidationException>()),
      );
    },
  );
}

descriptor.FileDescriptorSet _foundationSet() {
  descriptor.FieldDescriptorProto field(
    String name,
    int number,
    descriptor_enum.FieldDescriptorProto_Type kind, {
    String typeName = '',
    descriptor_enum.FieldDescriptorProto_Label cardinality =
        descriptor_enum.FieldDescriptorProto_Label.LABEL_OPTIONAL,
    int? oneofIndex,
    String? jsonName,
  }) => descriptor.FieldDescriptorProto(
    name: name,
    number: number,
    type: kind,
    typeName: typeName,
    label: cardinality,
    oneofIndex: oneofIndex,
    jsonName: jsonName,
  );
  return descriptor.FileDescriptorSet(
    file: <descriptor.FileDescriptorProto>[
      descriptor.FileDescriptorProto(
        name: 'foundation.proto',
        package: 'test',
        enumType: <descriptor.EnumDescriptorProto>[
          descriptor.EnumDescriptorProto(
            name: 'Mode',
            value: <descriptor.EnumValueDescriptorProto>[
              descriptor.EnumValueDescriptorProto(
                name: 'MODE_UNKNOWN',
                number: 0,
              ),
              descriptor.EnumValueDescriptorProto(
                name: 'MODE_ACTIVE',
                number: 1,
              ),
            ],
          ),
        ],
        messageType: <descriptor.DescriptorProto>[
          descriptor.DescriptorProto(
            name: 'Address',
            field: <descriptor.FieldDescriptorProto>[
              field(
                'zip_code',
                1,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
                jsonName: 'zipCode',
              ),
            ],
          ),
          descriptor.DescriptorProto(
            name: 'Customer',
            field: <descriptor.FieldDescriptorProto>[
              field(
                'address',
                1,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_MESSAGE,
                typeName: '.test.Address',
              ),
            ],
          ),
          descriptor.DescriptorProto(
            name: 'Item',
            field: <descriptor.FieldDescriptorProto>[
              field(
                'price',
                1,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_INT32,
              ),
            ],
          ),
          descriptor.DescriptorProto(
            name: 'LabelsEntry',
            options: descriptor.MessageOptions(mapEntry: true),
            field: <descriptor.FieldDescriptorProto>[
              field(
                'key',
                1,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
              ),
              field(
                'value',
                2,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
              ),
            ],
          ),
          descriptor.DescriptorProto(
            name: 'Request',
            oneofDecl: <descriptor.OneofDescriptorProto>[
              descriptor.OneofDescriptorProto(name: 'selection'),
            ],
            field: <descriptor.FieldDescriptorProto>[
              field(
                'customer',
                1,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_MESSAGE,
                typeName: '.test.Customer',
              ),
              field(
                'items',
                2,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_MESSAGE,
                typeName: '.test.Item',
                cardinality:
                    descriptor_enum.FieldDescriptorProto_Label.LABEL_REPEATED,
              ),
              field(
                'labels',
                3,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_MESSAGE,
                typeName: '.test.LabelsEntry',
                cardinality:
                    descriptor_enum.FieldDescriptorProto_Label.LABEL_REPEATED,
              ),
              field(
                'mode',
                4,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_ENUM,
                typeName: '.test.Mode',
              ),
              field(
                'quantity',
                5,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_UINT32,
              ),
              field(
                'first',
                6,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
                oneofIndex: 0,
              ),
              field(
                'second',
                7,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
                oneofIndex: 0,
              ),
            ],
          ),
          descriptor.DescriptorProto(name: 'Response'),
        ],
        service: <descriptor.ServiceDescriptorProto>[
          descriptor.ServiceDescriptorProto(
            name: 'Echo',
            method: <descriptor.MethodDescriptorProto>[
              descriptor.MethodDescriptorProto(
                name: 'Unary',
                inputType: '.test.Request',
                outputType: '.test.Response',
              ),
              descriptor.MethodDescriptorProto(
                name: 'Server',
                inputType: '.test.Request',
                outputType: '.test.Response',
                serverStreaming: true,
              ),
              descriptor.MethodDescriptorProto(
                name: 'Client',
                inputType: '.test.Request',
                outputType: '.test.Response',
                clientStreaming: true,
              ),
              descriptor.MethodDescriptorProto(
                name: 'Bidi',
                inputType: '.test.Request',
                outputType: '.test.Response',
                clientStreaming: true,
                serverStreaming: true,
              ),
            ],
          ),
        ],
      ),
      descriptor.FileDescriptorProto(
        name: 'legacy.proto',
        package: 'test',
        syntax: 'proto2',
        messageType: <descriptor.DescriptorProto>[
          descriptor.DescriptorProto(
            name: 'Legacy',
            field: <descriptor.FieldDescriptorProto>[
              field(
                'required_name',
                1,
                descriptor_enum.FieldDescriptorProto_Type.TYPE_STRING,
                cardinality:
                    descriptor_enum.FieldDescriptorProto_Label.LABEL_REQUIRED,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
