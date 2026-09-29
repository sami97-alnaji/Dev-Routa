import 'dart:typed_data';

import 'grpc_codec_models.dart';
import 'grpc_streaming_models.dart';

class GrpcDynamicUnaryResult {
  const GrpcDynamicUnaryResult({
    required this.rawBytes,
    required this.payload,
    required this.headers,
    required this.trailers,
  });

  final Uint8List rawBytes;
  final Object? payload;
  final Map<String, String> headers;
  final Map<String, String> trailers;
}

class GrpcDynamicStreamEvent {
  const GrpcDynamicStreamEvent({
    required this.raw,
    this.payload,
    this.decodeFailure,
  });

  final GrpcStreamEvent raw;
  final Object? payload;
  final GrpcCodecException? decodeFailure;
}

class GrpcDynamicStreamingResult {
  const GrpcDynamicStreamingResult({
    required this.rawBytes,
    required this.payload,
    required this.headers,
    required this.trailers,
  });

  final Uint8List rawBytes;
  final Object? payload;
  final Map<String, String> headers;
  final Map<String, String> trailers;
}
