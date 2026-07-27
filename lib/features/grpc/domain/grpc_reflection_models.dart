import 'grpc_descriptor_models.dart';

enum GrpcReflectionFailureCategory {
  reflectionDisabled,
  permissionDenied,
  unauthenticated,
  deadlineExceeded,
  cancelled,
  tlsFailure,
  transportFailure,
  malformedDescriptorResponse,
  descriptorConflict,
  limitsExceeded,
}

class GrpcReflectionException implements Exception {
  const GrpcReflectionException({
    required this.category,
    required this.message,
    this.statusCode,
  });

  final GrpcReflectionFailureCategory category;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'gRPC reflection ${category.name}: $message';
}

class GrpcReflectionResult {
  const GrpcReflectionResult({required this.services, required this.snapshot});

  final List<String> services;
  final GrpcDescriptorSnapshot snapshot;
}
