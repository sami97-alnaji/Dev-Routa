import 'dart:convert';
import 'dart:typed_data';

import '../domain/grpc_codec_models.dart';
import '../domain/grpc_descriptor_models.dart';
import 'grpc_dynamic_message_validator.dart';

class GrpcDynamicMessageCodec {
  GrpcDynamicMessageCodec(
    this._registry, {
    this.maximumMessageBytes = 4 * 1024 * 1024,
    this.maximumRecursionDepth = 32,
    this.maximumRepeatedItems = 10000,
    this.maximumDecodedFields = 50000,
  }) : _validator = GrpcDynamicMessageValidator(_registry);

  static const int _maximumSafeJsonInteger = 9007199254740991;

  final GrpcDescriptorRegistry _registry;
  final GrpcDynamicMessageValidator _validator;
  final int maximumMessageBytes;
  final int maximumRecursionDepth;
  final int maximumRepeatedItems;
  final int maximumDecodedFields;

  Uint8List encode(
    String messageType,
    Object? input, {
    String rootPath = 'request',
  }) {
    final normalized = _prepareInput(messageType, input, rootPath, 0);
    final validated = _validator.validate(
      messageType,
      normalized,
      rootPath: rootPath,
    );
    final output = _encodeMessage(
      _message(messageType, rootPath),
      validated,
      rootPath,
      0,
    );
    if (output.length > maximumMessageBytes) {
      _fail(
        GrpcCodecFailureCategory.limitExceeded,
        rootPath,
        'Encoded message exceeds the byte limit.',
      );
    }
    return output;
  }

  Object? decode(
    String messageType,
    Uint8List bytes, {
    String rootPath = 'response',
  }) {
    if (bytes.length > maximumMessageBytes) {
      _fail(
        GrpcCodecFailureCategory.limitExceeded,
        rootPath,
        'Message exceeds the byte limit.',
      );
    }
    final reader = _WireReader(bytes, rootPath);
    final budget = _DecodeBudget(maximumDecodedFields);
    final decoded = _decodeMessage(
      _message(messageType, rootPath),
      reader,
      rootPath,
      0,
      budget,
    );
    return _wellKnownOutput(messageType, decoded);
  }

  Uint8List _encodeMessage(
    GrpcMessageDescriptor message,
    Map<String, Object?> value,
    String path,
    int depth,
  ) {
    _checkDepth(depth, path);
    final output = BytesBuilder(copy: false);
    final fields = message.fields.toList()
      ..sort((left, right) => left.number.compareTo(right.number));
    for (final field in fields) {
      if (!value.containsKey(field.jsonName)) continue;
      final fieldValue = value[field.jsonName];
      final fieldPath = '$path.${field.jsonName}';
      if (field.repeated) {
        final mapEntry = field.type == 'TYPE_MESSAGE'
            ? _registry.message(_normalize(field.typeName))
            : null;
        if (mapEntry?.isMapEntry == true) {
          final entries = (fieldValue! as Map<String, Object?>).entries.toList()
            ..sort((left, right) => left.key.compareTo(right.key));
          _checkRepeated(entries.length, fieldPath);
          for (final entry in entries) {
            final keyField = mapEntry!.fields.firstWhere(
              (item) => item.number == 1,
            );
            final mapValue = <String, Object?>{
              keyField.jsonName: _mapKeyInput(keyField, entry.key),
              mapEntry.fields.firstWhere((item) => item.number == 2).jsonName:
                  entry.value,
            };
            _writeSingle(
              output,
              field,
              mapValue,
              fieldPathForMap(fieldPath, entry.key),
              depth,
            );
          }
          continue;
        }
        final items = fieldValue! as List<Object?>;
        _checkRepeated(items.length, fieldPath);
        if (_isPackable(field.type) && items.isNotEmpty) {
          final packed = BytesBuilder(copy: false);
          for (var index = 0; index < items.length; index++) {
            _writeScalar(packed, field, items[index], '$fieldPath[$index]');
          }
          _writeTag(output, field.number, 2);
          final bytes = packed.takeBytes();
          _writeVarint(output, BigInt.from(bytes.length));
          output.add(bytes);
        } else {
          for (var index = 0; index < items.length; index++) {
            _writeSingle(
              output,
              field,
              items[index],
              '$fieldPath[$index]',
              depth,
            );
          }
        }
      } else {
        _writeSingle(output, field, fieldValue, fieldPath, depth);
      }
    }
    return output.takeBytes();
  }

