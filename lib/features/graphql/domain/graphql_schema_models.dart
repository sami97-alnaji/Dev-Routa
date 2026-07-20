import 'dart:convert';

import 'package:crypto/crypto.dart';

class GraphqlSchemaArgument {
  const GraphqlSchemaArgument({
    required this.name,
    required this.type,
    this.description,
    this.defaultValue,
  });
  final String name;
  final String type;
  final String? description;
  final Object? defaultValue;
  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'type': type,
    if (description != null) 'description': description,
    if (defaultValue != null) 'defaultValue': defaultValue,
  };
}

class GraphqlSchemaField {
  const GraphqlSchemaField({
    required this.name,
    required this.type,
    this.description,
    this.args = const <GraphqlSchemaArgument>[],
    this.isDeprecated = false,
    this.deprecationReason,
  });
  final String name;
  final String type;
  final String? description;
  final List<GraphqlSchemaArgument> args;
  final bool isDeprecated;
  final String? deprecationReason;
  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'type': type,
    'args': args.map((item) => item.toJson()).toList(),
    if (description != null) 'description': description,
    if (isDeprecated) 'isDeprecated': true,
    if (deprecationReason != null) 'deprecationReason': deprecationReason,
  };
}

class GraphqlSchemaType {
  const GraphqlSchemaType({
    required this.name,
    required this.kind,
    this.description,
    this.fields = const <GraphqlSchemaField>[],
    this.enumValues = const <String>[],
    this.interfaces = const <String>[],
  });
  final String name;
  final String kind;
  final String? description;
  final List<GraphqlSchemaField> fields;
  final List<String> enumValues;
  final List<String> interfaces;
  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'kind': kind,
    'fields': fields.map((item) => item.toJson()).toList(),
    'enumValues': enumValues,
    'interfaces': interfaces,
    if (description != null) 'description': description,
  };
}

class GraphqlSchemaSnapshot {
  const GraphqlSchemaSnapshot({
    required this.hash,
    required this.fetchedAt,
    required this.types,
    this.queryRoot,
    this.mutationRoot,
    this.subscriptionRoot,
  });
  final String hash;
  final DateTime fetchedAt;
  final List<GraphqlSchemaType> types;
  final String? queryRoot;
  final String? mutationRoot;
  final String? subscriptionRoot;
  String get safeJson => jsonEncode(<String, Object?>{
    'hash': hash,
    'fetchedAt': fetchedAt.toIso8601String(),
    'queryRoot': queryRoot,
    'mutationRoot': mutationRoot,
    'subscriptionRoot': subscriptionRoot,
    'types': types.map((item) => item.toJson()).toList(),
  });
}

class GraphqlSchemaDiff {
  const GraphqlSchemaDiff({
    this.addedTypes = const <String>[],
    this.removedTypes = const <String>[],
    this.addedFields = const <String>[],
    this.removedFields = const <String>[],
    this.changedFields = const <String>[],
  });
  final List<String> addedTypes;
  final List<String> removedTypes;
  final List<String> addedFields;
  final List<String> removedFields;
  final List<String> changedFields;
  bool get isEmpty =>
      addedTypes.isEmpty &&
      removedTypes.isEmpty &&
      addedFields.isEmpty &&
      removedFields.isEmpty &&
      changedFields.isEmpty;
  String get classification =>
      removedTypes.isNotEmpty ||
          removedFields.isNotEmpty ||
          changedFields.isNotEmpty
      ? 'Breaking candidate'
      : addedTypes.isNotEmpty || addedFields.isNotEmpty
      ? 'Non-breaking candidate'
      : 'Informational';
}

