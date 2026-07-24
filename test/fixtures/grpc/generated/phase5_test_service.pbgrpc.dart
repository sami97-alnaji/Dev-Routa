// This is a generated file - do not edit.
//
// Generated from phase5_test_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'phase5_test_service.pb.dart' as $0;

export 'phase5_test_service.pb.dart';

@$pb.GrpcServiceName('devroute.phase5.test.Phase5TestService')
class Phase5TestServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  Phase5TestServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.EchoResponse> echo(
    $0.EchoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$echo, request, options: options);
  }

  // method descriptors

  static final _$echo = $grpc.ClientMethod<$0.EchoRequest, $0.EchoResponse>(
      '/devroute.phase5.test.Phase5TestService/Echo',
      ($0.EchoRequest value) => value.writeToBuffer(),
      $0.EchoResponse.fromBuffer);
}

@$pb.GrpcServiceName('devroute.phase5.test.Phase5TestService')
abstract class Phase5TestServiceBase extends $grpc.Service {
  $core.String get $name => 'devroute.phase5.test.Phase5TestService';

  Phase5TestServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EchoRequest, $0.EchoResponse>(
        'Echo',
        echo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EchoRequest.fromBuffer(value),
        ($0.EchoResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.EchoResponse> echo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.EchoRequest> $request) async {
    return echo($call, await $request);
  }

  $async.Future<$0.EchoResponse> echo(
      $grpc.ServiceCall call, $0.EchoRequest request);
}
