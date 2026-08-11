import 'dart:typed_data';

class GrpcUnaryResponse {
  const GrpcUnaryResponse({
    required this.message,
    required this.headers,
    required this.trailers,
  });

  final Uint8List message;
  final Map<String, String> headers;
  final Map<String, String> trailers;
}

class GrpcUnaryException implements Exception {
  const GrpcUnaryException({
    required this.statusCode,
    required this.statusName,
    required this.message,
    required this.trailers,
  });

  final int statusCode;
  final String statusName;
  final String message;
  final Map<String, String> trailers;

  @override
  String toString() => 'gRPC $statusName ($statusCode): $message';
}