abstract final class GraphqlSchemaTools {
  static GraphqlSchemaSnapshot parse(
    Object? payload, {
    int maxTypes = 1000,
    int maxFields = 10000,
  }) {
    if (payload is! Map) {
      throw const FormatException(
        'Schema introspection payload must be an object.',
      );
    }
    final data = payload['data'];
    final schema = data is Map ? data['__schema'] : null;
    if (schema is! Map) {
      throw const FormatException(
        'Introspection payload does not contain data.__schema.',
      );
    }
    final rawTypes = (schema['types'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .take(maxTypes);
    var fieldCount = 0;
    final types = <GraphqlSchemaType>[];
    for (final item in rawTypes) {
      final fields = <GraphqlSchemaField>[];
      for (final field
          in (item['fields'] as List? ?? const <Object?>[]).whereType<Map>()) {
        if (++fieldCount > maxFields) break;
        fields.add(
          GraphqlSchemaField(
            name: field['name']?.toString() ?? '',
            type: _typeRef(field['type']),
            description: field['description']?.toString(),
            isDeprecated: field['isDeprecated'] == true,
            deprecationReason: field['deprecationReason']?.toString(),
            args: (field['args'] as List? ?? const <Object?>[])
                .whereType<Map>()
                .map(
                  (arg) => GraphqlSchemaArgument(
                    name: arg['name']?.toString() ?? '',
                    type: _typeRef(arg['type']),
                    description: arg['description']?.toString(),
                    defaultValue: arg['defaultValue'],
                  ),
                )
                .toList(growable: false),
          ),
        );
      }
      types.add(
        GraphqlSchemaType(
          name: item['name']?.toString() ?? '',
          kind: item['kind']?.toString() ?? '',
          description: item['description']?.toString(),
          fields: fields,
          enumValues: (item['enumValues'] as List? ?? const <Object?>[])
              .whereType<Map>()
              .map((value) => value['name']?.toString() ?? '')
              .toList(growable: false),
          interfaces: (item['interfaces'] as List? ?? const <Object?>[])
              .whereType<Map>()
              .map((value) => value['name']?.toString() ?? '')
              .toList(growable: false),
        ),
      );
    }
    final normalized = jsonEncode(<String, Object?>{
      'queryType': (schema['queryType'] as Map?)?['name'],
      'mutationType': (schema['mutationType'] as Map?)?['name'],
      'subscriptionType': (schema['subscriptionType'] as Map?)?['name'],
      'types': types.map((item) => item.toJson()).toList(),
    });
    final hash = sha256.convert(utf8.encode(normalized)).toString();
    return GraphqlSchemaSnapshot(
      hash: hash,
      fetchedAt: DateTime.now(),
      types: types,
      queryRoot: (schema['queryType'] as Map?)?['name']?.toString(),
      mutationRoot: (schema['mutationType'] as Map?)?['name']?.toString(),
      subscriptionRoot: (schema['subscriptionType'] as Map?)?['name']
          ?.toString(),
    );
  }

  static GraphqlSchemaDiff compare(
    GraphqlSchemaSnapshot before,
    GraphqlSchemaSnapshot after,
  ) {
    final oldTypes = {for (final type in before.types) type.name: type};
    final newTypes = {for (final type in after.types) type.name: type};
    final addedTypes = newTypes.keys
        .where((name) => !oldTypes.containsKey(name))
        .toList();
    final removedTypes = oldTypes.keys
        .where((name) => !newTypes.containsKey(name))
        .toList();
    final addedFields = <String>[];
    final removedFields = <String>[];
    final changedFields = <String>[];
    for (final name in oldTypes.keys.toSet().intersection(
      newTypes.keys.toSet(),
    )) {
      final oldFields = {
        for (final field in oldTypes[name]!.fields) field.name: field,
      };
      final newFields = {
        for (final field in newTypes[name]!.fields) field.name: field,
      };
      for (final field in newFields.keys.where(
        (key) => !oldFields.containsKey(key),
      )) {
        addedFields.add('$name.$field');
      }
      for (final field in oldFields.keys.where(
        (key) => !newFields.containsKey(key),
      )) {
        removedFields.add('$name.$field');
      }
      for (final field in oldFields.keys.toSet().intersection(
        newFields.keys.toSet(),
      )) {
        if (oldFields[field]!.type != newFields[field]!.type ||
            oldFields[field]!.isDeprecated != newFields[field]!.isDeprecated) {
          changedFields.add('$name.$field');
        }
      }
    }
    return GraphqlSchemaDiff(
      addedTypes: addedTypes,
      removedTypes: removedTypes,
      addedFields: addedFields,
      removedFields: removedFields,
      changedFields: changedFields,
    );
  }

  static String _typeRef(Object? value) {
    if (value is! Map) return 'Unknown';
    final kind = value['kind'];
    if (kind == 'NON_NULL') return '${_typeRef(value['ofType'])}!';
    if (kind == 'LIST') return '[${_typeRef(value['ofType'])}]';
    return value['name']?.toString() ?? 'Unknown';
  }
}