  void _writeSingle(
    BytesBuilder output,
    GrpcFieldDescriptor field,
    Object? value,
    String path,
    int depth,
  ) {
    final wireType = _wireType(field.type, path);
    _writeTag(output, field.number, wireType);
    if (field.type == 'TYPE_MESSAGE') {
      final nestedType = _normalize(field.typeName);
      final nestedInput = _wellKnownInput(nestedType, value, path);
      final nested = _encodeMessage(
        _message(nestedType, path),
        nestedInput! as Map<String, Object?>,
        path,
        depth + 1,
      );
      _writeVarint(output, BigInt.from(nested.length));
      output.add(nested);
    } else {
      _writeScalar(output, field, value, path);
    }
  }

  Object _mapKeyInput(GrpcFieldDescriptor field, String value) {
    if (field.type == 'TYPE_BOOL') return value == 'true';
    if (field.type == 'TYPE_STRING') return value;
    return value;
  }

  void _writeScalar(
    BytesBuilder output,
    GrpcFieldDescriptor field,
    Object? value,
    String path,
  ) {
    switch (field.type) {
      case 'TYPE_DOUBLE':
        _writeDouble(output, (value! as num).toDouble());
      case 'TYPE_FLOAT':
        _writeFloat(output, (value! as num).toDouble());
      case 'TYPE_INT32':
      case 'TYPE_INT64':
        _writeVarint(output, _signedVarint(_integer(value, path)));
      case 'TYPE_UINT32':
      case 'TYPE_UINT64':
        _writeVarint(output, _integer(value, path));
      case 'TYPE_SINT32':
      case 'TYPE_SINT64':
        final integer = _integer(value, path);
        _writeVarint(output, (integer << 1) ^ (integer >> 63));
      case 'TYPE_FIXED32':
        _writeFixed32(output, _integer(value, path).toInt());
      case 'TYPE_SFIXED32':
        _writeFixed32(output, _integer(value, path).toSigned(32).toInt());
      case 'TYPE_FIXED64':
      case 'TYPE_SFIXED64':
        _writeFixed64(output, _integer(value, path));
      case 'TYPE_BOOL':
        _writeVarint(output, (value! as bool) ? BigInt.one : BigInt.zero);
      case 'TYPE_STRING':
        _writeLengthDelimited(output, utf8.encode(value! as String));
      case 'TYPE_BYTES':
        try {
          _writeLengthDelimited(output, base64Decode(value! as String));
        } on FormatException {
          _fail(
            GrpcCodecFailureCategory.validation,
            path,
            'Expected canonical base64 bytes.',
            expectedType: 'base64',
          );
        }
      case 'TYPE_ENUM':
        final enumType = _registry.enumType(_normalize(field.typeName));
        final number = value is String
            ? enumType?.values[value]
            : value as int?;
        if (number == null) {
          _fail(
            GrpcCodecFailureCategory.validation,
            path,
            'Unknown enum value.',
          );
        }
        _writeVarint(output, _signedVarint(BigInt.from(number)));
      default:
        _fail(
          GrpcCodecFailureCategory.unsupportedType,
          path,
          'Unsupported Protobuf field type.',
          expectedType: field.type,
        );
    }
  }

