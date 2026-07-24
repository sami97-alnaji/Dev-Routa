import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../domain/grpc_descriptor_models.dart';
import 'generated/google/protobuf/descriptor.pb.dart' as descriptor;
import 'generated/google/protobuf/descriptor.pbenum.dart' as descriptor_enum;

/// Loads compiler-produced descriptors with bounded, deterministic indexes.
class GrpcDescriptorLoader {
  const GrpcDescriptorLoader({
    this.maximumBytes = 4 * 1024 * 1024,
    this.maximumFiles = 256,
    this.maximumSymbols = 10000,
  });

  final int maximumBytes;
  final int maximumFiles;
  final int maximumSymbols;

  GrpcDescriptorSnapshot load(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maximumBytes) {
      throw const GrpcDescriptorException(
        'Descriptor set exceeds the allowed size.',
      );
    }
    final descriptor.FileDescriptorSet set;
    try {
      set = descriptor.FileDescriptorSet.fromBuffer(bytes);
    } on Object {
      throw const GrpcDescriptorException('Invalid FileDescriptorSet.');
    }
    if (set.file.isEmpty || set.file.length > maximumFiles) {
      throw const GrpcDescriptorException(
        'Invalid number of descriptor files.',
      );
    }
    final files = <GrpcDescriptorFile>[];
    final services = <String, GrpcServiceDescriptor>{};
    final messages = <String, GrpcMessageDescriptor>{};
    final enums = <String, GrpcEnumDescriptor>{};
    final fileNames = <String>{};
    final symbols = <String>{};
    var symbolCount = 0;
    void claim(String value, String kind) {
      if (value.isEmpty || !symbols.add(value)) {
        throw GrpcDescriptorException(
          'Duplicate or missing $kind symbol.',
          path: value,
        );
      }
      if (++symbolCount > maximumSymbols) {
        throw const GrpcDescriptorException(
          'Descriptor set exceeds the symbol limit.',
        );
      }
    }

