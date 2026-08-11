enum GrpcCodecFailureCategory {
  validation,
  malformedWire,
  limitExceeded,
  unsupportedType,
}

class GrpcCodecException implements Exception {
  const GrpcCodecException({
    required this.category,
    required this.path,
    required this.message,
    this.expectedType,
  });

  final GrpcCodecFailureCategory category;
  final String path;
  final String message;
  final String? expectedType;

  @override
  String toString() =>
      'gRPC codec ${category.name} at $path: $message'
      '${expectedType == null ? '' : ' (expected $expectedType)'}';
}