  Map<String, Object?> _decodeMessage(
    GrpcMessageDescriptor message,
    _WireReader reader,
    String path,
    int depth,
    _DecodeBudget budget,
  ) {
    _checkDepth(depth, path);
    final output = <String, Object?>{};
    final fields = <int, GrpcFieldDescriptor>{
      for (final field in message.fields) field.number: field,
    };
    final selectedOneofs = <int, String>{};
    while (!reader.isDone) {
      budget.take(path);
      final tag = reader.readVarint();
      final fieldNumber = (tag >> 3).toInt();
      final wireType = (tag & BigInt.from(7)).toInt();
      if (fieldNumber <= 0) reader.malformed('Invalid field tag.');
      final field = fields[fieldNumber];
      if (field == null) {
        reader.skip(wireType);
        continue;
      }
      final fieldPath = '$path.${field.jsonName}';
      final oneofIndex = field.oneofIndex;
      if (oneofIndex != null) {
        final old = selectedOneofs[oneofIndex];
        if (old != null) output.remove(old);
        selectedOneofs[oneofIndex] = field.jsonName;
      }
      final mapEntry = field.repeated && field.type == 'TYPE_MESSAGE'
          ? _registry.message(_normalize(field.typeName))
          : null;
      if (mapEntry?.isMapEntry == true) {
        _expectWire(wireType, 2, fieldPath);
        final entryReader = reader.readSubReader();
        final entry = _decodeMessage(
          mapEntry!,
          entryReader,
          fieldPath,
          depth + 1,
          budget,
        );
        final keyField = mapEntry.fields.firstWhere((item) => item.number == 1);
        final valueField = mapEntry.fields.firstWhere(
          (item) => item.number == 2,
        );
        final key = entry[keyField.jsonName]?.toString() ?? '';
        final map =
            (output[field.jsonName] as Map<String, Object?>?) ??
            <String, Object?>{};
        _checkRepeated(map.length + 1, fieldPath);
        map[key] = entry[valueField.jsonName];
        output[field.jsonName] = map;
        continue;
      }
      if (field.repeated && _isPackable(field.type) && wireType == 2) {
        final packed = reader.readSubReader();
        final values =
            (output[field.jsonName] as List<Object?>?) ?? <Object?>[];
        while (!packed.isDone) {
          _checkRepeated(values.length + 1, fieldPath);
          values.add(
            _readScalar(
              packed,
              field,
              _wireType(field.type, fieldPath),
              fieldPath,
            ),
          );
        }
        output[field.jsonName] = values;
        continue;
      }
      final decoded = field.type == 'TYPE_MESSAGE'
          ? _decodeNested(reader, field, wireType, fieldPath, depth, budget)
          : _readScalar(reader, field, wireType, fieldPath);
      if (field.repeated) {
        final values =
            (output[field.jsonName] as List<Object?>?) ?? <Object?>[];
        _checkRepeated(values.length + 1, fieldPath);
        values.add(decoded);
        output[field.jsonName] = values;
      } else {
        output[field.jsonName] = decoded;
      }
    }
    if (message.isProto2) {
      for (final field in message.fields.where((item) => item.required)) {
        if (!output.containsKey(field.jsonName)) {
          _fail(
            GrpcCodecFailureCategory.malformedWire,
            '$path.${field.jsonName}',
            'Required field is missing.',
          );
        }
      }
    }
    return output;
  }

  Object? _decodeNested(
    _WireReader reader,
    GrpcFieldDescriptor field,
    int wireType,
    String path,
    int depth,
    _DecodeBudget budget,
  ) {
    _expectWire(wireType, 2, path);
    final nestedType = _normalize(field.typeName);
    final nested = _decodeMessage(
      _message(nestedType, path),
      reader.readSubReader(),
      path,
      depth + 1,
      budget,
    );
    return _wellKnownOutput(nestedType, nested);
  }

