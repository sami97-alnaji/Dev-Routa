import 'dart:convert';

import '../domain/grpc_descriptor_models.dart';

class GrpcDynamicValidationException implements Exception {
  const GrpcDynamicValidationException(this.message, {required this.path});

  final String message;
  final String path;

  @override
  String toString() => 'gRPC input at $path: $message';
}

/// Validates JSON-style input without mutating it or including input values in
/// failures. Wire encoding remains a later, separate transport concern.
class GrpcDynamicMessageValidator {
  const GrpcDynamicMessageValidator(this._registry);

  final GrpcDescriptorRegistry _registry;

  Map<String, Object?> validate(
    String messageType,
    Object? value, {
    String rootPath = 'request',
  }) => _validateMessage(_message(messageType, rootPath), value, rootPath);

  Map<String, Object?> _validateMessage(
    GrpcMessageDescriptor message,
    Object? value,
    String valuePath,
  ) {
    if (value is! Map) {
      _fail('Expected an object.', valuePath);
    }
    final fields = <String, GrpcFieldDescriptor>{
      for (final field in message.fields) field.name: field,
      for (final field in message.fields) field.jsonName: field,
    };
    final result = <String, Object?>{};
    final oneofCounts = <int, int>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        _fail('Field names must be strings.', valuePath);
      }
      final field = fields[key];
      final fieldPath = '$valuePath.$key';
      if (field == null) {
        _fail('Unknown field.', fieldPath);
      }
      final oneofIndex = field.oneofIndex;
      if (oneofIndex != null) {
        oneofCounts[oneofIndex] = (oneofCounts[oneofIndex] ?? 0) + 1;
        if (oneofCounts[oneofIndex]! > 1) {
          _fail('Only one field in a oneof may be set.', fieldPath);
        }
      }
      result[field.jsonName] = field.repeated
          ? _validateRepeated(field, entry.value, fieldPath)
          : _validateField(field, entry.value, fieldPath);
    }
    if (message.isProto2) {
      for (final field in message.fields.where((item) => item.required)) {
        if (!result.containsKey(field.jsonName)) {
          _fail('Required field is missing.', '$valuePath.${field.jsonName}');
        }
      }
    }
    return result;
  }

  Object _validateRepeated(
    GrpcFieldDescriptor field,
    Object? value,
    String valuePath,
  ) {
    final nested = field.type == 'TYPE_MESSAGE'
        ? _registry.message(_normalize(field.typeName))
        : null;
    if (nested?.isMapEntry == true) {
      return _validateMap(nested!, value, valuePath);
    }
    if (value is! List) {
      _fail('Expected an array.', valuePath);
    }
    return List<Object?>.unmodifiable(
      List<Object?>.generate(
        value.length,
        (index) => _validateField(field, value[index], '$valuePath[$index]'),
      ),
    );
  }

  Map<String, Object?> _validateMap(
    GrpcMessageDescriptor entry,
    Object? value,
    String valuePath,
  ) {
    if (value is! Map) {
      _fail('Expected an object map.', valuePath);
    }
    final keyField = entry.fields
        .where((field) => field.number == 1)
        .firstOrNull;
    final valueField = entry.fields
        .where((field) => field.number == 2)
        .firstOrNull;
    if (keyField == null || valueField == null) {
      _fail('Invalid map entry descriptor.', valuePath);
    }
    final result = <String, Object?>{};
    for (final pair in value.entries) {
      if (pair.key is! String) {
        _fail('Map keys must be strings.', valuePath);
      }
      _validateField(keyField, pair.key, '$valuePath.${pair.key}');
      result[pair.key] = _validateField(
        valueField,
        pair.value,
        '$valuePath.${pair.key}',
      );
    }
    return result;
  }

  Object? _validateField(
    GrpcFieldDescriptor field,
    Object? value,
    String valuePath,
  ) {
    switch (field.type) {
      case 'TYPE_MESSAGE':
        return _validateMessage(
          _message(field.typeName, valuePath),
          value,
          valuePath,
        );
      case 'TYPE_STRING':
        if (value is! String) {
          _fail('Expected a string.', valuePath);
        }
      case 'TYPE_BYTES':
        if (value is! String) _fail('Expected a base64 string.', valuePath);
        try {
          base64Decode(value);
        } on FormatException {
          _fail('Expected valid base64.', valuePath);
        }
      case 'TYPE_BOOL':
        if (value is! bool) {
          _fail('Expected a boolean.', valuePath);
        }
      case 'TYPE_DOUBLE':
      case 'TYPE_FLOAT':
        if (value is! num || !value.isFinite) {
          _fail('Expected a finite number.', valuePath);
        }
      case 'TYPE_INT32':
      case 'TYPE_SINT32':
      case 'TYPE_SFIXED32':
        _integerInRange(value, '-2147483648', '2147483647', valuePath);
      case 'TYPE_UINT32':
      case 'TYPE_FIXED32':
        _integerInRange(value, '0', '4294967295', valuePath);
      case 'TYPE_INT64':
      case 'TYPE_SINT64':
      case 'TYPE_SFIXED64':
        _integerInRange(
          value,
          '-9223372036854775808',
          '9223372036854775807',
          valuePath,
        );
      case 'TYPE_UINT64':
      case 'TYPE_FIXED64':
        _integerInRange(value, '0', '18446744073709551615', valuePath);
      case 'TYPE_ENUM':
        final enumType = _registry.enumType(_normalize(field.typeName));
        final valid =
            enumType != null &&
            ((value is String && enumType.values.containsKey(value)) ||
                (value is int && enumType.values.containsValue(value)));
        if (!valid) _fail('Expected a declared enum name or value.', valuePath);
    }
    return value;
  }

  void _integerInRange(
    Object? value,
    String minimum,
    String maximum,
    String path,
  ) {
    if (value is! int ||
        BigInt.from(value) < BigInt.parse(minimum) ||
        BigInt.from(value) > BigInt.parse(maximum)) {
      _fail('Integer is outside the allowed range.', path);
    }
  }

  GrpcMessageDescriptor _message(String name, String valuePath) {
    final message = _registry.message(_normalize(name));
    if (message == null) {
      _fail('Descriptor message was not found.', valuePath);
    }
    return message;
  }

  Never _fail(String message, String path) =>
      throw GrpcDynamicValidationException(message, path: path);

  String _normalize(String value) =>
      value.startsWith('.') ? value.substring(1) : value;
}
