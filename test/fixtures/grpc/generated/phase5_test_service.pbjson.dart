// This is a generated file - do not edit.
//
// Generated from phase5_test_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use testModeDescriptor instead')
const TestMode$json = {
  '1': 'TestMode',
  '2': [
    {'1': 'TEST_MODE_UNSPECIFIED', '2': 0},
    {'1': 'TEST_MODE_ACTIVE', '2': 1},
  ],
};

/// Descriptor for `TestMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List testModeDescriptor = $convert.base64Decode(
    'CghUZXN0TW9kZRIZChVURVNUX01PREVfVU5TUEVDSUZJRUQQABIUChBURVNUX01PREVfQUNUSV'
    'ZFEAE=');

@$core.Deprecated('Use echoRequestDescriptor instead')
const EchoRequest$json = {
  '1': 'EchoRequest',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'samples', '3': 2, '4': 3, '5': 5, '10': 'samples'},
  ],
};

/// Descriptor for `EchoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List echoRequestDescriptor = $convert.base64Decode(
    'CgtFY2hvUmVxdWVzdBIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdlEhgKB3NhbXBsZXMYAiADKA'
    'VSB3NhbXBsZXM=');

@$core.Deprecated('Use echoResponseDescriptor instead')
const EchoResponse$json = {
  '1': 'EchoResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `EchoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List echoResponseDescriptor = $convert
    .base64Decode('CgxFY2hvUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use nestedValueDescriptor instead')
const NestedValue$json = {
  '1': 'NestedValue',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `NestedValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nestedValueDescriptor =
    $convert.base64Decode('CgtOZXN0ZWRWYWx1ZRISCgRuYW1lGAEgASgJUgRuYW1l');

@$core.Deprecated('Use codecMessageDescriptor instead')
const CodecMessage$json = {
  '1': 'CodecMessage',
  '2': [
    {'1': 'double_value', '3': 1, '4': 1, '5': 1, '10': 'doubleValue'},
    {'1': 'float_value', '3': 2, '4': 1, '5': 2, '10': 'floatValue'},
    {'1': 'int32_value', '3': 3, '4': 1, '5': 5, '10': 'int32Value'},
    {'1': 'int64_value', '3': 4, '4': 1, '5': 3, '10': 'int64Value'},
    {'1': 'uint32_value', '3': 5, '4': 1, '5': 13, '10': 'uint32Value'},
    {'1': 'uint64_value', '3': 6, '4': 1, '5': 4, '10': 'uint64Value'},
    {'1': 'sint32_value', '3': 7, '4': 1, '5': 17, '10': 'sint32Value'},
    {'1': 'sint64_value', '3': 8, '4': 1, '5': 18, '10': 'sint64Value'},
    {'1': 'fixed32_value', '3': 9, '4': 1, '5': 7, '10': 'fixed32Value'},
    {'1': 'fixed64_value', '3': 10, '4': 1, '5': 6, '10': 'fixed64Value'},
    {'1': 'sfixed32_value', '3': 11, '4': 1, '5': 15, '10': 'sfixed32Value'},
    {'1': 'sfixed64_value', '3': 12, '4': 1, '5': 16, '10': 'sfixed64Value'},
    {'1': 'bool_value', '3': 13, '4': 1, '5': 8, '10': 'boolValue'},
    {'1': 'string_value', '3': 14, '4': 1, '5': 9, '10': 'stringValue'},
    {'1': 'bytes_value', '3': 15, '4': 1, '5': 12, '10': 'bytesValue'},
    {
      '1': 'mode',
      '3': 16,
      '4': 1,
      '5': 14,
      '6': '.devroute.phase5.test.TestMode',
      '10': 'mode'
    },
    {
      '1': 'nested',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.devroute.phase5.test.NestedValue',
      '10': 'nested'
    },
    {'1': 'packed_values', '3': 18, '4': 3, '5': 5, '10': 'packedValues'},
    {
      '1': 'labels',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.devroute.phase5.test.CodecMessage.LabelsEntry',
      '10': 'labels'
    },
    {'1': 'first', '3': 20, '4': 1, '5': 9, '9': 0, '10': 'first'},
    {'1': 'second', '3': 21, '4': 1, '5': 5, '9': 0, '10': 'second'},
    {'1': 'reflected_values', '3': 22, '4': 3, '5': 9, '10': 'reflectedValues'},
    {
      '1': 'reflected_labels',
      '3': 23,
      '4': 3,
      '5': 11,
      '6': '.devroute.phase5.test.CodecMessage.ReflectedLabelsEntry',
      '10': 'reflectedLabels'
    },
    {
      '1': 'numeric_labels',
      '3': 24,
      '4': 3,
      '5': 11,
      '6': '.devroute.phase5.test.CodecMessage.NumericLabelsEntry',
      '10': 'numericLabels'
    },
    {
      '1': 'boolean_labels',
      '3': 25,
      '4': 3,
      '5': 11,
      '6': '.devroute.phase5.test.CodecMessage.BooleanLabelsEntry',
      '10': 'booleanLabels'
    },
  ],
  '3': [
    CodecMessage_LabelsEntry$json,
    CodecMessage_ReflectedLabelsEntry$json,
    CodecMessage_NumericLabelsEntry$json,
    CodecMessage_BooleanLabelsEntry$json
  ],
  '8': [
    {'1': 'selection'},
  ],
};

@$core.Deprecated('Use codecMessageDescriptor instead')
const CodecMessage_LabelsEntry$json = {
  '1': 'LabelsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use codecMessageDescriptor instead')
const CodecMessage_ReflectedLabelsEntry$json = {
  '1': 'ReflectedLabelsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use codecMessageDescriptor instead')
const CodecMessage_NumericLabelsEntry$json = {
  '1': 'NumericLabelsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use codecMessageDescriptor instead')
const CodecMessage_BooleanLabelsEntry$json = {
  '1': 'BooleanLabelsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 8, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CodecMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List codecMessageDescriptor = $convert.base64Decode(
    'CgxDb2RlY01lc3NhZ2USIQoMZG91YmxlX3ZhbHVlGAEgASgBUgtkb3VibGVWYWx1ZRIfCgtmbG'
    '9hdF92YWx1ZRgCIAEoAlIKZmxvYXRWYWx1ZRIfCgtpbnQzMl92YWx1ZRgDIAEoBVIKaW50MzJW'
    'YWx1ZRIfCgtpbnQ2NF92YWx1ZRgEIAEoA1IKaW50NjRWYWx1ZRIhCgx1aW50MzJfdmFsdWUYBS'
    'ABKA1SC3VpbnQzMlZhbHVlEiEKDHVpbnQ2NF92YWx1ZRgGIAEoBFILdWludDY0VmFsdWUSIQoM'
    'c2ludDMyX3ZhbHVlGAcgASgRUgtzaW50MzJWYWx1ZRIhCgxzaW50NjRfdmFsdWUYCCABKBJSC3'
    'NpbnQ2NFZhbHVlEiMKDWZpeGVkMzJfdmFsdWUYCSABKAdSDGZpeGVkMzJWYWx1ZRIjCg1maXhl'
    'ZDY0X3ZhbHVlGAogASgGUgxmaXhlZDY0VmFsdWUSJQoOc2ZpeGVkMzJfdmFsdWUYCyABKA9SDX'
    'NmaXhlZDMyVmFsdWUSJQoOc2ZpeGVkNjRfdmFsdWUYDCABKBBSDXNmaXhlZDY0VmFsdWUSHQoK'
    'Ym9vbF92YWx1ZRgNIAEoCFIJYm9vbFZhbHVlEiEKDHN0cmluZ192YWx1ZRgOIAEoCVILc3RyaW'
    '5nVmFsdWUSHwoLYnl0ZXNfdmFsdWUYDyABKAxSCmJ5dGVzVmFsdWUSMgoEbW9kZRgQIAEoDjIe'
    'LmRldnJvdXRlLnBoYXNlNS50ZXN0LlRlc3RNb2RlUgRtb2RlEjkKBm5lc3RlZBgRIAEoCzIhLm'
    'RldnJvdXRlLnBoYXNlNS50ZXN0Lk5lc3RlZFZhbHVlUgZuZXN0ZWQSIwoNcGFja2VkX3ZhbHVl'
    'cxgSIAMoBVIMcGFja2VkVmFsdWVzEkYKBmxhYmVscxgTIAMoCzIuLmRldnJvdXRlLnBoYXNlNS'
    '50ZXN0LkNvZGVjTWVzc2FnZS5MYWJlbHNFbnRyeVIGbGFiZWxzEhYKBWZpcnN0GBQgASgJSABS'
    'BWZpcnN0EhgKBnNlY29uZBgVIAEoBUgAUgZzZWNvbmQSKQoQcmVmbGVjdGVkX3ZhbHVlcxgWIA'
    'MoCVIPcmVmbGVjdGVkVmFsdWVzEmIKEHJlZmxlY3RlZF9sYWJlbHMYFyADKAsyNy5kZXZyb3V0'
    'ZS5waGFzZTUudGVzdC5Db2RlY01lc3NhZ2UuUmVmbGVjdGVkTGFiZWxzRW50cnlSD3JlZmxlY3'
    'RlZExhYmVscxJcCg5udW1lcmljX2xhYmVscxgYIAMoCzI1LmRldnJvdXRlLnBoYXNlNS50ZXN0'
    'LkNvZGVjTWVzc2FnZS5OdW1lcmljTGFiZWxzRW50cnlSDW51bWVyaWNMYWJlbHMSXAoOYm9vbG'
    'Vhbl9sYWJlbHMYGSADKAsyNS5kZXZyb3V0ZS5waGFzZTUudGVzdC5Db2RlY01lc3NhZ2UuQm9v'
    'bGVhbkxhYmVsc0VudHJ5Ug1ib29sZWFuTGFiZWxzGjkKC0xhYmVsc0VudHJ5EhAKA2tleRgBIA'
    'EoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaQgoUUmVmbGVjdGVkTGFiZWxzRW50'
    'cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4ARpAChJOdW1lcm'
    'ljTGFiZWxzRW50cnkSEAoDa2V5GAEgASgFUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4'
    'ARpAChJCb29sZWFuTGFiZWxzRW50cnkSEAoDa2V5GAEgASgIUgNrZXkSFAoFdmFsdWUYAiABKA'
    'lSBXZhbHVlOgI4AUILCglzZWxlY3Rpb24=');

@$core.Deprecated('Use wellKnownMessageDescriptor instead')
const WellKnownMessage$json = {
  '1': 'WellKnownMessage',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'duration',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'duration'
    },
    {
      '1': 'empty',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Empty',
      '10': 'empty'
    },
    {
      '1': 'struct_value',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'structValue'
    },
    {
      '1': 'value',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Value',
      '10': 'value'
    },
    {
      '1': 'list_value',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.ListValue',
      '10': 'listValue'
    },
    {
      '1': 'field_mask',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'fieldMask'
    },
    {
      '1': 'string_wrapper',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.StringValue',
      '10': 'stringWrapper'
    },
    {
      '1': 'int64_wrapper',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Int64Value',
      '10': 'int64Wrapper'
    },
    {
      '1': 'bool_wrapper',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.BoolValue',
      '10': 'boolWrapper'
    },
    {
      '1': 'any_value',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'anyValue'
    },
  ],
};

/// Descriptor for `WellKnownMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wellKnownMessageDescriptor = $convert.base64Decode(
    'ChBXZWxsS25vd25NZXNzYWdlEjgKCXRpbWVzdGFtcBgBIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSCXRpbWVzdGFtcBI1CghkdXJhdGlvbhgCIAEoCzIZLmdvb2dsZS5wcm90b2J1'
    'Zi5EdXJhdGlvblIIZHVyYXRpb24SLAoFZW1wdHkYAyABKAsyFi5nb29nbGUucHJvdG9idWYuRW'
    '1wdHlSBWVtcHR5EjoKDHN0cnVjdF92YWx1ZRgEIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1'
    'Y3RSC3N0cnVjdFZhbHVlEiwKBXZhbHVlGAUgASgLMhYuZ29vZ2xlLnByb3RvYnVmLlZhbHVlUg'
    'V2YWx1ZRI5CgpsaXN0X3ZhbHVlGAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLkxpc3RWYWx1ZVIJ'
    'bGlzdFZhbHVlEjkKCmZpZWxkX21hc2sYByABKAsyGi5nb29nbGUucHJvdG9idWYuRmllbGRNYX'
    'NrUglmaWVsZE1hc2sSQwoOc3RyaW5nX3dyYXBwZXIYCCABKAsyHC5nb29nbGUucHJvdG9idWYu'
    'U3RyaW5nVmFsdWVSDXN0cmluZ1dyYXBwZXISQAoNaW50NjRfd3JhcHBlchgJIAEoCzIbLmdvb2'
    'dsZS5wcm90b2J1Zi5JbnQ2NFZhbHVlUgxpbnQ2NFdyYXBwZXISPQoMYm9vbF93cmFwcGVyGAog'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLkJvb2xWYWx1ZVILYm9vbFdyYXBwZXISMQoJYW55X3ZhbH'
    'VlGAsgASgLMhQuZ29vZ2xlLnByb3RvYnVmLkFueVIIYW55VmFsdWU=');