  Object _readScalar(
    _WireReader reader,
    GrpcFieldDescriptor field,
    int wireType,
    String path,
  ) {
    _expectWire(wireType, _wireType(field.type, path), path);
    switch (field.type) {
      case 'TYPE_DOUBLE':
        return reader.readDouble();
      case 'TYPE_FLOAT':
        return reader.readFloat();
      case 'TYPE_INT32':
        return reader.readVarint().toSigned(32).toInt();
      case 'TYPE_INT64':
        return _jsonInteger(reader.readVarint().toSigned(64));
      case 'TYPE_UINT32':
        return reader.readVarint().toUnsigned(32).toInt();
      case 'TYPE_UINT64':
        return _jsonInteger(reader.readVarint().toUnsigned(64));
      case 'TYPE_SINT32':
        return _decodeZigZag(reader.readVarint()).toSigned(32).toInt();
      case 'TYPE_SINT64':
        return _jsonInteger(_decodeZigZag(reader.readVarint()).toSigned(64));
      case 'TYPE_FIXED32':
        return reader.readFixed32();
      case 'TYPE_SFIXED32':
        return reader.readFixed32().toSigned(32);
      case 'TYPE_FIXED64':
        return _jsonInteger(reader.readFixed64().toUnsigned(64));
      case 'TYPE_SFIXED64':
        return _jsonInteger(reader.readFixed64().toSigned(64));
      case 'TYPE_BOOL':
        return reader.readVarint() != BigInt.zero;
      case 'TYPE_STRING':
        try {
          return utf8.decode(reader.readLengthDelimited());
        } on FormatException {
          reader.malformed('Invalid UTF-8 string.');
        }
      case 'TYPE_BYTES':
        return base64Encode(reader.readLengthDelimited());
      case 'TYPE_ENUM':
        final number = reader.readVarint().toSigned(32).toInt();
        final enumType = _registry.enumType(_normalize(field.typeName));
        for (final entry
            in enumType?.values.entries ?? const Iterable.empty()) {
          if (entry.value == number) return entry.key;
        }
        return number;
      default:
        _fail(
          GrpcCodecFailureCategory.unsupportedType,
          path,
          'Unsupported Protobuf field type.',
        );
    }
  }

  Object? _wellKnownInput(String type, Object? value, String path) {
    final name = _normalize(type);
    if (name == 'google.protobuf.Empty') return <String, Object?>{};
    if (name == 'google.protobuf.Timestamp' && value is String) {
      final parsed = DateTime.tryParse(value)?.toUtc();
      if (parsed == null) {
        _fail(GrpcCodecFailureCategory.validation, path, 'Invalid Timestamp.');
      }
      final micros = parsed.microsecondsSinceEpoch;
      return <String, Object?>{
        'seconds': (micros ~/ Duration.microsecondsPerSecond).toString(),
        'nanos': (micros.remainder(Duration.microsecondsPerSecond) * 1000),
      };
    }
    if (name == 'google.protobuf.Duration' && value is String) {
      final match = RegExp(r'^(-?)(\d+)(?:\.(\d{1,9}))?s$').firstMatch(value);
      if (match == null) {
        _fail(GrpcCodecFailureCategory.validation, path, 'Invalid Duration.');
      }
      final negative = match.group(1) == '-';
      final fraction = (match.group(3) ?? '').padRight(9, '0');
      return <String, Object?>{
        'seconds': '${negative ? '-' : ''}${match.group(2)}',
        'nanos':
            (negative ? -1 : 1) * int.parse(fraction.isEmpty ? '0' : fraction),
      };
    }
    if (name == 'google.protobuf.FieldMask' && value is String) {
      return <String, Object?>{'paths': value.split(',')};
    }
    if (name == 'google.protobuf.Struct' && value is Map) {
      if (value.containsKey('fields')) return value;
      return <String, Object?>{
        'fields': <String, Object?>{
          for (final entry in value.entries)
            entry.key.toString(): _valueInput(entry.value),
        },
      };
    }
    if (name == 'google.protobuf.ListValue' && value is List) {
      return <String, Object?>{
        'values': value.map(_valueInput).toList(growable: false),
      };
    }
    if (name == 'google.protobuf.ListValue' &&
        value is Map &&
        value.containsKey('values')) {
      return value;
    }
    if (name == 'google.protobuf.Value') {
      const rawFields = <String>{
        'nullValue',
        'numberValue',
        'stringValue',
        'boolValue',
        'structValue',
        'listValue',
      };
      if (value is Map && value.keys.any(rawFields.contains)) return value;
      return _valueInput(value);
    }
    if (name == 'google.protobuf.Any' && value is Map) {
      if (value.containsKey('typeUrl') && value.containsKey('value')) {
        return value;
      }
      final typeUrl = value['@type'];
      if (typeUrl is! String || typeUrl.isEmpty) {
        _fail(GrpcCodecFailureCategory.validation, path, 'Any requires @type.');
      }
      final typeName = typeUrl.substring(typeUrl.lastIndexOf('/') + 1);
      final structured = value['value'];
      if (_registry.message(typeName) != null && structured is! String) {
        final embedded = encode(typeName, structured, rootPath: '$path.value');
        return <String, Object?>{
          'typeUrl': typeUrl,
          'value': base64Encode(embedded),
        };
      }
      if (structured is! String) {
        _fail(
          GrpcCodecFailureCategory.validation,
          '$path.value',
          'Unknown Any payload must be base64.',
        );
      }
      return <String, Object?>{'typeUrl': typeUrl, 'value': structured};
    }
    const wrappers = <String>{
      'google.protobuf.StringValue',
      'google.protobuf.Int32Value',
      'google.protobuf.Int64Value',
      'google.protobuf.UInt32Value',
      'google.protobuf.UInt64Value',
      'google.protobuf.BoolValue',
      'google.protobuf.FloatValue',
      'google.protobuf.DoubleValue',
      'google.protobuf.BytesValue',
    };
    if (wrappers.contains(name) && value is! Map) {
      return <String, Object?>{'value': value};
    }
    return value;
  }

