import 'dart:typed_data';

enum GrpcStreamingSessionState {
  connecting,
  active,
  clientHalfClosed,
  serverCompleted,
  cancelling,
  cancelled,
  failed,
  closed,
}

enum GrpcStreamEventDirection { sent, received, system }

enum GrpcStreamEventCategory { message, headers, trailers, status, diagnostic }

class GrpcStreamEvent {
  const GrpcStreamEvent({
    required this.sequence,
    required this.direction,
    required this.category,
    required this.timestamp,
    this.bytes,
    this.metadata,
    this.statusCode,
    this.safeMessage,
  });

  final int sequence;
  final GrpcStreamEventDirection direction;
  final GrpcStreamEventCategory category;
  final DateTime timestamp;
  final Uint8List? bytes;
  final Map<String, String>? metadata;
  final int? statusCode;
  final String? safeMessage;

  int get retainedBytes => bytes?.length ?? 0;
}

class GrpcStreamingResult {
  const GrpcStreamingResult({
    required this.message,
    required this.headers,
    required this.trailers,
  });

  final Uint8List message;
  final Map<String, String> headers;
  final Map<String, String> trailers;
}

class GrpcStreamingException implements Exception {
  const GrpcStreamingException({
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
  String toString() => 'gRPC stream $statusName ($statusCode): $message';
}
