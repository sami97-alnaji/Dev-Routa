enum GrpcStreamingKind {
  unary,
  serverStreaming,
  clientStreaming,
  bidirectionalStreaming,
}

class GrpcDescriptorException implements Exception {
  const GrpcDescriptorException(this.message, {this.path});

  final String message;
  final String? path;

  @override
  String toString() =>
      'gRPC descriptor${path == null ? '' : ' at $path'}: $message';
}

class GrpcDescriptorSnapshot {
  const GrpcDescriptorSnapshot({required this.sha256, required this.registry});

  final String sha256;
  final GrpcDescriptorRegistry registry;
}

class GrpcDescriptorRegistry {
  const GrpcDescriptorRegistry({
    required this.files,
    required this.services,
    required this.messages,
    required this.enums,
  });

  final List<GrpcDescriptorFile> files;
  final Map<String, GrpcServiceDescriptor> services;
  final Map<String, GrpcMessageDescriptor> messages;
  final Map<String, GrpcEnumDescriptor> enums;

  GrpcServiceDescriptor? service(String fullName) => services[fullName];
  GrpcMessageDescriptor? message(String fullName) => messages[fullName];
  GrpcEnumDescriptor? enumType(String fullName) => enums[fullName];
}

class GrpcDescriptorFile {
  const GrpcDescriptorFile({
    required this.name,
    required this.packageName,
    required this.imports,
  });

  final String name;
  final String packageName;
  final List<String> imports;
}

class GrpcServiceDescriptor {
  const GrpcServiceDescriptor({
    required this.fullName,
    required this.fileName,
    required this.methods,
  });

  final String fullName;
  final String fileName;
  final List<GrpcMethodDescriptor> methods;
}

class GrpcMethodDescriptor {
  const GrpcMethodDescriptor({
    required this.name,
    required this.serviceFullName,
    required this.inputType,
    required this.outputType,
    required this.streamingKind,
  });

  final String name;
  final String serviceFullName;
  final String inputType;
  final String outputType;
  final GrpcStreamingKind streamingKind;

  String get path => '/$serviceFullName/$name';
}

class GrpcMessageDescriptor {
  const GrpcMessageDescriptor({
    required this.fullName,
    required this.fields,
    required this.oneofs,
    this.isMapEntry = false,
    this.isProto2 = false,
  });

  final String fullName;
  final List<GrpcFieldDescriptor> fields;
  final List<GrpcOneofDescriptor> oneofs;
  final bool isMapEntry;
  final bool isProto2;
}

class GrpcOneofDescriptor {
  const GrpcOneofDescriptor({required this.name, required this.fieldNames});

  final String name;
  final List<String> fieldNames;
}

class GrpcFieldDescriptor {
  const GrpcFieldDescriptor({
    required this.name,
    required this.jsonName,
    required this.number,
    required this.type,
    required this.typeName,
    required this.repeated,
    required this.required,
    this.oneofIndex,
  });

  final String name;
  final String jsonName;
  final int number;
  final String type;
  final String typeName;
  final bool repeated;
  final bool required;
  final int? oneofIndex;
}

class GrpcEnumDescriptor {
  const GrpcEnumDescriptor({required this.fullName, required this.values});

  final String fullName;
  final Map<String, int> values;
}