  Object? _prepareInput(String type, Object? value, String path, int depth) {
    _checkDepth(depth, path);
    final prepared = _wellKnownInput(type, value, path);
    if (prepared is! Map) return prepared;
    final message = _message(type, path);
    final fields = <String, GrpcFieldDescriptor>{
      for (final field in message.fields) field.name: field,
      for (final field in message.fields) field.jsonName: field,
    };
    return <String, Object?>{
      for (final entry in prepared.entries)
        entry.key.toString(): _prepareFieldInput(
          fields[entry.key],
          entry.value,
          '$path.${entry.key}',
          depth,
        ),
    };
  }

  Object? _prepareFieldInput(
    GrpcFieldDescriptor? field,
    Object? value,
    String path,
    int depth,
  ) {
    if (field == null || field.type != 'TYPE_MESSAGE') return value;
    final nestedType = _normalize(field.typeName);
    final nested = _registry.message(nestedType);
    if (field.repeated && nested?.isMapEntry == true && value is Map) {
      final valueField = nested!.fields.firstWhere((item) => item.number == 2);
      if (valueField.type != 'TYPE_MESSAGE') return value;
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): _prepareInput(
            valueField.typeName,
            entry.value,
            '$path[${jsonEncode(entry.key.toString())}]',
            depth + 1,
          ),
      };
    }
    if (field.repeated && value is List) {
      return <Object?>[
        for (var index = 0; index < value.length; index++)
          _prepareInput(nestedType, value[index], '$path[$index]', depth + 1),
      ];
    }
    return _prepareInput(nestedType, value, path, depth + 1);
  }

  Object? _wellKnownOutput(String type, Map<String, Object?> value) {
    final name = _normalize(type);
    if (name == 'google.protobuf.Empty') return <String, Object?>{};
    if (name == 'google.protobuf.Timestamp') {
      final seconds = BigInt.parse(value['seconds'].toString());
      final nanos = value['nanos'] as int? ?? 0;
      return DateTime.fromMicrosecondsSinceEpoch(
        (seconds * BigInt.from(Duration.microsecondsPerSecond)).toInt() +
            nanos ~/ 1000,
        isUtc: true,
      ).toIso8601String();
    }
    if (name == 'google.protobuf.Duration') {
      final seconds = value['seconds'].toString();
      final nanos = (value['nanos'] as int? ?? 0).abs();
      final fraction = nanos == 0
          ? ''
          : '.${nanos.toString().padLeft(9, '0').replaceFirst(RegExp(r'0+$'), '')}';
      return '$seconds${fraction}s';
    }
    if (name == 'google.protobuf.FieldMask') {
      return ((value['paths'] as List?) ?? const <Object?>[]).join(',');
    }
    if (name == 'google.protobuf.Struct') {
      final fields = value['fields'] as Map<String, Object?>? ?? const {};
      return <String, Object?>{
        for (final entry in fields.entries)
          entry.key:
              entry.value is Map<String, Object?> &&
                  _looksLikeValue(entry.value! as Map<String, Object?>)
              ? _valueOutput(entry.value! as Map<String, Object?>)
              : entry.value,
      };
    }
    if (name == 'google.protobuf.ListValue') {
      return ((value['values'] as List?) ?? const <Object?>[])
          .map(
            (item) => item is Map<String, Object?> && _looksLikeValue(item)
                ? _valueOutput(item)
                : item,
          )
          .toList(growable: false);
    }
    if (name == 'google.protobuf.Value') return _valueOutput(value);
    if (name == 'google.protobuf.Any') {
      final typeUrl = value['typeUrl'] as String? ?? '';
      final payload = value['value'] as String? ?? '';
      final typeName = typeUrl.substring(typeUrl.lastIndexOf('/') + 1);
      final descriptor = _registry.message(typeName);
      if (descriptor != null) {
        try {
          return <String, Object?>{
            '@type': typeUrl,
            'value': decode(
              typeName,
              Uint8List.fromList(base64Decode(payload)),
              rootPath: 'response.value',
            ),
          };
        } on FormatException {
          _fail(
            GrpcCodecFailureCategory.malformedWire,
            'response.value',
            'Any contains invalid base64.',
          );
        }
      }
      return <String, Object?>{'@type': typeUrl, 'value': payload};
    }
    if (name.startsWith('google.protobuf.') &&
        name.endsWith('Value') &&
        name != 'google.protobuf.Value' &&
        name != 'google.protobuf.ListValue') {
      return value['value'];
    }
    return value;
  }

  Map<String, Object?> _valueInput(Object? value) {
    if (value == null) return <String, Object?>{'nullValue': 'NULL_VALUE'};
    if (value is bool) return <String, Object?>{'boolValue': value};
    if (value is num) return <String, Object?>{'numberValue': value};
    if (value is String) return <String, Object?>{'stringValue': value};
    if (value is List) {
      return <String, Object?>{
        'listValue': <String, Object?>{
          'values': value.map(_valueInput).toList(growable: false),
        },
      };
    }
    if (value is Map) {
      return <String, Object?>{
        'structValue': <String, Object?>{
          'fields': <String, Object?>{
            for (final entry in value.entries)
              entry.key.toString(): _valueInput(entry.value),
          },
        },
      };
    }
    _fail(
      GrpcCodecFailureCategory.validation,
      'request',
      'Unsupported google.protobuf.Value input.',
    );
  }

  Object? _valueOutput(Map<String, Object?> value) {
    if (value.containsKey('nullValue')) return null;
    if (value.containsKey('boolValue')) return value['boolValue'];
    if (value.containsKey('numberValue')) return value['numberValue'];
    if (value.containsKey('stringValue')) return value['stringValue'];
    if (value['listValue'] case final Map<String, Object?> listValue) {
      return listValue.containsKey('values')
          ? _wellKnownOutput('google.protobuf.ListValue', listValue)
          : listValue;
    }
    if (value.containsKey('listValue')) return value['listValue'];
    if (value['structValue'] case final Map<String, Object?> structValue) {
      return structValue.containsKey('fields')
          ? _wellKnownOutput('google.protobuf.Struct', structValue)
          : structValue;
    }
    if (value.containsKey('structValue')) return value['structValue'];
    return null;
  }

  bool _looksLikeValue(Map<String, Object?> value) => value.keys.any(
    const <String>{
      'nullValue',
      'numberValue',
      'stringValue',
      'boolValue',
      'structValue',
      'listValue',
    }.contains,
  );

  BigInt _integer(Object? value, String path) {
    if (value is int) return BigInt.from(value);
    if (value is String && RegExp(r'^-?(0|[1-9]\d*)$').hasMatch(value)) {
      return BigInt.parse(value);
    }
    _fail(
      GrpcCodecFailureCategory.validation,
      path,
      'Expected an integer or canonical decimal string.',
      expectedType: 'integer',
    );
  }

  Object _jsonInteger(BigInt value) =>
      value.abs() <= BigInt.from(_maximumSafeJsonInteger)
      ? value.toInt()
      : value.toString();

  int _wireType(String type, String path) {
    if (<String>{
      'TYPE_INT32',
      'TYPE_INT64',
      'TYPE_UINT32',
      'TYPE_UINT64',
      'TYPE_SINT32',
      'TYPE_SINT64',
      'TYPE_BOOL',
      'TYPE_ENUM',
    }.contains(type)) {
      return 0;
    }
    if (<String>{
      'TYPE_FIXED64',
      'TYPE_SFIXED64',
      'TYPE_DOUBLE',
    }.contains(type)) {
      return 1;
    }
    if (<String>{'TYPE_STRING', 'TYPE_BYTES', 'TYPE_MESSAGE'}.contains(type)) {
      return 2;
    }
    if (<String>{
      'TYPE_FIXED32',
      'TYPE_SFIXED32',
      'TYPE_FLOAT',
    }.contains(type)) {
      return 5;
    }
    _fail(
      GrpcCodecFailureCategory.unsupportedType,
      path,
      'Unsupported Protobuf field type.',
      expectedType: type,
    );
  }

  bool _isPackable(String type) =>
      !<String>{'TYPE_STRING', 'TYPE_BYTES', 'TYPE_MESSAGE'}.contains(type);

  void _checkDepth(int depth, String path) {
    if (depth > maximumRecursionDepth) {
      _fail(
        GrpcCodecFailureCategory.limitExceeded,
        path,
        'Maximum recursion depth exceeded.',
      );
    }
  }

  void _checkRepeated(int count, String path) {
    if (count > maximumRepeatedItems) {
      _fail(
        GrpcCodecFailureCategory.limitExceeded,
        path,
        'Maximum repeated item count exceeded.',
      );
    }
  }

  GrpcMessageDescriptor _message(String type, String path) {
    final message = _registry.message(_normalize(type));
    if (message == null) {
      _fail(
        GrpcCodecFailureCategory.validation,
        path,
        'Descriptor message was not found.',
      );
    }
    return message;
  }

  String fieldPathForMap(String path, String key) =>
      '$path[${jsonEncode(key)}]';
  String _normalize(String value) =>
      value.startsWith('.') ? value.substring(1) : value;

  Never _fail(
    GrpcCodecFailureCategory category,
    String path,
    String message, {
    String? expectedType,
  }) => throw GrpcCodecException(
    category: category,
    path: path,
    message: message,
    expectedType: expectedType,
  );

  void _expectWire(int actual, int expected, String path) {
    if (actual != expected) {
      _fail(
        GrpcCodecFailureCategory.malformedWire,
        path,
        'Unexpected wire type.',
        expectedType: '$expected',
      );
    }
  }
}