    for (final file in set.file) {
      if (file.name.isEmpty || !fileNames.add(file.name)) {
        throw GrpcDescriptorException(
          'Duplicate or missing descriptor file.',
          path: file.name,
        );
      }
      files.add(
        GrpcDescriptorFile(
          name: file.name,
          packageName: file.package,
          imports: List<String>.unmodifiable(file.dependency),
        ),
      );
      final prefix = _prefix(file.package);
      _collectMessages(
        file.messageType,
        prefix,
        file.syntax == 'proto2',
        messages,
        enums,
        claim,
      );
      _collectEnums(file.enumType, prefix, enums, claim);
      for (final service in file.service) {
        final serviceName = _prefix(prefix, service.name);
        claim(serviceName, 'service');
        final methodNames = <String>{};
        final methods = service.method
            .map((method) {
              if (method.name.isEmpty ||
                  method.inputType.isEmpty ||
                  method.outputType.isEmpty ||
                  !methodNames.add(method.name)) {
                throw GrpcDescriptorException(
                  'Invalid or duplicate method.',
                  path: '$serviceName/${method.name}',
                );
              }
              return GrpcMethodDescriptor(
                name: method.name,
                serviceFullName: serviceName,
                inputType: method.inputType,
                outputType: method.outputType,
                streamingKind: _streamingKind(method),
              );
            })
            .toList(growable: false);
        services[serviceName] = GrpcServiceDescriptor(
          fullName: serviceName,
          fileName: file.name,
          methods: methods,
        );
      }
    }
    for (final file in files) {
      for (final dependency in file.imports) {
        if (!fileNames.contains(dependency)) {
          throw GrpcDescriptorException(
            'Descriptor dependency is missing.',
            path: '${file.name}:$dependency',
          );
        }
      }
    }
    for (final service in services.values) {
      for (final method in service.methods) {
        _requireMessage(messages, method.inputType, method.path);
        _requireMessage(messages, method.outputType, method.path);
      }
    }
    for (final message in messages.values) {
      for (final field in message.fields) {
        if (field.type == 'TYPE_MESSAGE') {
          _requireMessage(
            messages,
            field.typeName,
            '${message.fullName}.${field.name}',
          );
        }
        if (field.type == 'TYPE_ENUM' &&
            !enums.containsKey(_normalizeType(field.typeName))) {
          throw GrpcDescriptorException(
            'Field enum type is missing.',
            path: '${message.fullName}.${field.name}',
          );
        }
      }
    }
    return GrpcDescriptorSnapshot(
      sha256: sha256.convert(bytes).toString(),
      registry: GrpcDescriptorRegistry(
        files: List<GrpcDescriptorFile>.unmodifiable(files),
        services: Map<String, GrpcServiceDescriptor>.unmodifiable(services),
        messages: Map<String, GrpcMessageDescriptor>.unmodifiable(messages),
        enums: Map<String, GrpcEnumDescriptor>.unmodifiable(enums),
      ),
    );
  }

  void _collectMessages(
    Iterable<descriptor.DescriptorProto> source,
    String prefix,
    bool isProto2,
    Map<String, GrpcMessageDescriptor> messages,
    Map<String, GrpcEnumDescriptor> enums,
    void Function(String, String) claim,
  ) {
    for (final message in source) {
      final fullName = _prefix(prefix, message.name);
      claim(fullName, 'message');
      final oneofs = message.oneofDecl
          .map(
            (item) => GrpcOneofDescriptor(
              name: item.name,
              fieldNames: const <String>[],
            ),
          )
          .toList(growable: false);
      final oneofFields = List<List<String>>.generate(
        oneofs.length,
        (_) => <String>[],
      );
      final fields = <GrpcFieldDescriptor>[];
      final fieldNames = <String>{};
      final fieldNumbers = <int>{};
      for (final field in message.field) {
        if (field.name.isEmpty ||
            field.number <= 0 ||
            !fieldNames.add(field.name) ||
            !fieldNumbers.add(field.number)) {
          throw GrpcDescriptorException(
            'Invalid or duplicate field.',
            path: '$fullName.${field.name}',
          );
        }
        final oneofIndex = field.hasOneofIndex() ? field.oneofIndex : null;
        if (oneofIndex != null &&
            (oneofIndex < 0 || oneofIndex >= oneofFields.length)) {
          throw GrpcDescriptorException(
            'Field references a missing oneof.',
            path: '$fullName.${field.name}',
          );
        }
        if (oneofIndex != null) {
          oneofFields[oneofIndex].add(field.name);
        }
        fields.add(_field(field, oneofIndex));
      }
      messages[fullName] = GrpcMessageDescriptor(
        fullName: fullName,
        isMapEntry: message.hasOptions() && message.options.mapEntry,
        isProto2: isProto2,
        fields: List<GrpcFieldDescriptor>.unmodifiable(fields),
        oneofs: List<GrpcOneofDescriptor>.unmodifiable(
          List<GrpcOneofDescriptor>.generate(
            oneofs.length,
            (index) => GrpcOneofDescriptor(
              name: oneofs[index].name,
              fieldNames: List<String>.unmodifiable(oneofFields[index]),
            ),
          ),
        ),
      );
      _collectMessages(
        message.nestedType,
        fullName,
        isProto2,
        messages,
        enums,
        claim,
      );
      _collectEnums(message.enumType, fullName, enums, claim);
    }
  }

  void _collectEnums(
    Iterable<descriptor.EnumDescriptorProto> source,
    String prefix,
    Map<String, GrpcEnumDescriptor> enums,
    void Function(String, String) claim,
  ) {
    for (final item in source) {
      final fullName = _prefix(prefix, item.name);
      claim(fullName, 'enum');
      final values = <String, int>{};
      for (final value in item.value) {
        if (value.name.isEmpty || values.containsKey(value.name)) {
          throw GrpcDescriptorException(
            'Invalid or duplicate enum value.',
            path: '$fullName.${value.name}',
          );
        }
        values[value.name] = value.number;
      }
      enums[fullName] = GrpcEnumDescriptor(
        fullName: fullName,
        values: Map<String, int>.unmodifiable(values),
      );
    }
  }

  GrpcFieldDescriptor _field(
    descriptor.FieldDescriptorProto field,
    int? oneofIndex,
  ) => GrpcFieldDescriptor(
    name: field.name,
    jsonName: field.jsonName.isEmpty ? field.name : field.jsonName,
    number: field.number,
    type: field.type.name,
    typeName: field.typeName,
    repeated:
        field.label ==
        descriptor_enum.FieldDescriptorProto_Label.LABEL_REPEATED,
    required:
        field.label ==
        descriptor_enum.FieldDescriptorProto_Label.LABEL_REQUIRED,
    oneofIndex: oneofIndex,
  );

  void _requireMessage(
    Map<String, GrpcMessageDescriptor> messages,
    String type,
    String owner,
  ) {
    if (!messages.containsKey(_normalizeType(type))) {
      throw GrpcDescriptorException('Message type is missing.', path: owner);
    }
  }

  GrpcStreamingKind _streamingKind(descriptor.MethodDescriptorProto method) =>
      switch ((method.clientStreaming, method.serverStreaming)) {
        (false, false) => GrpcStreamingKind.unary,
        (false, true) => GrpcStreamingKind.serverStreaming,
        (true, false) => GrpcStreamingKind.clientStreaming,
        (true, true) => GrpcStreamingKind.bidirectionalStreaming,
      };

  String _normalizeType(String type) =>
      type.startsWith('.') ? type.substring(1) : type;
  String _prefix(String first, [String? second]) => <String>[
    first,
    if (second case final String value) value,
  ].where((item) => item.isNotEmpty).join('.');
}
