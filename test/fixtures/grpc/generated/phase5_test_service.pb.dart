// This is a generated file - do not edit.
//
// Generated from phase5_test_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $7;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $2;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $3;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart'
    as $5;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $4;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart'
    as $6;

import 'phase5_test_service.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'phase5_test_service.pbenum.dart';

class EchoRequest extends $pb.GeneratedMessage {
  factory EchoRequest({
    $core.String? message,
    $core.Iterable<$core.int>? samples,
  }) {
    final result = create();
    if (message != null) result.message = message;
    if (samples != null) result.samples.addAll(samples);
    return result;
  }

  EchoRequest._();

  factory EchoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EchoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EchoRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'devroute.phase5.test'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'samples', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EchoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EchoRequest copyWith(void Function(EchoRequest) updates) =>
      super.copyWith((message) => updates(message as EchoRequest))
          as EchoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EchoRequest create() => EchoRequest._();
  @$core.override
  EchoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EchoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EchoRequest>(create);
  static EchoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get samples => $_getList(1);
}

class EchoResponse extends $pb.GeneratedMessage {
  factory EchoResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  EchoResponse._();

  factory EchoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EchoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EchoResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'devroute.phase5.test'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EchoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EchoResponse copyWith(void Function(EchoResponse) updates) =>
      super.copyWith((message) => updates(message as EchoResponse))
          as EchoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EchoResponse create() => EchoResponse._();
  @$core.override
  EchoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EchoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EchoResponse>(create);
  static EchoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class NestedValue extends $pb.GeneratedMessage {
  factory NestedValue({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  NestedValue._();

  factory NestedValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NestedValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NestedValue',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'devroute.phase5.test'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NestedValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NestedValue copyWith(void Function(NestedValue) updates) =>
      super.copyWith((message) => updates(message as NestedValue))
          as NestedValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NestedValue create() => NestedValue._();
  @$core.override
  NestedValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NestedValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NestedValue>(create);
  static NestedValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

enum CodecMessage_Selection { first, second, notSet }

class CodecMessage extends $pb.GeneratedMessage {
  factory CodecMessage({
    $core.double? doubleValue,
    $core.double? floatValue,
    $core.int? int32Value,
    $fixnum.Int64? int64Value,
    $core.int? uint32Value,
    $fixnum.Int64? uint64Value,
    $core.int? sint32Value,
    $fixnum.Int64? sint64Value,
    $core.int? fixed32Value,
    $fixnum.Int64? fixed64Value,
    $core.int? sfixed32Value,
    $fixnum.Int64? sfixed64Value,
    $core.bool? boolValue,
    $core.String? stringValue,
    $core.List<$core.int>? bytesValue,
    TestMode? mode,
    NestedValue? nested,
    $core.Iterable<$core.int>? packedValues,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? labels,
    $core.String? first,
    $core.int? second,
    $core.Iterable<$core.String>? reflectedValues,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? reflectedLabels,
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? numericLabels,
    $core.Iterable<$core.MapEntry<$core.bool, $core.String>>? booleanLabels,
  }) {
    final result = create();
    if (doubleValue != null) result.doubleValue = doubleValue;
    if (floatValue != null) result.floatValue = floatValue;
    if (int32Value != null) result.int32Value = int32Value;
    if (int64Value != null) result.int64Value = int64Value;
    if (uint32Value != null) result.uint32Value = uint32Value;
    if (uint64Value != null) result.uint64Value = uint64Value;
    if (sint32Value != null) result.sint32Value = sint32Value;
    if (sint64Value != null) result.sint64Value = sint64Value;
    if (fixed32Value != null) result.fixed32Value = fixed32Value;
    if (fixed64Value != null) result.fixed64Value = fixed64Value;
    if (sfixed32Value != null) result.sfixed32Value = sfixed32Value;
    if (sfixed64Value != null) result.sfixed64Value = sfixed64Value;
    if (boolValue != null) result.boolValue = boolValue;
    if (stringValue != null) result.stringValue = stringValue;
    if (bytesValue != null) result.bytesValue = bytesValue;
    if (mode != null) result.mode = mode;
    if (nested != null) result.nested = nested;
    if (packedValues != null) result.packedValues.addAll(packedValues);
    if (labels != null) result.labels.addEntries(labels);
    if (first != null) result.first = first;
    if (second != null) result.second = second;
    if (reflectedValues != null) result.reflectedValues.addAll(reflectedValues);
    if (reflectedLabels != null)
      result.reflectedLabels.addEntries(reflectedLabels);
    if (numericLabels != null) result.numericLabels.addEntries(numericLabels);
    if (booleanLabels != null) result.booleanLabels.addEntries(booleanLabels);
    return result;
  }

  CodecMessage._();

  factory CodecMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CodecMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CodecMessage_Selection>
      _CodecMessage_SelectionByTag = {
    20: CodecMessage_Selection.first,
    21: CodecMessage_Selection.second,
    0: CodecMessage_Selection.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CodecMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'devroute.phase5.test'),
      createEmptyInstance: create)
    ..oo(0, [20, 21])
    ..aD(1, _omitFieldNames ? '' : 'doubleValue')
    ..aD(2, _omitFieldNames ? '' : 'floatValue', fieldType: $pb.PbFieldType.OF)
    ..aI(3, _omitFieldNames ? '' : 'int32Value')
    ..aInt64(4, _omitFieldNames ? '' : 'int64Value')
    ..aI(5, _omitFieldNames ? '' : 'uint32Value',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'uint64Value', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(7, _omitFieldNames ? '' : 'sint32Value',
        fieldType: $pb.PbFieldType.OS3)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'sint64Value', $pb.PbFieldType.OS6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(9, _omitFieldNames ? '' : 'fixed32Value',
        fieldType: $pb.PbFieldType.OF3)
    ..a<$fixnum.Int64>(
        10, _omitFieldNames ? '' : 'fixed64Value', $pb.PbFieldType.OF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(11, _omitFieldNames ? '' : 'sfixed32Value',
        fieldType: $pb.PbFieldType.OSF3)
    ..a<$fixnum.Int64>(
        12, _omitFieldNames ? '' : 'sfixed64Value', $pb.PbFieldType.OSF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(13, _omitFieldNames ? '' : 'boolValue')
    ..aOS(14, _omitFieldNames ? '' : 'stringValue')
    ..a<$core.List<$core.int>>(
        15, _omitFieldNames ? '' : 'bytesValue', $pb.PbFieldType.OY)
    ..aE<TestMode>(16, _omitFieldNames ? '' : 'mode',
        enumValues: TestMode.values)
    ..aOM<NestedValue>(17, _omitFieldNames ? '' : 'nested',
        subBuilder: NestedValue.create)
    ..p<$core.int>(
        18, _omitFieldNames ? '' : 'packedValues', $pb.PbFieldType.K3)
    ..m<$core.String, $core.int>(19, _omitFieldNames ? '' : 'labels',
        entryClassName: 'CodecMessage.LabelsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('devroute.phase5.test'))
    ..aOS(20, _omitFieldNames ? '' : 'first')
    ..aI(21, _omitFieldNames ? '' : 'second')
    ..pPS(22, _omitFieldNames ? '' : 'reflectedValues')
    ..m<$core.String, $core.String>(
        23, _omitFieldNames ? '' : 'reflectedLabels',
        entryClassName: 'CodecMessage.ReflectedLabelsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('devroute.phase5.test'))
    ..m<$core.int, $core.String>(24, _omitFieldNames ? '' : 'numericLabels',
        entryClassName: 'CodecMessage.NumericLabelsEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('devroute.phase5.test'))
    ..m<$core.bool, $core.String>(25, _omitFieldNames ? '' : 'booleanLabels',
        entryClassName: 'CodecMessage.BooleanLabelsEntry',
        keyFieldType: $pb.PbFieldType.OB,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('devroute.phase5.test'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CodecMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CodecMessage copyWith(void Function(CodecMessage) updates) =>
      super.copyWith((message) => updates(message as CodecMessage))
          as CodecMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CodecMessage create() => CodecMessage._();
  @$core.override
  CodecMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CodecMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CodecMessage>(create);
  static CodecMessage? _defaultInstance;

  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  CodecMessage_Selection whichSelection() =>
      _CodecMessage_SelectionByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  void clearSelection() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.double get doubleValue => $_getN(0);
  @$pb.TagNumber(1)
  set doubleValue($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDoubleValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearDoubleValue() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get floatValue => $_getN(1);
  @$pb.TagNumber(2)
  set floatValue($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFloatValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearFloatValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get int32Value => $_getIZ(2);
  @$pb.TagNumber(3)
  set int32Value($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInt32Value() => $_has(2);
  @$pb.TagNumber(3)
  void clearInt32Value() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get int64Value => $_getI64(3);
  @$pb.TagNumber(4)
  set int64Value($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInt64Value() => $_has(3);
  @$pb.TagNumber(4)
  void clearInt64Value() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get uint32Value => $_getIZ(4);
  @$pb.TagNumber(5)
  set uint32Value($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUint32Value() => $_has(4);
  @$pb.TagNumber(5)
  void clearUint32Value() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get uint64Value => $_getI64(5);
  @$pb.TagNumber(6)
  set uint64Value($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUint64Value() => $_has(5);
  @$pb.TagNumber(6)
  void clearUint64Value() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get sint32Value => $_getIZ(6);
  @$pb.TagNumber(7)
  set sint32Value($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSint32Value() => $_has(6);
  @$pb.TagNumber(7)
  void clearSint32Value() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get sint64Value => $_getI64(7);
  @$pb.TagNumber(8)
  set sint64Value($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSint64Value() => $_has(7);
  @$pb.TagNumber(8)
  void clearSint64Value() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get fixed32Value => $_getIZ(8);
  @$pb.TagNumber(9)
  set fixed32Value($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFixed32Value() => $_has(8);
  @$pb.TagNumber(9)
  void clearFixed32Value() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get fixed64Value => $_getI64(9);
  @$pb.TagNumber(10)
  set fixed64Value($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFixed64Value() => $_has(9);
  @$pb.TagNumber(10)
  void clearFixed64Value() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get sfixed32Value => $_getIZ(10);
  @$pb.TagNumber(11)
  set sfixed32Value($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSfixed32Value() => $_has(10);
  @$pb.TagNumber(11)
  void clearSfixed32Value() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get sfixed64Value => $_getI64(11);
  @$pb.TagNumber(12)
  set sfixed64Value($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSfixed64Value() => $_has(11);
  @$pb.TagNumber(12)
  void clearSfixed64Value() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get boolValue => $_getBF(12);
  @$pb.TagNumber(13)
  set boolValue($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasBoolValue() => $_has(12);
  @$pb.TagNumber(13)
  void clearBoolValue() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get stringValue => $_getSZ(13);
  @$pb.TagNumber(14)
  set stringValue($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasStringValue() => $_has(13);
  @$pb.TagNumber(14)
  void clearStringValue() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.List<$core.int> get bytesValue => $_getN(14);
  @$pb.TagNumber(15)
  set bytesValue($core.List<$core.int> value) => $_setBytes(14, value);
  @$pb.TagNumber(15)
  $core.bool hasBytesValue() => $_has(14);
  @$pb.TagNumber(15)
  void clearBytesValue() => $_clearField(15);

  @$pb.TagNumber(16)
  TestMode get mode => $_getN(15);
  @$pb.TagNumber(16)
  set mode(TestMode value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasMode() => $_has(15);
  @$pb.TagNumber(16)
  void clearMode() => $_clearField(16);

  @$pb.TagNumber(17)
  NestedValue get nested => $_getN(16);
  @$pb.TagNumber(17)
  set nested(NestedValue value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasNested() => $_has(16);
  @$pb.TagNumber(17)
  void clearNested() => $_clearField(17);
  @$pb.TagNumber(17)
  NestedValue ensureNested() => $_ensure(16);

  @$pb.TagNumber(18)
  $pb.PbList<$core.int> get packedValues => $_getList(17);

  @$pb.TagNumber(19)
  $pb.PbMap<$core.String, $core.int> get labels => $_getMap(18);

  @$pb.TagNumber(20)
  $core.String get first => $_getSZ(19);
  @$pb.TagNumber(20)
  set first($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasFirst() => $_has(19);
  @$pb.TagNumber(20)
  void clearFirst() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.int get second => $_getIZ(20);
  @$pb.TagNumber(21)
  set second($core.int value) => $_setSignedInt32(20, value);
  @$pb.TagNumber(21)
  $core.bool hasSecond() => $_has(20);
  @$pb.TagNumber(21)
  void clearSecond() => $_clearField(21);

  @$pb.TagNumber(22)
  $pb.PbList<$core.String> get reflectedValues => $_getList(21);

  @$pb.TagNumber(23)
  $pb.PbMap<$core.String, $core.String> get reflectedLabels => $_getMap(22);

  @$pb.TagNumber(24)
  $pb.PbMap<$core.int, $core.String> get numericLabels => $_getMap(23);

  @$pb.TagNumber(25)
  $pb.PbMap<$core.bool, $core.String> get booleanLabels => $_getMap(24);
}

class WellKnownMessage extends $pb.GeneratedMessage {
  factory WellKnownMessage({
    $1.Timestamp? timestamp,
    $2.Duration? duration,
    $3.Empty? empty,
    $4.Struct? structValue,
    $4.Value? value,
    $4.ListValue? listValue,
    $5.FieldMask? fieldMask,
    $6.StringValue? stringWrapper,
    $6.Int64Value? int64Wrapper,
    $6.BoolValue? boolWrapper,
    $7.Any? anyValue,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (duration != null) result.duration = duration;
    if (empty != null) result.empty = empty;
    if (structValue != null) result.structValue = structValue;
    if (value != null) result.value = value;
    if (listValue != null) result.listValue = listValue;
    if (fieldMask != null) result.fieldMask = fieldMask;
    if (stringWrapper != null) result.stringWrapper = stringWrapper;
    if (int64Wrapper != null) result.int64Wrapper = int64Wrapper;
    if (boolWrapper != null) result.boolWrapper = boolWrapper;
    if (anyValue != null) result.anyValue = anyValue;
    return result;
  }

  WellKnownMessage._();

  factory WellKnownMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WellKnownMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WellKnownMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'devroute.phase5.test'),
      createEmptyInstance: create)
    ..aOM<$1.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $1.Timestamp.create)
    ..aOM<$2.Duration>(2, _omitFieldNames ? '' : 'duration',
        subBuilder: $2.Duration.create)
    ..aOM<$3.Empty>(3, _omitFieldNames ? '' : 'empty',
        subBuilder: $3.Empty.create)
    ..aOM<$4.Struct>(4, _omitFieldNames ? '' : 'structValue',
        subBuilder: $4.Struct.create)
    ..aOM<$4.Value>(5, _omitFieldNames ? '' : 'value',
        subBuilder: $4.Value.create)
    ..aOM<$4.ListValue>(6, _omitFieldNames ? '' : 'listValue',
        subBuilder: $4.ListValue.create)
    ..aOM<$5.FieldMask>(7, _omitFieldNames ? '' : 'fieldMask',
        subBuilder: $5.FieldMask.create)
    ..aOM<$6.StringValue>(8, _omitFieldNames ? '' : 'stringWrapper',
        subBuilder: $6.StringValue.create)
    ..aOM<$6.Int64Value>(9, _omitFieldNames ? '' : 'int64Wrapper',
        subBuilder: $6.Int64Value.create)
    ..aOM<$6.BoolValue>(10, _omitFieldNames ? '' : 'boolWrapper',
        subBuilder: $6.BoolValue.create)
    ..aOM<$7.Any>(11, _omitFieldNames ? '' : 'anyValue',
        subBuilder: $7.Any.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WellKnownMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WellKnownMessage copyWith(void Function(WellKnownMessage) updates) =>
      super.copyWith((message) => updates(message as WellKnownMessage))
          as WellKnownMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WellKnownMessage create() => WellKnownMessage._();
  @$core.override
  WellKnownMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WellKnownMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WellKnownMessage>(create);
  static WellKnownMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($1.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $2.Duration get duration => $_getN(1);
  @$pb.TagNumber(2)
  set duration($2.Duration value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Duration ensureDuration() => $_ensure(1);

  @$pb.TagNumber(3)
  $3.Empty get empty => $_getN(2);
  @$pb.TagNumber(3)
  set empty($3.Empty value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEmpty() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmpty() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Empty ensureEmpty() => $_ensure(2);

  @$pb.TagNumber(4)
  $4.Struct get structValue => $_getN(3);
  @$pb.TagNumber(4)
  set structValue($4.Struct value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStructValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearStructValue() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Struct ensureStructValue() => $_ensure(3);

  @$pb.TagNumber(5)
  $4.Value get value => $_getN(4);
  @$pb.TagNumber(5)
  set value($4.Value value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.Value ensureValue() => $_ensure(4);

  @$pb.TagNumber(6)
  $4.ListValue get listValue => $_getN(5);
  @$pb.TagNumber(6)
  set listValue($4.ListValue value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasListValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearListValue() => $_clearField(6);
  @$pb.TagNumber(6)
  $4.ListValue ensureListValue() => $_ensure(5);

  @$pb.TagNumber(7)
  $5.FieldMask get fieldMask => $_getN(6);
  @$pb.TagNumber(7)
  set fieldMask($5.FieldMask value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFieldMask() => $_has(6);
  @$pb.TagNumber(7)
  void clearFieldMask() => $_clearField(7);
  @$pb.TagNumber(7)
  $5.FieldMask ensureFieldMask() => $_ensure(6);

  @$pb.TagNumber(8)
  $6.StringValue get stringWrapper => $_getN(7);
  @$pb.TagNumber(8)
  set stringWrapper($6.StringValue value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStringWrapper() => $_has(7);
  @$pb.TagNumber(8)
  void clearStringWrapper() => $_clearField(8);
  @$pb.TagNumber(8)
  $6.StringValue ensureStringWrapper() => $_ensure(7);

  @$pb.TagNumber(9)
  $6.Int64Value get int64Wrapper => $_getN(8);
  @$pb.TagNumber(9)
  set int64Wrapper($6.Int64Value value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasInt64Wrapper() => $_has(8);
  @$pb.TagNumber(9)
  void clearInt64Wrapper() => $_clearField(9);
  @$pb.TagNumber(9)
  $6.Int64Value ensureInt64Wrapper() => $_ensure(8);

  @$pb.TagNumber(10)
  $6.BoolValue get boolWrapper => $_getN(9);
  @$pb.TagNumber(10)
  set boolWrapper($6.BoolValue value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasBoolWrapper() => $_has(9);
  @$pb.TagNumber(10)
  void clearBoolWrapper() => $_clearField(10);
  @$pb.TagNumber(10)
  $6.BoolValue ensureBoolWrapper() => $_ensure(9);

  @$pb.TagNumber(11)
  $7.Any get anyValue => $_getN(10);
  @$pb.TagNumber(11)
  set anyValue($7.Any value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAnyValue() => $_has(10);
  @$pb.TagNumber(11)
  void clearAnyValue() => $_clearField(11);
  @$pb.TagNumber(11)
  $7.Any ensureAnyValue() => $_ensure(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