class _DecodeBudget {
  _DecodeBudget(this.remaining);
  int remaining;
  void take(String path) {
    if (--remaining < 0) {
      throw GrpcCodecException(
        category: GrpcCodecFailureCategory.limitExceeded,
        path: path,
        message: 'Maximum decoded field count exceeded.',
      );
    }
  }
}

class _WireReader {
  _WireReader(this.bytes, this.path);
  final Uint8List bytes;
  final String path;
  int offset = 0;
  bool get isDone => offset == bytes.length;

  BigInt readVarint() {
    var result = BigInt.zero;
    for (var shift = 0; shift < 70; shift += 7) {
      if (offset >= bytes.length) malformed('Truncated varint.');
      final byte = bytes[offset++];
      result |= BigInt.from(byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) return result;
    }
    malformed('Varint is too long.');
  }

  Uint8List readLengthDelimited() {
    final length = readVarint().toInt();
    if (length < 0 || offset + length > bytes.length) {
      malformed('Truncated length-delimited field.');
    }
    final value = Uint8List.sublistView(bytes, offset, offset + length);
    offset += length;
    return value;
  }

  _WireReader readSubReader() => _WireReader(readLengthDelimited(), path);
  int readFixed32() {
    _require(4);
    final value = ByteData.sublistView(
      bytes,
      offset,
      offset + 4,
    ).getUint32(0, Endian.little);
    offset += 4;
    return value;
  }

  BigInt readFixed64() {
    _require(8);
    final low = readFixed32();
    final high = readFixed32();
    return (BigInt.from(high) << 32) | BigInt.from(low);
  }

  double readFloat() {
    _require(4);
    final value = ByteData.sublistView(
      bytes,
      offset,
      offset + 4,
    ).getFloat32(0, Endian.little);
    offset += 4;
    return value;
  }

  double readDouble() {
    _require(8);
    final value = ByteData.sublistView(
      bytes,
      offset,
      offset + 8,
    ).getFloat64(0, Endian.little);
    offset += 8;
    return value;
  }

  void skip(int wireType) {
    switch (wireType) {
      case 0:
        readVarint();
      case 1:
        _require(8);
        offset += 8;
      case 2:
        readLengthDelimited();
      case 5:
        _require(4);
        offset += 4;
      default:
        malformed('Unsupported wire type.');
    }
  }

  void _require(int count) {
    if (offset + count > bytes.length) {
      malformed('Truncated fixed-width field.');
    }
  }

  Never malformed(String message) => throw GrpcCodecException(
    category: GrpcCodecFailureCategory.malformedWire,
    path: path,
    message: message,
  );
}

void _writeTag(BytesBuilder output, int fieldNumber, int wireType) =>
    _writeVarint(output, BigInt.from((fieldNumber << 3) | wireType));
void _writeVarint(BytesBuilder output, BigInt value) {
  var current = value.toUnsigned(64);
  while (current >= BigInt.from(0x80)) {
    output.addByte((current & BigInt.from(0x7f)).toInt() | 0x80);
    current >>= 7;
  }
  output.addByte(current.toInt());
}

BigInt _signedVarint(BigInt value) => value.toUnsigned(64);
BigInt _decodeZigZag(BigInt value) => (value >> 1) ^ (-(value & BigInt.one));
void _writeLengthDelimited(BytesBuilder output, List<int> value) {
  _writeVarint(output, BigInt.from(value.length));
  output.add(value);
}

void _writeFixed32(BytesBuilder output, int value) {
  final data = ByteData(4)..setUint32(0, value.toUnsigned(32), Endian.little);
  output.add(data.buffer.asUint8List());
}

void _writeFixed64(BytesBuilder output, BigInt value) {
  final unsigned = value.toUnsigned(64);
  _writeFixed32(output, (unsigned & BigInt.from(0xffffffff)).toInt());
  _writeFixed32(output, (unsigned >> 32).toInt());
}

void _writeFloat(BytesBuilder output, double value) {
  final data = ByteData(4)..setFloat32(0, value, Endian.little);
  output.add(data.buffer.asUint8List());
}

void _writeDouble(BytesBuilder output, double value) {
  final data = ByteData(8)..setFloat64(0, value, Endian.little);
  output.add(data.buffer.asUint8List());
}
