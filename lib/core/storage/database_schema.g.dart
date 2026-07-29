// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_schema.dart';

// ignore_for_file: type=lint
class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _productionStrictModeMeta =
      const VerificationMeta('productionStrictMode');
  @override
  late final GeneratedColumn<bool> productionStrictMode = GeneratedColumn<bool>(
    'production_strict_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("production_strict_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    sortOrder,
    productionStrictMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('production_strict_mode')) {
      context.handle(
        _productionStrictModeMeta,
        productionStrictMode.isAcceptableOrUnknown(
          data['production_strict_mode']!,
          _productionStrictModeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      productionStrictMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}production_strict_mode'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;
  final bool productionStrictMode;
  const Workspace({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
    required this.productionStrictMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    map['production_strict_mode'] = Variable<bool>(productionStrictMode);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sortOrder: Value(sortOrder),
      productionStrictMode: Value(productionStrictMode),
    );
  }

  factory Workspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      productionStrictMode: serializer.fromJson<bool>(
        json['productionStrictMode'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'productionStrictMode': serializer.toJson<bool>(productionStrictMode),
    };
  }

  Workspace copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
    bool? productionStrictMode,
  }) => Workspace(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sortOrder: sortOrder ?? this.sortOrder,
    productionStrictMode: productionStrictMode ?? this.productionStrictMode,
  );
  Workspace copyWithCompanion(WorkspacesCompanion data) {
    return Workspace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      productionStrictMode: data.productionStrictMode.present
          ? data.productionStrictMode.value
          : this.productionStrictMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('productionStrictMode: $productionStrictMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    updatedAt,
    sortOrder,
    productionStrictMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sortOrder == this.sortOrder &&
          other.productionStrictMode == this.productionStrictMode);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> sortOrder;
  final Value<bool> productionStrictMode;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.productionStrictMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sortOrder = const Value.absent(),
    this.productionStrictMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Workspace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? sortOrder,
    Expression<bool>? productionStrictMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (productionStrictMode != null)
        'production_strict_mode': productionStrictMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? sortOrder,
    Value<bool>? productionStrictMode,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      productionStrictMode: productionStrictMode ?? this.productionStrictMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (productionStrictMode.present) {
      map['production_strict_mode'] = Variable<bool>(
        productionStrictMode.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('productionStrictMode: $productionStrictMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    name,
    createdAt,
    updatedAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String workspaceId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;
  const Collection({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Collection copyWith({
    String? id,
    String? workspaceId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) => Collection(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workspaceId, name, createdAt, updatedAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sortOrder == this.sortOrder);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String workspaceId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parentFolderIdMeta = const VerificationMeta(
    'parentFolderId',
  );
  @override
  late final GeneratedColumn<String> parentFolderId = GeneratedColumn<String>(
    'parent_folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    name,
    createdAt,
    updatedAt,
    sortOrder,
    parentFolderId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('parent_folder_id')) {
      context.handle(
        _parentFolderIdMeta,
        parentFolderId.isAcceptableOrUnknown(
          data['parent_folder_id']!,
          _parentFolderIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      parentFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_folder_id'],
      ),
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String collectionId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;
  final String? parentFolderId;
  const Folder({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
    this.parentFolderId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || parentFolderId != null) {
      map['parent_folder_id'] = Variable<String>(parentFolderId);
    }
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sortOrder: Value(sortOrder),
      parentFolderId: parentFolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentFolderId),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      parentFolderId: serializer.fromJson<String?>(json['parentFolderId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'parentFolderId': serializer.toJson<String?>(parentFolderId),
    };
  }

  Folder copyWith({
    String? id,
    String? collectionId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
    Value<String?> parentFolderId = const Value.absent(),
  }) => Folder(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sortOrder: sortOrder ?? this.sortOrder,
    parentFolderId: parentFolderId.present
        ? parentFolderId.value
        : this.parentFolderId,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      parentFolderId: data.parentFolderId.present
          ? data.parentFolderId.value
          : this.parentFolderId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('parentFolderId: $parentFolderId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    collectionId,
    name,
    createdAt,
    updatedAt,
    sortOrder,
    parentFolderId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sortOrder == this.sortOrder &&
          other.parentFolderId == this.parentFolderId);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> sortOrder;
  final Value<String?> parentFolderId;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.parentFolderId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String collectionId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sortOrder = const Value.absent(),
    this.parentFolderId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? sortOrder,
    Expression<String>? parentFolderId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (parentFolderId != null) 'parent_folder_id': parentFolderId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? sortOrder,
    Value<String?>? parentFolderId,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (parentFolderId.present) {
      map['parent_folder_id'] = Variable<String>(parentFolderId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('parentFolderId: $parentFolderId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestsTable extends Requests with TableInfo<$RequestsTable, Request> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    folderId,
    name,
    method,
    url,
    createdAt,
    updatedAt,
    sortOrder,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<Request> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Request map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Request(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $RequestsTable createAlias(String alias) {
    return $RequestsTable(attachedDatabase, alias);
  }
}

class Request extends DataClass implements Insertable<Request> {
  final String id;
  final String? collectionId;
  final String? folderId;
  final String name;
  final String method;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;
  final String payloadJson;
  const Request({
    required this.id,
    this.collectionId,
    this.folderId,
    required this.name,
    required this.method,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['name'] = Variable<String>(name);
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  RequestsCompanion toCompanion(bool nullToAbsent) {
    return RequestsCompanion(
      id: Value(id),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      name: Value(name),
      method: Value(method),
      url: Value(url),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sortOrder: Value(sortOrder),
      payloadJson: Value(payloadJson),
    );
  }

  factory Request.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Request(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      name: serializer.fromJson<String>(json['name']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String?>(collectionId),
      'folderId': serializer.toJson<String?>(folderId),
      'name': serializer.toJson<String>(name),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  Request copyWith({
    String? id,
    Value<String?> collectionId = const Value.absent(),
    Value<String?> folderId = const Value.absent(),
    String? name,
    String? method,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
    String? payloadJson,
  }) => Request(
    id: id ?? this.id,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    folderId: folderId.present ? folderId.value : this.folderId,
    name: name ?? this.name,
    method: method ?? this.method,
    url: url ?? this.url,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sortOrder: sortOrder ?? this.sortOrder,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  Request copyWithCompanion(RequestsCompanion data) {
    return Request(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      name: data.name.present ? data.name.value : this.name,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Request(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    collectionId,
    folderId,
    name,
    method,
    url,
    createdAt,
    updatedAt,
    sortOrder,
    payloadJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Request &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.folderId == this.folderId &&
          other.name == this.name &&
          other.method == this.method &&
          other.url == this.url &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sortOrder == this.sortOrder &&
          other.payloadJson == this.payloadJson);
}

class RequestsCompanion extends UpdateCompanion<Request> {
  final Value<String> id;
  final Value<String?> collectionId;
  final Value<String?> folderId;
  final Value<String> name;
  final Value<String> method;
  final Value<String> url;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> sortOrder;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const RequestsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.name = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestsCompanion.insert({
    required String id,
    this.collectionId = const Value.absent(),
    this.folderId = const Value.absent(),
    required String name,
    required String method,
    required String url,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sortOrder = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       method = Value(method),
       url = Value(url),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Request> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? folderId,
    Expression<String>? name,
    Expression<String>? method,
    Expression<String>? url,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? sortOrder,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (folderId != null) 'folder_id': folderId,
      if (name != null) 'name': name,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestsCompanion copyWith({
    Value<String>? id,
    Value<String?>? collectionId,
    Value<String?>? folderId,
    Value<String>? name,
    Value<String>? method,
    Value<String>? url,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? sortOrder,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return RequestsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      method: method ?? this.method,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestHeadersTable extends RequestHeaders
    with TableInfo<$RequestHeadersTable, RequestHeader> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestHeadersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueOrSecretRefMeta = const VerificationMeta(
    'valueOrSecretRef',
  );
  @override
  late final GeneratedColumn<String> valueOrSecretRef = GeneratedColumn<String>(
    'value_or_secret_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSecretMeta = const VerificationMeta(
    'isSecret',
  );
  @override
  late final GeneratedColumn<bool> isSecret = GeneratedColumn<bool>(
    'is_secret',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_secret" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestId,
    name,
    valueOrSecretRef,
    isSecret,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request_headers';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestHeader> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value_or_secret_ref')) {
      context.handle(
        _valueOrSecretRefMeta,
        valueOrSecretRef.isAcceptableOrUnknown(
          data['value_or_secret_ref']!,
          _valueOrSecretRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueOrSecretRefMeta);
    }
    if (data.containsKey('is_secret')) {
      context.handle(
        _isSecretMeta,
        isSecret.isAcceptableOrUnknown(data['is_secret']!, _isSecretMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestHeader map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestHeader(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      valueOrSecretRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_or_secret_ref'],
      )!,
      isSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_secret'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $RequestHeadersTable createAlias(String alias) {
    return $RequestHeadersTable(attachedDatabase, alias);
  }
}

class RequestHeader extends DataClass implements Insertable<RequestHeader> {
  final String id;
  final String requestId;
  final String name;
  final String valueOrSecretRef;
  final bool isSecret;
  final bool enabled;
  const RequestHeader({
    required this.id,
    required this.requestId,
    required this.name,
    required this.valueOrSecretRef,
    required this.isSecret,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_id'] = Variable<String>(requestId);
    map['name'] = Variable<String>(name);
    map['value_or_secret_ref'] = Variable<String>(valueOrSecretRef);
    map['is_secret'] = Variable<bool>(isSecret);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  RequestHeadersCompanion toCompanion(bool nullToAbsent) {
    return RequestHeadersCompanion(
      id: Value(id),
      requestId: Value(requestId),
      name: Value(name),
      valueOrSecretRef: Value(valueOrSecretRef),
      isSecret: Value(isSecret),
      enabled: Value(enabled),
    );
  }

  factory RequestHeader.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestHeader(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String>(json['requestId']),
      name: serializer.fromJson<String>(json['name']),
      valueOrSecretRef: serializer.fromJson<String>(json['valueOrSecretRef']),
      isSecret: serializer.fromJson<bool>(json['isSecret']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String>(requestId),
      'name': serializer.toJson<String>(name),
      'valueOrSecretRef': serializer.toJson<String>(valueOrSecretRef),
      'isSecret': serializer.toJson<bool>(isSecret),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  RequestHeader copyWith({
    String? id,
    String? requestId,
    String? name,
    String? valueOrSecretRef,
    bool? isSecret,
    bool? enabled,
  }) => RequestHeader(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    name: name ?? this.name,
    valueOrSecretRef: valueOrSecretRef ?? this.valueOrSecretRef,
    isSecret: isSecret ?? this.isSecret,
    enabled: enabled ?? this.enabled,
  );
  RequestHeader copyWithCompanion(RequestHeadersCompanion data) {
    return RequestHeader(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      name: data.name.present ? data.name.value : this.name,
      valueOrSecretRef: data.valueOrSecretRef.present
          ? data.valueOrSecretRef.value
          : this.valueOrSecretRef,
      isSecret: data.isSecret.present ? data.isSecret.value : this.isSecret,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestHeader(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('name: $name, ')
          ..write('valueOrSecretRef: $valueOrSecretRef, ')
          ..write('isSecret: $isSecret, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, requestId, name, valueOrSecretRef, isSecret, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestHeader &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.name == this.name &&
          other.valueOrSecretRef == this.valueOrSecretRef &&
          other.isSecret == this.isSecret &&
          other.enabled == this.enabled);
}

class RequestHeadersCompanion extends UpdateCompanion<RequestHeader> {
  final Value<String> id;
  final Value<String> requestId;
  final Value<String> name;
  final Value<String> valueOrSecretRef;
  final Value<bool> isSecret;
  final Value<bool> enabled;
  final Value<int> rowid;
  const RequestHeadersCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.name = const Value.absent(),
    this.valueOrSecretRef = const Value.absent(),
    this.isSecret = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestHeadersCompanion.insert({
    required String id,
    required String requestId,
    required String name,
    required String valueOrSecretRef,
    this.isSecret = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       requestId = Value(requestId),
       name = Value(name),
       valueOrSecretRef = Value(valueOrSecretRef);
  static Insertable<RequestHeader> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<String>? name,
    Expression<String>? valueOrSecretRef,
    Expression<bool>? isSecret,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (name != null) 'name': name,
      if (valueOrSecretRef != null) 'value_or_secret_ref': valueOrSecretRef,
      if (isSecret != null) 'is_secret': isSecret,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestHeadersCompanion copyWith({
    Value<String>? id,
    Value<String>? requestId,
    Value<String>? name,
    Value<String>? valueOrSecretRef,
    Value<bool>? isSecret,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return RequestHeadersCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      name: name ?? this.name,
      valueOrSecretRef: valueOrSecretRef ?? this.valueOrSecretRef,
      isSecret: isSecret ?? this.isSecret,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (valueOrSecretRef.present) {
      map['value_or_secret_ref'] = Variable<String>(valueOrSecretRef.value);
    }
    if (isSecret.present) {
      map['is_secret'] = Variable<bool>(isSecret.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestHeadersCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('name: $name, ')
          ..write('valueOrSecretRef: $valueOrSecretRef, ')
          ..write('isSecret: $isSecret, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestQueryParamsTable extends RequestQueryParams
    with TableInfo<$RequestQueryParamsTable, RequestQueryParam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestQueryParamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, requestId, name, value, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request_query_params';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestQueryParam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestQueryParam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestQueryParam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $RequestQueryParamsTable createAlias(String alias) {
    return $RequestQueryParamsTable(attachedDatabase, alias);
  }
}

class RequestQueryParam extends DataClass
    implements Insertable<RequestQueryParam> {
  final String id;
  final String requestId;
  final String name;
  final String value;
  final bool enabled;
  const RequestQueryParam({
    required this.id,
    required this.requestId,
    required this.name,
    required this.value,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_id'] = Variable<String>(requestId);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  RequestQueryParamsCompanion toCompanion(bool nullToAbsent) {
    return RequestQueryParamsCompanion(
      id: Value(id),
      requestId: Value(requestId),
      name: Value(name),
      value: Value(value),
      enabled: Value(enabled),
    );
  }

  factory RequestQueryParam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestQueryParam(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String>(json['requestId']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String>(requestId),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  RequestQueryParam copyWith({
    String? id,
    String? requestId,
    String? name,
    String? value,
    bool? enabled,
  }) => RequestQueryParam(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    name: name ?? this.name,
    value: value ?? this.value,
    enabled: enabled ?? this.enabled,
  );
  RequestQueryParam copyWithCompanion(RequestQueryParamsCompanion data) {
    return RequestQueryParam(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestQueryParam(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, requestId, name, value, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestQueryParam &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.name == this.name &&
          other.value == this.value &&
          other.enabled == this.enabled);
}

class RequestQueryParamsCompanion extends UpdateCompanion<RequestQueryParam> {
  final Value<String> id;
  final Value<String> requestId;
  final Value<String> name;
  final Value<String> value;
  final Value<bool> enabled;
  final Value<int> rowid;
  const RequestQueryParamsCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestQueryParamsCompanion.insert({
    required String id,
    required String requestId,
    required String name,
    required String value,
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       requestId = Value(requestId),
       name = Value(name),
       value = Value(value);
  static Insertable<RequestQueryParam> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<String>? name,
    Expression<String>? value,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestQueryParamsCompanion copyWith({
    Value<String>? id,
    Value<String>? requestId,
    Value<String>? name,
    Value<String>? value,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return RequestQueryParamsCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      name: name ?? this.name,
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestQueryParamsCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestBodiesTable extends RequestBodies
    with TableInfo<$RequestBodiesTable, RequestBody> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestBodiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentOrSecretRefMeta =
      const VerificationMeta('contentOrSecretRef');
  @override
  late final GeneratedColumn<String> contentOrSecretRef =
      GeneratedColumn<String>(
        'content_or_secret_ref',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestId,
    type,
    contentOrSecretRef,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request_bodies';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestBody> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content_or_secret_ref')) {
      context.handle(
        _contentOrSecretRefMeta,
        contentOrSecretRef.isAcceptableOrUnknown(
          data['content_or_secret_ref']!,
          _contentOrSecretRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentOrSecretRefMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestBody map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestBody(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      contentOrSecretRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_or_secret_ref'],
      )!,
    );
  }

  @override
  $RequestBodiesTable createAlias(String alias) {
    return $RequestBodiesTable(attachedDatabase, alias);
  }
}

class RequestBody extends DataClass implements Insertable<RequestBody> {
  final String id;
  final String requestId;
  final String type;
  final String contentOrSecretRef;
  const RequestBody({
    required this.id,
    required this.requestId,
    required this.type,
    required this.contentOrSecretRef,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_id'] = Variable<String>(requestId);
    map['type'] = Variable<String>(type);
    map['content_or_secret_ref'] = Variable<String>(contentOrSecretRef);
    return map;
  }

  RequestBodiesCompanion toCompanion(bool nullToAbsent) {
    return RequestBodiesCompanion(
      id: Value(id),
      requestId: Value(requestId),
      type: Value(type),
      contentOrSecretRef: Value(contentOrSecretRef),
    );
  }

  factory RequestBody.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestBody(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String>(json['requestId']),
      type: serializer.fromJson<String>(json['type']),
      contentOrSecretRef: serializer.fromJson<String>(
        json['contentOrSecretRef'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String>(requestId),
      'type': serializer.toJson<String>(type),
      'contentOrSecretRef': serializer.toJson<String>(contentOrSecretRef),
    };
  }

  RequestBody copyWith({
    String? id,
    String? requestId,
    String? type,
    String? contentOrSecretRef,
  }) => RequestBody(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    type: type ?? this.type,
    contentOrSecretRef: contentOrSecretRef ?? this.contentOrSecretRef,
  );
  RequestBody copyWithCompanion(RequestBodiesCompanion data) {
    return RequestBody(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      type: data.type.present ? data.type.value : this.type,
      contentOrSecretRef: data.contentOrSecretRef.present
          ? data.contentOrSecretRef.value
          : this.contentOrSecretRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestBody(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('type: $type, ')
          ..write('contentOrSecretRef: $contentOrSecretRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, requestId, type, contentOrSecretRef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestBody &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.type == this.type &&
          other.contentOrSecretRef == this.contentOrSecretRef);
}

class RequestBodiesCompanion extends UpdateCompanion<RequestBody> {
  final Value<String> id;
  final Value<String> requestId;
  final Value<String> type;
  final Value<String> contentOrSecretRef;
  final Value<int> rowid;
  const RequestBodiesCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.type = const Value.absent(),
    this.contentOrSecretRef = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestBodiesCompanion.insert({
    required String id,
    required String requestId,
    required String type,
    required String contentOrSecretRef,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       requestId = Value(requestId),
       type = Value(type),
       contentOrSecretRef = Value(contentOrSecretRef);
  static Insertable<RequestBody> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<String>? type,
    Expression<String>? contentOrSecretRef,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (type != null) 'type': type,
      if (contentOrSecretRef != null)
        'content_or_secret_ref': contentOrSecretRef,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestBodiesCompanion copyWith({
    Value<String>? id,
    Value<String>? requestId,
    Value<String>? type,
    Value<String>? contentOrSecretRef,
    Value<int>? rowid,
  }) {
    return RequestBodiesCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      type: type ?? this.type,
      contentOrSecretRef: contentOrSecretRef ?? this.contentOrSecretRef,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (contentOrSecretRef.present) {
      map['content_or_secret_ref'] = Variable<String>(contentOrSecretRef.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestBodiesCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('type: $type, ')
          ..write('contentOrSecretRef: $contentOrSecretRef, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentsTable extends Environments
    with TableInfo<$EnvironmentsTable, Environment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    workspaceId,
    kind,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Environment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Environment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Environment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $EnvironmentsTable createAlias(String alias) {
    return $EnvironmentsTable(attachedDatabase, alias);
  }
}

class Environment extends DataClass implements Insertable<Environment> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? workspaceId;
  final String kind;
  final bool isActive;
  const Environment({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.workspaceId,
    required this.kind,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    map['kind'] = Variable<String>(kind);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  EnvironmentsCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
      kind: Value(kind),
      isActive: Value(isActive),
    );
  }

  factory Environment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Environment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
      kind: serializer.fromJson<String>(json['kind']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String?>(workspaceId),
      'kind': serializer.toJson<String>(kind),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Environment copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> workspaceId = const Value.absent(),
    String? kind,
    bool? isActive,
  }) => Environment(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
    kind: kind ?? this.kind,
    isActive: isActive ?? this.isActive,
  );
  Environment copyWithCompanion(EnvironmentsCompanion data) {
    return Environment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Environment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('kind: $kind, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, createdAt, updatedAt, workspaceId, kind, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Environment &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.kind == this.kind &&
          other.isActive == this.isActive);
}

class EnvironmentsCompanion extends UpdateCompanion<Environment> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> workspaceId;
  final Value<String> kind;
  final Value<bool> isActive;
  final Value<int> rowid;
  const EnvironmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvironmentsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.workspaceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Environment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? kind,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (kind != null) 'kind': kind,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvironmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? workspaceId,
    Value<String>? kind,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return EnvironmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      kind: kind ?? this.kind,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('kind: $kind, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentVariablesTable extends EnvironmentVariables
    with TableInfo<$EnvironmentVariablesTable, EnvironmentVariable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentVariablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<String> environmentId = GeneratedColumn<String>(
    'environment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueOrSecretRefMeta = const VerificationMeta(
    'valueOrSecretRef',
  );
  @override
  late final GeneratedColumn<String> valueOrSecretRef = GeneratedColumn<String>(
    'value_or_secret_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSecretMeta = const VerificationMeta(
    'isSecret',
  );
  @override
  late final GeneratedColumn<bool> isSecret = GeneratedColumn<bool>(
    'is_secret',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_secret" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    environmentId,
    name,
    valueOrSecretRef,
    isSecret,
    enabled,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environment_variables';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvironmentVariable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value_or_secret_ref')) {
      context.handle(
        _valueOrSecretRefMeta,
        valueOrSecretRef.isAcceptableOrUnknown(
          data['value_or_secret_ref']!,
          _valueOrSecretRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueOrSecretRefMeta);
    }
    if (data.containsKey('is_secret')) {
      context.handle(
        _isSecretMeta,
        isSecret.isAcceptableOrUnknown(data['is_secret']!, _isSecretMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvironmentVariable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvironmentVariable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      valueOrSecretRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_or_secret_ref'],
      )!,
      isSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_secret'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $EnvironmentVariablesTable createAlias(String alias) {
    return $EnvironmentVariablesTable(attachedDatabase, alias);
  }
}

class EnvironmentVariable extends DataClass
    implements Insertable<EnvironmentVariable> {
  final String id;
  final String environmentId;
  final String name;
  final String valueOrSecretRef;
  final bool isSecret;
  final bool enabled;
  final int sortOrder;
  const EnvironmentVariable({
    required this.id,
    required this.environmentId,
    required this.name,
    required this.valueOrSecretRef,
    required this.isSecret,
    required this.enabled,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['environment_id'] = Variable<String>(environmentId);
    map['name'] = Variable<String>(name);
    map['value_or_secret_ref'] = Variable<String>(valueOrSecretRef);
    map['is_secret'] = Variable<bool>(isSecret);
    map['enabled'] = Variable<bool>(enabled);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  EnvironmentVariablesCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentVariablesCompanion(
      id: Value(id),
      environmentId: Value(environmentId),
      name: Value(name),
      valueOrSecretRef: Value(valueOrSecretRef),
      isSecret: Value(isSecret),
      enabled: Value(enabled),
      sortOrder: Value(sortOrder),
    );
  }

  factory EnvironmentVariable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvironmentVariable(
      id: serializer.fromJson<String>(json['id']),
      environmentId: serializer.fromJson<String>(json['environmentId']),
      name: serializer.fromJson<String>(json['name']),
      valueOrSecretRef: serializer.fromJson<String>(json['valueOrSecretRef']),
      isSecret: serializer.fromJson<bool>(json['isSecret']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'environmentId': serializer.toJson<String>(environmentId),
      'name': serializer.toJson<String>(name),
      'valueOrSecretRef': serializer.toJson<String>(valueOrSecretRef),
      'isSecret': serializer.toJson<bool>(isSecret),
      'enabled': serializer.toJson<bool>(enabled),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  EnvironmentVariable copyWith({
    String? id,
    String? environmentId,
    String? name,
    String? valueOrSecretRef,
    bool? isSecret,
    bool? enabled,
    int? sortOrder,
  }) => EnvironmentVariable(
    id: id ?? this.id,
    environmentId: environmentId ?? this.environmentId,
    name: name ?? this.name,
    valueOrSecretRef: valueOrSecretRef ?? this.valueOrSecretRef,
    isSecret: isSecret ?? this.isSecret,
    enabled: enabled ?? this.enabled,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  EnvironmentVariable copyWithCompanion(EnvironmentVariablesCompanion data) {
    return EnvironmentVariable(
      id: data.id.present ? data.id.value : this.id,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      name: data.name.present ? data.name.value : this.name,
      valueOrSecretRef: data.valueOrSecretRef.present
          ? data.valueOrSecretRef.value
          : this.valueOrSecretRef,
      isSecret: data.isSecret.present ? data.isSecret.value : this.isSecret,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentVariable(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('name: $name, ')
          ..write('valueOrSecretRef: $valueOrSecretRef, ')
          ..write('isSecret: $isSecret, ')
          ..write('enabled: $enabled, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    environmentId,
    name,
    valueOrSecretRef,
    isSecret,
    enabled,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvironmentVariable &&
          other.id == this.id &&
          other.environmentId == this.environmentId &&
          other.name == this.name &&
          other.valueOrSecretRef == this.valueOrSecretRef &&
          other.isSecret == this.isSecret &&
          other.enabled == this.enabled &&
          other.sortOrder == this.sortOrder);
}

class EnvironmentVariablesCompanion
    extends UpdateCompanion<EnvironmentVariable> {
  final Value<String> id;
  final Value<String> environmentId;
  final Value<String> name;
  final Value<String> valueOrSecretRef;
  final Value<bool> isSecret;
  final Value<bool> enabled;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const EnvironmentVariablesCompanion({
    this.id = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.name = const Value.absent(),
    this.valueOrSecretRef = const Value.absent(),
    this.isSecret = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvironmentVariablesCompanion.insert({
    required String id,
    required String environmentId,
    required String name,
    required String valueOrSecretRef,
    this.isSecret = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       environmentId = Value(environmentId),
       name = Value(name),
       valueOrSecretRef = Value(valueOrSecretRef);
  static Insertable<EnvironmentVariable> custom({
    Expression<String>? id,
    Expression<String>? environmentId,
    Expression<String>? name,
    Expression<String>? valueOrSecretRef,
    Expression<bool>? isSecret,
    Expression<bool>? enabled,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (environmentId != null) 'environment_id': environmentId,
      if (name != null) 'name': name,
      if (valueOrSecretRef != null) 'value_or_secret_ref': valueOrSecretRef,
      if (isSecret != null) 'is_secret': isSecret,
      if (enabled != null) 'enabled': enabled,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvironmentVariablesCompanion copyWith({
    Value<String>? id,
    Value<String>? environmentId,
    Value<String>? name,
    Value<String>? valueOrSecretRef,
    Value<bool>? isSecret,
    Value<bool>? enabled,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return EnvironmentVariablesCompanion(
      id: id ?? this.id,
      environmentId: environmentId ?? this.environmentId,
      name: name ?? this.name,
      valueOrSecretRef: valueOrSecretRef ?? this.valueOrSecretRef,
      isSecret: isSecret ?? this.isSecret,
      enabled: enabled ?? this.enabled,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<String>(environmentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (valueOrSecretRef.present) {
      map['value_or_secret_ref'] = Variable<String>(valueOrSecretRef.value);
    }
    if (isSecret.present) {
      map['is_secret'] = Variable<bool>(isSecret.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentVariablesCompanion(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('name: $name, ')
          ..write('valueOrSecretRef: $valueOrSecretRef, ')
          ..write('isSecret: $isSecret, ')
          ..write('enabled: $enabled, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestHistoryTable extends RequestHistory
    with TableInfo<$RequestHistoryTable, RequestHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseSnapshotIdMeta =
      const VerificationMeta('responseSnapshotId');
  @override
  late final GeneratedColumn<String> responseSnapshotId =
      GeneratedColumn<String>(
        'response_snapshot_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestId,
    responseSnapshotId,
    createdAt,
    snapshotJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('response_snapshot_id')) {
      context.handle(
        _responseSnapshotIdMeta,
        responseSnapshotId.isAcceptableOrUnknown(
          data['response_snapshot_id']!,
          _responseSnapshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseSnapshotIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      responseSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_snapshot_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
    );
  }

  @override
  $RequestHistoryTable createAlias(String alias) {
    return $RequestHistoryTable(attachedDatabase, alias);
  }
}

class RequestHistoryData extends DataClass
    implements Insertable<RequestHistoryData> {
  final String id;
  final String requestId;
  final String responseSnapshotId;
  final DateTime createdAt;
  final String snapshotJson;
  const RequestHistoryData({
    required this.id,
    required this.requestId,
    required this.responseSnapshotId,
    required this.createdAt,
    required this.snapshotJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_id'] = Variable<String>(requestId);
    map['response_snapshot_id'] = Variable<String>(responseSnapshotId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    return map;
  }

  RequestHistoryCompanion toCompanion(bool nullToAbsent) {
    return RequestHistoryCompanion(
      id: Value(id),
      requestId: Value(requestId),
      responseSnapshotId: Value(responseSnapshotId),
      createdAt: Value(createdAt),
      snapshotJson: Value(snapshotJson),
    );
  }

  factory RequestHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestHistoryData(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String>(json['requestId']),
      responseSnapshotId: serializer.fromJson<String>(
        json['responseSnapshotId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String>(requestId),
      'responseSnapshotId': serializer.toJson<String>(responseSnapshotId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
    };
  }

  RequestHistoryData copyWith({
    String? id,
    String? requestId,
    String? responseSnapshotId,
    DateTime? createdAt,
    String? snapshotJson,
  }) => RequestHistoryData(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    responseSnapshotId: responseSnapshotId ?? this.responseSnapshotId,
    createdAt: createdAt ?? this.createdAt,
    snapshotJson: snapshotJson ?? this.snapshotJson,
  );
  RequestHistoryData copyWithCompanion(RequestHistoryCompanion data) {
    return RequestHistoryData(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      responseSnapshotId: data.responseSnapshotId.present
          ? data.responseSnapshotId.value
          : this.responseSnapshotId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestHistoryData(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('responseSnapshotId: $responseSnapshotId, ')
          ..write('createdAt: $createdAt, ')
          ..write('snapshotJson: $snapshotJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, requestId, responseSnapshotId, createdAt, snapshotJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestHistoryData &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.responseSnapshotId == this.responseSnapshotId &&
          other.createdAt == this.createdAt &&
          other.snapshotJson == this.snapshotJson);
}

class RequestHistoryCompanion extends UpdateCompanion<RequestHistoryData> {
  final Value<String> id;
  final Value<String> requestId;
  final Value<String> responseSnapshotId;
  final Value<DateTime> createdAt;
  final Value<String> snapshotJson;
  final Value<int> rowid;
  const RequestHistoryCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.responseSnapshotId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestHistoryCompanion.insert({
    required String id,
    required String requestId,
    required String responseSnapshotId,
    required DateTime createdAt,
    this.snapshotJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       requestId = Value(requestId),
       responseSnapshotId = Value(responseSnapshotId),
       createdAt = Value(createdAt);
  static Insertable<RequestHistoryData> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<String>? responseSnapshotId,
    Expression<DateTime>? createdAt,
    Expression<String>? snapshotJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (responseSnapshotId != null)
        'response_snapshot_id': responseSnapshotId,
      if (createdAt != null) 'created_at': createdAt,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? requestId,
    Value<String>? responseSnapshotId,
    Value<DateTime>? createdAt,
    Value<String>? snapshotJson,
    Value<int>? rowid,
  }) {
    return RequestHistoryCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      responseSnapshotId: responseSnapshotId ?? this.responseSnapshotId,
      createdAt: createdAt ?? this.createdAt,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (responseSnapshotId.present) {
      map['response_snapshot_id'] = Variable<String>(responseSnapshotId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestHistoryCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('responseSnapshotId: $responseSnapshotId, ')
          ..write('createdAt: $createdAt, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResponseSnapshotsTable extends ResponseSnapshots
    with TableInfo<$ResponseSnapshotsTable, ResponseSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResponseSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyPreviewMeta = const VerificationMeta(
    'bodyPreview',
  );
  @override
  late final GeneratedColumn<String> bodyPreview = GeneratedColumn<String>(
    'body_preview',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestId,
    statusCode,
    bodyPreview,
    durationMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'response_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResponseSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    }
    if (data.containsKey('body_preview')) {
      context.handle(
        _bodyPreviewMeta,
        bodyPreview.isAcceptableOrUnknown(
          data['body_preview']!,
          _bodyPreviewMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodyPreviewMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResponseSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResponseSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      ),
      bodyPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_preview'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ResponseSnapshotsTable createAlias(String alias) {
    return $ResponseSnapshotsTable(attachedDatabase, alias);
  }
}

class ResponseSnapshot extends DataClass
    implements Insertable<ResponseSnapshot> {
  final String id;
  final String requestId;
  final int? statusCode;
  final String bodyPreview;
  final int durationMs;
  final DateTime createdAt;
  const ResponseSnapshot({
    required this.id,
    required this.requestId,
    this.statusCode,
    required this.bodyPreview,
    required this.durationMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_id'] = Variable<String>(requestId);
    if (!nullToAbsent || statusCode != null) {
      map['status_code'] = Variable<int>(statusCode);
    }
    map['body_preview'] = Variable<String>(bodyPreview);
    map['duration_ms'] = Variable<int>(durationMs);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ResponseSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ResponseSnapshotsCompanion(
      id: Value(id),
      requestId: Value(requestId),
      statusCode: statusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusCode),
      bodyPreview: Value(bodyPreview),
      durationMs: Value(durationMs),
      createdAt: Value(createdAt),
    );
  }

  factory ResponseSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResponseSnapshot(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String>(json['requestId']),
      statusCode: serializer.fromJson<int?>(json['statusCode']),
      bodyPreview: serializer.fromJson<String>(json['bodyPreview']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String>(requestId),
      'statusCode': serializer.toJson<int?>(statusCode),
      'bodyPreview': serializer.toJson<String>(bodyPreview),
      'durationMs': serializer.toJson<int>(durationMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ResponseSnapshot copyWith({
    String? id,
    String? requestId,
    Value<int?> statusCode = const Value.absent(),
    String? bodyPreview,
    int? durationMs,
    DateTime? createdAt,
  }) => ResponseSnapshot(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    statusCode: statusCode.present ? statusCode.value : this.statusCode,
    bodyPreview: bodyPreview ?? this.bodyPreview,
    durationMs: durationMs ?? this.durationMs,
    createdAt: createdAt ?? this.createdAt,
  );
  ResponseSnapshot copyWithCompanion(ResponseSnapshotsCompanion data) {
    return ResponseSnapshot(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      bodyPreview: data.bodyPreview.present
          ? data.bodyPreview.value
          : this.bodyPreview,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResponseSnapshot(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('statusCode: $statusCode, ')
          ..write('bodyPreview: $bodyPreview, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    requestId,
    statusCode,
    bodyPreview,
    durationMs,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResponseSnapshot &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.statusCode == this.statusCode &&
          other.bodyPreview == this.bodyPreview &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt);
}

class ResponseSnapshotsCompanion extends UpdateCompanion<ResponseSnapshot> {
  final Value<String> id;
  final Value<String> requestId;
  final Value<int?> statusCode;
  final Value<String> bodyPreview;
  final Value<int> durationMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ResponseSnapshotsCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.bodyPreview = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResponseSnapshotsCompanion.insert({
    required String id,
    required String requestId,
    this.statusCode = const Value.absent(),
    required String bodyPreview,
    required int durationMs,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       requestId = Value(requestId),
       bodyPreview = Value(bodyPreview),
       durationMs = Value(durationMs),
       createdAt = Value(createdAt);
  static Insertable<ResponseSnapshot> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<int>? statusCode,
    Expression<String>? bodyPreview,
    Expression<int>? durationMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (statusCode != null) 'status_code': statusCode,
      if (bodyPreview != null) 'body_preview': bodyPreview,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResponseSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? requestId,
    Value<int?>? statusCode,
    Value<String>? bodyPreview,
    Value<int>? durationMs,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ResponseSnapshotsCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      statusCode: statusCode ?? this.statusCode,
      bodyPreview: bodyPreview ?? this.bodyPreview,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (bodyPreview.present) {
      map['body_preview'] = Variable<String>(bodyPreview.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResponseSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('statusCode: $statusCode, ')
          ..write('bodyPreview: $bodyPreview, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WebSocketSessionsTable extends WebSocketSessions
    with TableInfo<$WebSocketSessionsTable, WebSocketSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WebSocketSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, url, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'web_socket_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WebSocketSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WebSocketSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WebSocketSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WebSocketSessionsTable createAlias(String alias) {
    return $WebSocketSessionsTable(attachedDatabase, alias);
  }
}

class WebSocketSession extends DataClass
    implements Insertable<WebSocketSession> {
  final String id;
  final String url;
  final DateTime createdAt;
  const WebSocketSession({
    required this.id,
    required this.url,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WebSocketSessionsCompanion toCompanion(bool nullToAbsent) {
    return WebSocketSessionsCompanion(
      id: Value(id),
      url: Value(url),
      createdAt: Value(createdAt),
    );
  }

  factory WebSocketSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WebSocketSession(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WebSocketSession copyWith({String? id, String? url, DateTime? createdAt}) =>
      WebSocketSession(
        id: id ?? this.id,
        url: url ?? this.url,
        createdAt: createdAt ?? this.createdAt,
      );
  WebSocketSession copyWithCompanion(WebSocketSessionsCompanion data) {
    return WebSocketSession(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WebSocketSession(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WebSocketSession &&
          other.id == this.id &&
          other.url == this.url &&
          other.createdAt == this.createdAt);
}

class WebSocketSessionsCompanion extends UpdateCompanion<WebSocketSession> {
  final Value<String> id;
  final Value<String> url;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WebSocketSessionsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WebSocketSessionsCompanion.insert({
    required String id,
    required String url,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url),
       createdAt = Value(createdAt);
  static Insertable<WebSocketSession> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WebSocketSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WebSocketSessionsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WebSocketSessionsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiAnalysesTable extends AiAnalyses
    with TableInfo<$AiAnalysesTable, AiAnalyse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiAnalysesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseSnapshotIdMeta =
      const VerificationMeta('responseSnapshotId');
  @override
  late final GeneratedColumn<String> responseSnapshotId =
      GeneratedColumn<String>(
        'response_snapshot_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    responseSnapshotId,
    summary,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_analyses';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiAnalyse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('response_snapshot_id')) {
      context.handle(
        _responseSnapshotIdMeta,
        responseSnapshotId.isAcceptableOrUnknown(
          data['response_snapshot_id']!,
          _responseSnapshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseSnapshotIdMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiAnalyse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiAnalyse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      responseSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_snapshot_id'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiAnalysesTable createAlias(String alias) {
    return $AiAnalysesTable(attachedDatabase, alias);
  }
}

class AiAnalyse extends DataClass implements Insertable<AiAnalyse> {
  final String id;
  final String responseSnapshotId;
  final String summary;
  final DateTime createdAt;
  const AiAnalyse({
    required this.id,
    required this.responseSnapshotId,
    required this.summary,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['response_snapshot_id'] = Variable<String>(responseSnapshotId);
    map['summary'] = Variable<String>(summary);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiAnalysesCompanion toCompanion(bool nullToAbsent) {
    return AiAnalysesCompanion(
      id: Value(id),
      responseSnapshotId: Value(responseSnapshotId),
      summary: Value(summary),
      createdAt: Value(createdAt),
    );
  }

  factory AiAnalyse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiAnalyse(
      id: serializer.fromJson<String>(json['id']),
      responseSnapshotId: serializer.fromJson<String>(
        json['responseSnapshotId'],
      ),
      summary: serializer.fromJson<String>(json['summary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'responseSnapshotId': serializer.toJson<String>(responseSnapshotId),
      'summary': serializer.toJson<String>(summary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiAnalyse copyWith({
    String? id,
    String? responseSnapshotId,
    String? summary,
    DateTime? createdAt,
  }) => AiAnalyse(
    id: id ?? this.id,
    responseSnapshotId: responseSnapshotId ?? this.responseSnapshotId,
    summary: summary ?? this.summary,
    createdAt: createdAt ?? this.createdAt,
  );
  AiAnalyse copyWithCompanion(AiAnalysesCompanion data) {
    return AiAnalyse(
      id: data.id.present ? data.id.value : this.id,
      responseSnapshotId: data.responseSnapshotId.present
          ? data.responseSnapshotId.value
          : this.responseSnapshotId,
      summary: data.summary.present ? data.summary.value : this.summary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiAnalyse(')
          ..write('id: $id, ')
          ..write('responseSnapshotId: $responseSnapshotId, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, responseSnapshotId, summary, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiAnalyse &&
          other.id == this.id &&
          other.responseSnapshotId == this.responseSnapshotId &&
          other.summary == this.summary &&
          other.createdAt == this.createdAt);
}

class AiAnalysesCompanion extends UpdateCompanion<AiAnalyse> {
  final Value<String> id;
  final Value<String> responseSnapshotId;
  final Value<String> summary;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiAnalysesCompanion({
    this.id = const Value.absent(),
    this.responseSnapshotId = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiAnalysesCompanion.insert({
    required String id,
    required String responseSnapshotId,
    required String summary,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       responseSnapshotId = Value(responseSnapshotId),
       summary = Value(summary),
       createdAt = Value(createdAt);
  static Insertable<AiAnalyse> custom({
    Expression<String>? id,
    Expression<String>? responseSnapshotId,
    Expression<String>? summary,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (responseSnapshotId != null)
        'response_snapshot_id': responseSnapshotId,
      if (summary != null) 'summary': summary,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiAnalysesCompanion copyWith({
    Value<String>? id,
    Value<String>? responseSnapshotId,
    Value<String>? summary,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AiAnalysesCompanion(
      id: id ?? this.id,
      responseSnapshotId: responseSnapshotId ?? this.responseSnapshotId,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (responseSnapshotId.present) {
      map['response_snapshot_id'] = Variable<String>(responseSnapshotId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiAnalysesCompanion(')
          ..write('id: $id, ')
          ..write('responseSnapshotId: $responseSnapshotId, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestDraftsTable extends RequestDrafts
    with TableInfo<$RequestDraftsTable, RequestDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestId,
    title,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RequestDraftsTable createAlias(String alias) {
    return $RequestDraftsTable(attachedDatabase, alias);
  }
}

class RequestDraft extends DataClass implements Insertable<RequestDraft> {
  final String id;
  final String? requestId;
  final String title;
  final String payloadJson;
  final DateTime updatedAt;
  const RequestDraft({
    required this.id,
    this.requestId,
    required this.title,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    map['title'] = Variable<String>(title);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RequestDraftsCompanion toCompanion(bool nullToAbsent) {
    return RequestDraftsCompanion(
      id: Value(id),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      title: Value(title),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory RequestDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestDraft(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      title: serializer.fromJson<String>(json['title']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String?>(requestId),
      'title': serializer.toJson<String>(title),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RequestDraft copyWith({
    String? id,
    Value<String?> requestId = const Value.absent(),
    String? title,
    String? payloadJson,
    DateTime? updatedAt,
  }) => RequestDraft(
    id: id ?? this.id,
    requestId: requestId.present ? requestId.value : this.requestId,
    title: title ?? this.title,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RequestDraft copyWithCompanion(RequestDraftsCompanion data) {
    return RequestDraft(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      title: data.title.present ? data.title.value : this.title,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestDraft(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, requestId, title, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestDraft &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.title == this.title &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class RequestDraftsCompanion extends UpdateCompanion<RequestDraft> {
  final Value<String> id;
  final Value<String?> requestId;
  final Value<String> title;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RequestDraftsCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.title = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestDraftsCompanion.insert({
    required String id,
    this.requestId = const Value.absent(),
    required String title,
    required String payloadJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<RequestDraft> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<String>? title,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (title != null) 'title': title,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestDraftsCompanion copyWith({
    Value<String>? id,
    Value<String?>? requestId,
    Value<String>? title,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RequestDraftsCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      title: title ?? this.title,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestDraftsCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RealtimeConfigurationsTable extends RealtimeConfigurations
    with TableInfo<$RealtimeConfigurationsTable, RealtimeConfiguration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RealtimeConfigurationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    protocol,
    name,
    url,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'realtime_configurations';
  @override
  VerificationContext validateIntegrity(
    Insertable<RealtimeConfiguration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    } else if (isInserting) {
      context.missing(_protocolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RealtimeConfiguration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RealtimeConfiguration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RealtimeConfigurationsTable createAlias(String alias) {
    return $RealtimeConfigurationsTable(attachedDatabase, alias);
  }
}

class RealtimeConfiguration extends DataClass
    implements Insertable<RealtimeConfiguration> {
  final String id;
  final String workspaceId;
  final String protocol;
  final String name;
  final String url;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RealtimeConfiguration({
    required this.id,
    required this.workspaceId,
    required this.protocol,
    required this.name,
    required this.url,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['protocol'] = Variable<String>(protocol);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RealtimeConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return RealtimeConfigurationsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      protocol: Value(protocol),
      name: Value(name),
      url: Value(url),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RealtimeConfiguration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RealtimeConfiguration(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      protocol: serializer.fromJson<String>(json['protocol']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'protocol': serializer.toJson<String>(protocol),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RealtimeConfiguration copyWith({
    String? id,
    String? workspaceId,
    String? protocol,
    String? name,
    String? url,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RealtimeConfiguration(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    protocol: protocol ?? this.protocol,
    name: name ?? this.name,
    url: url ?? this.url,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RealtimeConfiguration copyWithCompanion(
    RealtimeConfigurationsCompanion data,
  ) {
    return RealtimeConfiguration(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RealtimeConfiguration(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('protocol: $protocol, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    protocol,
    name,
    url,
    payloadJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RealtimeConfiguration &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.protocol == this.protocol &&
          other.name == this.name &&
          other.url == this.url &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RealtimeConfigurationsCompanion
    extends UpdateCompanion<RealtimeConfiguration> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> protocol;
  final Value<String> name;
  final Value<String> url;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RealtimeConfigurationsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.protocol = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RealtimeConfigurationsCompanion.insert({
    required String id,
    required String workspaceId,
    required String protocol,
    required String name,
    required String url,
    this.payloadJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       protocol = Value(protocol),
       name = Value(name),
       url = Value(url),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RealtimeConfiguration> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? protocol,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (protocol != null) 'protocol': protocol,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RealtimeConfigurationsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? protocol,
    Value<String>? name,
    Value<String>? url,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RealtimeConfigurationsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      protocol: protocol ?? this.protocol,
      name: name ?? this.name,
      url: url ?? this.url,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RealtimeConfigurationsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('protocol: $protocol, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RealtimeDraftsTable extends RealtimeDrafts
    with TableInfo<$RealtimeDraftsTable, RealtimeDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RealtimeDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configurationIdMeta = const VerificationMeta(
    'configurationId',
  );
  @override
  late final GeneratedColumn<String> configurationId = GeneratedColumn<String>(
    'configuration_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    configurationId,
    workspaceId,
    protocol,
    title,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'realtime_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RealtimeDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('configuration_id')) {
      context.handle(
        _configurationIdMeta,
        configurationId.isAcceptableOrUnknown(
          data['configuration_id']!,
          _configurationIdMeta,
        ),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    } else if (isInserting) {
      context.missing(_protocolMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RealtimeDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RealtimeDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      configurationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configuration_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RealtimeDraftsTable createAlias(String alias) {
    return $RealtimeDraftsTable(attachedDatabase, alias);
  }
}

class RealtimeDraft extends DataClass implements Insertable<RealtimeDraft> {
  final String id;
  final String? configurationId;
  final String workspaceId;
  final String protocol;
  final String title;
  final String payloadJson;
  final DateTime updatedAt;
  const RealtimeDraft({
    required this.id,
    this.configurationId,
    required this.workspaceId,
    required this.protocol,
    required this.title,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || configurationId != null) {
      map['configuration_id'] = Variable<String>(configurationId);
    }
    map['workspace_id'] = Variable<String>(workspaceId);
    map['protocol'] = Variable<String>(protocol);
    map['title'] = Variable<String>(title);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RealtimeDraftsCompanion toCompanion(bool nullToAbsent) {
    return RealtimeDraftsCompanion(
      id: Value(id),
      configurationId: configurationId == null && nullToAbsent
          ? const Value.absent()
          : Value(configurationId),
      workspaceId: Value(workspaceId),
      protocol: Value(protocol),
      title: Value(title),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory RealtimeDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RealtimeDraft(
      id: serializer.fromJson<String>(json['id']),
      configurationId: serializer.fromJson<String?>(json['configurationId']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      protocol: serializer.fromJson<String>(json['protocol']),
      title: serializer.fromJson<String>(json['title']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'configurationId': serializer.toJson<String?>(configurationId),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'protocol': serializer.toJson<String>(protocol),
      'title': serializer.toJson<String>(title),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RealtimeDraft copyWith({
    String? id,
    Value<String?> configurationId = const Value.absent(),
    String? workspaceId,
    String? protocol,
    String? title,
    String? payloadJson,
    DateTime? updatedAt,
  }) => RealtimeDraft(
    id: id ?? this.id,
    configurationId: configurationId.present
        ? configurationId.value
        : this.configurationId,
    workspaceId: workspaceId ?? this.workspaceId,
    protocol: protocol ?? this.protocol,
    title: title ?? this.title,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RealtimeDraft copyWithCompanion(RealtimeDraftsCompanion data) {
    return RealtimeDraft(
      id: data.id.present ? data.id.value : this.id,
      configurationId: data.configurationId.present
          ? data.configurationId.value
          : this.configurationId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      title: data.title.present ? data.title.value : this.title,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RealtimeDraft(')
          ..write('id: $id, ')
          ..write('configurationId: $configurationId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('protocol: $protocol, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    configurationId,
    workspaceId,
    protocol,
    title,
    payloadJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RealtimeDraft &&
          other.id == this.id &&
          other.configurationId == this.configurationId &&
          other.workspaceId == this.workspaceId &&
          other.protocol == this.protocol &&
          other.title == this.title &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class RealtimeDraftsCompanion extends UpdateCompanion<RealtimeDraft> {
  final Value<String> id;
  final Value<String?> configurationId;
  final Value<String> workspaceId;
  final Value<String> protocol;
  final Value<String> title;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RealtimeDraftsCompanion({
    this.id = const Value.absent(),
    this.configurationId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.protocol = const Value.absent(),
    this.title = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RealtimeDraftsCompanion.insert({
    required String id,
    this.configurationId = const Value.absent(),
    required String workspaceId,
    required String protocol,
    required String title,
    required String payloadJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       protocol = Value(protocol),
       title = Value(title),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<RealtimeDraft> custom({
    Expression<String>? id,
    Expression<String>? configurationId,
    Expression<String>? workspaceId,
    Expression<String>? protocol,
    Expression<String>? title,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (configurationId != null) 'configuration_id': configurationId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (protocol != null) 'protocol': protocol,
      if (title != null) 'title': title,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RealtimeDraftsCompanion copyWith({
    Value<String>? id,
    Value<String?>? configurationId,
    Value<String>? workspaceId,
    Value<String>? protocol,
    Value<String>? title,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RealtimeDraftsCompanion(
      id: id ?? this.id,
      configurationId: configurationId ?? this.configurationId,
      workspaceId: workspaceId ?? this.workspaceId,
      protocol: protocol ?? this.protocol,
      title: title ?? this.title,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (configurationId.present) {
      map['configuration_id'] = Variable<String>(configurationId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RealtimeDraftsCompanion(')
          ..write('id: $id, ')
          ..write('configurationId: $configurationId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('protocol: $protocol, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RealtimeHistoryTable extends RealtimeHistory
    with TableInfo<$RealtimeHistoryTable, RealtimeHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RealtimeHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configurationIdMeta = const VerificationMeta(
    'configurationId',
  );
  @override
  late final GeneratedColumn<String> configurationId = GeneratedColumn<String>(
    'configuration_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<String> environmentId = GeneratedColumn<String>(
    'environment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureCategoryMeta = const VerificationMeta(
    'failureCategory',
  );
  @override
  late final GeneratedColumn<String> failureCategory = GeneratedColumn<String>(
    'failure_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    configurationId,
    protocol,
    status,
    collectionId,
    requestId,
    environmentId,
    failureCategory,
    summaryJson,
    pinned,
    tagsJson,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'realtime_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<RealtimeHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('configuration_id')) {
      context.handle(
        _configurationIdMeta,
        configurationId.isAcceptableOrUnknown(
          data['configuration_id']!,
          _configurationIdMeta,
        ),
      );
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    } else if (isInserting) {
      context.missing(_protocolMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    }
    if (data.containsKey('failure_category')) {
      context.handle(
        _failureCategoryMeta,
        failureCategory.isAcceptableOrUnknown(
          data['failure_category']!,
          _failureCategoryMeta,
        ),
      );
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryJsonMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RealtimeHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RealtimeHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      configurationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configuration_id'],
      ),
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment_id'],
      ),
      failureCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_category'],
      ),
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RealtimeHistoryTable createAlias(String alias) {
    return $RealtimeHistoryTable(attachedDatabase, alias);
  }
}

class RealtimeHistoryData extends DataClass
    implements Insertable<RealtimeHistoryData> {
  final String id;
  final String workspaceId;
  final String? configurationId;
  final String protocol;
  final String status;
  final String? collectionId;
  final String? requestId;
  final String? environmentId;
  final String? failureCategory;
  final String summaryJson;
  final bool pinned;
  final String tagsJson;
  final String notes;
  final DateTime createdAt;
  const RealtimeHistoryData({
    required this.id,
    required this.workspaceId,
    this.configurationId,
    required this.protocol,
    required this.status,
    this.collectionId,
    this.requestId,
    this.environmentId,
    this.failureCategory,
    required this.summaryJson,
    required this.pinned,
    required this.tagsJson,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || configurationId != null) {
      map['configuration_id'] = Variable<String>(configurationId);
    }
    map['protocol'] = Variable<String>(protocol);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    if (!nullToAbsent || environmentId != null) {
      map['environment_id'] = Variable<String>(environmentId);
    }
    if (!nullToAbsent || failureCategory != null) {
      map['failure_category'] = Variable<String>(failureCategory);
    }
    map['summary_json'] = Variable<String>(summaryJson);
    map['pinned'] = Variable<bool>(pinned);
    map['tags_json'] = Variable<String>(tagsJson);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RealtimeHistoryCompanion toCompanion(bool nullToAbsent) {
    return RealtimeHistoryCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      configurationId: configurationId == null && nullToAbsent
          ? const Value.absent()
          : Value(configurationId),
      protocol: Value(protocol),
      status: Value(status),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      environmentId: environmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(environmentId),
      failureCategory: failureCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCategory),
      summaryJson: Value(summaryJson),
      pinned: Value(pinned),
      tagsJson: Value(tagsJson),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory RealtimeHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RealtimeHistoryData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      configurationId: serializer.fromJson<String?>(json['configurationId']),
      protocol: serializer.fromJson<String>(json['protocol']),
      status: serializer.fromJson<String>(json['status']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      environmentId: serializer.fromJson<String?>(json['environmentId']),
      failureCategory: serializer.fromJson<String?>(json['failureCategory']),
      summaryJson: serializer.fromJson<String>(json['summaryJson']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'configurationId': serializer.toJson<String?>(configurationId),
      'protocol': serializer.toJson<String>(protocol),
      'status': serializer.toJson<String>(status),
      'collectionId': serializer.toJson<String?>(collectionId),
      'requestId': serializer.toJson<String?>(requestId),
      'environmentId': serializer.toJson<String?>(environmentId),
      'failureCategory': serializer.toJson<String?>(failureCategory),
      'summaryJson': serializer.toJson<String>(summaryJson),
      'pinned': serializer.toJson<bool>(pinned),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RealtimeHistoryData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> configurationId = const Value.absent(),
    String? protocol,
    String? status,
    Value<String?> collectionId = const Value.absent(),
    Value<String?> requestId = const Value.absent(),
    Value<String?> environmentId = const Value.absent(),
    Value<String?> failureCategory = const Value.absent(),
    String? summaryJson,
    bool? pinned,
    String? tagsJson,
    String? notes,
    DateTime? createdAt,
  }) => RealtimeHistoryData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    configurationId: configurationId.present
        ? configurationId.value
        : this.configurationId,
    protocol: protocol ?? this.protocol,
    status: status ?? this.status,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    requestId: requestId.present ? requestId.value : this.requestId,
    environmentId: environmentId.present
        ? environmentId.value
        : this.environmentId,
    failureCategory: failureCategory.present
        ? failureCategory.value
        : this.failureCategory,
    summaryJson: summaryJson ?? this.summaryJson,
    pinned: pinned ?? this.pinned,
    tagsJson: tagsJson ?? this.tagsJson,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  RealtimeHistoryData copyWithCompanion(RealtimeHistoryCompanion data) {
    return RealtimeHistoryData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      configurationId: data.configurationId.present
          ? data.configurationId.value
          : this.configurationId,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      status: data.status.present ? data.status.value : this.status,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      failureCategory: data.failureCategory.present
          ? data.failureCategory.value
          : this.failureCategory,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RealtimeHistoryData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('configurationId: $configurationId, ')
          ..write('protocol: $protocol, ')
          ..write('status: $status, ')
          ..write('collectionId: $collectionId, ')
          ..write('requestId: $requestId, ')
          ..write('environmentId: $environmentId, ')
          ..write('failureCategory: $failureCategory, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('pinned: $pinned, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    configurationId,
    protocol,
    status,
    collectionId,
    requestId,
    environmentId,
    failureCategory,
    summaryJson,
    pinned,
    tagsJson,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RealtimeHistoryData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.configurationId == this.configurationId &&
          other.protocol == this.protocol &&
          other.status == this.status &&
          other.collectionId == this.collectionId &&
          other.requestId == this.requestId &&
          other.environmentId == this.environmentId &&
          other.failureCategory == this.failureCategory &&
          other.summaryJson == this.summaryJson &&
          other.pinned == this.pinned &&
          other.tagsJson == this.tagsJson &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class RealtimeHistoryCompanion extends UpdateCompanion<RealtimeHistoryData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> configurationId;
  final Value<String> protocol;
  final Value<String> status;
  final Value<String?> collectionId;
  final Value<String?> requestId;
  final Value<String?> environmentId;
  final Value<String?> failureCategory;
  final Value<String> summaryJson;
  final Value<bool> pinned;
  final Value<String> tagsJson;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RealtimeHistoryCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.configurationId = const Value.absent(),
    this.protocol = const Value.absent(),
    this.status = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.failureCategory = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.pinned = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RealtimeHistoryCompanion.insert({
    required String id,
    required String workspaceId,
    this.configurationId = const Value.absent(),
    required String protocol,
    required String status,
    this.collectionId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.failureCategory = const Value.absent(),
    required String summaryJson,
    this.pinned = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       protocol = Value(protocol),
       status = Value(status),
       summaryJson = Value(summaryJson),
       createdAt = Value(createdAt);
  static Insertable<RealtimeHistoryData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? configurationId,
    Expression<String>? protocol,
    Expression<String>? status,
    Expression<String>? collectionId,
    Expression<String>? requestId,
    Expression<String>? environmentId,
    Expression<String>? failureCategory,
    Expression<String>? summaryJson,
    Expression<bool>? pinned,
    Expression<String>? tagsJson,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (configurationId != null) 'configuration_id': configurationId,
      if (protocol != null) 'protocol': protocol,
      if (status != null) 'status': status,
      if (collectionId != null) 'collection_id': collectionId,
      if (requestId != null) 'request_id': requestId,
      if (environmentId != null) 'environment_id': environmentId,
      if (failureCategory != null) 'failure_category': failureCategory,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (pinned != null) 'pinned': pinned,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RealtimeHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? configurationId,
    Value<String>? protocol,
    Value<String>? status,
    Value<String?>? collectionId,
    Value<String?>? requestId,
    Value<String?>? environmentId,
    Value<String?>? failureCategory,
    Value<String>? summaryJson,
    Value<bool>? pinned,
    Value<String>? tagsJson,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RealtimeHistoryCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      configurationId: configurationId ?? this.configurationId,
      protocol: protocol ?? this.protocol,
      status: status ?? this.status,
      collectionId: collectionId ?? this.collectionId,
      requestId: requestId ?? this.requestId,
      environmentId: environmentId ?? this.environmentId,
      failureCategory: failureCategory ?? this.failureCategory,
      summaryJson: summaryJson ?? this.summaryJson,
      pinned: pinned ?? this.pinned,
      tagsJson: tagsJson ?? this.tagsJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (configurationId.present) {
      map['configuration_id'] = Variable<String>(configurationId.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<String>(environmentId.value);
    }
    if (failureCategory.present) {
      map['failure_category'] = Variable<String>(failureCategory.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RealtimeHistoryCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('configurationId: $configurationId, ')
          ..write('protocol: $protocol, ')
          ..write('status: $status, ')
          ..write('collectionId: $collectionId, ')
          ..write('requestId: $requestId, ')
          ..write('environmentId: $environmentId, ')
          ..write('failureCategory: $failureCategory, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('pinned: $pinned, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiPreferencesTable extends AiPreferences
    with TableInfo<$AiPreferencesTable, AiPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consentGrantedMeta = const VerificationMeta(
    'consentGranted',
  );
  @override
  late final GeneratedColumn<bool> consentGranted = GeneratedColumn<bool>(
    'consent_granted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("consent_granted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _providerNameMeta = const VerificationMeta(
    'providerName',
  );
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
    'provider_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerModelMeta = const VerificationMeta(
    'providerModel',
  );
  @override
  late final GeneratedColumn<String> providerModel = GeneratedColumn<String>(
    'provider_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerEndpointMeta = const VerificationMeta(
    'providerEndpoint',
  );
  @override
  late final GeneratedColumn<String> providerEndpoint = GeneratedColumn<String>(
    'provider_endpoint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _includeBodiesMeta = const VerificationMeta(
    'includeBodies',
  );
  @override
  late final GeneratedColumn<bool> includeBodies = GeneratedColumn<bool>(
    'include_bodies',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_bodies" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includeHeadersMeta = const VerificationMeta(
    'includeHeaders',
  );
  @override
  late final GeneratedColumn<bool> includeHeaders = GeneratedColumn<bool>(
    'include_headers',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_headers" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includeHistoryMeta = const VerificationMeta(
    'includeHistory',
  );
  @override
  late final GeneratedColumn<bool> includeHistory = GeneratedColumn<bool>(
    'include_history',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_history" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includeEventsMeta = const VerificationMeta(
    'includeEvents',
  );
  @override
  late final GeneratedColumn<bool> includeEvents = GeneratedColumn<bool>(
    'include_events',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_events" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    consentGranted,
    providerName,
    providerModel,
    providerEndpoint,
    includeBodies,
    includeHeaders,
    includeHistory,
    includeEvents,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('consent_granted')) {
      context.handle(
        _consentGrantedMeta,
        consentGranted.isAcceptableOrUnknown(
          data['consent_granted']!,
          _consentGrantedMeta,
        ),
      );
    }
    if (data.containsKey('provider_name')) {
      context.handle(
        _providerNameMeta,
        providerName.isAcceptableOrUnknown(
          data['provider_name']!,
          _providerNameMeta,
        ),
      );
    }
    if (data.containsKey('provider_model')) {
      context.handle(
        _providerModelMeta,
        providerModel.isAcceptableOrUnknown(
          data['provider_model']!,
          _providerModelMeta,
        ),
      );
    }
    if (data.containsKey('provider_endpoint')) {
      context.handle(
        _providerEndpointMeta,
        providerEndpoint.isAcceptableOrUnknown(
          data['provider_endpoint']!,
          _providerEndpointMeta,
        ),
      );
    }
    if (data.containsKey('include_bodies')) {
      context.handle(
        _includeBodiesMeta,
        includeBodies.isAcceptableOrUnknown(
          data['include_bodies']!,
          _includeBodiesMeta,
        ),
      );
    }
    if (data.containsKey('include_headers')) {
      context.handle(
        _includeHeadersMeta,
        includeHeaders.isAcceptableOrUnknown(
          data['include_headers']!,
          _includeHeadersMeta,
        ),
      );
    }
    if (data.containsKey('include_history')) {
      context.handle(
        _includeHistoryMeta,
        includeHistory.isAcceptableOrUnknown(
          data['include_history']!,
          _includeHistoryMeta,
        ),
      );
    }
    if (data.containsKey('include_events')) {
      context.handle(
        _includeEventsMeta,
        includeEvents.isAcceptableOrUnknown(
          data['include_events']!,
          _includeEventsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      consentGranted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}consent_granted'],
      )!,
      providerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_name'],
      ),
      providerModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_model'],
      ),
      providerEndpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_endpoint'],
      ),
      includeBodies: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_bodies'],
      )!,
      includeHeaders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_headers'],
      )!,
      includeHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_history'],
      )!,
      includeEvents: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_events'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AiPreferencesTable createAlias(String alias) {
    return $AiPreferencesTable(attachedDatabase, alias);
  }
}

class AiPreference extends DataClass implements Insertable<AiPreference> {
  final String id;
  final bool consentGranted;
  final String? providerName;
  final String? providerModel;
  final String? providerEndpoint;
  final bool includeBodies;
  final bool includeHeaders;
  final bool includeHistory;
  final bool includeEvents;
  final DateTime updatedAt;
  const AiPreference({
    required this.id,
    required this.consentGranted,
    this.providerName,
    this.providerModel,
    this.providerEndpoint,
    required this.includeBodies,
    required this.includeHeaders,
    required this.includeHistory,
    required this.includeEvents,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['consent_granted'] = Variable<bool>(consentGranted);
    if (!nullToAbsent || providerName != null) {
      map['provider_name'] = Variable<String>(providerName);
    }
    if (!nullToAbsent || providerModel != null) {
      map['provider_model'] = Variable<String>(providerModel);
    }
    if (!nullToAbsent || providerEndpoint != null) {
      map['provider_endpoint'] = Variable<String>(providerEndpoint);
    }
    map['include_bodies'] = Variable<bool>(includeBodies);
    map['include_headers'] = Variable<bool>(includeHeaders);
    map['include_history'] = Variable<bool>(includeHistory);
    map['include_events'] = Variable<bool>(includeEvents);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AiPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AiPreferencesCompanion(
      id: Value(id),
      consentGranted: Value(consentGranted),
      providerName: providerName == null && nullToAbsent
          ? const Value.absent()
          : Value(providerName),
      providerModel: providerModel == null && nullToAbsent
          ? const Value.absent()
          : Value(providerModel),
      providerEndpoint: providerEndpoint == null && nullToAbsent
          ? const Value.absent()
          : Value(providerEndpoint),
      includeBodies: Value(includeBodies),
      includeHeaders: Value(includeHeaders),
      includeHistory: Value(includeHistory),
      includeEvents: Value(includeEvents),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiPreference(
      id: serializer.fromJson<String>(json['id']),
      consentGranted: serializer.fromJson<bool>(json['consentGranted']),
      providerName: serializer.fromJson<String?>(json['providerName']),
      providerModel: serializer.fromJson<String?>(json['providerModel']),
      providerEndpoint: serializer.fromJson<String?>(json['providerEndpoint']),
      includeBodies: serializer.fromJson<bool>(json['includeBodies']),
      includeHeaders: serializer.fromJson<bool>(json['includeHeaders']),
      includeHistory: serializer.fromJson<bool>(json['includeHistory']),
      includeEvents: serializer.fromJson<bool>(json['includeEvents']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'consentGranted': serializer.toJson<bool>(consentGranted),
      'providerName': serializer.toJson<String?>(providerName),
      'providerModel': serializer.toJson<String?>(providerModel),
      'providerEndpoint': serializer.toJson<String?>(providerEndpoint),
      'includeBodies': serializer.toJson<bool>(includeBodies),
      'includeHeaders': serializer.toJson<bool>(includeHeaders),
      'includeHistory': serializer.toJson<bool>(includeHistory),
      'includeEvents': serializer.toJson<bool>(includeEvents),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AiPreference copyWith({
    String? id,
    bool? consentGranted,
    Value<String?> providerName = const Value.absent(),
    Value<String?> providerModel = const Value.absent(),
    Value<String?> providerEndpoint = const Value.absent(),
    bool? includeBodies,
    bool? includeHeaders,
    bool? includeHistory,
    bool? includeEvents,
    DateTime? updatedAt,
  }) => AiPreference(
    id: id ?? this.id,
    consentGranted: consentGranted ?? this.consentGranted,
    providerName: providerName.present ? providerName.value : this.providerName,
    providerModel: providerModel.present
        ? providerModel.value
        : this.providerModel,
    providerEndpoint: providerEndpoint.present
        ? providerEndpoint.value
        : this.providerEndpoint,
    includeBodies: includeBodies ?? this.includeBodies,
    includeHeaders: includeHeaders ?? this.includeHeaders,
    includeHistory: includeHistory ?? this.includeHistory,
    includeEvents: includeEvents ?? this.includeEvents,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AiPreference copyWithCompanion(AiPreferencesCompanion data) {
    return AiPreference(
      id: data.id.present ? data.id.value : this.id,
      consentGranted: data.consentGranted.present
          ? data.consentGranted.value
          : this.consentGranted,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      providerModel: data.providerModel.present
          ? data.providerModel.value
          : this.providerModel,
      providerEndpoint: data.providerEndpoint.present
          ? data.providerEndpoint.value
          : this.providerEndpoint,
      includeBodies: data.includeBodies.present
          ? data.includeBodies.value
          : this.includeBodies,
      includeHeaders: data.includeHeaders.present
          ? data.includeHeaders.value
          : this.includeHeaders,
      includeHistory: data.includeHistory.present
          ? data.includeHistory.value
          : this.includeHistory,
      includeEvents: data.includeEvents.present
          ? data.includeEvents.value
          : this.includeEvents,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiPreference(')
          ..write('id: $id, ')
          ..write('consentGranted: $consentGranted, ')
          ..write('providerName: $providerName, ')
          ..write('providerModel: $providerModel, ')
          ..write('providerEndpoint: $providerEndpoint, ')
          ..write('includeBodies: $includeBodies, ')
          ..write('includeHeaders: $includeHeaders, ')
          ..write('includeHistory: $includeHistory, ')
          ..write('includeEvents: $includeEvents, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    consentGranted,
    providerName,
    providerModel,
    providerEndpoint,
    includeBodies,
    includeHeaders,
    includeHistory,
    includeEvents,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiPreference &&
          other.id == this.id &&
          other.consentGranted == this.consentGranted &&
          other.providerName == this.providerName &&
          other.providerModel == this.providerModel &&
          other.providerEndpoint == this.providerEndpoint &&
          other.includeBodies == this.includeBodies &&
          other.includeHeaders == this.includeHeaders &&
          other.includeHistory == this.includeHistory &&
          other.includeEvents == this.includeEvents &&
          other.updatedAt == this.updatedAt);
}

class AiPreferencesCompanion extends UpdateCompanion<AiPreference> {
  final Value<String> id;
  final Value<bool> consentGranted;
  final Value<String?> providerName;
  final Value<String?> providerModel;
  final Value<String?> providerEndpoint;
  final Value<bool> includeBodies;
  final Value<bool> includeHeaders;
  final Value<bool> includeHistory;
  final Value<bool> includeEvents;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AiPreferencesCompanion({
    this.id = const Value.absent(),
    this.consentGranted = const Value.absent(),
    this.providerName = const Value.absent(),
    this.providerModel = const Value.absent(),
    this.providerEndpoint = const Value.absent(),
    this.includeBodies = const Value.absent(),
    this.includeHeaders = const Value.absent(),
    this.includeHistory = const Value.absent(),
    this.includeEvents = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiPreferencesCompanion.insert({
    required String id,
    this.consentGranted = const Value.absent(),
    this.providerName = const Value.absent(),
    this.providerModel = const Value.absent(),
    this.providerEndpoint = const Value.absent(),
    this.includeBodies = const Value.absent(),
    this.includeHeaders = const Value.absent(),
    this.includeHistory = const Value.absent(),
    this.includeEvents = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<AiPreference> custom({
    Expression<String>? id,
    Expression<bool>? consentGranted,
    Expression<String>? providerName,
    Expression<String>? providerModel,
    Expression<String>? providerEndpoint,
    Expression<bool>? includeBodies,
    Expression<bool>? includeHeaders,
    Expression<bool>? includeHistory,
    Expression<bool>? includeEvents,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (consentGranted != null) 'consent_granted': consentGranted,
      if (providerName != null) 'provider_name': providerName,
      if (providerModel != null) 'provider_model': providerModel,
      if (providerEndpoint != null) 'provider_endpoint': providerEndpoint,
      if (includeBodies != null) 'include_bodies': includeBodies,
      if (includeHeaders != null) 'include_headers': includeHeaders,
      if (includeHistory != null) 'include_history': includeHistory,
      if (includeEvents != null) 'include_events': includeEvents,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiPreferencesCompanion copyWith({
    Value<String>? id,
    Value<bool>? consentGranted,
    Value<String?>? providerName,
    Value<String?>? providerModel,
    Value<String?>? providerEndpoint,
    Value<bool>? includeBodies,
    Value<bool>? includeHeaders,
    Value<bool>? includeHistory,
    Value<bool>? includeEvents,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AiPreferencesCompanion(
      id: id ?? this.id,
      consentGranted: consentGranted ?? this.consentGranted,
      providerName: providerName ?? this.providerName,
      providerModel: providerModel ?? this.providerModel,
      providerEndpoint: providerEndpoint ?? this.providerEndpoint,
      includeBodies: includeBodies ?? this.includeBodies,
      includeHeaders: includeHeaders ?? this.includeHeaders,
      includeHistory: includeHistory ?? this.includeHistory,
      includeEvents: includeEvents ?? this.includeEvents,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (consentGranted.present) {
      map['consent_granted'] = Variable<bool>(consentGranted.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (providerModel.present) {
      map['provider_model'] = Variable<String>(providerModel.value);
    }
    if (providerEndpoint.present) {
      map['provider_endpoint'] = Variable<String>(providerEndpoint.value);
    }
    if (includeBodies.present) {
      map['include_bodies'] = Variable<bool>(includeBodies.value);
    }
    if (includeHeaders.present) {
      map['include_headers'] = Variable<bool>(includeHeaders.value);
    }
    if (includeHistory.present) {
      map['include_history'] = Variable<bool>(includeHistory.value);
    }
    if (includeEvents.present) {
      map['include_events'] = Variable<bool>(includeEvents.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('consentGranted: $consentGranted, ')
          ..write('providerName: $providerName, ')
          ..write('providerModel: $providerModel, ')
          ..write('providerEndpoint: $providerEndpoint, ')
          ..write('includeBodies: $includeBodies, ')
          ..write('includeHeaders: $includeHeaders, ')
          ..write('includeHistory: $includeHistory, ')
          ..write('includeEvents: $includeEvents, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspaceSettingsTable extends WorkspaceSettings
    with TableInfo<$WorkspaceSettingsTable, WorkspaceSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspaceSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _historyRetentionDaysMeta =
      const VerificationMeta('historyRetentionDays');
  @override
  late final GeneratedColumn<int> historyRetentionDays = GeneratedColumn<int>(
    'history_retention_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _historyMaximumCountMeta =
      const VerificationMeta('historyMaximumCount');
  @override
  late final GeneratedColumn<int> historyMaximumCount = GeneratedColumn<int>(
    'history_maximum_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _responsePreviewBytesMeta =
      const VerificationMeta('responsePreviewBytes');
  @override
  late final GeneratedColumn<int> responsePreviewBytes = GeneratedColumn<int>(
    'response_preview_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1048576),
  );
  static const VerificationMeta _productionStrictModeMeta =
      const VerificationMeta('productionStrictMode');
  @override
  late final GeneratedColumn<bool> productionStrictMode = GeneratedColumn<bool>(
    'production_strict_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("production_strict_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _realtimeRetentionDaysMeta =
      const VerificationMeta('realtimeRetentionDays');
  @override
  late final GeneratedColumn<int> realtimeRetentionDays = GeneratedColumn<int>(
    'realtime_retention_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _realtimeMaximumCountMeta =
      const VerificationMeta('realtimeMaximumCount');
  @override
  late final GeneratedColumn<int> realtimeMaximumCount = GeneratedColumn<int>(
    'realtime_maximum_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(500),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    workspaceId,
    historyRetentionDays,
    historyMaximumCount,
    responsePreviewBytes,
    productionStrictMode,
    realtimeRetentionDays,
    realtimeMaximumCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspace_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('history_retention_days')) {
      context.handle(
        _historyRetentionDaysMeta,
        historyRetentionDays.isAcceptableOrUnknown(
          data['history_retention_days']!,
          _historyRetentionDaysMeta,
        ),
      );
    }
    if (data.containsKey('history_maximum_count')) {
      context.handle(
        _historyMaximumCountMeta,
        historyMaximumCount.isAcceptableOrUnknown(
          data['history_maximum_count']!,
          _historyMaximumCountMeta,
        ),
      );
    }
    if (data.containsKey('response_preview_bytes')) {
      context.handle(
        _responsePreviewBytesMeta,
        responsePreviewBytes.isAcceptableOrUnknown(
          data['response_preview_bytes']!,
          _responsePreviewBytesMeta,
        ),
      );
    }
    if (data.containsKey('production_strict_mode')) {
      context.handle(
        _productionStrictModeMeta,
        productionStrictMode.isAcceptableOrUnknown(
          data['production_strict_mode']!,
          _productionStrictModeMeta,
        ),
      );
    }
    if (data.containsKey('realtime_retention_days')) {
      context.handle(
        _realtimeRetentionDaysMeta,
        realtimeRetentionDays.isAcceptableOrUnknown(
          data['realtime_retention_days']!,
          _realtimeRetentionDaysMeta,
        ),
      );
    }
    if (data.containsKey('realtime_maximum_count')) {
      context.handle(
        _realtimeMaximumCountMeta,
        realtimeMaximumCount.isAcceptableOrUnknown(
          data['realtime_maximum_count']!,
          _realtimeMaximumCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId};
  @override
  WorkspaceSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceSetting(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      historyRetentionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_retention_days'],
      )!,
      historyMaximumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_maximum_count'],
      )!,
      responsePreviewBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_preview_bytes'],
      )!,
      productionStrictMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}production_strict_mode'],
      )!,
      realtimeRetentionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}realtime_retention_days'],
      )!,
      realtimeMaximumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}realtime_maximum_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkspaceSettingsTable createAlias(String alias) {
    return $WorkspaceSettingsTable(attachedDatabase, alias);
  }
}

class WorkspaceSetting extends DataClass
    implements Insertable<WorkspaceSetting> {
  final String workspaceId;
  final int historyRetentionDays;
  final int historyMaximumCount;
  final int responsePreviewBytes;
  final bool productionStrictMode;
  final int realtimeRetentionDays;
  final int realtimeMaximumCount;
  final DateTime updatedAt;
  const WorkspaceSetting({
    required this.workspaceId,
    required this.historyRetentionDays,
    required this.historyMaximumCount,
    required this.responsePreviewBytes,
    required this.productionStrictMode,
    required this.realtimeRetentionDays,
    required this.realtimeMaximumCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<String>(workspaceId);
    map['history_retention_days'] = Variable<int>(historyRetentionDays);
    map['history_maximum_count'] = Variable<int>(historyMaximumCount);
    map['response_preview_bytes'] = Variable<int>(responsePreviewBytes);
    map['production_strict_mode'] = Variable<bool>(productionStrictMode);
    map['realtime_retention_days'] = Variable<int>(realtimeRetentionDays);
    map['realtime_maximum_count'] = Variable<int>(realtimeMaximumCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkspaceSettingsCompanion toCompanion(bool nullToAbsent) {
    return WorkspaceSettingsCompanion(
      workspaceId: Value(workspaceId),
      historyRetentionDays: Value(historyRetentionDays),
      historyMaximumCount: Value(historyMaximumCount),
      responsePreviewBytes: Value(responsePreviewBytes),
      productionStrictMode: Value(productionStrictMode),
      realtimeRetentionDays: Value(realtimeRetentionDays),
      realtimeMaximumCount: Value(realtimeMaximumCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkspaceSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceSetting(
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      historyRetentionDays: serializer.fromJson<int>(
        json['historyRetentionDays'],
      ),
      historyMaximumCount: serializer.fromJson<int>(
        json['historyMaximumCount'],
      ),
      responsePreviewBytes: serializer.fromJson<int>(
        json['responsePreviewBytes'],
      ),
      productionStrictMode: serializer.fromJson<bool>(
        json['productionStrictMode'],
      ),
      realtimeRetentionDays: serializer.fromJson<int>(
        json['realtimeRetentionDays'],
      ),
      realtimeMaximumCount: serializer.fromJson<int>(
        json['realtimeMaximumCount'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<String>(workspaceId),
      'historyRetentionDays': serializer.toJson<int>(historyRetentionDays),
      'historyMaximumCount': serializer.toJson<int>(historyMaximumCount),
      'responsePreviewBytes': serializer.toJson<int>(responsePreviewBytes),
      'productionStrictMode': serializer.toJson<bool>(productionStrictMode),
      'realtimeRetentionDays': serializer.toJson<int>(realtimeRetentionDays),
      'realtimeMaximumCount': serializer.toJson<int>(realtimeMaximumCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkspaceSetting copyWith({
    String? workspaceId,
    int? historyRetentionDays,
    int? historyMaximumCount,
    int? responsePreviewBytes,
    bool? productionStrictMode,
    int? realtimeRetentionDays,
    int? realtimeMaximumCount,
    DateTime? updatedAt,
  }) => WorkspaceSetting(
    workspaceId: workspaceId ?? this.workspaceId,
    historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
    historyMaximumCount: historyMaximumCount ?? this.historyMaximumCount,
    responsePreviewBytes: responsePreviewBytes ?? this.responsePreviewBytes,
    productionStrictMode: productionStrictMode ?? this.productionStrictMode,
    realtimeRetentionDays: realtimeRetentionDays ?? this.realtimeRetentionDays,
    realtimeMaximumCount: realtimeMaximumCount ?? this.realtimeMaximumCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkspaceSetting copyWithCompanion(WorkspaceSettingsCompanion data) {
    return WorkspaceSetting(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      historyRetentionDays: data.historyRetentionDays.present
          ? data.historyRetentionDays.value
          : this.historyRetentionDays,
      historyMaximumCount: data.historyMaximumCount.present
          ? data.historyMaximumCount.value
          : this.historyMaximumCount,
      responsePreviewBytes: data.responsePreviewBytes.present
          ? data.responsePreviewBytes.value
          : this.responsePreviewBytes,
      productionStrictMode: data.productionStrictMode.present
          ? data.productionStrictMode.value
          : this.productionStrictMode,
      realtimeRetentionDays: data.realtimeRetentionDays.present
          ? data.realtimeRetentionDays.value
          : this.realtimeRetentionDays,
      realtimeMaximumCount: data.realtimeMaximumCount.present
          ? data.realtimeMaximumCount.value
          : this.realtimeMaximumCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceSetting(')
          ..write('workspaceId: $workspaceId, ')
          ..write('historyRetentionDays: $historyRetentionDays, ')
          ..write('historyMaximumCount: $historyMaximumCount, ')
          ..write('responsePreviewBytes: $responsePreviewBytes, ')
          ..write('productionStrictMode: $productionStrictMode, ')
          ..write('realtimeRetentionDays: $realtimeRetentionDays, ')
          ..write('realtimeMaximumCount: $realtimeMaximumCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    workspaceId,
    historyRetentionDays,
    historyMaximumCount,
    responsePreviewBytes,
    productionStrictMode,
    realtimeRetentionDays,
    realtimeMaximumCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceSetting &&
          other.workspaceId == this.workspaceId &&
          other.historyRetentionDays == this.historyRetentionDays &&
          other.historyMaximumCount == this.historyMaximumCount &&
          other.responsePreviewBytes == this.responsePreviewBytes &&
          other.productionStrictMode == this.productionStrictMode &&
          other.realtimeRetentionDays == this.realtimeRetentionDays &&
          other.realtimeMaximumCount == this.realtimeMaximumCount &&
          other.updatedAt == this.updatedAt);
}

class WorkspaceSettingsCompanion extends UpdateCompanion<WorkspaceSetting> {
  final Value<String> workspaceId;
  final Value<int> historyRetentionDays;
  final Value<int> historyMaximumCount;
  final Value<int> responsePreviewBytes;
  final Value<bool> productionStrictMode;
  final Value<int> realtimeRetentionDays;
  final Value<int> realtimeMaximumCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkspaceSettingsCompanion({
    this.workspaceId = const Value.absent(),
    this.historyRetentionDays = const Value.absent(),
    this.historyMaximumCount = const Value.absent(),
    this.responsePreviewBytes = const Value.absent(),
    this.productionStrictMode = const Value.absent(),
    this.realtimeRetentionDays = const Value.absent(),
    this.realtimeMaximumCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspaceSettingsCompanion.insert({
    required String workspaceId,
    this.historyRetentionDays = const Value.absent(),
    this.historyMaximumCount = const Value.absent(),
    this.responsePreviewBytes = const Value.absent(),
    this.productionStrictMode = const Value.absent(),
    this.realtimeRetentionDays = const Value.absent(),
    this.realtimeMaximumCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       updatedAt = Value(updatedAt);
  static Insertable<WorkspaceSetting> custom({
    Expression<String>? workspaceId,
    Expression<int>? historyRetentionDays,
    Expression<int>? historyMaximumCount,
    Expression<int>? responsePreviewBytes,
    Expression<bool>? productionStrictMode,
    Expression<int>? realtimeRetentionDays,
    Expression<int>? realtimeMaximumCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (historyRetentionDays != null)
        'history_retention_days': historyRetentionDays,
      if (historyMaximumCount != null)
        'history_maximum_count': historyMaximumCount,
      if (responsePreviewBytes != null)
        'response_preview_bytes': responsePreviewBytes,
      if (productionStrictMode != null)
        'production_strict_mode': productionStrictMode,
      if (realtimeRetentionDays != null)
        'realtime_retention_days': realtimeRetentionDays,
      if (realtimeMaximumCount != null)
        'realtime_maximum_count': realtimeMaximumCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspaceSettingsCompanion copyWith({
    Value<String>? workspaceId,
    Value<int>? historyRetentionDays,
    Value<int>? historyMaximumCount,
    Value<int>? responsePreviewBytes,
    Value<bool>? productionStrictMode,
    Value<int>? realtimeRetentionDays,
    Value<int>? realtimeMaximumCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkspaceSettingsCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
      historyMaximumCount: historyMaximumCount ?? this.historyMaximumCount,
      responsePreviewBytes: responsePreviewBytes ?? this.responsePreviewBytes,
      productionStrictMode: productionStrictMode ?? this.productionStrictMode,
      realtimeRetentionDays:
          realtimeRetentionDays ?? this.realtimeRetentionDays,
      realtimeMaximumCount: realtimeMaximumCount ?? this.realtimeMaximumCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (historyRetentionDays.present) {
      map['history_retention_days'] = Variable<int>(historyRetentionDays.value);
    }
    if (historyMaximumCount.present) {
      map['history_maximum_count'] = Variable<int>(historyMaximumCount.value);
    }
    if (responsePreviewBytes.present) {
      map['response_preview_bytes'] = Variable<int>(responsePreviewBytes.value);
    }
    if (productionStrictMode.present) {
      map['production_strict_mode'] = Variable<bool>(
        productionStrictMode.value,
      );
    }
    if (realtimeRetentionDays.present) {
      map['realtime_retention_days'] = Variable<int>(
        realtimeRetentionDays.value,
      );
    }
    if (realtimeMaximumCount.present) {
      map['realtime_maximum_count'] = Variable<int>(realtimeMaximumCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceSettingsCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('historyRetentionDays: $historyRetentionDays, ')
          ..write('historyMaximumCount: $historyMaximumCount, ')
          ..write('responsePreviewBytes: $responsePreviewBytes, ')
          ..write('productionStrictMode: $productionStrictMode, ')
          ..write('realtimeRetentionDays: $realtimeRetentionDays, ')
          ..write('realtimeMaximumCount: $realtimeMaximumCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GraphqlDraftsTable extends GraphqlDrafts
    with TableInfo<$GraphqlDraftsTable, GraphqlDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraphqlDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentMeta = const VerificationMeta(
    'document',
  );
  @override
  late final GeneratedColumn<String> document = GeneratedColumn<String>(
    'document',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationNameMeta = const VerificationMeta(
    'operationName',
  );
  @override
  late final GeneratedColumn<String> operationName = GeneratedColumn<String>(
    'operation_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variablesJsonMeta = const VerificationMeta(
    'variablesJson',
  );
  @override
  late final GeneratedColumn<String> variablesJson = GeneratedColumn<String>(
    'variables_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    title,
    endpoint,
    document,
    operationName,
    variablesJson,
    headersJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'graphql_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<GraphqlDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('document')) {
      context.handle(
        _documentMeta,
        document.isAcceptableOrUnknown(data['document']!, _documentMeta),
      );
    } else if (isInserting) {
      context.missing(_documentMeta);
    }
    if (data.containsKey('operation_name')) {
      context.handle(
        _operationNameMeta,
        operationName.isAcceptableOrUnknown(
          data['operation_name']!,
          _operationNameMeta,
        ),
      );
    }
    if (data.containsKey('variables_json')) {
      context.handle(
        _variablesJsonMeta,
        variablesJson.isAcceptableOrUnknown(
          data['variables_json']!,
          _variablesJsonMeta,
        ),
      );
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GraphqlDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GraphqlDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      document: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document'],
      )!,
      operationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_name'],
      ),
      variablesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variables_json'],
      )!,
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GraphqlDraftsTable createAlias(String alias) {
    return $GraphqlDraftsTable(attachedDatabase, alias);
  }
}

class GraphqlDraft extends DataClass implements Insertable<GraphqlDraft> {
  final String id;
  final String workspaceId;
  final String title;
  final String endpoint;
  final String document;
  final String? operationName;
  final String variablesJson;
  final String headersJson;
  final DateTime updatedAt;
  const GraphqlDraft({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.endpoint,
    required this.document,
    this.operationName,
    required this.variablesJson,
    required this.headersJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['title'] = Variable<String>(title);
    map['endpoint'] = Variable<String>(endpoint);
    map['document'] = Variable<String>(document);
    if (!nullToAbsent || operationName != null) {
      map['operation_name'] = Variable<String>(operationName);
    }
    map['variables_json'] = Variable<String>(variablesJson);
    map['headers_json'] = Variable<String>(headersJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GraphqlDraftsCompanion toCompanion(bool nullToAbsent) {
    return GraphqlDraftsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      title: Value(title),
      endpoint: Value(endpoint),
      document: Value(document),
      operationName: operationName == null && nullToAbsent
          ? const Value.absent()
          : Value(operationName),
      variablesJson: Value(variablesJson),
      headersJson: Value(headersJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory GraphqlDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GraphqlDraft(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      title: serializer.fromJson<String>(json['title']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      document: serializer.fromJson<String>(json['document']),
      operationName: serializer.fromJson<String?>(json['operationName']),
      variablesJson: serializer.fromJson<String>(json['variablesJson']),
      headersJson: serializer.fromJson<String>(json['headersJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'title': serializer.toJson<String>(title),
      'endpoint': serializer.toJson<String>(endpoint),
      'document': serializer.toJson<String>(document),
      'operationName': serializer.toJson<String?>(operationName),
      'variablesJson': serializer.toJson<String>(variablesJson),
      'headersJson': serializer.toJson<String>(headersJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GraphqlDraft copyWith({
    String? id,
    String? workspaceId,
    String? title,
    String? endpoint,
    String? document,
    Value<String?> operationName = const Value.absent(),
    String? variablesJson,
    String? headersJson,
    DateTime? updatedAt,
  }) => GraphqlDraft(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    title: title ?? this.title,
    endpoint: endpoint ?? this.endpoint,
    document: document ?? this.document,
    operationName: operationName.present
        ? operationName.value
        : this.operationName,
    variablesJson: variablesJson ?? this.variablesJson,
    headersJson: headersJson ?? this.headersJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GraphqlDraft copyWithCompanion(GraphqlDraftsCompanion data) {
    return GraphqlDraft(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      title: data.title.present ? data.title.value : this.title,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      document: data.document.present ? data.document.value : this.document,
      operationName: data.operationName.present
          ? data.operationName.value
          : this.operationName,
      variablesJson: data.variablesJson.present
          ? data.variablesJson.value
          : this.variablesJson,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlDraft(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('endpoint: $endpoint, ')
          ..write('document: $document, ')
          ..write('operationName: $operationName, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('headersJson: $headersJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    title,
    endpoint,
    document,
    operationName,
    variablesJson,
    headersJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphqlDraft &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.title == this.title &&
          other.endpoint == this.endpoint &&
          other.document == this.document &&
          other.operationName == this.operationName &&
          other.variablesJson == this.variablesJson &&
          other.headersJson == this.headersJson &&
          other.updatedAt == this.updatedAt);
}

class GraphqlDraftsCompanion extends UpdateCompanion<GraphqlDraft> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> title;
  final Value<String> endpoint;
  final Value<String> document;
  final Value<String?> operationName;
  final Value<String> variablesJson;
  final Value<String> headersJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GraphqlDraftsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.document = const Value.absent(),
    this.operationName = const Value.absent(),
    this.variablesJson = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GraphqlDraftsCompanion.insert({
    required String id,
    required String workspaceId,
    required String title,
    required String endpoint,
    required String document,
    this.operationName = const Value.absent(),
    this.variablesJson = const Value.absent(),
    this.headersJson = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       title = Value(title),
       endpoint = Value(endpoint),
       document = Value(document),
       updatedAt = Value(updatedAt);
  static Insertable<GraphqlDraft> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? title,
    Expression<String>? endpoint,
    Expression<String>? document,
    Expression<String>? operationName,
    Expression<String>? variablesJson,
    Expression<String>? headersJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (title != null) 'title': title,
      if (endpoint != null) 'endpoint': endpoint,
      if (document != null) 'document': document,
      if (operationName != null) 'operation_name': operationName,
      if (variablesJson != null) 'variables_json': variablesJson,
      if (headersJson != null) 'headers_json': headersJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GraphqlDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? title,
    Value<String>? endpoint,
    Value<String>? document,
    Value<String?>? operationName,
    Value<String>? variablesJson,
    Value<String>? headersJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GraphqlDraftsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      endpoint: endpoint ?? this.endpoint,
      document: document ?? this.document,
      operationName: operationName ?? this.operationName,
      variablesJson: variablesJson ?? this.variablesJson,
      headersJson: headersJson ?? this.headersJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (document.present) {
      map['document'] = Variable<String>(document.value);
    }
    if (operationName.present) {
      map['operation_name'] = Variable<String>(operationName.value);
    }
    if (variablesJson.present) {
      map['variables_json'] = Variable<String>(variablesJson.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlDraftsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('endpoint: $endpoint, ')
          ..write('document: $document, ')
          ..write('operationName: $operationName, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('headersJson: $headersJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GraphqlHistoryTable extends GraphqlHistory
    with TableInfo<$GraphqlHistoryTable, GraphqlHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraphqlHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _draftIdMeta = const VerificationMeta(
    'draftId',
  );
  @override
  late final GeneratedColumn<String> draftId = GeneratedColumn<String>(
    'draft_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    draftId,
    workspaceId,
    operationType,
    summaryJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'graphql_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<GraphqlHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('draft_id')) {
      context.handle(
        _draftIdMeta,
        draftId.isAcceptableOrUnknown(data['draft_id']!, _draftIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GraphqlHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GraphqlHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      draftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GraphqlHistoryTable createAlias(String alias) {
    return $GraphqlHistoryTable(attachedDatabase, alias);
  }
}

class GraphqlHistoryData extends DataClass
    implements Insertable<GraphqlHistoryData> {
  final String id;
  final String? draftId;
  final String workspaceId;
  final String operationType;
  final String summaryJson;
  final DateTime createdAt;
  const GraphqlHistoryData({
    required this.id,
    this.draftId,
    required this.workspaceId,
    required this.operationType,
    required this.summaryJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || draftId != null) {
      map['draft_id'] = Variable<String>(draftId);
    }
    map['workspace_id'] = Variable<String>(workspaceId);
    map['operation_type'] = Variable<String>(operationType);
    map['summary_json'] = Variable<String>(summaryJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GraphqlHistoryCompanion toCompanion(bool nullToAbsent) {
    return GraphqlHistoryCompanion(
      id: Value(id),
      draftId: draftId == null && nullToAbsent
          ? const Value.absent()
          : Value(draftId),
      workspaceId: Value(workspaceId),
      operationType: Value(operationType),
      summaryJson: Value(summaryJson),
      createdAt: Value(createdAt),
    );
  }

  factory GraphqlHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GraphqlHistoryData(
      id: serializer.fromJson<String>(json['id']),
      draftId: serializer.fromJson<String?>(json['draftId']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      summaryJson: serializer.fromJson<String>(json['summaryJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'draftId': serializer.toJson<String?>(draftId),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'operationType': serializer.toJson<String>(operationType),
      'summaryJson': serializer.toJson<String>(summaryJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GraphqlHistoryData copyWith({
    String? id,
    Value<String?> draftId = const Value.absent(),
    String? workspaceId,
    String? operationType,
    String? summaryJson,
    DateTime? createdAt,
  }) => GraphqlHistoryData(
    id: id ?? this.id,
    draftId: draftId.present ? draftId.value : this.draftId,
    workspaceId: workspaceId ?? this.workspaceId,
    operationType: operationType ?? this.operationType,
    summaryJson: summaryJson ?? this.summaryJson,
    createdAt: createdAt ?? this.createdAt,
  );
  GraphqlHistoryData copyWithCompanion(GraphqlHistoryCompanion data) {
    return GraphqlHistoryData(
      id: data.id.present ? data.id.value : this.id,
      draftId: data.draftId.present ? data.draftId.value : this.draftId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlHistoryData(')
          ..write('id: $id, ')
          ..write('draftId: $draftId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('operationType: $operationType, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    draftId,
    workspaceId,
    operationType,
    summaryJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphqlHistoryData &&
          other.id == this.id &&
          other.draftId == this.draftId &&
          other.workspaceId == this.workspaceId &&
          other.operationType == this.operationType &&
          other.summaryJson == this.summaryJson &&
          other.createdAt == this.createdAt);
}

class GraphqlHistoryCompanion extends UpdateCompanion<GraphqlHistoryData> {
  final Value<String> id;
  final Value<String?> draftId;
  final Value<String> workspaceId;
  final Value<String> operationType;
  final Value<String> summaryJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GraphqlHistoryCompanion({
    this.id = const Value.absent(),
    this.draftId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GraphqlHistoryCompanion.insert({
    required String id,
    this.draftId = const Value.absent(),
    required String workspaceId,
    required String operationType,
    required String summaryJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       operationType = Value(operationType),
       summaryJson = Value(summaryJson),
       createdAt = Value(createdAt);
  static Insertable<GraphqlHistoryData> custom({
    Expression<String>? id,
    Expression<String>? draftId,
    Expression<String>? workspaceId,
    Expression<String>? operationType,
    Expression<String>? summaryJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (draftId != null) 'draft_id': draftId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (operationType != null) 'operation_type': operationType,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GraphqlHistoryCompanion copyWith({
    Value<String>? id,
    Value<String?>? draftId,
    Value<String>? workspaceId,
    Value<String>? operationType,
    Value<String>? summaryJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GraphqlHistoryCompanion(
      id: id ?? this.id,
      draftId: draftId ?? this.draftId,
      workspaceId: workspaceId ?? this.workspaceId,
      operationType: operationType ?? this.operationType,
      summaryJson: summaryJson ?? this.summaryJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (draftId.present) {
      map['draft_id'] = Variable<String>(draftId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlHistoryCompanion(')
          ..write('id: $id, ')
          ..write('draftId: $draftId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('operationType: $operationType, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GraphqlSavedRequestsTable extends GraphqlSavedRequests
    with TableInfo<$GraphqlSavedRequestsTable, GraphqlSavedRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraphqlSavedRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    collectionId,
    folderId,
    name,
    payloadJson,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'graphql_saved_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<GraphqlSavedRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GraphqlSavedRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GraphqlSavedRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GraphqlSavedRequestsTable createAlias(String alias) {
    return $GraphqlSavedRequestsTable(attachedDatabase, alias);
  }
}

class GraphqlSavedRequest extends DataClass
    implements Insertable<GraphqlSavedRequest> {
  final String id;
  final String workspaceId;
  final String? collectionId;
  final String? folderId;
  final String name;
  final String payloadJson;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GraphqlSavedRequest({
    required this.id,
    required this.workspaceId,
    this.collectionId,
    this.folderId,
    required this.name,
    required this.payloadJson,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['name'] = Variable<String>(name);
    map['payload_json'] = Variable<String>(payloadJson);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GraphqlSavedRequestsCompanion toCompanion(bool nullToAbsent) {
    return GraphqlSavedRequestsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      name: Value(name),
      payloadJson: Value(payloadJson),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GraphqlSavedRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GraphqlSavedRequest(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      name: serializer.fromJson<String>(json['name']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'collectionId': serializer.toJson<String?>(collectionId),
      'folderId': serializer.toJson<String?>(folderId),
      'name': serializer.toJson<String>(name),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GraphqlSavedRequest copyWith({
    String? id,
    String? workspaceId,
    Value<String?> collectionId = const Value.absent(),
    Value<String?> folderId = const Value.absent(),
    String? name,
    String? payloadJson,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GraphqlSavedRequest(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    folderId: folderId.present ? folderId.value : this.folderId,
    name: name ?? this.name,
    payloadJson: payloadJson ?? this.payloadJson,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GraphqlSavedRequest copyWithCompanion(GraphqlSavedRequestsCompanion data) {
    return GraphqlSavedRequest(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      name: data.name.present ? data.name.value : this.name,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlSavedRequest(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    collectionId,
    folderId,
    name,
    payloadJson,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphqlSavedRequest &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.collectionId == this.collectionId &&
          other.folderId == this.folderId &&
          other.name == this.name &&
          other.payloadJson == this.payloadJson &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GraphqlSavedRequestsCompanion
    extends UpdateCompanion<GraphqlSavedRequest> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> collectionId;
  final Value<String?> folderId;
  final Value<String> name;
  final Value<String> payloadJson;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GraphqlSavedRequestsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.name = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GraphqlSavedRequestsCompanion.insert({
    required String id,
    required String workspaceId,
    this.collectionId = const Value.absent(),
    this.folderId = const Value.absent(),
    required String name,
    required String payloadJson,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GraphqlSavedRequest> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? collectionId,
    Expression<String>? folderId,
    Expression<String>? name,
    Expression<String>? payloadJson,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (collectionId != null) 'collection_id': collectionId,
      if (folderId != null) 'folder_id': folderId,
      if (name != null) 'name': name,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GraphqlSavedRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? collectionId,
    Value<String?>? folderId,
    Value<String>? name,
    Value<String>? payloadJson,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GraphqlSavedRequestsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      collectionId: collectionId ?? this.collectionId,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      payloadJson: payloadJson ?? this.payloadJson,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlSavedRequestsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GraphqlSchemaSnapshotsTable extends GraphqlSchemaSnapshots
    with TableInfo<$GraphqlSchemaSnapshotsTable, GraphqlSchemaSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraphqlSchemaSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointFingerprintMeta =
      const VerificationMeta('endpointFingerprint');
  @override
  late final GeneratedColumn<String> endpointFingerprint =
      GeneratedColumn<String>(
        'endpoint_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _schemaHashMeta = const VerificationMeta(
    'schemaHash',
  );
  @override
  late final GeneratedColumn<String> schemaHash = GeneratedColumn<String>(
    'schema_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    endpointFingerprint,
    schemaHash,
    snapshotJson,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'graphql_schema_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<GraphqlSchemaSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('endpoint_fingerprint')) {
      context.handle(
        _endpointFingerprintMeta,
        endpointFingerprint.isAcceptableOrUnknown(
          data['endpoint_fingerprint']!,
          _endpointFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endpointFingerprintMeta);
    }
    if (data.containsKey('schema_hash')) {
      context.handle(
        _schemaHashMeta,
        schemaHash.isAcceptableOrUnknown(data['schema_hash']!, _schemaHashMeta),
      );
    } else if (isInserting) {
      context.missing(_schemaHashMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GraphqlSchemaSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GraphqlSchemaSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      endpointFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint_fingerprint'],
      )!,
      schemaHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema_hash'],
      )!,
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $GraphqlSchemaSnapshotsTable createAlias(String alias) {
    return $GraphqlSchemaSnapshotsTable(attachedDatabase, alias);
  }
}

class GraphqlSchemaSnapshot extends DataClass
    implements Insertable<GraphqlSchemaSnapshot> {
  final String id;
  final String workspaceId;
  final String endpointFingerprint;
  final String schemaHash;
  final String snapshotJson;
  final DateTime fetchedAt;
  const GraphqlSchemaSnapshot({
    required this.id,
    required this.workspaceId,
    required this.endpointFingerprint,
    required this.schemaHash,
    required this.snapshotJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['endpoint_fingerprint'] = Variable<String>(endpointFingerprint);
    map['schema_hash'] = Variable<String>(schemaHash);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  GraphqlSchemaSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return GraphqlSchemaSnapshotsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      endpointFingerprint: Value(endpointFingerprint),
      schemaHash: Value(schemaHash),
      snapshotJson: Value(snapshotJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory GraphqlSchemaSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GraphqlSchemaSnapshot(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      endpointFingerprint: serializer.fromJson<String>(
        json['endpointFingerprint'],
      ),
      schemaHash: serializer.fromJson<String>(json['schemaHash']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'endpointFingerprint': serializer.toJson<String>(endpointFingerprint),
      'schemaHash': serializer.toJson<String>(schemaHash),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  GraphqlSchemaSnapshot copyWith({
    String? id,
    String? workspaceId,
    String? endpointFingerprint,
    String? schemaHash,
    String? snapshotJson,
    DateTime? fetchedAt,
  }) => GraphqlSchemaSnapshot(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    endpointFingerprint: endpointFingerprint ?? this.endpointFingerprint,
    schemaHash: schemaHash ?? this.schemaHash,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  GraphqlSchemaSnapshot copyWithCompanion(
    GraphqlSchemaSnapshotsCompanion data,
  ) {
    return GraphqlSchemaSnapshot(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      endpointFingerprint: data.endpointFingerprint.present
          ? data.endpointFingerprint.value
          : this.endpointFingerprint,
      schemaHash: data.schemaHash.present
          ? data.schemaHash.value
          : this.schemaHash,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlSchemaSnapshot(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('endpointFingerprint: $endpointFingerprint, ')
          ..write('schemaHash: $schemaHash, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    endpointFingerprint,
    schemaHash,
    snapshotJson,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphqlSchemaSnapshot &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.endpointFingerprint == this.endpointFingerprint &&
          other.schemaHash == this.schemaHash &&
          other.snapshotJson == this.snapshotJson &&
          other.fetchedAt == this.fetchedAt);
}

class GraphqlSchemaSnapshotsCompanion
    extends UpdateCompanion<GraphqlSchemaSnapshot> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> endpointFingerprint;
  final Value<String> schemaHash;
  final Value<String> snapshotJson;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const GraphqlSchemaSnapshotsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.endpointFingerprint = const Value.absent(),
    this.schemaHash = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GraphqlSchemaSnapshotsCompanion.insert({
    required String id,
    required String workspaceId,
    required String endpointFingerprint,
    required String schemaHash,
    required String snapshotJson,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       endpointFingerprint = Value(endpointFingerprint),
       schemaHash = Value(schemaHash),
       snapshotJson = Value(snapshotJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<GraphqlSchemaSnapshot> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? endpointFingerprint,
    Expression<String>? schemaHash,
    Expression<String>? snapshotJson,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (endpointFingerprint != null)
        'endpoint_fingerprint': endpointFingerprint,
      if (schemaHash != null) 'schema_hash': schemaHash,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GraphqlSchemaSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? endpointFingerprint,
    Value<String>? schemaHash,
    Value<String>? snapshotJson,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return GraphqlSchemaSnapshotsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      endpointFingerprint: endpointFingerprint ?? this.endpointFingerprint,
      schemaHash: schemaHash ?? this.schemaHash,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (endpointFingerprint.present) {
      map['endpoint_fingerprint'] = Variable<String>(endpointFingerprint.value);
    }
    if (schemaHash.present) {
      map['schema_hash'] = Variable<String>(schemaHash.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraphqlSchemaSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('endpointFingerprint: $endpointFingerprint, ')
          ..write('schemaHash: $schemaHash, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrpcDescriptorSnapshotsTable extends GrpcDescriptorSnapshots
    with TableInfo<$GrpcDescriptorSnapshotsTable, GrpcDescriptorSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrpcDescriptorSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdentityMeta = const VerificationMeta(
    'sourceIdentity',
  );
  @override
  late final GeneratedColumn<String> sourceIdentity = GeneratedColumn<String>(
    'source_identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptorBytesMeta = const VerificationMeta(
    'descriptorBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> descriptorBytes =
      GeneratedColumn<Uint8List>(
        'descriptor_bytes',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _descriptorByteCountMeta =
      const VerificationMeta('descriptorByteCount');
  @override
  late final GeneratedColumn<int> descriptorByteCount = GeneratedColumn<int>(
    'descriptor_byte_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileCountMeta = const VerificationMeta(
    'fileCount',
  );
  @override
  late final GeneratedColumn<int> fileCount = GeneratedColumn<int>(
    'file_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceCountMeta = const VerificationMeta(
    'serviceCount',
  );
  @override
  late final GeneratedColumn<int> serviceCount = GeneratedColumn<int>(
    'service_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    fingerprint,
    sourceType,
    displayName,
    sourceIdentity,
    descriptorBytes,
    descriptorByteCount,
    fileCount,
    serviceCount,
    createdAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grpc_descriptor_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrpcDescriptorSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('source_identity')) {
      context.handle(
        _sourceIdentityMeta,
        sourceIdentity.isAcceptableOrUnknown(
          data['source_identity']!,
          _sourceIdentityMeta,
        ),
      );
    }
    if (data.containsKey('descriptor_bytes')) {
      context.handle(
        _descriptorBytesMeta,
        descriptorBytes.isAcceptableOrUnknown(
          data['descriptor_bytes']!,
          _descriptorBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptorBytesMeta);
    }
    if (data.containsKey('descriptor_byte_count')) {
      context.handle(
        _descriptorByteCountMeta,
        descriptorByteCount.isAcceptableOrUnknown(
          data['descriptor_byte_count']!,
          _descriptorByteCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptorByteCountMeta);
    }
    if (data.containsKey('file_count')) {
      context.handle(
        _fileCountMeta,
        fileCount.isAcceptableOrUnknown(data['file_count']!, _fileCountMeta),
      );
    } else if (isInserting) {
      context.missing(_fileCountMeta);
    }
    if (data.containsKey('service_count')) {
      context.handle(
        _serviceCountMeta,
        serviceCount.isAcceptableOrUnknown(
          data['service_count']!,
          _serviceCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrpcDescriptorSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrpcDescriptorSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      sourceIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_identity'],
      ),
      descriptorBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}descriptor_bytes'],
      )!,
      descriptorByteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}descriptor_byte_count'],
      )!,
      fileCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_count'],
      )!,
      serviceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $GrpcDescriptorSnapshotsTable createAlias(String alias) {
    return $GrpcDescriptorSnapshotsTable(attachedDatabase, alias);
  }
}

class GrpcDescriptorSnapshot extends DataClass
    implements Insertable<GrpcDescriptorSnapshot> {
  final String id;
  final String workspaceId;
  final String fingerprint;
  final String sourceType;
  final String displayName;
  final String? sourceIdentity;
  final Uint8List descriptorBytes;
  final int descriptorByteCount;
  final int fileCount;
  final int serviceCount;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  const GrpcDescriptorSnapshot({
    required this.id,
    required this.workspaceId,
    required this.fingerprint,
    required this.sourceType,
    required this.displayName,
    this.sourceIdentity,
    required this.descriptorBytes,
    required this.descriptorByteCount,
    required this.fileCount,
    required this.serviceCount,
    required this.createdAt,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['source_type'] = Variable<String>(sourceType);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || sourceIdentity != null) {
      map['source_identity'] = Variable<String>(sourceIdentity);
    }
    map['descriptor_bytes'] = Variable<Uint8List>(descriptorBytes);
    map['descriptor_byte_count'] = Variable<int>(descriptorByteCount);
    map['file_count'] = Variable<int>(fileCount);
    map['service_count'] = Variable<int>(serviceCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  GrpcDescriptorSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return GrpcDescriptorSnapshotsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      fingerprint: Value(fingerprint),
      sourceType: Value(sourceType),
      displayName: Value(displayName),
      sourceIdentity: sourceIdentity == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceIdentity),
      descriptorBytes: Value(descriptorBytes),
      descriptorByteCount: Value(descriptorByteCount),
      fileCount: Value(fileCount),
      serviceCount: Value(serviceCount),
      createdAt: Value(createdAt),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory GrpcDescriptorSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrpcDescriptorSnapshot(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      displayName: serializer.fromJson<String>(json['displayName']),
      sourceIdentity: serializer.fromJson<String?>(json['sourceIdentity']),
      descriptorBytes: serializer.fromJson<Uint8List>(json['descriptorBytes']),
      descriptorByteCount: serializer.fromJson<int>(
        json['descriptorByteCount'],
      ),
      fileCount: serializer.fromJson<int>(json['fileCount']),
      serviceCount: serializer.fromJson<int>(json['serviceCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'sourceType': serializer.toJson<String>(sourceType),
      'displayName': serializer.toJson<String>(displayName),
      'sourceIdentity': serializer.toJson<String?>(sourceIdentity),
      'descriptorBytes': serializer.toJson<Uint8List>(descriptorBytes),
      'descriptorByteCount': serializer.toJson<int>(descriptorByteCount),
      'fileCount': serializer.toJson<int>(fileCount),
      'serviceCount': serializer.toJson<int>(serviceCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  GrpcDescriptorSnapshot copyWith({
    String? id,
    String? workspaceId,
    String? fingerprint,
    String? sourceType,
    String? displayName,
    Value<String?> sourceIdentity = const Value.absent(),
    Uint8List? descriptorBytes,
    int? descriptorByteCount,
    int? fileCount,
    int? serviceCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) => GrpcDescriptorSnapshot(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    fingerprint: fingerprint ?? this.fingerprint,
    sourceType: sourceType ?? this.sourceType,
    displayName: displayName ?? this.displayName,
    sourceIdentity: sourceIdentity.present
        ? sourceIdentity.value
        : this.sourceIdentity,
    descriptorBytes: descriptorBytes ?? this.descriptorBytes,
    descriptorByteCount: descriptorByteCount ?? this.descriptorByteCount,
    fileCount: fileCount ?? this.fileCount,
    serviceCount: serviceCount ?? this.serviceCount,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  GrpcDescriptorSnapshot copyWithCompanion(
    GrpcDescriptorSnapshotsCompanion data,
  ) {
    return GrpcDescriptorSnapshot(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      sourceIdentity: data.sourceIdentity.present
          ? data.sourceIdentity.value
          : this.sourceIdentity,
      descriptorBytes: data.descriptorBytes.present
          ? data.descriptorBytes.value
          : this.descriptorBytes,
      descriptorByteCount: data.descriptorByteCount.present
          ? data.descriptorByteCount.value
          : this.descriptorByteCount,
      fileCount: data.fileCount.present ? data.fileCount.value : this.fileCount,
      serviceCount: data.serviceCount.present
          ? data.serviceCount.value
          : this.serviceCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrpcDescriptorSnapshot(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('sourceType: $sourceType, ')
          ..write('displayName: $displayName, ')
          ..write('sourceIdentity: $sourceIdentity, ')
          ..write('descriptorBytes: $descriptorBytes, ')
          ..write('descriptorByteCount: $descriptorByteCount, ')
          ..write('fileCount: $fileCount, ')
          ..write('serviceCount: $serviceCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    fingerprint,
    sourceType,
    displayName,
    sourceIdentity,
    $driftBlobEquality.hash(descriptorBytes),
    descriptorByteCount,
    fileCount,
    serviceCount,
    createdAt,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrpcDescriptorSnapshot &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.fingerprint == this.fingerprint &&
          other.sourceType == this.sourceType &&
          other.displayName == this.displayName &&
          other.sourceIdentity == this.sourceIdentity &&
          $driftBlobEquality.equals(
            other.descriptorBytes,
            this.descriptorBytes,
          ) &&
          other.descriptorByteCount == this.descriptorByteCount &&
          other.fileCount == this.fileCount &&
          other.serviceCount == this.serviceCount &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class GrpcDescriptorSnapshotsCompanion
    extends UpdateCompanion<GrpcDescriptorSnapshot> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> fingerprint;
  final Value<String> sourceType;
  final Value<String> displayName;
  final Value<String?> sourceIdentity;
  final Value<Uint8List> descriptorBytes;
  final Value<int> descriptorByteCount;
  final Value<int> fileCount;
  final Value<int> serviceCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const GrpcDescriptorSnapshotsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.displayName = const Value.absent(),
    this.sourceIdentity = const Value.absent(),
    this.descriptorBytes = const Value.absent(),
    this.descriptorByteCount = const Value.absent(),
    this.fileCount = const Value.absent(),
    this.serviceCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrpcDescriptorSnapshotsCompanion.insert({
    required String id,
    required String workspaceId,
    required String fingerprint,
    required String sourceType,
    required String displayName,
    this.sourceIdentity = const Value.absent(),
    required Uint8List descriptorBytes,
    required int descriptorByteCount,
    required int fileCount,
    required int serviceCount,
    required DateTime createdAt,
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       fingerprint = Value(fingerprint),
       sourceType = Value(sourceType),
       displayName = Value(displayName),
       descriptorBytes = Value(descriptorBytes),
       descriptorByteCount = Value(descriptorByteCount),
       fileCount = Value(fileCount),
       serviceCount = Value(serviceCount),
       createdAt = Value(createdAt),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<GrpcDescriptorSnapshot> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? fingerprint,
    Expression<String>? sourceType,
    Expression<String>? displayName,
    Expression<String>? sourceIdentity,
    Expression<Uint8List>? descriptorBytes,
    Expression<int>? descriptorByteCount,
    Expression<int>? fileCount,
    Expression<int>? serviceCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (sourceType != null) 'source_type': sourceType,
      if (displayName != null) 'display_name': displayName,
      if (sourceIdentity != null) 'source_identity': sourceIdentity,
      if (descriptorBytes != null) 'descriptor_bytes': descriptorBytes,
      if (descriptorByteCount != null)
        'descriptor_byte_count': descriptorByteCount,
      if (fileCount != null) 'file_count': fileCount,
      if (serviceCount != null) 'service_count': serviceCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrpcDescriptorSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? fingerprint,
    Value<String>? sourceType,
    Value<String>? displayName,
    Value<String?>? sourceIdentity,
    Value<Uint8List>? descriptorBytes,
    Value<int>? descriptorByteCount,
    Value<int>? fileCount,
    Value<int>? serviceCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return GrpcDescriptorSnapshotsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      fingerprint: fingerprint ?? this.fingerprint,
      sourceType: sourceType ?? this.sourceType,
      displayName: displayName ?? this.displayName,
      sourceIdentity: sourceIdentity ?? this.sourceIdentity,
      descriptorBytes: descriptorBytes ?? this.descriptorBytes,
      descriptorByteCount: descriptorByteCount ?? this.descriptorByteCount,
      fileCount: fileCount ?? this.fileCount,
      serviceCount: serviceCount ?? this.serviceCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (sourceIdentity.present) {
      map['source_identity'] = Variable<String>(sourceIdentity.value);
    }
    if (descriptorBytes.present) {
      map['descriptor_bytes'] = Variable<Uint8List>(descriptorBytes.value);
    }
    if (descriptorByteCount.present) {
      map['descriptor_byte_count'] = Variable<int>(descriptorByteCount.value);
    }
    if (fileCount.present) {
      map['file_count'] = Variable<int>(fileCount.value);
    }
    if (serviceCount.present) {
      map['service_count'] = Variable<int>(serviceCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrpcDescriptorSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('sourceType: $sourceType, ')
          ..write('displayName: $displayName, ')
          ..write('sourceIdentity: $sourceIdentity, ')
          ..write('descriptorBytes: $descriptorBytes, ')
          ..write('descriptorByteCount: $descriptorByteCount, ')
          ..write('fileCount: $fileCount, ')
          ..write('serviceCount: $serviceCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrpcSavedRequestsTable extends GrpcSavedRequests
    with TableInfo<$GrpcSavedRequestsTable, GrpcSavedRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrpcSavedRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptorSnapshotIdMeta =
      const VerificationMeta('descriptorSnapshotId');
  @override
  late final GeneratedColumn<String> descriptorSnapshotId =
      GeneratedColumn<String>(
        'descriptor_snapshot_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES grpc_descriptor_snapshots (id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serviceFullNameMeta = const VerificationMeta(
    'serviceFullName',
  );
  @override
  late final GeneratedColumn<String> serviceFullName = GeneratedColumn<String>(
    'service_full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodNameMeta = const VerificationMeta(
    'methodName',
  );
  @override
  late final GeneratedColumn<String> methodName = GeneratedColumn<String>(
    'method_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodPathMeta = const VerificationMeta(
    'methodPath',
  );
  @override
  late final GeneratedColumn<String> methodPath = GeneratedColumn<String>(
    'method_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invocationKindMeta = const VerificationMeta(
    'invocationKind',
  );
  @override
  late final GeneratedColumn<String> invocationKind = GeneratedColumn<String>(
    'invocation_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointJsonMeta = const VerificationMeta(
    'endpointJson',
  );
  @override
  late final GeneratedColumn<String> endpointJson = GeneratedColumn<String>(
    'endpoint_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestJsonMeta = const VerificationMeta(
    'requestJson',
  );
  @override
  late final GeneratedColumn<String> requestJson = GeneratedColumn<String>(
    'request_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _certificateReferencesJsonMeta =
      const VerificationMeta('certificateReferencesJson');
  @override
  late final GeneratedColumn<String> certificateReferencesJson =
      GeneratedColumn<String>(
        'certificate_references_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    collectionId,
    folderId,
    descriptorSnapshotId,
    name,
    sortOrder,
    serviceFullName,
    methodName,
    methodPath,
    invocationKind,
    endpointJson,
    requestJson,
    metadataJson,
    certificateReferencesJson,
    revision,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grpc_saved_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrpcSavedRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('descriptor_snapshot_id')) {
      context.handle(
        _descriptorSnapshotIdMeta,
        descriptorSnapshotId.isAcceptableOrUnknown(
          data['descriptor_snapshot_id']!,
          _descriptorSnapshotIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('service_full_name')) {
      context.handle(
        _serviceFullNameMeta,
        serviceFullName.isAcceptableOrUnknown(
          data['service_full_name']!,
          _serviceFullNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceFullNameMeta);
    }
    if (data.containsKey('method_name')) {
      context.handle(
        _methodNameMeta,
        methodName.isAcceptableOrUnknown(data['method_name']!, _methodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_methodNameMeta);
    }
    if (data.containsKey('method_path')) {
      context.handle(
        _methodPathMeta,
        methodPath.isAcceptableOrUnknown(data['method_path']!, _methodPathMeta),
      );
    } else if (isInserting) {
      context.missing(_methodPathMeta);
    }
    if (data.containsKey('invocation_kind')) {
      context.handle(
        _invocationKindMeta,
        invocationKind.isAcceptableOrUnknown(
          data['invocation_kind']!,
          _invocationKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invocationKindMeta);
    }
    if (data.containsKey('endpoint_json')) {
      context.handle(
        _endpointJsonMeta,
        endpointJson.isAcceptableOrUnknown(
          data['endpoint_json']!,
          _endpointJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endpointJsonMeta);
    }
    if (data.containsKey('request_json')) {
      context.handle(
        _requestJsonMeta,
        requestJson.isAcceptableOrUnknown(
          data['request_json']!,
          _requestJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestJsonMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    if (data.containsKey('certificate_references_json')) {
      context.handle(
        _certificateReferencesJsonMeta,
        certificateReferencesJson.isAcceptableOrUnknown(
          data['certificate_references_json']!,
          _certificateReferencesJsonMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrpcSavedRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrpcSavedRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      descriptorSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descriptor_snapshot_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      serviceFullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_full_name'],
      )!,
      methodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_name'],
      )!,
      methodPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_path'],
      )!,
      invocationKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invocation_kind'],
      )!,
      endpointJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint_json'],
      )!,
      requestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_json'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      certificateReferencesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certificate_references_json'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GrpcSavedRequestsTable createAlias(String alias) {
    return $GrpcSavedRequestsTable(attachedDatabase, alias);
  }
}

class GrpcSavedRequest extends DataClass
    implements Insertable<GrpcSavedRequest> {
  final String id;
  final String workspaceId;
  final String? collectionId;
  final String? folderId;
  final String? descriptorSnapshotId;
  final String name;
  final int sortOrder;
  final String serviceFullName;
  final String methodName;
  final String methodPath;
  final String invocationKind;
  final String endpointJson;
  final String requestJson;
  final String metadataJson;
  final String certificateReferencesJson;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GrpcSavedRequest({
    required this.id,
    required this.workspaceId,
    this.collectionId,
    this.folderId,
    this.descriptorSnapshotId,
    required this.name,
    required this.sortOrder,
    required this.serviceFullName,
    required this.methodName,
    required this.methodPath,
    required this.invocationKind,
    required this.endpointJson,
    required this.requestJson,
    required this.metadataJson,
    required this.certificateReferencesJson,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    if (!nullToAbsent || descriptorSnapshotId != null) {
      map['descriptor_snapshot_id'] = Variable<String>(descriptorSnapshotId);
    }
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['service_full_name'] = Variable<String>(serviceFullName);
    map['method_name'] = Variable<String>(methodName);
    map['method_path'] = Variable<String>(methodPath);
    map['invocation_kind'] = Variable<String>(invocationKind);
    map['endpoint_json'] = Variable<String>(endpointJson);
    map['request_json'] = Variable<String>(requestJson);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['certificate_references_json'] = Variable<String>(
      certificateReferencesJson,
    );
    map['revision'] = Variable<int>(revision);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GrpcSavedRequestsCompanion toCompanion(bool nullToAbsent) {
    return GrpcSavedRequestsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      descriptorSnapshotId: descriptorSnapshotId == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptorSnapshotId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      serviceFullName: Value(serviceFullName),
      methodName: Value(methodName),
      methodPath: Value(methodPath),
      invocationKind: Value(invocationKind),
      endpointJson: Value(endpointJson),
      requestJson: Value(requestJson),
      metadataJson: Value(metadataJson),
      certificateReferencesJson: Value(certificateReferencesJson),
      revision: Value(revision),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GrpcSavedRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrpcSavedRequest(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      descriptorSnapshotId: serializer.fromJson<String?>(
        json['descriptorSnapshotId'],
      ),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      serviceFullName: serializer.fromJson<String>(json['serviceFullName']),
      methodName: serializer.fromJson<String>(json['methodName']),
      methodPath: serializer.fromJson<String>(json['methodPath']),
      invocationKind: serializer.fromJson<String>(json['invocationKind']),
      endpointJson: serializer.fromJson<String>(json['endpointJson']),
      requestJson: serializer.fromJson<String>(json['requestJson']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      certificateReferencesJson: serializer.fromJson<String>(
        json['certificateReferencesJson'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'collectionId': serializer.toJson<String?>(collectionId),
      'folderId': serializer.toJson<String?>(folderId),
      'descriptorSnapshotId': serializer.toJson<String?>(descriptorSnapshotId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'serviceFullName': serializer.toJson<String>(serviceFullName),
      'methodName': serializer.toJson<String>(methodName),
      'methodPath': serializer.toJson<String>(methodPath),
      'invocationKind': serializer.toJson<String>(invocationKind),
      'endpointJson': serializer.toJson<String>(endpointJson),
      'requestJson': serializer.toJson<String>(requestJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'certificateReferencesJson': serializer.toJson<String>(
        certificateReferencesJson,
      ),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GrpcSavedRequest copyWith({
    String? id,
    String? workspaceId,
    Value<String?> collectionId = const Value.absent(),
    Value<String?> folderId = const Value.absent(),
    Value<String?> descriptorSnapshotId = const Value.absent(),
    String? name,
    int? sortOrder,
    String? serviceFullName,
    String? methodName,
    String? methodPath,
    String? invocationKind,
    String? endpointJson,
    String? requestJson,
    String? metadataJson,
    String? certificateReferencesJson,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GrpcSavedRequest(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    folderId: folderId.present ? folderId.value : this.folderId,
    descriptorSnapshotId: descriptorSnapshotId.present
        ? descriptorSnapshotId.value
        : this.descriptorSnapshotId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    serviceFullName: serviceFullName ?? this.serviceFullName,
    methodName: methodName ?? this.methodName,
    methodPath: methodPath ?? this.methodPath,
    invocationKind: invocationKind ?? this.invocationKind,
    endpointJson: endpointJson ?? this.endpointJson,
    requestJson: requestJson ?? this.requestJson,
    metadataJson: metadataJson ?? this.metadataJson,
    certificateReferencesJson:
        certificateReferencesJson ?? this.certificateReferencesJson,
    revision: revision ?? this.revision,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GrpcSavedRequest copyWithCompanion(GrpcSavedRequestsCompanion data) {
    return GrpcSavedRequest(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      descriptorSnapshotId: data.descriptorSnapshotId.present
          ? data.descriptorSnapshotId.value
          : this.descriptorSnapshotId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      serviceFullName: data.serviceFullName.present
          ? data.serviceFullName.value
          : this.serviceFullName,
      methodName: data.methodName.present
          ? data.methodName.value
          : this.methodName,
      methodPath: data.methodPath.present
          ? data.methodPath.value
          : this.methodPath,
      invocationKind: data.invocationKind.present
          ? data.invocationKind.value
          : this.invocationKind,
      endpointJson: data.endpointJson.present
          ? data.endpointJson.value
          : this.endpointJson,
      requestJson: data.requestJson.present
          ? data.requestJson.value
          : this.requestJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      certificateReferencesJson: data.certificateReferencesJson.present
          ? data.certificateReferencesJson.value
          : this.certificateReferencesJson,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrpcSavedRequest(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('descriptorSnapshotId: $descriptorSnapshotId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serviceFullName: $serviceFullName, ')
          ..write('methodName: $methodName, ')
          ..write('methodPath: $methodPath, ')
          ..write('invocationKind: $invocationKind, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('requestJson: $requestJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('certificateReferencesJson: $certificateReferencesJson, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    collectionId,
    folderId,
    descriptorSnapshotId,
    name,
    sortOrder,
    serviceFullName,
    methodName,
    methodPath,
    invocationKind,
    endpointJson,
    requestJson,
    metadataJson,
    certificateReferencesJson,
    revision,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrpcSavedRequest &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.collectionId == this.collectionId &&
          other.folderId == this.folderId &&
          other.descriptorSnapshotId == this.descriptorSnapshotId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.serviceFullName == this.serviceFullName &&
          other.methodName == this.methodName &&
          other.methodPath == this.methodPath &&
          other.invocationKind == this.invocationKind &&
          other.endpointJson == this.endpointJson &&
          other.requestJson == this.requestJson &&
          other.metadataJson == this.metadataJson &&
          other.certificateReferencesJson == this.certificateReferencesJson &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GrpcSavedRequestsCompanion extends UpdateCompanion<GrpcSavedRequest> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> collectionId;
  final Value<String?> folderId;
  final Value<String?> descriptorSnapshotId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String> serviceFullName;
  final Value<String> methodName;
  final Value<String> methodPath;
  final Value<String> invocationKind;
  final Value<String> endpointJson;
  final Value<String> requestJson;
  final Value<String> metadataJson;
  final Value<String> certificateReferencesJson;
  final Value<int> revision;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GrpcSavedRequestsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.descriptorSnapshotId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.serviceFullName = const Value.absent(),
    this.methodName = const Value.absent(),
    this.methodPath = const Value.absent(),
    this.invocationKind = const Value.absent(),
    this.endpointJson = const Value.absent(),
    this.requestJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.certificateReferencesJson = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrpcSavedRequestsCompanion.insert({
    required String id,
    required String workspaceId,
    this.collectionId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.descriptorSnapshotId = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    required String serviceFullName,
    required String methodName,
    required String methodPath,
    required String invocationKind,
    required String endpointJson,
    required String requestJson,
    required String metadataJson,
    this.certificateReferencesJson = const Value.absent(),
    this.revision = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name),
       serviceFullName = Value(serviceFullName),
       methodName = Value(methodName),
       methodPath = Value(methodPath),
       invocationKind = Value(invocationKind),
       endpointJson = Value(endpointJson),
       requestJson = Value(requestJson),
       metadataJson = Value(metadataJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GrpcSavedRequest> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? collectionId,
    Expression<String>? folderId,
    Expression<String>? descriptorSnapshotId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? serviceFullName,
    Expression<String>? methodName,
    Expression<String>? methodPath,
    Expression<String>? invocationKind,
    Expression<String>? endpointJson,
    Expression<String>? requestJson,
    Expression<String>? metadataJson,
    Expression<String>? certificateReferencesJson,
    Expression<int>? revision,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (collectionId != null) 'collection_id': collectionId,
      if (folderId != null) 'folder_id': folderId,
      if (descriptorSnapshotId != null)
        'descriptor_snapshot_id': descriptorSnapshotId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (serviceFullName != null) 'service_full_name': serviceFullName,
      if (methodName != null) 'method_name': methodName,
      if (methodPath != null) 'method_path': methodPath,
      if (invocationKind != null) 'invocation_kind': invocationKind,
      if (endpointJson != null) 'endpoint_json': endpointJson,
      if (requestJson != null) 'request_json': requestJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (certificateReferencesJson != null)
        'certificate_references_json': certificateReferencesJson,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrpcSavedRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? collectionId,
    Value<String?>? folderId,
    Value<String?>? descriptorSnapshotId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<String>? serviceFullName,
    Value<String>? methodName,
    Value<String>? methodPath,
    Value<String>? invocationKind,
    Value<String>? endpointJson,
    Value<String>? requestJson,
    Value<String>? metadataJson,
    Value<String>? certificateReferencesJson,
    Value<int>? revision,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GrpcSavedRequestsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      collectionId: collectionId ?? this.collectionId,
      folderId: folderId ?? this.folderId,
      descriptorSnapshotId: descriptorSnapshotId ?? this.descriptorSnapshotId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      serviceFullName: serviceFullName ?? this.serviceFullName,
      methodName: methodName ?? this.methodName,
      methodPath: methodPath ?? this.methodPath,
      invocationKind: invocationKind ?? this.invocationKind,
      endpointJson: endpointJson ?? this.endpointJson,
      requestJson: requestJson ?? this.requestJson,
      metadataJson: metadataJson ?? this.metadataJson,
      certificateReferencesJson:
          certificateReferencesJson ?? this.certificateReferencesJson,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (descriptorSnapshotId.present) {
      map['descriptor_snapshot_id'] = Variable<String>(
        descriptorSnapshotId.value,
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (serviceFullName.present) {
      map['service_full_name'] = Variable<String>(serviceFullName.value);
    }
    if (methodName.present) {
      map['method_name'] = Variable<String>(methodName.value);
    }
    if (methodPath.present) {
      map['method_path'] = Variable<String>(methodPath.value);
    }
    if (invocationKind.present) {
      map['invocation_kind'] = Variable<String>(invocationKind.value);
    }
    if (endpointJson.present) {
      map['endpoint_json'] = Variable<String>(endpointJson.value);
    }
    if (requestJson.present) {
      map['request_json'] = Variable<String>(requestJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (certificateReferencesJson.present) {
      map['certificate_references_json'] = Variable<String>(
        certificateReferencesJson.value,
      );
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrpcSavedRequestsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('descriptorSnapshotId: $descriptorSnapshotId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serviceFullName: $serviceFullName, ')
          ..write('methodName: $methodName, ')
          ..write('methodPath: $methodPath, ')
          ..write('invocationKind: $invocationKind, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('requestJson: $requestJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('certificateReferencesJson: $certificateReferencesJson, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrpcDraftsTable extends GrpcDrafts
    with TableInfo<$GrpcDraftsTable, GrpcDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrpcDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceSavedRequestIdMeta =
      const VerificationMeta('sourceSavedRequestId');
  @override
  late final GeneratedColumn<String> sourceSavedRequestId =
      GeneratedColumn<String>(
        'source_saved_request_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES grpc_saved_requests (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _descriptorSnapshotIdMeta =
      const VerificationMeta('descriptorSnapshotId');
  @override
  late final GeneratedColumn<String> descriptorSnapshotId =
      GeneratedColumn<String>(
        'descriptor_snapshot_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES grpc_descriptor_snapshots (id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodIdentityJsonMeta =
      const VerificationMeta('methodIdentityJson');
  @override
  late final GeneratedColumn<String> methodIdentityJson =
      GeneratedColumn<String>(
        'method_identity_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endpointJsonMeta = const VerificationMeta(
    'endpointJson',
  );
  @override
  late final GeneratedColumn<String> endpointJson = GeneratedColumn<String>(
    'endpoint_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestJsonMeta = const VerificationMeta(
    'requestJson',
  );
  @override
  late final GeneratedColumn<String> requestJson = GeneratedColumn<String>(
    'request_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _certificateReferencesJsonMeta =
      const VerificationMeta('certificateReferencesJson');
  @override
  late final GeneratedColumn<String> certificateReferencesJson =
      GeneratedColumn<String>(
        'certificate_references_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tabOrderMeta = const VerificationMeta(
    'tabOrder',
  );
  @override
  late final GeneratedColumn<int> tabOrder = GeneratedColumn<int>(
    'tab_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    sourceSavedRequestId,
    descriptorSnapshotId,
    title,
    methodIdentityJson,
    endpointJson,
    requestJson,
    metadataJson,
    certificateReferencesJson,
    revision,
    tabOrder,
    dirty,
    createdAt,
    updatedAt,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grpc_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrpcDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('source_saved_request_id')) {
      context.handle(
        _sourceSavedRequestIdMeta,
        sourceSavedRequestId.isAcceptableOrUnknown(
          data['source_saved_request_id']!,
          _sourceSavedRequestIdMeta,
        ),
      );
    }
    if (data.containsKey('descriptor_snapshot_id')) {
      context.handle(
        _descriptorSnapshotIdMeta,
        descriptorSnapshotId.isAcceptableOrUnknown(
          data['descriptor_snapshot_id']!,
          _descriptorSnapshotIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('method_identity_json')) {
      context.handle(
        _methodIdentityJsonMeta,
        methodIdentityJson.isAcceptableOrUnknown(
          data['method_identity_json']!,
          _methodIdentityJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_methodIdentityJsonMeta);
    }
    if (data.containsKey('endpoint_json')) {
      context.handle(
        _endpointJsonMeta,
        endpointJson.isAcceptableOrUnknown(
          data['endpoint_json']!,
          _endpointJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endpointJsonMeta);
    }
    if (data.containsKey('request_json')) {
      context.handle(
        _requestJsonMeta,
        requestJson.isAcceptableOrUnknown(
          data['request_json']!,
          _requestJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestJsonMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    if (data.containsKey('certificate_references_json')) {
      context.handle(
        _certificateReferencesJsonMeta,
        certificateReferencesJson.isAcceptableOrUnknown(
          data['certificate_references_json']!,
          _certificateReferencesJsonMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('tab_order')) {
      context.handle(
        _tabOrderMeta,
        tabOrder.isAcceptableOrUnknown(data['tab_order']!, _tabOrderMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrpcDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrpcDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      sourceSavedRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_saved_request_id'],
      ),
      descriptorSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descriptor_snapshot_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      methodIdentityJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_identity_json'],
      )!,
      endpointJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint_json'],
      )!,
      requestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_json'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      certificateReferencesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certificate_references_json'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      tabOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tab_order'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
    );
  }

  @override
  $GrpcDraftsTable createAlias(String alias) {
    return $GrpcDraftsTable(attachedDatabase, alias);
  }
}

class GrpcDraft extends DataClass implements Insertable<GrpcDraft> {
  final String id;
  final String workspaceId;
  final String? sourceSavedRequestId;
  final String? descriptorSnapshotId;
  final String title;
  final String methodIdentityJson;
  final String endpointJson;
  final String requestJson;
  final String metadataJson;
  final String certificateReferencesJson;
  final int revision;
  final int tabOrder;
  final bool dirty;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastOpenedAt;
  const GrpcDraft({
    required this.id,
    required this.workspaceId,
    this.sourceSavedRequestId,
    this.descriptorSnapshotId,
    required this.title,
    required this.methodIdentityJson,
    required this.endpointJson,
    required this.requestJson,
    required this.metadataJson,
    required this.certificateReferencesJson,
    required this.revision,
    required this.tabOrder,
    required this.dirty,
    required this.createdAt,
    required this.updatedAt,
    required this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || sourceSavedRequestId != null) {
      map['source_saved_request_id'] = Variable<String>(sourceSavedRequestId);
    }
    if (!nullToAbsent || descriptorSnapshotId != null) {
      map['descriptor_snapshot_id'] = Variable<String>(descriptorSnapshotId);
    }
    map['title'] = Variable<String>(title);
    map['method_identity_json'] = Variable<String>(methodIdentityJson);
    map['endpoint_json'] = Variable<String>(endpointJson);
    map['request_json'] = Variable<String>(requestJson);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['certificate_references_json'] = Variable<String>(
      certificateReferencesJson,
    );
    map['revision'] = Variable<int>(revision);
    map['tab_order'] = Variable<int>(tabOrder);
    map['dirty'] = Variable<bool>(dirty);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    return map;
  }

  GrpcDraftsCompanion toCompanion(bool nullToAbsent) {
    return GrpcDraftsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      sourceSavedRequestId: sourceSavedRequestId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSavedRequestId),
      descriptorSnapshotId: descriptorSnapshotId == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptorSnapshotId),
      title: Value(title),
      methodIdentityJson: Value(methodIdentityJson),
      endpointJson: Value(endpointJson),
      requestJson: Value(requestJson),
      metadataJson: Value(metadataJson),
      certificateReferencesJson: Value(certificateReferencesJson),
      revision: Value(revision),
      tabOrder: Value(tabOrder),
      dirty: Value(dirty),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastOpenedAt: Value(lastOpenedAt),
    );
  }

  factory GrpcDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrpcDraft(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      sourceSavedRequestId: serializer.fromJson<String?>(
        json['sourceSavedRequestId'],
      ),
      descriptorSnapshotId: serializer.fromJson<String?>(
        json['descriptorSnapshotId'],
      ),
      title: serializer.fromJson<String>(json['title']),
      methodIdentityJson: serializer.fromJson<String>(
        json['methodIdentityJson'],
      ),
      endpointJson: serializer.fromJson<String>(json['endpointJson']),
      requestJson: serializer.fromJson<String>(json['requestJson']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      certificateReferencesJson: serializer.fromJson<String>(
        json['certificateReferencesJson'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      tabOrder: serializer.fromJson<int>(json['tabOrder']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'sourceSavedRequestId': serializer.toJson<String?>(sourceSavedRequestId),
      'descriptorSnapshotId': serializer.toJson<String?>(descriptorSnapshotId),
      'title': serializer.toJson<String>(title),
      'methodIdentityJson': serializer.toJson<String>(methodIdentityJson),
      'endpointJson': serializer.toJson<String>(endpointJson),
      'requestJson': serializer.toJson<String>(requestJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'certificateReferencesJson': serializer.toJson<String>(
        certificateReferencesJson,
      ),
      'revision': serializer.toJson<int>(revision),
      'tabOrder': serializer.toJson<int>(tabOrder),
      'dirty': serializer.toJson<bool>(dirty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
    };
  }

  GrpcDraft copyWith({
    String? id,
    String? workspaceId,
    Value<String?> sourceSavedRequestId = const Value.absent(),
    Value<String?> descriptorSnapshotId = const Value.absent(),
    String? title,
    String? methodIdentityJson,
    String? endpointJson,
    String? requestJson,
    String? metadataJson,
    String? certificateReferencesJson,
    int? revision,
    int? tabOrder,
    bool? dirty,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
  }) => GrpcDraft(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    sourceSavedRequestId: sourceSavedRequestId.present
        ? sourceSavedRequestId.value
        : this.sourceSavedRequestId,
    descriptorSnapshotId: descriptorSnapshotId.present
        ? descriptorSnapshotId.value
        : this.descriptorSnapshotId,
    title: title ?? this.title,
    methodIdentityJson: methodIdentityJson ?? this.methodIdentityJson,
    endpointJson: endpointJson ?? this.endpointJson,
    requestJson: requestJson ?? this.requestJson,
    metadataJson: metadataJson ?? this.metadataJson,
    certificateReferencesJson:
        certificateReferencesJson ?? this.certificateReferencesJson,
    revision: revision ?? this.revision,
    tabOrder: tabOrder ?? this.tabOrder,
    dirty: dirty ?? this.dirty,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
  GrpcDraft copyWithCompanion(GrpcDraftsCompanion data) {
    return GrpcDraft(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      sourceSavedRequestId: data.sourceSavedRequestId.present
          ? data.sourceSavedRequestId.value
          : this.sourceSavedRequestId,
      descriptorSnapshotId: data.descriptorSnapshotId.present
          ? data.descriptorSnapshotId.value
          : this.descriptorSnapshotId,
      title: data.title.present ? data.title.value : this.title,
      methodIdentityJson: data.methodIdentityJson.present
          ? data.methodIdentityJson.value
          : this.methodIdentityJson,
      endpointJson: data.endpointJson.present
          ? data.endpointJson.value
          : this.endpointJson,
      requestJson: data.requestJson.present
          ? data.requestJson.value
          : this.requestJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      certificateReferencesJson: data.certificateReferencesJson.present
          ? data.certificateReferencesJson.value
          : this.certificateReferencesJson,
      revision: data.revision.present ? data.revision.value : this.revision,
      tabOrder: data.tabOrder.present ? data.tabOrder.value : this.tabOrder,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrpcDraft(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sourceSavedRequestId: $sourceSavedRequestId, ')
          ..write('descriptorSnapshotId: $descriptorSnapshotId, ')
          ..write('title: $title, ')
          ..write('methodIdentityJson: $methodIdentityJson, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('requestJson: $requestJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('certificateReferencesJson: $certificateReferencesJson, ')
          ..write('revision: $revision, ')
          ..write('tabOrder: $tabOrder, ')
          ..write('dirty: $dirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    sourceSavedRequestId,
    descriptorSnapshotId,
    title,
    methodIdentityJson,
    endpointJson,
    requestJson,
    metadataJson,
    certificateReferencesJson,
    revision,
    tabOrder,
    dirty,
    createdAt,
    updatedAt,
    lastOpenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrpcDraft &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.sourceSavedRequestId == this.sourceSavedRequestId &&
          other.descriptorSnapshotId == this.descriptorSnapshotId &&
          other.title == this.title &&
          other.methodIdentityJson == this.methodIdentityJson &&
          other.endpointJson == this.endpointJson &&
          other.requestJson == this.requestJson &&
          other.metadataJson == this.metadataJson &&
          other.certificateReferencesJson == this.certificateReferencesJson &&
          other.revision == this.revision &&
          other.tabOrder == this.tabOrder &&
          other.dirty == this.dirty &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class GrpcDraftsCompanion extends UpdateCompanion<GrpcDraft> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> sourceSavedRequestId;
  final Value<String?> descriptorSnapshotId;
  final Value<String> title;
  final Value<String> methodIdentityJson;
  final Value<String> endpointJson;
  final Value<String> requestJson;
  final Value<String> metadataJson;
  final Value<String> certificateReferencesJson;
  final Value<int> revision;
  final Value<int> tabOrder;
  final Value<bool> dirty;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> lastOpenedAt;
  final Value<int> rowid;
  const GrpcDraftsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.sourceSavedRequestId = const Value.absent(),
    this.descriptorSnapshotId = const Value.absent(),
    this.title = const Value.absent(),
    this.methodIdentityJson = const Value.absent(),
    this.endpointJson = const Value.absent(),
    this.requestJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.certificateReferencesJson = const Value.absent(),
    this.revision = const Value.absent(),
    this.tabOrder = const Value.absent(),
    this.dirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrpcDraftsCompanion.insert({
    required String id,
    required String workspaceId,
    this.sourceSavedRequestId = const Value.absent(),
    this.descriptorSnapshotId = const Value.absent(),
    required String title,
    required String methodIdentityJson,
    required String endpointJson,
    required String requestJson,
    required String metadataJson,
    this.certificateReferencesJson = const Value.absent(),
    this.revision = const Value.absent(),
    this.tabOrder = const Value.absent(),
    this.dirty = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastOpenedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       title = Value(title),
       methodIdentityJson = Value(methodIdentityJson),
       endpointJson = Value(endpointJson),
       requestJson = Value(requestJson),
       metadataJson = Value(metadataJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<GrpcDraft> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? sourceSavedRequestId,
    Expression<String>? descriptorSnapshotId,
    Expression<String>? title,
    Expression<String>? methodIdentityJson,
    Expression<String>? endpointJson,
    Expression<String>? requestJson,
    Expression<String>? metadataJson,
    Expression<String>? certificateReferencesJson,
    Expression<int>? revision,
    Expression<int>? tabOrder,
    Expression<bool>? dirty,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (sourceSavedRequestId != null)
        'source_saved_request_id': sourceSavedRequestId,
      if (descriptorSnapshotId != null)
        'descriptor_snapshot_id': descriptorSnapshotId,
      if (title != null) 'title': title,
      if (methodIdentityJson != null)
        'method_identity_json': methodIdentityJson,
      if (endpointJson != null) 'endpoint_json': endpointJson,
      if (requestJson != null) 'request_json': requestJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (certificateReferencesJson != null)
        'certificate_references_json': certificateReferencesJson,
      if (revision != null) 'revision': revision,
      if (tabOrder != null) 'tab_order': tabOrder,
      if (dirty != null) 'dirty': dirty,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrpcDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? sourceSavedRequestId,
    Value<String?>? descriptorSnapshotId,
    Value<String>? title,
    Value<String>? methodIdentityJson,
    Value<String>? endpointJson,
    Value<String>? requestJson,
    Value<String>? metadataJson,
    Value<String>? certificateReferencesJson,
    Value<int>? revision,
    Value<int>? tabOrder,
    Value<bool>? dirty,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? lastOpenedAt,
    Value<int>? rowid,
  }) {
    return GrpcDraftsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      sourceSavedRequestId: sourceSavedRequestId ?? this.sourceSavedRequestId,
      descriptorSnapshotId: descriptorSnapshotId ?? this.descriptorSnapshotId,
      title: title ?? this.title,
      methodIdentityJson: methodIdentityJson ?? this.methodIdentityJson,
      endpointJson: endpointJson ?? this.endpointJson,
      requestJson: requestJson ?? this.requestJson,
      metadataJson: metadataJson ?? this.metadataJson,
      certificateReferencesJson:
          certificateReferencesJson ?? this.certificateReferencesJson,
      revision: revision ?? this.revision,
      tabOrder: tabOrder ?? this.tabOrder,
      dirty: dirty ?? this.dirty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (sourceSavedRequestId.present) {
      map['source_saved_request_id'] = Variable<String>(
        sourceSavedRequestId.value,
      );
    }
    if (descriptorSnapshotId.present) {
      map['descriptor_snapshot_id'] = Variable<String>(
        descriptorSnapshotId.value,
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (methodIdentityJson.present) {
      map['method_identity_json'] = Variable<String>(methodIdentityJson.value);
    }
    if (endpointJson.present) {
      map['endpoint_json'] = Variable<String>(endpointJson.value);
    }
    if (requestJson.present) {
      map['request_json'] = Variable<String>(requestJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (certificateReferencesJson.present) {
      map['certificate_references_json'] = Variable<String>(
        certificateReferencesJson.value,
      );
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (tabOrder.present) {
      map['tab_order'] = Variable<int>(tabOrder.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrpcDraftsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sourceSavedRequestId: $sourceSavedRequestId, ')
          ..write('descriptorSnapshotId: $descriptorSnapshotId, ')
          ..write('title: $title, ')
          ..write('methodIdentityJson: $methodIdentityJson, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('requestJson: $requestJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('certificateReferencesJson: $certificateReferencesJson, ')
          ..write('revision: $revision, ')
          ..write('tabOrder: $tabOrder, ')
          ..write('dirty: $dirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrpcInvocationHistoryTable extends GrpcInvocationHistory
    with TableInfo<$GrpcInvocationHistoryTable, GrpcInvocationHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrpcInvocationHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _savedRequestIdMeta = const VerificationMeta(
    'savedRequestId',
  );
  @override
  late final GeneratedColumn<String> savedRequestId = GeneratedColumn<String>(
    'saved_request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grpc_saved_requests (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _descriptorSnapshotIdMeta =
      const VerificationMeta('descriptorSnapshotId');
  @override
  late final GeneratedColumn<String> descriptorSnapshotId =
      GeneratedColumn<String>(
        'descriptor_snapshot_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES grpc_descriptor_snapshots (id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _invocationKindMeta = const VerificationMeta(
    'invocationKind',
  );
  @override
  late final GeneratedColumn<String> invocationKind = GeneratedColumn<String>(
    'invocation_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMicrosecondsMeta =
      const VerificationMeta('durationMicroseconds');
  @override
  late final GeneratedColumn<int> durationMicroseconds = GeneratedColumn<int>(
    'duration_microseconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endpointJsonMeta = const VerificationMeta(
    'endpointJson',
  );
  @override
  late final GeneratedColumn<String> endpointJson = GeneratedColumn<String>(
    'endpoint_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodIdentityJsonMeta =
      const VerificationMeta('methodIdentityJson');
  @override
  late final GeneratedColumn<String> methodIdentityJson =
      GeneratedColumn<String>(
        'method_identity_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _requestJsonMeta = const VerificationMeta(
    'requestJson',
  );
  @override
  late final GeneratedColumn<String> requestJson = GeneratedColumn<String>(
    'request_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestMetadataJsonMeta =
      const VerificationMeta('requestMetadataJson');
  @override
  late final GeneratedColumn<String> requestMetadataJson =
      GeneratedColumn<String>(
        'request_metadata_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _responseJsonMeta = const VerificationMeta(
    'responseJson',
  );
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
    'response_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseHeadersJsonMeta =
      const VerificationMeta('responseHeadersJson');
  @override
  late final GeneratedColumn<String> responseHeadersJson =
      GeneratedColumn<String>(
        'response_headers_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _responseTrailersJsonMeta =
      const VerificationMeta('responseTrailersJson');
  @override
  late final GeneratedColumn<String> responseTrailersJson =
      GeneratedColumn<String>(
        'response_trailers_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusNameMeta = const VerificationMeta(
    'statusName',
  );
  @override
  late final GeneratedColumn<String> statusName = GeneratedColumn<String>(
    'status_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMessageMeta = const VerificationMeta(
    'statusMessage',
  );
  @override
  late final GeneratedColumn<String> statusMessage = GeneratedColumn<String>(
    'status_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestByteCountMeta = const VerificationMeta(
    'requestByteCount',
  );
  @override
  late final GeneratedColumn<int> requestByteCount = GeneratedColumn<int>(
    'request_byte_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _responseByteCountMeta = const VerificationMeta(
    'responseByteCount',
  );
  @override
  late final GeneratedColumn<int> responseByteCount = GeneratedColumn<int>(
    'response_byte_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosticCategoryMeta =
      const VerificationMeta('diagnosticCategory');
  @override
  late final GeneratedColumn<String> diagnosticCategory =
      GeneratedColumn<String>(
        'diagnostic_category',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _droppedEventCountMeta = const VerificationMeta(
    'droppedEventCount',
  );
  @override
  late final GeneratedColumn<int> droppedEventCount = GeneratedColumn<int>(
    'dropped_event_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _terminalStateMeta = const VerificationMeta(
    'terminalState',
  );
  @override
  late final GeneratedColumn<String> terminalState = GeneratedColumn<String>(
    'terminal_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    savedRequestId,
    descriptorSnapshotId,
    invocationKind,
    startedAt,
    completedAt,
    durationMicroseconds,
    endpointJson,
    methodIdentityJson,
    requestJson,
    requestMetadataJson,
    responseJson,
    responseHeadersJson,
    responseTrailersJson,
    statusCode,
    statusName,
    statusMessage,
    requestByteCount,
    responseByteCount,
    outcome,
    diagnosticCategory,
    droppedEventCount,
    terminalState,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grpc_invocation_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrpcInvocationHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('saved_request_id')) {
      context.handle(
        _savedRequestIdMeta,
        savedRequestId.isAcceptableOrUnknown(
          data['saved_request_id']!,
          _savedRequestIdMeta,
        ),
      );
    }
    if (data.containsKey('descriptor_snapshot_id')) {
      context.handle(
        _descriptorSnapshotIdMeta,
        descriptorSnapshotId.isAcceptableOrUnknown(
          data['descriptor_snapshot_id']!,
          _descriptorSnapshotIdMeta,
        ),
      );
    }
    if (data.containsKey('invocation_kind')) {
      context.handle(
        _invocationKindMeta,
        invocationKind.isAcceptableOrUnknown(
          data['invocation_kind']!,
          _invocationKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invocationKindMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('duration_microseconds')) {
      context.handle(
        _durationMicrosecondsMeta,
        durationMicroseconds.isAcceptableOrUnknown(
          data['duration_microseconds']!,
          _durationMicrosecondsMeta,
        ),
      );
    }
    if (data.containsKey('endpoint_json')) {
      context.handle(
        _endpointJsonMeta,
        endpointJson.isAcceptableOrUnknown(
          data['endpoint_json']!,
          _endpointJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endpointJsonMeta);
    }
    if (data.containsKey('method_identity_json')) {
      context.handle(
        _methodIdentityJsonMeta,
        methodIdentityJson.isAcceptableOrUnknown(
          data['method_identity_json']!,
          _methodIdentityJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_methodIdentityJsonMeta);
    }
    if (data.containsKey('request_json')) {
      context.handle(
        _requestJsonMeta,
        requestJson.isAcceptableOrUnknown(
          data['request_json']!,
          _requestJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestJsonMeta);
    }
    if (data.containsKey('request_metadata_json')) {
      context.handle(
        _requestMetadataJsonMeta,
        requestMetadataJson.isAcceptableOrUnknown(
          data['request_metadata_json']!,
          _requestMetadataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestMetadataJsonMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
        _responseJsonMeta,
        responseJson.isAcceptableOrUnknown(
          data['response_json']!,
          _responseJsonMeta,
        ),
      );
    }
    if (data.containsKey('response_headers_json')) {
      context.handle(
        _responseHeadersJsonMeta,
        responseHeadersJson.isAcceptableOrUnknown(
          data['response_headers_json']!,
          _responseHeadersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseHeadersJsonMeta);
    }
    if (data.containsKey('response_trailers_json')) {
      context.handle(
        _responseTrailersJsonMeta,
        responseTrailersJson.isAcceptableOrUnknown(
          data['response_trailers_json']!,
          _responseTrailersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseTrailersJsonMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    }
    if (data.containsKey('status_name')) {
      context.handle(
        _statusNameMeta,
        statusName.isAcceptableOrUnknown(data['status_name']!, _statusNameMeta),
      );
    }
    if (data.containsKey('status_message')) {
      context.handle(
        _statusMessageMeta,
        statusMessage.isAcceptableOrUnknown(
          data['status_message']!,
          _statusMessageMeta,
        ),
      );
    }
    if (data.containsKey('request_byte_count')) {
      context.handle(
        _requestByteCountMeta,
        requestByteCount.isAcceptableOrUnknown(
          data['request_byte_count']!,
          _requestByteCountMeta,
        ),
      );
    }
    if (data.containsKey('response_byte_count')) {
      context.handle(
        _responseByteCountMeta,
        responseByteCount.isAcceptableOrUnknown(
          data['response_byte_count']!,
          _responseByteCountMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('diagnostic_category')) {
      context.handle(
        _diagnosticCategoryMeta,
        diagnosticCategory.isAcceptableOrUnknown(
          data['diagnostic_category']!,
          _diagnosticCategoryMeta,
        ),
      );
    }
    if (data.containsKey('dropped_event_count')) {
      context.handle(
        _droppedEventCountMeta,
        droppedEventCount.isAcceptableOrUnknown(
          data['dropped_event_count']!,
          _droppedEventCountMeta,
        ),
      );
    }
    if (data.containsKey('terminal_state')) {
      context.handle(
        _terminalStateMeta,
        terminalState.isAcceptableOrUnknown(
          data['terminal_state']!,
          _terminalStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_terminalStateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrpcInvocationHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrpcInvocationHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      savedRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_request_id'],
      ),
      descriptorSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descriptor_snapshot_id'],
      ),
      invocationKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invocation_kind'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      durationMicroseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_microseconds'],
      ),
      endpointJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint_json'],
      )!,
      methodIdentityJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_identity_json'],
      )!,
      requestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_json'],
      )!,
      requestMetadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_metadata_json'],
      )!,
      responseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_json'],
      ),
      responseHeadersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_headers_json'],
      )!,
      responseTrailersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_trailers_json'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      ),
      statusName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_name'],
      ),
      statusMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_message'],
      ),
      requestByteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_byte_count'],
      )!,
      responseByteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_byte_count'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      diagnosticCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnostic_category'],
      ),
      droppedEventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dropped_event_count'],
      )!,
      terminalState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terminal_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GrpcInvocationHistoryTable createAlias(String alias) {
    return $GrpcInvocationHistoryTable(attachedDatabase, alias);
  }
}

class GrpcInvocationHistoryData extends DataClass
    implements Insertable<GrpcInvocationHistoryData> {
  final String id;
  final String workspaceId;
  final String? savedRequestId;
  final String? descriptorSnapshotId;
  final String invocationKind;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMicroseconds;
  final String endpointJson;
  final String methodIdentityJson;
  final String requestJson;
  final String requestMetadataJson;
  final String? responseJson;
  final String responseHeadersJson;
  final String responseTrailersJson;
  final int? statusCode;
  final String? statusName;
  final String? statusMessage;
  final int requestByteCount;
  final int responseByteCount;
  final String outcome;
  final String? diagnosticCategory;
  final int droppedEventCount;
  final String terminalState;
  final DateTime createdAt;
  const GrpcInvocationHistoryData({
    required this.id,
    required this.workspaceId,
    this.savedRequestId,
    this.descriptorSnapshotId,
    required this.invocationKind,
    required this.startedAt,
    this.completedAt,
    this.durationMicroseconds,
    required this.endpointJson,
    required this.methodIdentityJson,
    required this.requestJson,
    required this.requestMetadataJson,
    this.responseJson,
    required this.responseHeadersJson,
    required this.responseTrailersJson,
    this.statusCode,
    this.statusName,
    this.statusMessage,
    required this.requestByteCount,
    required this.responseByteCount,
    required this.outcome,
    this.diagnosticCategory,
    required this.droppedEventCount,
    required this.terminalState,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || savedRequestId != null) {
      map['saved_request_id'] = Variable<String>(savedRequestId);
    }
    if (!nullToAbsent || descriptorSnapshotId != null) {
      map['descriptor_snapshot_id'] = Variable<String>(descriptorSnapshotId);
    }
    map['invocation_kind'] = Variable<String>(invocationKind);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || durationMicroseconds != null) {
      map['duration_microseconds'] = Variable<int>(durationMicroseconds);
    }
    map['endpoint_json'] = Variable<String>(endpointJson);
    map['method_identity_json'] = Variable<String>(methodIdentityJson);
    map['request_json'] = Variable<String>(requestJson);
    map['request_metadata_json'] = Variable<String>(requestMetadataJson);
    if (!nullToAbsent || responseJson != null) {
      map['response_json'] = Variable<String>(responseJson);
    }
    map['response_headers_json'] = Variable<String>(responseHeadersJson);
    map['response_trailers_json'] = Variable<String>(responseTrailersJson);
    if (!nullToAbsent || statusCode != null) {
      map['status_code'] = Variable<int>(statusCode);
    }
    if (!nullToAbsent || statusName != null) {
      map['status_name'] = Variable<String>(statusName);
    }
    if (!nullToAbsent || statusMessage != null) {
      map['status_message'] = Variable<String>(statusMessage);
    }
    map['request_byte_count'] = Variable<int>(requestByteCount);
    map['response_byte_count'] = Variable<int>(responseByteCount);
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || diagnosticCategory != null) {
      map['diagnostic_category'] = Variable<String>(diagnosticCategory);
    }
    map['dropped_event_count'] = Variable<int>(droppedEventCount);
    map['terminal_state'] = Variable<String>(terminalState);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GrpcInvocationHistoryCompanion toCompanion(bool nullToAbsent) {
    return GrpcInvocationHistoryCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      savedRequestId: savedRequestId == null && nullToAbsent
          ? const Value.absent()
          : Value(savedRequestId),
      descriptorSnapshotId: descriptorSnapshotId == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptorSnapshotId),
      invocationKind: Value(invocationKind),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      durationMicroseconds: durationMicroseconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMicroseconds),
      endpointJson: Value(endpointJson),
      methodIdentityJson: Value(methodIdentityJson),
      requestJson: Value(requestJson),
      requestMetadataJson: Value(requestMetadataJson),
      responseJson: responseJson == null && nullToAbsent
          ? const Value.absent()
          : Value(responseJson),
      responseHeadersJson: Value(responseHeadersJson),
      responseTrailersJson: Value(responseTrailersJson),
      statusCode: statusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusCode),
      statusName: statusName == null && nullToAbsent
          ? const Value.absent()
          : Value(statusName),
      statusMessage: statusMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(statusMessage),
      requestByteCount: Value(requestByteCount),
      responseByteCount: Value(responseByteCount),
      outcome: Value(outcome),
      diagnosticCategory: diagnosticCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosticCategory),
      droppedEventCount: Value(droppedEventCount),
      terminalState: Value(terminalState),
      createdAt: Value(createdAt),
    );
  }

  factory GrpcInvocationHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrpcInvocationHistoryData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      savedRequestId: serializer.fromJson<String?>(json['savedRequestId']),
      descriptorSnapshotId: serializer.fromJson<String?>(
        json['descriptorSnapshotId'],
      ),
      invocationKind: serializer.fromJson<String>(json['invocationKind']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      durationMicroseconds: serializer.fromJson<int?>(
        json['durationMicroseconds'],
      ),
      endpointJson: serializer.fromJson<String>(json['endpointJson']),
      methodIdentityJson: serializer.fromJson<String>(
        json['methodIdentityJson'],
      ),
      requestJson: serializer.fromJson<String>(json['requestJson']),
      requestMetadataJson: serializer.fromJson<String>(
        json['requestMetadataJson'],
      ),
      responseJson: serializer.fromJson<String?>(json['responseJson']),
      responseHeadersJson: serializer.fromJson<String>(
        json['responseHeadersJson'],
      ),
      responseTrailersJson: serializer.fromJson<String>(
        json['responseTrailersJson'],
      ),
      statusCode: serializer.fromJson<int?>(json['statusCode']),
      statusName: serializer.fromJson<String?>(json['statusName']),
      statusMessage: serializer.fromJson<String?>(json['statusMessage']),
      requestByteCount: serializer.fromJson<int>(json['requestByteCount']),
      responseByteCount: serializer.fromJson<int>(json['responseByteCount']),
      outcome: serializer.fromJson<String>(json['outcome']),
      diagnosticCategory: serializer.fromJson<String?>(
        json['diagnosticCategory'],
      ),
      droppedEventCount: serializer.fromJson<int>(json['droppedEventCount']),
      terminalState: serializer.fromJson<String>(json['terminalState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'savedRequestId': serializer.toJson<String?>(savedRequestId),
      'descriptorSnapshotId': serializer.toJson<String?>(descriptorSnapshotId),
      'invocationKind': serializer.toJson<String>(invocationKind),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'durationMicroseconds': serializer.toJson<int?>(durationMicroseconds),
      'endpointJson': serializer.toJson<String>(endpointJson),
      'methodIdentityJson': serializer.toJson<String>(methodIdentityJson),
      'requestJson': serializer.toJson<String>(requestJson),
      'requestMetadataJson': serializer.toJson<String>(requestMetadataJson),
      'responseJson': serializer.toJson<String?>(responseJson),
      'responseHeadersJson': serializer.toJson<String>(responseHeadersJson),
      'responseTrailersJson': serializer.toJson<String>(responseTrailersJson),
      'statusCode': serializer.toJson<int?>(statusCode),
      'statusName': serializer.toJson<String?>(statusName),
      'statusMessage': serializer.toJson<String?>(statusMessage),
      'requestByteCount': serializer.toJson<int>(requestByteCount),
      'responseByteCount': serializer.toJson<int>(responseByteCount),
      'outcome': serializer.toJson<String>(outcome),
      'diagnosticCategory': serializer.toJson<String?>(diagnosticCategory),
      'droppedEventCount': serializer.toJson<int>(droppedEventCount),
      'terminalState': serializer.toJson<String>(terminalState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GrpcInvocationHistoryData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> savedRequestId = const Value.absent(),
    Value<String?> descriptorSnapshotId = const Value.absent(),
    String? invocationKind,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> durationMicroseconds = const Value.absent(),
    String? endpointJson,
    String? methodIdentityJson,
    String? requestJson,
    String? requestMetadataJson,
    Value<String?> responseJson = const Value.absent(),
    String? responseHeadersJson,
    String? responseTrailersJson,
    Value<int?> statusCode = const Value.absent(),
    Value<String?> statusName = const Value.absent(),
    Value<String?> statusMessage = const Value.absent(),
    int? requestByteCount,
    int? responseByteCount,
    String? outcome,
    Value<String?> diagnosticCategory = const Value.absent(),
    int? droppedEventCount,
    String? terminalState,
    DateTime? createdAt,
  }) => GrpcInvocationHistoryData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    savedRequestId: savedRequestId.present
        ? savedRequestId.value
        : this.savedRequestId,
    descriptorSnapshotId: descriptorSnapshotId.present
        ? descriptorSnapshotId.value
        : this.descriptorSnapshotId,
    invocationKind: invocationKind ?? this.invocationKind,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    durationMicroseconds: durationMicroseconds.present
        ? durationMicroseconds.value
        : this.durationMicroseconds,
    endpointJson: endpointJson ?? this.endpointJson,
    methodIdentityJson: methodIdentityJson ?? this.methodIdentityJson,
    requestJson: requestJson ?? this.requestJson,
    requestMetadataJson: requestMetadataJson ?? this.requestMetadataJson,
    responseJson: responseJson.present ? responseJson.value : this.responseJson,
    responseHeadersJson: responseHeadersJson ?? this.responseHeadersJson,
    responseTrailersJson: responseTrailersJson ?? this.responseTrailersJson,
    statusCode: statusCode.present ? statusCode.value : this.statusCode,
    statusName: statusName.present ? statusName.value : this.statusName,
    statusMessage: statusMessage.present
        ? statusMessage.value
        : this.statusMessage,
    requestByteCount: requestByteCount ?? this.requestByteCount,
    responseByteCount: responseByteCount ?? this.responseByteCount,
    outcome: outcome ?? this.outcome,
    diagnosticCategory: diagnosticCategory.present
        ? diagnosticCategory.value
        : this.diagnosticCategory,
    droppedEventCount: droppedEventCount ?? this.droppedEventCount,
    terminalState: terminalState ?? this.terminalState,
    createdAt: createdAt ?? this.createdAt,
  );
  GrpcInvocationHistoryData copyWithCompanion(
    GrpcInvocationHistoryCompanion data,
  ) {
    return GrpcInvocationHistoryData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      savedRequestId: data.savedRequestId.present
          ? data.savedRequestId.value
          : this.savedRequestId,
      descriptorSnapshotId: data.descriptorSnapshotId.present
          ? data.descriptorSnapshotId.value
          : this.descriptorSnapshotId,
      invocationKind: data.invocationKind.present
          ? data.invocationKind.value
          : this.invocationKind,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationMicroseconds: data.durationMicroseconds.present
          ? data.durationMicroseconds.value
          : this.durationMicroseconds,
      endpointJson: data.endpointJson.present
          ? data.endpointJson.value
          : this.endpointJson,
      methodIdentityJson: data.methodIdentityJson.present
          ? data.methodIdentityJson.value
          : this.methodIdentityJson,
      requestJson: data.requestJson.present
          ? data.requestJson.value
          : this.requestJson,
      requestMetadataJson: data.requestMetadataJson.present
          ? data.requestMetadataJson.value
          : this.requestMetadataJson,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      responseHeadersJson: data.responseHeadersJson.present
          ? data.responseHeadersJson.value
          : this.responseHeadersJson,
      responseTrailersJson: data.responseTrailersJson.present
          ? data.responseTrailersJson.value
          : this.responseTrailersJson,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      statusName: data.statusName.present
          ? data.statusName.value
          : this.statusName,
      statusMessage: data.statusMessage.present
          ? data.statusMessage.value
          : this.statusMessage,
      requestByteCount: data.requestByteCount.present
          ? data.requestByteCount.value
          : this.requestByteCount,
      responseByteCount: data.responseByteCount.present
          ? data.responseByteCount.value
          : this.responseByteCount,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      diagnosticCategory: data.diagnosticCategory.present
          ? data.diagnosticCategory.value
          : this.diagnosticCategory,
      droppedEventCount: data.droppedEventCount.present
          ? data.droppedEventCount.value
          : this.droppedEventCount,
      terminalState: data.terminalState.present
          ? data.terminalState.value
          : this.terminalState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrpcInvocationHistoryData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('savedRequestId: $savedRequestId, ')
          ..write('descriptorSnapshotId: $descriptorSnapshotId, ')
          ..write('invocationKind: $invocationKind, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMicroseconds: $durationMicroseconds, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('methodIdentityJson: $methodIdentityJson, ')
          ..write('requestJson: $requestJson, ')
          ..write('requestMetadataJson: $requestMetadataJson, ')
          ..write('responseJson: $responseJson, ')
          ..write('responseHeadersJson: $responseHeadersJson, ')
          ..write('responseTrailersJson: $responseTrailersJson, ')
          ..write('statusCode: $statusCode, ')
          ..write('statusName: $statusName, ')
          ..write('statusMessage: $statusMessage, ')
          ..write('requestByteCount: $requestByteCount, ')
          ..write('responseByteCount: $responseByteCount, ')
          ..write('outcome: $outcome, ')
          ..write('diagnosticCategory: $diagnosticCategory, ')
          ..write('droppedEventCount: $droppedEventCount, ')
          ..write('terminalState: $terminalState, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    workspaceId,
    savedRequestId,
    descriptorSnapshotId,
    invocationKind,
    startedAt,
    completedAt,
    durationMicroseconds,
    endpointJson,
    methodIdentityJson,
    requestJson,
    requestMetadataJson,
    responseJson,
    responseHeadersJson,
    responseTrailersJson,
    statusCode,
    statusName,
    statusMessage,
    requestByteCount,
    responseByteCount,
    outcome,
    diagnosticCategory,
    droppedEventCount,
    terminalState,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrpcInvocationHistoryData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.savedRequestId == this.savedRequestId &&
          other.descriptorSnapshotId == this.descriptorSnapshotId &&
          other.invocationKind == this.invocationKind &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.durationMicroseconds == this.durationMicroseconds &&
          other.endpointJson == this.endpointJson &&
          other.methodIdentityJson == this.methodIdentityJson &&
          other.requestJson == this.requestJson &&
          other.requestMetadataJson == this.requestMetadataJson &&
          other.responseJson == this.responseJson &&
          other.responseHeadersJson == this.responseHeadersJson &&
          other.responseTrailersJson == this.responseTrailersJson &&
          other.statusCode == this.statusCode &&
          other.statusName == this.statusName &&
          other.statusMessage == this.statusMessage &&
          other.requestByteCount == this.requestByteCount &&
          other.responseByteCount == this.responseByteCount &&
          other.outcome == this.outcome &&
          other.diagnosticCategory == this.diagnosticCategory &&
          other.droppedEventCount == this.droppedEventCount &&
          other.terminalState == this.terminalState &&
          other.createdAt == this.createdAt);
}

class GrpcInvocationHistoryCompanion
    extends UpdateCompanion<GrpcInvocationHistoryData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> savedRequestId;
  final Value<String?> descriptorSnapshotId;
  final Value<String> invocationKind;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int?> durationMicroseconds;
  final Value<String> endpointJson;
  final Value<String> methodIdentityJson;
  final Value<String> requestJson;
  final Value<String> requestMetadataJson;
  final Value<String?> responseJson;
  final Value<String> responseHeadersJson;
  final Value<String> responseTrailersJson;
  final Value<int?> statusCode;
  final Value<String?> statusName;
  final Value<String?> statusMessage;
  final Value<int> requestByteCount;
  final Value<int> responseByteCount;
  final Value<String> outcome;
  final Value<String?> diagnosticCategory;
  final Value<int> droppedEventCount;
  final Value<String> terminalState;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GrpcInvocationHistoryCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.savedRequestId = const Value.absent(),
    this.descriptorSnapshotId = const Value.absent(),
    this.invocationKind = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationMicroseconds = const Value.absent(),
    this.endpointJson = const Value.absent(),
    this.methodIdentityJson = const Value.absent(),
    this.requestJson = const Value.absent(),
    this.requestMetadataJson = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.responseHeadersJson = const Value.absent(),
    this.responseTrailersJson = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.statusName = const Value.absent(),
    this.statusMessage = const Value.absent(),
    this.requestByteCount = const Value.absent(),
    this.responseByteCount = const Value.absent(),
    this.outcome = const Value.absent(),
    this.diagnosticCategory = const Value.absent(),
    this.droppedEventCount = const Value.absent(),
    this.terminalState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrpcInvocationHistoryCompanion.insert({
    required String id,
    required String workspaceId,
    this.savedRequestId = const Value.absent(),
    this.descriptorSnapshotId = const Value.absent(),
    required String invocationKind,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.durationMicroseconds = const Value.absent(),
    required String endpointJson,
    required String methodIdentityJson,
    required String requestJson,
    required String requestMetadataJson,
    this.responseJson = const Value.absent(),
    required String responseHeadersJson,
    required String responseTrailersJson,
    this.statusCode = const Value.absent(),
    this.statusName = const Value.absent(),
    this.statusMessage = const Value.absent(),
    this.requestByteCount = const Value.absent(),
    this.responseByteCount = const Value.absent(),
    required String outcome,
    this.diagnosticCategory = const Value.absent(),
    this.droppedEventCount = const Value.absent(),
    required String terminalState,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       invocationKind = Value(invocationKind),
       startedAt = Value(startedAt),
       endpointJson = Value(endpointJson),
       methodIdentityJson = Value(methodIdentityJson),
       requestJson = Value(requestJson),
       requestMetadataJson = Value(requestMetadataJson),
       responseHeadersJson = Value(responseHeadersJson),
       responseTrailersJson = Value(responseTrailersJson),
       outcome = Value(outcome),
       terminalState = Value(terminalState),
       createdAt = Value(createdAt);
  static Insertable<GrpcInvocationHistoryData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? savedRequestId,
    Expression<String>? descriptorSnapshotId,
    Expression<String>? invocationKind,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? durationMicroseconds,
    Expression<String>? endpointJson,
    Expression<String>? methodIdentityJson,
    Expression<String>? requestJson,
    Expression<String>? requestMetadataJson,
    Expression<String>? responseJson,
    Expression<String>? responseHeadersJson,
    Expression<String>? responseTrailersJson,
    Expression<int>? statusCode,
    Expression<String>? statusName,
    Expression<String>? statusMessage,
    Expression<int>? requestByteCount,
    Expression<int>? responseByteCount,
    Expression<String>? outcome,
    Expression<String>? diagnosticCategory,
    Expression<int>? droppedEventCount,
    Expression<String>? terminalState,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (savedRequestId != null) 'saved_request_id': savedRequestId,
      if (descriptorSnapshotId != null)
        'descriptor_snapshot_id': descriptorSnapshotId,
      if (invocationKind != null) 'invocation_kind': invocationKind,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationMicroseconds != null)
        'duration_microseconds': durationMicroseconds,
      if (endpointJson != null) 'endpoint_json': endpointJson,
      if (methodIdentityJson != null)
        'method_identity_json': methodIdentityJson,
      if (requestJson != null) 'request_json': requestJson,
      if (requestMetadataJson != null)
        'request_metadata_json': requestMetadataJson,
      if (responseJson != null) 'response_json': responseJson,
      if (responseHeadersJson != null)
        'response_headers_json': responseHeadersJson,
      if (responseTrailersJson != null)
        'response_trailers_json': responseTrailersJson,
      if (statusCode != null) 'status_code': statusCode,
      if (statusName != null) 'status_name': statusName,
      if (statusMessage != null) 'status_message': statusMessage,
      if (requestByteCount != null) 'request_byte_count': requestByteCount,
      if (responseByteCount != null) 'response_byte_count': responseByteCount,
      if (outcome != null) 'outcome': outcome,
      if (diagnosticCategory != null) 'diagnostic_category': diagnosticCategory,
      if (droppedEventCount != null) 'dropped_event_count': droppedEventCount,
      if (terminalState != null) 'terminal_state': terminalState,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrpcInvocationHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? savedRequestId,
    Value<String?>? descriptorSnapshotId,
    Value<String>? invocationKind,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int?>? durationMicroseconds,
    Value<String>? endpointJson,
    Value<String>? methodIdentityJson,
    Value<String>? requestJson,
    Value<String>? requestMetadataJson,
    Value<String?>? responseJson,
    Value<String>? responseHeadersJson,
    Value<String>? responseTrailersJson,
    Value<int?>? statusCode,
    Value<String?>? statusName,
    Value<String?>? statusMessage,
    Value<int>? requestByteCount,
    Value<int>? responseByteCount,
    Value<String>? outcome,
    Value<String?>? diagnosticCategory,
    Value<int>? droppedEventCount,
    Value<String>? terminalState,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GrpcInvocationHistoryCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      savedRequestId: savedRequestId ?? this.savedRequestId,
      descriptorSnapshotId: descriptorSnapshotId ?? this.descriptorSnapshotId,
      invocationKind: invocationKind ?? this.invocationKind,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMicroseconds: durationMicroseconds ?? this.durationMicroseconds,
      endpointJson: endpointJson ?? this.endpointJson,
      methodIdentityJson: methodIdentityJson ?? this.methodIdentityJson,
      requestJson: requestJson ?? this.requestJson,
      requestMetadataJson: requestMetadataJson ?? this.requestMetadataJson,
      responseJson: responseJson ?? this.responseJson,
      responseHeadersJson: responseHeadersJson ?? this.responseHeadersJson,
      responseTrailersJson: responseTrailersJson ?? this.responseTrailersJson,
      statusCode: statusCode ?? this.statusCode,
      statusName: statusName ?? this.statusName,
      statusMessage: statusMessage ?? this.statusMessage,
      requestByteCount: requestByteCount ?? this.requestByteCount,
      responseByteCount: responseByteCount ?? this.responseByteCount,
      outcome: outcome ?? this.outcome,
      diagnosticCategory: diagnosticCategory ?? this.diagnosticCategory,
      droppedEventCount: droppedEventCount ?? this.droppedEventCount,
      terminalState: terminalState ?? this.terminalState,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (savedRequestId.present) {
      map['saved_request_id'] = Variable<String>(savedRequestId.value);
    }
    if (descriptorSnapshotId.present) {
      map['descriptor_snapshot_id'] = Variable<String>(
        descriptorSnapshotId.value,
      );
    }
    if (invocationKind.present) {
      map['invocation_kind'] = Variable<String>(invocationKind.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationMicroseconds.present) {
      map['duration_microseconds'] = Variable<int>(durationMicroseconds.value);
    }
    if (endpointJson.present) {
      map['endpoint_json'] = Variable<String>(endpointJson.value);
    }
    if (methodIdentityJson.present) {
      map['method_identity_json'] = Variable<String>(methodIdentityJson.value);
    }
    if (requestJson.present) {
      map['request_json'] = Variable<String>(requestJson.value);
    }
    if (requestMetadataJson.present) {
      map['request_metadata_json'] = Variable<String>(
        requestMetadataJson.value,
      );
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (responseHeadersJson.present) {
      map['response_headers_json'] = Variable<String>(
        responseHeadersJson.value,
      );
    }
    if (responseTrailersJson.present) {
      map['response_trailers_json'] = Variable<String>(
        responseTrailersJson.value,
      );
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (statusName.present) {
      map['status_name'] = Variable<String>(statusName.value);
    }
    if (statusMessage.present) {
      map['status_message'] = Variable<String>(statusMessage.value);
    }
    if (requestByteCount.present) {
      map['request_byte_count'] = Variable<int>(requestByteCount.value);
    }
    if (responseByteCount.present) {
      map['response_byte_count'] = Variable<int>(responseByteCount.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (diagnosticCategory.present) {
      map['diagnostic_category'] = Variable<String>(diagnosticCategory.value);
    }
    if (droppedEventCount.present) {
      map['dropped_event_count'] = Variable<int>(droppedEventCount.value);
    }
    if (terminalState.present) {
      map['terminal_state'] = Variable<String>(terminalState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrpcInvocationHistoryCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('savedRequestId: $savedRequestId, ')
          ..write('descriptorSnapshotId: $descriptorSnapshotId, ')
          ..write('invocationKind: $invocationKind, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMicroseconds: $durationMicroseconds, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('methodIdentityJson: $methodIdentityJson, ')
          ..write('requestJson: $requestJson, ')
          ..write('requestMetadataJson: $requestMetadataJson, ')
          ..write('responseJson: $responseJson, ')
          ..write('responseHeadersJson: $responseHeadersJson, ')
          ..write('responseTrailersJson: $responseTrailersJson, ')
          ..write('statusCode: $statusCode, ')
          ..write('statusName: $statusName, ')
          ..write('statusMessage: $statusMessage, ')
          ..write('requestByteCount: $requestByteCount, ')
          ..write('responseByteCount: $responseByteCount, ')
          ..write('outcome: $outcome, ')
          ..write('diagnosticCategory: $diagnosticCategory, ')
          ..write('droppedEventCount: $droppedEventCount, ')
          ..write('terminalState: $terminalState, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrpcStoredStreamEventsTable extends GrpcStoredStreamEvents
    with TableInfo<$GrpcStoredStreamEventsTable, GrpcStoredStreamEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrpcStoredStreamEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionHistoryIdMeta = const VerificationMeta(
    'sessionHistoryId',
  );
  @override
  late final GeneratedColumn<String> sessionHistoryId = GeneratedColumn<String>(
    'session_history_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grpc_invocation_history (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decodedPayloadJsonMeta =
      const VerificationMeta('decodedPayloadJson');
  @override
  late final GeneratedColumn<String> decodedPayloadJson =
      GeneratedColumn<String>(
        'decoded_payload_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rawByteCountMeta = const VerificationMeta(
    'rawByteCount',
  );
  @override
  late final GeneratedColumn<int> rawByteCount = GeneratedColumn<int>(
    'raw_byte_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _retainedRawBytesMeta = const VerificationMeta(
    'retainedRawBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> retainedRawBytes =
      GeneratedColumn<Uint8List>(
        'retained_raw_bytes',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusTextMeta = const VerificationMeta(
    'statusText',
  );
  @override
  late final GeneratedColumn<String> statusText = GeneratedColumn<String>(
    'status_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decodeFailureCategoryMeta =
      const VerificationMeta('decodeFailureCategory');
  @override
  late final GeneratedColumn<String> decodeFailureCategory =
      GeneratedColumn<String>(
        'decode_failure_category',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionHistoryId,
    sequenceNumber,
    direction,
    category,
    occurredAt,
    decodedPayloadJson,
    rawByteCount,
    retainedRawBytes,
    statusCode,
    statusText,
    decodeFailureCategory,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grpc_stored_stream_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrpcStoredStreamEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_history_id')) {
      context.handle(
        _sessionHistoryIdMeta,
        sessionHistoryId.isAcceptableOrUnknown(
          data['session_history_id']!,
          _sessionHistoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionHistoryIdMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('decoded_payload_json')) {
      context.handle(
        _decodedPayloadJsonMeta,
        decodedPayloadJson.isAcceptableOrUnknown(
          data['decoded_payload_json']!,
          _decodedPayloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('raw_byte_count')) {
      context.handle(
        _rawByteCountMeta,
        rawByteCount.isAcceptableOrUnknown(
          data['raw_byte_count']!,
          _rawByteCountMeta,
        ),
      );
    }
    if (data.containsKey('retained_raw_bytes')) {
      context.handle(
        _retainedRawBytesMeta,
        retainedRawBytes.isAcceptableOrUnknown(
          data['retained_raw_bytes']!,
          _retainedRawBytesMeta,
        ),
      );
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    }
    if (data.containsKey('status_text')) {
      context.handle(
        _statusTextMeta,
        statusText.isAcceptableOrUnknown(data['status_text']!, _statusTextMeta),
      );
    }
    if (data.containsKey('decode_failure_category')) {
      context.handle(
        _decodeFailureCategoryMeta,
        decodeFailureCategory.isAcceptableOrUnknown(
          data['decode_failure_category']!,
          _decodeFailureCategoryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrpcStoredStreamEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrpcStoredStreamEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionHistoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_history_id'],
      )!,
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      decodedPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decoded_payload_json'],
      ),
      rawByteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}raw_byte_count'],
      )!,
      retainedRawBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}retained_raw_bytes'],
      ),
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      ),
      statusText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_text'],
      ),
      decodeFailureCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decode_failure_category'],
      ),
    );
  }

  @override
  $GrpcStoredStreamEventsTable createAlias(String alias) {
    return $GrpcStoredStreamEventsTable(attachedDatabase, alias);
  }
}

class GrpcStoredStreamEvent extends DataClass
    implements Insertable<GrpcStoredStreamEvent> {
  final String id;
  final String sessionHistoryId;
  final int sequenceNumber;
  final String direction;
  final String category;
  final DateTime occurredAt;
  final String? decodedPayloadJson;
  final int rawByteCount;
  final Uint8List? retainedRawBytes;
  final int? statusCode;
  final String? statusText;
  final String? decodeFailureCategory;
  const GrpcStoredStreamEvent({
    required this.id,
    required this.sessionHistoryId,
    required this.sequenceNumber,
    required this.direction,
    required this.category,
    required this.occurredAt,
    this.decodedPayloadJson,
    required this.rawByteCount,
    this.retainedRawBytes,
    this.statusCode,
    this.statusText,
    this.decodeFailureCategory,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_history_id'] = Variable<String>(sessionHistoryId);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['direction'] = Variable<String>(direction);
    map['category'] = Variable<String>(category);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || decodedPayloadJson != null) {
      map['decoded_payload_json'] = Variable<String>(decodedPayloadJson);
    }
    map['raw_byte_count'] = Variable<int>(rawByteCount);
    if (!nullToAbsent || retainedRawBytes != null) {
      map['retained_raw_bytes'] = Variable<Uint8List>(retainedRawBytes);
    }
    if (!nullToAbsent || statusCode != null) {
      map['status_code'] = Variable<int>(statusCode);
    }
    if (!nullToAbsent || statusText != null) {
      map['status_text'] = Variable<String>(statusText);
    }
    if (!nullToAbsent || decodeFailureCategory != null) {
      map['decode_failure_category'] = Variable<String>(decodeFailureCategory);
    }
    return map;
  }

  GrpcStoredStreamEventsCompanion toCompanion(bool nullToAbsent) {
    return GrpcStoredStreamEventsCompanion(
      id: Value(id),
      sessionHistoryId: Value(sessionHistoryId),
      sequenceNumber: Value(sequenceNumber),
      direction: Value(direction),
      category: Value(category),
      occurredAt: Value(occurredAt),
      decodedPayloadJson: decodedPayloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(decodedPayloadJson),
      rawByteCount: Value(rawByteCount),
      retainedRawBytes: retainedRawBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(retainedRawBytes),
      statusCode: statusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusCode),
      statusText: statusText == null && nullToAbsent
          ? const Value.absent()
          : Value(statusText),
      decodeFailureCategory: decodeFailureCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(decodeFailureCategory),
    );
  }

  factory GrpcStoredStreamEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrpcStoredStreamEvent(
      id: serializer.fromJson<String>(json['id']),
      sessionHistoryId: serializer.fromJson<String>(json['sessionHistoryId']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      direction: serializer.fromJson<String>(json['direction']),
      category: serializer.fromJson<String>(json['category']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      decodedPayloadJson: serializer.fromJson<String?>(
        json['decodedPayloadJson'],
      ),
      rawByteCount: serializer.fromJson<int>(json['rawByteCount']),
      retainedRawBytes: serializer.fromJson<Uint8List?>(
        json['retainedRawBytes'],
      ),
      statusCode: serializer.fromJson<int?>(json['statusCode']),
      statusText: serializer.fromJson<String?>(json['statusText']),
      decodeFailureCategory: serializer.fromJson<String?>(
        json['decodeFailureCategory'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionHistoryId': serializer.toJson<String>(sessionHistoryId),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'direction': serializer.toJson<String>(direction),
      'category': serializer.toJson<String>(category),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'decodedPayloadJson': serializer.toJson<String?>(decodedPayloadJson),
      'rawByteCount': serializer.toJson<int>(rawByteCount),
      'retainedRawBytes': serializer.toJson<Uint8List?>(retainedRawBytes),
      'statusCode': serializer.toJson<int?>(statusCode),
      'statusText': serializer.toJson<String?>(statusText),
      'decodeFailureCategory': serializer.toJson<String?>(
        decodeFailureCategory,
      ),
    };
  }

  GrpcStoredStreamEvent copyWith({
    String? id,
    String? sessionHistoryId,
    int? sequenceNumber,
    String? direction,
    String? category,
    DateTime? occurredAt,
    Value<String?> decodedPayloadJson = const Value.absent(),
    int? rawByteCount,
    Value<Uint8List?> retainedRawBytes = const Value.absent(),
    Value<int?> statusCode = const Value.absent(),
    Value<String?> statusText = const Value.absent(),
    Value<String?> decodeFailureCategory = const Value.absent(),
  }) => GrpcStoredStreamEvent(
    id: id ?? this.id,
    sessionHistoryId: sessionHistoryId ?? this.sessionHistoryId,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    direction: direction ?? this.direction,
    category: category ?? this.category,
    occurredAt: occurredAt ?? this.occurredAt,
    decodedPayloadJson: decodedPayloadJson.present
        ? decodedPayloadJson.value
        : this.decodedPayloadJson,
    rawByteCount: rawByteCount ?? this.rawByteCount,
    retainedRawBytes: retainedRawBytes.present
        ? retainedRawBytes.value
        : this.retainedRawBytes,
    statusCode: statusCode.present ? statusCode.value : this.statusCode,
    statusText: statusText.present ? statusText.value : this.statusText,
    decodeFailureCategory: decodeFailureCategory.present
        ? decodeFailureCategory.value
        : this.decodeFailureCategory,
  );
  GrpcStoredStreamEvent copyWithCompanion(
    GrpcStoredStreamEventsCompanion data,
  ) {
    return GrpcStoredStreamEvent(
      id: data.id.present ? data.id.value : this.id,
      sessionHistoryId: data.sessionHistoryId.present
          ? data.sessionHistoryId.value
          : this.sessionHistoryId,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      direction: data.direction.present ? data.direction.value : this.direction,
      category: data.category.present ? data.category.value : this.category,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      decodedPayloadJson: data.decodedPayloadJson.present
          ? data.decodedPayloadJson.value
          : this.decodedPayloadJson,
      rawByteCount: data.rawByteCount.present
          ? data.rawByteCount.value
          : this.rawByteCount,
      retainedRawBytes: data.retainedRawBytes.present
          ? data.retainedRawBytes.value
          : this.retainedRawBytes,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      statusText: data.statusText.present
          ? data.statusText.value
          : this.statusText,
      decodeFailureCategory: data.decodeFailureCategory.present
          ? data.decodeFailureCategory.value
          : this.decodeFailureCategory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrpcStoredStreamEvent(')
          ..write('id: $id, ')
          ..write('sessionHistoryId: $sessionHistoryId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('direction: $direction, ')
          ..write('category: $category, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('decodedPayloadJson: $decodedPayloadJson, ')
          ..write('rawByteCount: $rawByteCount, ')
          ..write('retainedRawBytes: $retainedRawBytes, ')
          ..write('statusCode: $statusCode, ')
          ..write('statusText: $statusText, ')
          ..write('decodeFailureCategory: $decodeFailureCategory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionHistoryId,
    sequenceNumber,
    direction,
    category,
    occurredAt,
    decodedPayloadJson,
    rawByteCount,
    $driftBlobEquality.hash(retainedRawBytes),
    statusCode,
    statusText,
    decodeFailureCategory,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrpcStoredStreamEvent &&
          other.id == this.id &&
          other.sessionHistoryId == this.sessionHistoryId &&
          other.sequenceNumber == this.sequenceNumber &&
          other.direction == this.direction &&
          other.category == this.category &&
          other.occurredAt == this.occurredAt &&
          other.decodedPayloadJson == this.decodedPayloadJson &&
          other.rawByteCount == this.rawByteCount &&
          $driftBlobEquality.equals(
            other.retainedRawBytes,
            this.retainedRawBytes,
          ) &&
          other.statusCode == this.statusCode &&
          other.statusText == this.statusText &&
          other.decodeFailureCategory == this.decodeFailureCategory);
}

class GrpcStoredStreamEventsCompanion
    extends UpdateCompanion<GrpcStoredStreamEvent> {
  final Value<String> id;
  final Value<String> sessionHistoryId;
  final Value<int> sequenceNumber;
  final Value<String> direction;
  final Value<String> category;
  final Value<DateTime> occurredAt;
  final Value<String?> decodedPayloadJson;
  final Value<int> rawByteCount;
  final Value<Uint8List?> retainedRawBytes;
  final Value<int?> statusCode;
  final Value<String?> statusText;
  final Value<String?> decodeFailureCategory;
  final Value<int> rowid;
  const GrpcStoredStreamEventsCompanion({
    this.id = const Value.absent(),
    this.sessionHistoryId = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.direction = const Value.absent(),
    this.category = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.decodedPayloadJson = const Value.absent(),
    this.rawByteCount = const Value.absent(),
    this.retainedRawBytes = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.statusText = const Value.absent(),
    this.decodeFailureCategory = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrpcStoredStreamEventsCompanion.insert({
    required String id,
    required String sessionHistoryId,
    required int sequenceNumber,
    required String direction,
    required String category,
    required DateTime occurredAt,
    this.decodedPayloadJson = const Value.absent(),
    this.rawByteCount = const Value.absent(),
    this.retainedRawBytes = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.statusText = const Value.absent(),
    this.decodeFailureCategory = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionHistoryId = Value(sessionHistoryId),
       sequenceNumber = Value(sequenceNumber),
       direction = Value(direction),
       category = Value(category),
       occurredAt = Value(occurredAt);
  static Insertable<GrpcStoredStreamEvent> custom({
    Expression<String>? id,
    Expression<String>? sessionHistoryId,
    Expression<int>? sequenceNumber,
    Expression<String>? direction,
    Expression<String>? category,
    Expression<DateTime>? occurredAt,
    Expression<String>? decodedPayloadJson,
    Expression<int>? rawByteCount,
    Expression<Uint8List>? retainedRawBytes,
    Expression<int>? statusCode,
    Expression<String>? statusText,
    Expression<String>? decodeFailureCategory,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionHistoryId != null) 'session_history_id': sessionHistoryId,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (direction != null) 'direction': direction,
      if (category != null) 'category': category,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (decodedPayloadJson != null)
        'decoded_payload_json': decodedPayloadJson,
      if (rawByteCount != null) 'raw_byte_count': rawByteCount,
      if (retainedRawBytes != null) 'retained_raw_bytes': retainedRawBytes,
      if (statusCode != null) 'status_code': statusCode,
      if (statusText != null) 'status_text': statusText,
      if (decodeFailureCategory != null)
        'decode_failure_category': decodeFailureCategory,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrpcStoredStreamEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionHistoryId,
    Value<int>? sequenceNumber,
    Value<String>? direction,
    Value<String>? category,
    Value<DateTime>? occurredAt,
    Value<String?>? decodedPayloadJson,
    Value<int>? rawByteCount,
    Value<Uint8List?>? retainedRawBytes,
    Value<int?>? statusCode,
    Value<String?>? statusText,
    Value<String?>? decodeFailureCategory,
    Value<int>? rowid,
  }) {
    return GrpcStoredStreamEventsCompanion(
      id: id ?? this.id,
      sessionHistoryId: sessionHistoryId ?? this.sessionHistoryId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      direction: direction ?? this.direction,
      category: category ?? this.category,
      occurredAt: occurredAt ?? this.occurredAt,
      decodedPayloadJson: decodedPayloadJson ?? this.decodedPayloadJson,
      rawByteCount: rawByteCount ?? this.rawByteCount,
      retainedRawBytes: retainedRawBytes ?? this.retainedRawBytes,
      statusCode: statusCode ?? this.statusCode,
      statusText: statusText ?? this.statusText,
      decodeFailureCategory:
          decodeFailureCategory ?? this.decodeFailureCategory,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionHistoryId.present) {
      map['session_history_id'] = Variable<String>(sessionHistoryId.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (decodedPayloadJson.present) {
      map['decoded_payload_json'] = Variable<String>(decodedPayloadJson.value);
    }
    if (rawByteCount.present) {
      map['raw_byte_count'] = Variable<int>(rawByteCount.value);
    }
    if (retainedRawBytes.present) {
      map['retained_raw_bytes'] = Variable<Uint8List>(retainedRawBytes.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (statusText.present) {
      map['status_text'] = Variable<String>(statusText.value);
    }
    if (decodeFailureCategory.present) {
      map['decode_failure_category'] = Variable<String>(
        decodeFailureCategory.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrpcStoredStreamEventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionHistoryId: $sessionHistoryId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('direction: $direction, ')
          ..write('category: $category, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('decodedPayloadJson: $decodedPayloadJson, ')
          ..write('rawByteCount: $rawByteCount, ')
          ..write('retainedRawBytes: $retainedRawBytes, ')
          ..write('statusCode: $statusCode, ')
          ..write('statusText: $statusText, ')
          ..write('decodeFailureCategory: $decodeFailureCategory, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $RequestsTable requests = $RequestsTable(this);
  late final $RequestHeadersTable requestHeaders = $RequestHeadersTable(this);
  late final $RequestQueryParamsTable requestQueryParams =
      $RequestQueryParamsTable(this);
  late final $RequestBodiesTable requestBodies = $RequestBodiesTable(this);
  late final $EnvironmentsTable environments = $EnvironmentsTable(this);
  late final $EnvironmentVariablesTable environmentVariables =
      $EnvironmentVariablesTable(this);
  late final $RequestHistoryTable requestHistory = $RequestHistoryTable(this);
  late final $ResponseSnapshotsTable responseSnapshots =
      $ResponseSnapshotsTable(this);
  late final $WebSocketSessionsTable webSocketSessions =
      $WebSocketSessionsTable(this);
  late final $AiAnalysesTable aiAnalyses = $AiAnalysesTable(this);
  late final $RequestDraftsTable requestDrafts = $RequestDraftsTable(this);
  late final $RealtimeConfigurationsTable realtimeConfigurations =
      $RealtimeConfigurationsTable(this);
  late final $RealtimeDraftsTable realtimeDrafts = $RealtimeDraftsTable(this);
  late final $RealtimeHistoryTable realtimeHistory = $RealtimeHistoryTable(
    this,
  );
  late final $AiPreferencesTable aiPreferences = $AiPreferencesTable(this);
  late final $WorkspaceSettingsTable workspaceSettings =
      $WorkspaceSettingsTable(this);
  late final $GraphqlDraftsTable graphqlDrafts = $GraphqlDraftsTable(this);
  late final $GraphqlHistoryTable graphqlHistory = $GraphqlHistoryTable(this);
  late final $GraphqlSavedRequestsTable graphqlSavedRequests =
      $GraphqlSavedRequestsTable(this);
  late final $GraphqlSchemaSnapshotsTable graphqlSchemaSnapshots =
      $GraphqlSchemaSnapshotsTable(this);
  late final $GrpcDescriptorSnapshotsTable grpcDescriptorSnapshots =
      $GrpcDescriptorSnapshotsTable(this);
  late final $GrpcSavedRequestsTable grpcSavedRequests =
      $GrpcSavedRequestsTable(this);
  late final $GrpcDraftsTable grpcDrafts = $GrpcDraftsTable(this);
  late final $GrpcInvocationHistoryTable grpcInvocationHistory =
      $GrpcInvocationHistoryTable(this);
  late final $GrpcStoredStreamEventsTable grpcStoredStreamEvents =
      $GrpcStoredStreamEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workspaces,
    collections,
    folders,
    requests,
    requestHeaders,
    requestQueryParams,
    requestBodies,
    environments,
    environmentVariables,
    requestHistory,
    responseSnapshots,
    webSocketSessions,
    aiAnalyses,
    requestDrafts,
    realtimeConfigurations,
    realtimeDrafts,
    realtimeHistory,
    aiPreferences,
    workspaceSettings,
    graphqlDrafts,
    graphqlHistory,
    graphqlSavedRequests,
    graphqlSchemaSnapshots,
    grpcDescriptorSnapshots,
    grpcSavedRequests,
    grpcDrafts,
    grpcInvocationHistory,
    grpcStoredStreamEvents,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('grpc_descriptor_snapshots', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grpc_saved_requests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grpc_drafts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grpc_saved_requests',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grpc_drafts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grpc_invocation_history', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grpc_saved_requests',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grpc_invocation_history', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grpc_invocation_history',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('grpc_stored_stream_events', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> sortOrder,
      Value<bool> productionStrictMode,
      Value<int> rowid,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> sortOrder,
      Value<bool> productionStrictMode,
      Value<int> rowid,
    });

final class $$WorkspacesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace> {
  $$WorkspacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $GrpcDescriptorSnapshotsTable,
    List<GrpcDescriptorSnapshot>
  >
  _grpcDescriptorSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.grpcDescriptorSnapshots,
        aliasName: 'workspaces__id__grpc_descriptor_snapshots__workspace_id',
      );

  $$GrpcDescriptorSnapshotsTableProcessedTableManager
  get grpcDescriptorSnapshotsRefs {
    final manager = $$GrpcDescriptorSnapshotsTableTableManager(
      $_db,
      $_db.grpcDescriptorSnapshots,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _grpcDescriptorSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GrpcSavedRequestsTable, List<GrpcSavedRequest>>
  _grpcSavedRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.grpcSavedRequests,
        aliasName: 'workspaces__id__grpc_saved_requests__workspace_id',
      );

  $$GrpcSavedRequestsTableProcessedTableManager get grpcSavedRequestsRefs {
    final manager = $$GrpcSavedRequestsTableTableManager(
      $_db,
      $_db.grpcSavedRequests,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _grpcSavedRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GrpcDraftsTable, List<GrpcDraft>>
  _grpcDraftsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grpcDrafts,
    aliasName: 'workspaces__id__grpc_drafts__workspace_id',
  );

  $$GrpcDraftsTableProcessedTableManager get grpcDraftsRefs {
    final manager = $$GrpcDraftsTableTableManager(
      $_db,
      $_db.grpcDrafts,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_grpcDraftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GrpcInvocationHistoryTable,
    List<GrpcInvocationHistoryData>
  >
  _grpcInvocationHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.grpcInvocationHistory,
        aliasName: 'workspaces__id__grpc_invocation_history__workspace_id',
      );

  $$GrpcInvocationHistoryTableProcessedTableManager
  get grpcInvocationHistoryRefs {
    final manager = $$GrpcInvocationHistoryTableTableManager(
      $_db,
      $_db.grpcInvocationHistory,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _grpcInvocationHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get productionStrictMode => $composableBuilder(
    column: $table.productionStrictMode,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> grpcDescriptorSnapshotsRefs(
    Expression<bool> Function($$GrpcDescriptorSnapshotsTableFilterComposer f) f,
  ) {
    final $$GrpcDescriptorSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> grpcSavedRequestsRefs(
    Expression<bool> Function($$GrpcSavedRequestsTableFilterComposer f) f,
  ) {
    final $$GrpcSavedRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcSavedRequests,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcSavedRequestsTableFilterComposer(
            $db: $db,
            $table: $db.grpcSavedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grpcDraftsRefs(
    Expression<bool> Function($$GrpcDraftsTableFilterComposer f) f,
  ) {
    final $$GrpcDraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcDrafts,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcDraftsTableFilterComposer(
            $db: $db,
            $table: $db.grpcDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grpcInvocationHistoryRefs(
    Expression<bool> Function($$GrpcInvocationHistoryTableFilterComposer f) f,
  ) {
    final $$GrpcInvocationHistoryTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableFilterComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get productionStrictMode => $composableBuilder(
    column: $table.productionStrictMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get productionStrictMode => $composableBuilder(
    column: $table.productionStrictMode,
    builder: (column) => column,
  );

  Expression<T> grpcDescriptorSnapshotsRefs<T extends Object>(
    Expression<T> Function($$GrpcDescriptorSnapshotsTableAnnotationComposer a)
    f,
  ) {
    final $$GrpcDescriptorSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> grpcSavedRequestsRefs<T extends Object>(
    Expression<T> Function($$GrpcSavedRequestsTableAnnotationComposer a) f,
  ) {
    final $$GrpcSavedRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcSavedRequests,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcSavedRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcSavedRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> grpcDraftsRefs<T extends Object>(
    Expression<T> Function($$GrpcDraftsTableAnnotationComposer a) f,
  ) {
    final $$GrpcDraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcDrafts,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcDraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.grpcDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> grpcInvocationHistoryRefs<T extends Object>(
    Expression<T> Function($$GrpcInvocationHistoryTableAnnotationComposer a) f,
  ) {
    final $$GrpcInvocationHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          Workspace,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (Workspace, $$WorkspacesTableReferences),
          Workspace,
          PrefetchHooks Function({
            bool grpcDescriptorSnapshotsRefs,
            bool grpcSavedRequestsRefs,
            bool grpcDraftsRefs,
            bool grpcInvocationHistoryRefs,
          })
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> productionStrictMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                productionStrictMode: productionStrictMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> productionStrictMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                productionStrictMode: productionStrictMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                grpcDescriptorSnapshotsRefs = false,
                grpcSavedRequestsRefs = false,
                grpcDraftsRefs = false,
                grpcInvocationHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (grpcDescriptorSnapshotsRefs) db.grpcDescriptorSnapshots,
                    if (grpcSavedRequestsRefs) db.grpcSavedRequests,
                    if (grpcDraftsRefs) db.grpcDrafts,
                    if (grpcInvocationHistoryRefs) db.grpcInvocationHistory,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (grpcDescriptorSnapshotsRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          GrpcDescriptorSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._grpcDescriptorSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcDescriptorSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grpcSavedRequestsRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          GrpcSavedRequest
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._grpcSavedRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcSavedRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grpcDraftsRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          GrpcDraft
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._grpcDraftsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcDraftsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grpcInvocationHistoryRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          GrpcInvocationHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._grpcInvocationHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcInvocationHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      Workspace,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (Workspace, $$WorkspacesTableReferences),
      Workspace,
      PrefetchHooks Function({
        bool grpcDescriptorSnapshotsRefs,
        bool grpcSavedRequestsRefs,
        bool grpcDraftsRefs,
        bool grpcInvocationHistoryRefs,
      })
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String workspaceId,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            Collection,
            BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
          ),
          Collection,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                workspaceId: workspaceId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        Collection,
        BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
      ),
      Collection,
      PrefetchHooks Function()
    >;
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      required String id,
      required String collectionId,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> sortOrder,
      Value<String?> parentFolderId,
      Value<int> rowid,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> sortOrder,
      Value<String?> parentFolderId,
      Value<int> rowid,
    });

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => column,
  );
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
          Folder,
          PrefetchHooks Function()
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> parentFolderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                collectionId: collectionId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                parentFolderId: parentFolderId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> parentFolderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                collectionId: collectionId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                parentFolderId: parentFolderId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
      Folder,
      PrefetchHooks Function()
    >;
typedef $$RequestsTableCreateCompanionBuilder =
    RequestsCompanion Function({
      required String id,
      Value<String?> collectionId,
      Value<String?> folderId,
      required String name,
      required String method,
      required String url,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> sortOrder,
      Value<String> payloadJson,
      Value<int> rowid,
    });
typedef $$RequestsTableUpdateCompanionBuilder =
    RequestsCompanion Function({
      Value<String> id,
      Value<String?> collectionId,
      Value<String?> folderId,
      Value<String> name,
      Value<String> method,
      Value<String> url,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> sortOrder,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$RequestsTableFilterComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$RequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestsTable,
          Request,
          $$RequestsTableFilterComposer,
          $$RequestsTableOrderingComposer,
          $$RequestsTableAnnotationComposer,
          $$RequestsTableCreateCompanionBuilder,
          $$RequestsTableUpdateCompanionBuilder,
          (Request, BaseReferences<_$AppDatabase, $RequestsTable, Request>),
          Request,
          PrefetchHooks Function()
        > {
  $$RequestsTableTableManager(_$AppDatabase db, $RequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestsCompanion(
                id: id,
                collectionId: collectionId,
                folderId: folderId,
                name: name,
                method: method,
                url: url,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> collectionId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                required String name,
                required String method,
                required String url,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> sortOrder = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestsCompanion.insert(
                id: id,
                collectionId: collectionId,
                folderId: folderId,
                name: name,
                method: method,
                url: url,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestsTable,
      Request,
      $$RequestsTableFilterComposer,
      $$RequestsTableOrderingComposer,
      $$RequestsTableAnnotationComposer,
      $$RequestsTableCreateCompanionBuilder,
      $$RequestsTableUpdateCompanionBuilder,
      (Request, BaseReferences<_$AppDatabase, $RequestsTable, Request>),
      Request,
      PrefetchHooks Function()
    >;
typedef $$RequestHeadersTableCreateCompanionBuilder =
    RequestHeadersCompanion Function({
      required String id,
      required String requestId,
      required String name,
      required String valueOrSecretRef,
      Value<bool> isSecret,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$RequestHeadersTableUpdateCompanionBuilder =
    RequestHeadersCompanion Function({
      Value<String> id,
      Value<String> requestId,
      Value<String> name,
      Value<String> valueOrSecretRef,
      Value<bool> isSecret,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$RequestHeadersTableFilterComposer
    extends Composer<_$AppDatabase, $RequestHeadersTable> {
  $$RequestHeadersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueOrSecretRef => $composableBuilder(
    column: $table.valueOrSecretRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSecret => $composableBuilder(
    column: $table.isSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestHeadersTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestHeadersTable> {
  $$RequestHeadersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueOrSecretRef => $composableBuilder(
    column: $table.valueOrSecretRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSecret => $composableBuilder(
    column: $table.isSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestHeadersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestHeadersTable> {
  $$RequestHeadersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get valueOrSecretRef => $composableBuilder(
    column: $table.valueOrSecretRef,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSecret =>
      $composableBuilder(column: $table.isSecret, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$RequestHeadersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestHeadersTable,
          RequestHeader,
          $$RequestHeadersTableFilterComposer,
          $$RequestHeadersTableOrderingComposer,
          $$RequestHeadersTableAnnotationComposer,
          $$RequestHeadersTableCreateCompanionBuilder,
          $$RequestHeadersTableUpdateCompanionBuilder,
          (
            RequestHeader,
            BaseReferences<_$AppDatabase, $RequestHeadersTable, RequestHeader>,
          ),
          RequestHeader,
          PrefetchHooks Function()
        > {
  $$RequestHeadersTableTableManager(
    _$AppDatabase db,
    $RequestHeadersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestHeadersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestHeadersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestHeadersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> valueOrSecretRef = const Value.absent(),
                Value<bool> isSecret = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestHeadersCompanion(
                id: id,
                requestId: requestId,
                name: name,
                valueOrSecretRef: valueOrSecretRef,
                isSecret: isSecret,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String requestId,
                required String name,
                required String valueOrSecretRef,
                Value<bool> isSecret = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestHeadersCompanion.insert(
                id: id,
                requestId: requestId,
                name: name,
                valueOrSecretRef: valueOrSecretRef,
                isSecret: isSecret,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestHeadersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestHeadersTable,
      RequestHeader,
      $$RequestHeadersTableFilterComposer,
      $$RequestHeadersTableOrderingComposer,
      $$RequestHeadersTableAnnotationComposer,
      $$RequestHeadersTableCreateCompanionBuilder,
      $$RequestHeadersTableUpdateCompanionBuilder,
      (
        RequestHeader,
        BaseReferences<_$AppDatabase, $RequestHeadersTable, RequestHeader>,
      ),
      RequestHeader,
      PrefetchHooks Function()
    >;
typedef $$RequestQueryParamsTableCreateCompanionBuilder =
    RequestQueryParamsCompanion Function({
      required String id,
      required String requestId,
      required String name,
      required String value,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$RequestQueryParamsTableUpdateCompanionBuilder =
    RequestQueryParamsCompanion Function({
      Value<String> id,
      Value<String> requestId,
      Value<String> name,
      Value<String> value,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$RequestQueryParamsTableFilterComposer
    extends Composer<_$AppDatabase, $RequestQueryParamsTable> {
  $$RequestQueryParamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestQueryParamsTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestQueryParamsTable> {
  $$RequestQueryParamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestQueryParamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestQueryParamsTable> {
  $$RequestQueryParamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$RequestQueryParamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestQueryParamsTable,
          RequestQueryParam,
          $$RequestQueryParamsTableFilterComposer,
          $$RequestQueryParamsTableOrderingComposer,
          $$RequestQueryParamsTableAnnotationComposer,
          $$RequestQueryParamsTableCreateCompanionBuilder,
          $$RequestQueryParamsTableUpdateCompanionBuilder,
          (
            RequestQueryParam,
            BaseReferences<
              _$AppDatabase,
              $RequestQueryParamsTable,
              RequestQueryParam
            >,
          ),
          RequestQueryParam,
          PrefetchHooks Function()
        > {
  $$RequestQueryParamsTableTableManager(
    _$AppDatabase db,
    $RequestQueryParamsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestQueryParamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestQueryParamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestQueryParamsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestQueryParamsCompanion(
                id: id,
                requestId: requestId,
                name: name,
                value: value,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String requestId,
                required String name,
                required String value,
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestQueryParamsCompanion.insert(
                id: id,
                requestId: requestId,
                name: name,
                value: value,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestQueryParamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestQueryParamsTable,
      RequestQueryParam,
      $$RequestQueryParamsTableFilterComposer,
      $$RequestQueryParamsTableOrderingComposer,
      $$RequestQueryParamsTableAnnotationComposer,
      $$RequestQueryParamsTableCreateCompanionBuilder,
      $$RequestQueryParamsTableUpdateCompanionBuilder,
      (
        RequestQueryParam,
        BaseReferences<
          _$AppDatabase,
          $RequestQueryParamsTable,
          RequestQueryParam
        >,
      ),
      RequestQueryParam,
      PrefetchHooks Function()
    >;
typedef $$RequestBodiesTableCreateCompanionBuilder =
    RequestBodiesCompanion Function({
      required String id,
      required String requestId,
      required String type,
      required String contentOrSecretRef,
      Value<int> rowid,
    });
typedef $$RequestBodiesTableUpdateCompanionBuilder =
    RequestBodiesCompanion Function({
      Value<String> id,
      Value<String> requestId,
      Value<String> type,
      Value<String> contentOrSecretRef,
      Value<int> rowid,
    });

class $$RequestBodiesTableFilterComposer
    extends Composer<_$AppDatabase, $RequestBodiesTable> {
  $$RequestBodiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentOrSecretRef => $composableBuilder(
    column: $table.contentOrSecretRef,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestBodiesTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestBodiesTable> {
  $$RequestBodiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentOrSecretRef => $composableBuilder(
    column: $table.contentOrSecretRef,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestBodiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestBodiesTable> {
  $$RequestBodiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contentOrSecretRef => $composableBuilder(
    column: $table.contentOrSecretRef,
    builder: (column) => column,
  );
}

class $$RequestBodiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestBodiesTable,
          RequestBody,
          $$RequestBodiesTableFilterComposer,
          $$RequestBodiesTableOrderingComposer,
          $$RequestBodiesTableAnnotationComposer,
          $$RequestBodiesTableCreateCompanionBuilder,
          $$RequestBodiesTableUpdateCompanionBuilder,
          (
            RequestBody,
            BaseReferences<_$AppDatabase, $RequestBodiesTable, RequestBody>,
          ),
          RequestBody,
          PrefetchHooks Function()
        > {
  $$RequestBodiesTableTableManager(_$AppDatabase db, $RequestBodiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestBodiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestBodiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestBodiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> contentOrSecretRef = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestBodiesCompanion(
                id: id,
                requestId: requestId,
                type: type,
                contentOrSecretRef: contentOrSecretRef,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String requestId,
                required String type,
                required String contentOrSecretRef,
                Value<int> rowid = const Value.absent(),
              }) => RequestBodiesCompanion.insert(
                id: id,
                requestId: requestId,
                type: type,
                contentOrSecretRef: contentOrSecretRef,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestBodiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestBodiesTable,
      RequestBody,
      $$RequestBodiesTableFilterComposer,
      $$RequestBodiesTableOrderingComposer,
      $$RequestBodiesTableAnnotationComposer,
      $$RequestBodiesTableCreateCompanionBuilder,
      $$RequestBodiesTableUpdateCompanionBuilder,
      (
        RequestBody,
        BaseReferences<_$AppDatabase, $RequestBodiesTable, RequestBody>,
      ),
      RequestBody,
      PrefetchHooks Function()
    >;
typedef $$EnvironmentsTableCreateCompanionBuilder =
    EnvironmentsCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> workspaceId,
      Value<String> kind,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$EnvironmentsTableUpdateCompanionBuilder =
    EnvironmentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> workspaceId,
      Value<String> kind,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$EnvironmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnvironmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvironmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$EnvironmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentsTable,
          Environment,
          $$EnvironmentsTableFilterComposer,
          $$EnvironmentsTableOrderingComposer,
          $$EnvironmentsTableAnnotationComposer,
          $$EnvironmentsTableCreateCompanionBuilder,
          $$EnvironmentsTableUpdateCompanionBuilder,
          (
            Environment,
            BaseReferences<_$AppDatabase, $EnvironmentsTable, Environment>,
          ),
          Environment,
          PrefetchHooks Function()
        > {
  $$EnvironmentsTableTableManager(_$AppDatabase db, $EnvironmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvironmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                kind: kind,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> workspaceId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                kind: kind,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvironmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentsTable,
      Environment,
      $$EnvironmentsTableFilterComposer,
      $$EnvironmentsTableOrderingComposer,
      $$EnvironmentsTableAnnotationComposer,
      $$EnvironmentsTableCreateCompanionBuilder,
      $$EnvironmentsTableUpdateCompanionBuilder,
      (
        Environment,
        BaseReferences<_$AppDatabase, $EnvironmentsTable, Environment>,
      ),
      Environment,
      PrefetchHooks Function()
    >;
typedef $$EnvironmentVariablesTableCreateCompanionBuilder =
    EnvironmentVariablesCompanion Function({
      required String id,
      required String environmentId,
      required String name,
      required String valueOrSecretRef,
      Value<bool> isSecret,
      Value<bool> enabled,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$EnvironmentVariablesTableUpdateCompanionBuilder =
    EnvironmentVariablesCompanion Function({
      Value<String> id,
      Value<String> environmentId,
      Value<String> name,
      Value<String> valueOrSecretRef,
      Value<bool> isSecret,
      Value<bool> enabled,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$EnvironmentVariablesTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentVariablesTable> {
  $$EnvironmentVariablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueOrSecretRef => $composableBuilder(
    column: $table.valueOrSecretRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSecret => $composableBuilder(
    column: $table.isSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnvironmentVariablesTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentVariablesTable> {
  $$EnvironmentVariablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueOrSecretRef => $composableBuilder(
    column: $table.valueOrSecretRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSecret => $composableBuilder(
    column: $table.isSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvironmentVariablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentVariablesTable> {
  $$EnvironmentVariablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get valueOrSecretRef => $composableBuilder(
    column: $table.valueOrSecretRef,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSecret =>
      $composableBuilder(column: $table.isSecret, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$EnvironmentVariablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentVariablesTable,
          EnvironmentVariable,
          $$EnvironmentVariablesTableFilterComposer,
          $$EnvironmentVariablesTableOrderingComposer,
          $$EnvironmentVariablesTableAnnotationComposer,
          $$EnvironmentVariablesTableCreateCompanionBuilder,
          $$EnvironmentVariablesTableUpdateCompanionBuilder,
          (
            EnvironmentVariable,
            BaseReferences<
              _$AppDatabase,
              $EnvironmentVariablesTable,
              EnvironmentVariable
            >,
          ),
          EnvironmentVariable,
          PrefetchHooks Function()
        > {
  $$EnvironmentVariablesTableTableManager(
    _$AppDatabase db,
    $EnvironmentVariablesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentVariablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentVariablesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EnvironmentVariablesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> environmentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> valueOrSecretRef = const Value.absent(),
                Value<bool> isSecret = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentVariablesCompanion(
                id: id,
                environmentId: environmentId,
                name: name,
                valueOrSecretRef: valueOrSecretRef,
                isSecret: isSecret,
                enabled: enabled,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String environmentId,
                required String name,
                required String valueOrSecretRef,
                Value<bool> isSecret = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentVariablesCompanion.insert(
                id: id,
                environmentId: environmentId,
                name: name,
                valueOrSecretRef: valueOrSecretRef,
                isSecret: isSecret,
                enabled: enabled,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvironmentVariablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentVariablesTable,
      EnvironmentVariable,
      $$EnvironmentVariablesTableFilterComposer,
      $$EnvironmentVariablesTableOrderingComposer,
      $$EnvironmentVariablesTableAnnotationComposer,
      $$EnvironmentVariablesTableCreateCompanionBuilder,
      $$EnvironmentVariablesTableUpdateCompanionBuilder,
      (
        EnvironmentVariable,
        BaseReferences<
          _$AppDatabase,
          $EnvironmentVariablesTable,
          EnvironmentVariable
        >,
      ),
      EnvironmentVariable,
      PrefetchHooks Function()
    >;
typedef $$RequestHistoryTableCreateCompanionBuilder =
    RequestHistoryCompanion Function({
      required String id,
      required String requestId,
      required String responseSnapshotId,
      required DateTime createdAt,
      Value<String> snapshotJson,
      Value<int> rowid,
    });
typedef $$RequestHistoryTableUpdateCompanionBuilder =
    RequestHistoryCompanion Function({
      Value<String> id,
      Value<String> requestId,
      Value<String> responseSnapshotId,
      Value<DateTime> createdAt,
      Value<String> snapshotJson,
      Value<int> rowid,
    });

class $$RequestHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $RequestHistoryTable> {
  $$RequestHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseSnapshotId => $composableBuilder(
    column: $table.responseSnapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestHistoryTable> {
  $$RequestHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseSnapshotId => $composableBuilder(
    column: $table.responseSnapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestHistoryTable> {
  $$RequestHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get responseSnapshotId => $composableBuilder(
    column: $table.responseSnapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );
}

class $$RequestHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestHistoryTable,
          RequestHistoryData,
          $$RequestHistoryTableFilterComposer,
          $$RequestHistoryTableOrderingComposer,
          $$RequestHistoryTableAnnotationComposer,
          $$RequestHistoryTableCreateCompanionBuilder,
          $$RequestHistoryTableUpdateCompanionBuilder,
          (
            RequestHistoryData,
            BaseReferences<
              _$AppDatabase,
              $RequestHistoryTable,
              RequestHistoryData
            >,
          ),
          RequestHistoryData,
          PrefetchHooks Function()
        > {
  $$RequestHistoryTableTableManager(
    _$AppDatabase db,
    $RequestHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> responseSnapshotId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestHistoryCompanion(
                id: id,
                requestId: requestId,
                responseSnapshotId: responseSnapshotId,
                createdAt: createdAt,
                snapshotJson: snapshotJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String requestId,
                required String responseSnapshotId,
                required DateTime createdAt,
                Value<String> snapshotJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestHistoryCompanion.insert(
                id: id,
                requestId: requestId,
                responseSnapshotId: responseSnapshotId,
                createdAt: createdAt,
                snapshotJson: snapshotJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestHistoryTable,
      RequestHistoryData,
      $$RequestHistoryTableFilterComposer,
      $$RequestHistoryTableOrderingComposer,
      $$RequestHistoryTableAnnotationComposer,
      $$RequestHistoryTableCreateCompanionBuilder,
      $$RequestHistoryTableUpdateCompanionBuilder,
      (
        RequestHistoryData,
        BaseReferences<_$AppDatabase, $RequestHistoryTable, RequestHistoryData>,
      ),
      RequestHistoryData,
      PrefetchHooks Function()
    >;
typedef $$ResponseSnapshotsTableCreateCompanionBuilder =
    ResponseSnapshotsCompanion Function({
      required String id,
      required String requestId,
      Value<int?> statusCode,
      required String bodyPreview,
      required int durationMs,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ResponseSnapshotsTableUpdateCompanionBuilder =
    ResponseSnapshotsCompanion Function({
      Value<String> id,
      Value<String> requestId,
      Value<int?> statusCode,
      Value<String> bodyPreview,
      Value<int> durationMs,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ResponseSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ResponseSnapshotsTable> {
  $$ResponseSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPreview => $composableBuilder(
    column: $table.bodyPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResponseSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResponseSnapshotsTable> {
  $$ResponseSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPreview => $composableBuilder(
    column: $table.bodyPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResponseSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResponseSnapshotsTable> {
  $$ResponseSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyPreview => $composableBuilder(
    column: $table.bodyPreview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ResponseSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResponseSnapshotsTable,
          ResponseSnapshot,
          $$ResponseSnapshotsTableFilterComposer,
          $$ResponseSnapshotsTableOrderingComposer,
          $$ResponseSnapshotsTableAnnotationComposer,
          $$ResponseSnapshotsTableCreateCompanionBuilder,
          $$ResponseSnapshotsTableUpdateCompanionBuilder,
          (
            ResponseSnapshot,
            BaseReferences<
              _$AppDatabase,
              $ResponseSnapshotsTable,
              ResponseSnapshot
            >,
          ),
          ResponseSnapshot,
          PrefetchHooks Function()
        > {
  $$ResponseSnapshotsTableTableManager(
    _$AppDatabase db,
    $ResponseSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResponseSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResponseSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResponseSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<String> bodyPreview = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResponseSnapshotsCompanion(
                id: id,
                requestId: requestId,
                statusCode: statusCode,
                bodyPreview: bodyPreview,
                durationMs: durationMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String requestId,
                Value<int?> statusCode = const Value.absent(),
                required String bodyPreview,
                required int durationMs,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ResponseSnapshotsCompanion.insert(
                id: id,
                requestId: requestId,
                statusCode: statusCode,
                bodyPreview: bodyPreview,
                durationMs: durationMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResponseSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResponseSnapshotsTable,
      ResponseSnapshot,
      $$ResponseSnapshotsTableFilterComposer,
      $$ResponseSnapshotsTableOrderingComposer,
      $$ResponseSnapshotsTableAnnotationComposer,
      $$ResponseSnapshotsTableCreateCompanionBuilder,
      $$ResponseSnapshotsTableUpdateCompanionBuilder,
      (
        ResponseSnapshot,
        BaseReferences<
          _$AppDatabase,
          $ResponseSnapshotsTable,
          ResponseSnapshot
        >,
      ),
      ResponseSnapshot,
      PrefetchHooks Function()
    >;
typedef $$WebSocketSessionsTableCreateCompanionBuilder =
    WebSocketSessionsCompanion Function({
      required String id,
      required String url,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WebSocketSessionsTableUpdateCompanionBuilder =
    WebSocketSessionsCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WebSocketSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WebSocketSessionsTable> {
  $$WebSocketSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WebSocketSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WebSocketSessionsTable> {
  $$WebSocketSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WebSocketSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WebSocketSessionsTable> {
  $$WebSocketSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WebSocketSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WebSocketSessionsTable,
          WebSocketSession,
          $$WebSocketSessionsTableFilterComposer,
          $$WebSocketSessionsTableOrderingComposer,
          $$WebSocketSessionsTableAnnotationComposer,
          $$WebSocketSessionsTableCreateCompanionBuilder,
          $$WebSocketSessionsTableUpdateCompanionBuilder,
          (
            WebSocketSession,
            BaseReferences<
              _$AppDatabase,
              $WebSocketSessionsTable,
              WebSocketSession
            >,
          ),
          WebSocketSession,
          PrefetchHooks Function()
        > {
  $$WebSocketSessionsTableTableManager(
    _$AppDatabase db,
    $WebSocketSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WebSocketSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WebSocketSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WebSocketSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WebSocketSessionsCompanion(
                id: id,
                url: url,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WebSocketSessionsCompanion.insert(
                id: id,
                url: url,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WebSocketSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WebSocketSessionsTable,
      WebSocketSession,
      $$WebSocketSessionsTableFilterComposer,
      $$WebSocketSessionsTableOrderingComposer,
      $$WebSocketSessionsTableAnnotationComposer,
      $$WebSocketSessionsTableCreateCompanionBuilder,
      $$WebSocketSessionsTableUpdateCompanionBuilder,
      (
        WebSocketSession,
        BaseReferences<
          _$AppDatabase,
          $WebSocketSessionsTable,
          WebSocketSession
        >,
      ),
      WebSocketSession,
      PrefetchHooks Function()
    >;
typedef $$AiAnalysesTableCreateCompanionBuilder =
    AiAnalysesCompanion Function({
      required String id,
      required String responseSnapshotId,
      required String summary,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AiAnalysesTableUpdateCompanionBuilder =
    AiAnalysesCompanion Function({
      Value<String> id,
      Value<String> responseSnapshotId,
      Value<String> summary,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AiAnalysesTableFilterComposer
    extends Composer<_$AppDatabase, $AiAnalysesTable> {
  $$AiAnalysesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseSnapshotId => $composableBuilder(
    column: $table.responseSnapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiAnalysesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiAnalysesTable> {
  $$AiAnalysesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseSnapshotId => $composableBuilder(
    column: $table.responseSnapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiAnalysesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiAnalysesTable> {
  $$AiAnalysesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get responseSnapshotId => $composableBuilder(
    column: $table.responseSnapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiAnalysesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiAnalysesTable,
          AiAnalyse,
          $$AiAnalysesTableFilterComposer,
          $$AiAnalysesTableOrderingComposer,
          $$AiAnalysesTableAnnotationComposer,
          $$AiAnalysesTableCreateCompanionBuilder,
          $$AiAnalysesTableUpdateCompanionBuilder,
          (
            AiAnalyse,
            BaseReferences<_$AppDatabase, $AiAnalysesTable, AiAnalyse>,
          ),
          AiAnalyse,
          PrefetchHooks Function()
        > {
  $$AiAnalysesTableTableManager(_$AppDatabase db, $AiAnalysesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiAnalysesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiAnalysesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiAnalysesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> responseSnapshotId = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiAnalysesCompanion(
                id: id,
                responseSnapshotId: responseSnapshotId,
                summary: summary,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String responseSnapshotId,
                required String summary,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AiAnalysesCompanion.insert(
                id: id,
                responseSnapshotId: responseSnapshotId,
                summary: summary,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiAnalysesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiAnalysesTable,
      AiAnalyse,
      $$AiAnalysesTableFilterComposer,
      $$AiAnalysesTableOrderingComposer,
      $$AiAnalysesTableAnnotationComposer,
      $$AiAnalysesTableCreateCompanionBuilder,
      $$AiAnalysesTableUpdateCompanionBuilder,
      (AiAnalyse, BaseReferences<_$AppDatabase, $AiAnalysesTable, AiAnalyse>),
      AiAnalyse,
      PrefetchHooks Function()
    >;
typedef $$RequestDraftsTableCreateCompanionBuilder =
    RequestDraftsCompanion Function({
      required String id,
      Value<String?> requestId,
      required String title,
      required String payloadJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RequestDraftsTableUpdateCompanionBuilder =
    RequestDraftsCompanion Function({
      Value<String> id,
      Value<String?> requestId,
      Value<String> title,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RequestDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $RequestDraftsTable> {
  $$RequestDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestDraftsTable> {
  $$RequestDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestDraftsTable> {
  $$RequestDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RequestDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestDraftsTable,
          RequestDraft,
          $$RequestDraftsTableFilterComposer,
          $$RequestDraftsTableOrderingComposer,
          $$RequestDraftsTableAnnotationComposer,
          $$RequestDraftsTableCreateCompanionBuilder,
          $$RequestDraftsTableUpdateCompanionBuilder,
          (
            RequestDraft,
            BaseReferences<_$AppDatabase, $RequestDraftsTable, RequestDraft>,
          ),
          RequestDraft,
          PrefetchHooks Function()
        > {
  $$RequestDraftsTableTableManager(_$AppDatabase db, $RequestDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestDraftsCompanion(
                id: id,
                requestId: requestId,
                title: title,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> requestId = const Value.absent(),
                required String title,
                required String payloadJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RequestDraftsCompanion.insert(
                id: id,
                requestId: requestId,
                title: title,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestDraftsTable,
      RequestDraft,
      $$RequestDraftsTableFilterComposer,
      $$RequestDraftsTableOrderingComposer,
      $$RequestDraftsTableAnnotationComposer,
      $$RequestDraftsTableCreateCompanionBuilder,
      $$RequestDraftsTableUpdateCompanionBuilder,
      (
        RequestDraft,
        BaseReferences<_$AppDatabase, $RequestDraftsTable, RequestDraft>,
      ),
      RequestDraft,
      PrefetchHooks Function()
    >;
typedef $$RealtimeConfigurationsTableCreateCompanionBuilder =
    RealtimeConfigurationsCompanion Function({
      required String id,
      required String workspaceId,
      required String protocol,
      required String name,
      required String url,
      Value<String> payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RealtimeConfigurationsTableUpdateCompanionBuilder =
    RealtimeConfigurationsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> protocol,
      Value<String> name,
      Value<String> url,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RealtimeConfigurationsTableFilterComposer
    extends Composer<_$AppDatabase, $RealtimeConfigurationsTable> {
  $$RealtimeConfigurationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RealtimeConfigurationsTableOrderingComposer
    extends Composer<_$AppDatabase, $RealtimeConfigurationsTable> {
  $$RealtimeConfigurationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RealtimeConfigurationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RealtimeConfigurationsTable> {
  $$RealtimeConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RealtimeConfigurationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RealtimeConfigurationsTable,
          RealtimeConfiguration,
          $$RealtimeConfigurationsTableFilterComposer,
          $$RealtimeConfigurationsTableOrderingComposer,
          $$RealtimeConfigurationsTableAnnotationComposer,
          $$RealtimeConfigurationsTableCreateCompanionBuilder,
          $$RealtimeConfigurationsTableUpdateCompanionBuilder,
          (
            RealtimeConfiguration,
            BaseReferences<
              _$AppDatabase,
              $RealtimeConfigurationsTable,
              RealtimeConfiguration
            >,
          ),
          RealtimeConfiguration,
          PrefetchHooks Function()
        > {
  $$RealtimeConfigurationsTableTableManager(
    _$AppDatabase db,
    $RealtimeConfigurationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RealtimeConfigurationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RealtimeConfigurationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RealtimeConfigurationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RealtimeConfigurationsCompanion(
                id: id,
                workspaceId: workspaceId,
                protocol: protocol,
                name: name,
                url: url,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String protocol,
                required String name,
                required String url,
                Value<String> payloadJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RealtimeConfigurationsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                protocol: protocol,
                name: name,
                url: url,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RealtimeConfigurationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RealtimeConfigurationsTable,
      RealtimeConfiguration,
      $$RealtimeConfigurationsTableFilterComposer,
      $$RealtimeConfigurationsTableOrderingComposer,
      $$RealtimeConfigurationsTableAnnotationComposer,
      $$RealtimeConfigurationsTableCreateCompanionBuilder,
      $$RealtimeConfigurationsTableUpdateCompanionBuilder,
      (
        RealtimeConfiguration,
        BaseReferences<
          _$AppDatabase,
          $RealtimeConfigurationsTable,
          RealtimeConfiguration
        >,
      ),
      RealtimeConfiguration,
      PrefetchHooks Function()
    >;
typedef $$RealtimeDraftsTableCreateCompanionBuilder =
    RealtimeDraftsCompanion Function({
      required String id,
      Value<String?> configurationId,
      required String workspaceId,
      required String protocol,
      required String title,
      required String payloadJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RealtimeDraftsTableUpdateCompanionBuilder =
    RealtimeDraftsCompanion Function({
      Value<String> id,
      Value<String?> configurationId,
      Value<String> workspaceId,
      Value<String> protocol,
      Value<String> title,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RealtimeDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $RealtimeDraftsTable> {
  $$RealtimeDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configurationId => $composableBuilder(
    column: $table.configurationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RealtimeDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $RealtimeDraftsTable> {
  $$RealtimeDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configurationId => $composableBuilder(
    column: $table.configurationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RealtimeDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RealtimeDraftsTable> {
  $$RealtimeDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get configurationId => $composableBuilder(
    column: $table.configurationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RealtimeDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RealtimeDraftsTable,
          RealtimeDraft,
          $$RealtimeDraftsTableFilterComposer,
          $$RealtimeDraftsTableOrderingComposer,
          $$RealtimeDraftsTableAnnotationComposer,
          $$RealtimeDraftsTableCreateCompanionBuilder,
          $$RealtimeDraftsTableUpdateCompanionBuilder,
          (
            RealtimeDraft,
            BaseReferences<_$AppDatabase, $RealtimeDraftsTable, RealtimeDraft>,
          ),
          RealtimeDraft,
          PrefetchHooks Function()
        > {
  $$RealtimeDraftsTableTableManager(
    _$AppDatabase db,
    $RealtimeDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RealtimeDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RealtimeDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RealtimeDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> configurationId = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RealtimeDraftsCompanion(
                id: id,
                configurationId: configurationId,
                workspaceId: workspaceId,
                protocol: protocol,
                title: title,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> configurationId = const Value.absent(),
                required String workspaceId,
                required String protocol,
                required String title,
                required String payloadJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RealtimeDraftsCompanion.insert(
                id: id,
                configurationId: configurationId,
                workspaceId: workspaceId,
                protocol: protocol,
                title: title,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RealtimeDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RealtimeDraftsTable,
      RealtimeDraft,
      $$RealtimeDraftsTableFilterComposer,
      $$RealtimeDraftsTableOrderingComposer,
      $$RealtimeDraftsTableAnnotationComposer,
      $$RealtimeDraftsTableCreateCompanionBuilder,
      $$RealtimeDraftsTableUpdateCompanionBuilder,
      (
        RealtimeDraft,
        BaseReferences<_$AppDatabase, $RealtimeDraftsTable, RealtimeDraft>,
      ),
      RealtimeDraft,
      PrefetchHooks Function()
    >;
typedef $$RealtimeHistoryTableCreateCompanionBuilder =
    RealtimeHistoryCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> configurationId,
      required String protocol,
      required String status,
      Value<String?> collectionId,
      Value<String?> requestId,
      Value<String?> environmentId,
      Value<String?> failureCategory,
      required String summaryJson,
      Value<bool> pinned,
      Value<String> tagsJson,
      Value<String> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RealtimeHistoryTableUpdateCompanionBuilder =
    RealtimeHistoryCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> configurationId,
      Value<String> protocol,
      Value<String> status,
      Value<String?> collectionId,
      Value<String?> requestId,
      Value<String?> environmentId,
      Value<String?> failureCategory,
      Value<String> summaryJson,
      Value<bool> pinned,
      Value<String> tagsJson,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RealtimeHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $RealtimeHistoryTable> {
  $$RealtimeHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configurationId => $composableBuilder(
    column: $table.configurationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureCategory => $composableBuilder(
    column: $table.failureCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RealtimeHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $RealtimeHistoryTable> {
  $$RealtimeHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configurationId => $composableBuilder(
    column: $table.configurationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureCategory => $composableBuilder(
    column: $table.failureCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RealtimeHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $RealtimeHistoryTable> {
  $$RealtimeHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configurationId => $composableBuilder(
    column: $table.configurationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureCategory => $composableBuilder(
    column: $table.failureCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RealtimeHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RealtimeHistoryTable,
          RealtimeHistoryData,
          $$RealtimeHistoryTableFilterComposer,
          $$RealtimeHistoryTableOrderingComposer,
          $$RealtimeHistoryTableAnnotationComposer,
          $$RealtimeHistoryTableCreateCompanionBuilder,
          $$RealtimeHistoryTableUpdateCompanionBuilder,
          (
            RealtimeHistoryData,
            BaseReferences<
              _$AppDatabase,
              $RealtimeHistoryTable,
              RealtimeHistoryData
            >,
          ),
          RealtimeHistoryData,
          PrefetchHooks Function()
        > {
  $$RealtimeHistoryTableTableManager(
    _$AppDatabase db,
    $RealtimeHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RealtimeHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RealtimeHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RealtimeHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> configurationId = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> environmentId = const Value.absent(),
                Value<String?> failureCategory = const Value.absent(),
                Value<String> summaryJson = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RealtimeHistoryCompanion(
                id: id,
                workspaceId: workspaceId,
                configurationId: configurationId,
                protocol: protocol,
                status: status,
                collectionId: collectionId,
                requestId: requestId,
                environmentId: environmentId,
                failureCategory: failureCategory,
                summaryJson: summaryJson,
                pinned: pinned,
                tagsJson: tagsJson,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> configurationId = const Value.absent(),
                required String protocol,
                required String status,
                Value<String?> collectionId = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> environmentId = const Value.absent(),
                Value<String?> failureCategory = const Value.absent(),
                required String summaryJson,
                Value<bool> pinned = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RealtimeHistoryCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                configurationId: configurationId,
                protocol: protocol,
                status: status,
                collectionId: collectionId,
                requestId: requestId,
                environmentId: environmentId,
                failureCategory: failureCategory,
                summaryJson: summaryJson,
                pinned: pinned,
                tagsJson: tagsJson,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RealtimeHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RealtimeHistoryTable,
      RealtimeHistoryData,
      $$RealtimeHistoryTableFilterComposer,
      $$RealtimeHistoryTableOrderingComposer,
      $$RealtimeHistoryTableAnnotationComposer,
      $$RealtimeHistoryTableCreateCompanionBuilder,
      $$RealtimeHistoryTableUpdateCompanionBuilder,
      (
        RealtimeHistoryData,
        BaseReferences<
          _$AppDatabase,
          $RealtimeHistoryTable,
          RealtimeHistoryData
        >,
      ),
      RealtimeHistoryData,
      PrefetchHooks Function()
    >;
typedef $$AiPreferencesTableCreateCompanionBuilder =
    AiPreferencesCompanion Function({
      required String id,
      Value<bool> consentGranted,
      Value<String?> providerName,
      Value<String?> providerModel,
      Value<String?> providerEndpoint,
      Value<bool> includeBodies,
      Value<bool> includeHeaders,
      Value<bool> includeHistory,
      Value<bool> includeEvents,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AiPreferencesTableUpdateCompanionBuilder =
    AiPreferencesCompanion Function({
      Value<String> id,
      Value<bool> consentGranted,
      Value<String?> providerName,
      Value<String?> providerModel,
      Value<String?> providerEndpoint,
      Value<bool> includeBodies,
      Value<bool> includeHeaders,
      Value<bool> includeHistory,
      Value<bool> includeEvents,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AiPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AiPreferencesTable> {
  $$AiPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get consentGranted => $composableBuilder(
    column: $table.consentGranted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerModel => $composableBuilder(
    column: $table.providerModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerEndpoint => $composableBuilder(
    column: $table.providerEndpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeBodies => $composableBuilder(
    column: $table.includeBodies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeHeaders => $composableBuilder(
    column: $table.includeHeaders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeHistory => $composableBuilder(
    column: $table.includeHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeEvents => $composableBuilder(
    column: $table.includeEvents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiPreferencesTable> {
  $$AiPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get consentGranted => $composableBuilder(
    column: $table.consentGranted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerModel => $composableBuilder(
    column: $table.providerModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerEndpoint => $composableBuilder(
    column: $table.providerEndpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeBodies => $composableBuilder(
    column: $table.includeBodies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeHeaders => $composableBuilder(
    column: $table.includeHeaders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeHistory => $composableBuilder(
    column: $table.includeHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeEvents => $composableBuilder(
    column: $table.includeEvents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiPreferencesTable> {
  $$AiPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get consentGranted => $composableBuilder(
    column: $table.consentGranted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerModel => $composableBuilder(
    column: $table.providerModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerEndpoint => $composableBuilder(
    column: $table.providerEndpoint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeBodies => $composableBuilder(
    column: $table.includeBodies,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeHeaders => $composableBuilder(
    column: $table.includeHeaders,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeHistory => $composableBuilder(
    column: $table.includeHistory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeEvents => $composableBuilder(
    column: $table.includeEvents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiPreferencesTable,
          AiPreference,
          $$AiPreferencesTableFilterComposer,
          $$AiPreferencesTableOrderingComposer,
          $$AiPreferencesTableAnnotationComposer,
          $$AiPreferencesTableCreateCompanionBuilder,
          $$AiPreferencesTableUpdateCompanionBuilder,
          (
            AiPreference,
            BaseReferences<_$AppDatabase, $AiPreferencesTable, AiPreference>,
          ),
          AiPreference,
          PrefetchHooks Function()
        > {
  $$AiPreferencesTableTableManager(_$AppDatabase db, $AiPreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> consentGranted = const Value.absent(),
                Value<String?> providerName = const Value.absent(),
                Value<String?> providerModel = const Value.absent(),
                Value<String?> providerEndpoint = const Value.absent(),
                Value<bool> includeBodies = const Value.absent(),
                Value<bool> includeHeaders = const Value.absent(),
                Value<bool> includeHistory = const Value.absent(),
                Value<bool> includeEvents = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiPreferencesCompanion(
                id: id,
                consentGranted: consentGranted,
                providerName: providerName,
                providerModel: providerModel,
                providerEndpoint: providerEndpoint,
                includeBodies: includeBodies,
                includeHeaders: includeHeaders,
                includeHistory: includeHistory,
                includeEvents: includeEvents,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<bool> consentGranted = const Value.absent(),
                Value<String?> providerName = const Value.absent(),
                Value<String?> providerModel = const Value.absent(),
                Value<String?> providerEndpoint = const Value.absent(),
                Value<bool> includeBodies = const Value.absent(),
                Value<bool> includeHeaders = const Value.absent(),
                Value<bool> includeHistory = const Value.absent(),
                Value<bool> includeEvents = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AiPreferencesCompanion.insert(
                id: id,
                consentGranted: consentGranted,
                providerName: providerName,
                providerModel: providerModel,
                providerEndpoint: providerEndpoint,
                includeBodies: includeBodies,
                includeHeaders: includeHeaders,
                includeHistory: includeHistory,
                includeEvents: includeEvents,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiPreferencesTable,
      AiPreference,
      $$AiPreferencesTableFilterComposer,
      $$AiPreferencesTableOrderingComposer,
      $$AiPreferencesTableAnnotationComposer,
      $$AiPreferencesTableCreateCompanionBuilder,
      $$AiPreferencesTableUpdateCompanionBuilder,
      (
        AiPreference,
        BaseReferences<_$AppDatabase, $AiPreferencesTable, AiPreference>,
      ),
      AiPreference,
      PrefetchHooks Function()
    >;
typedef $$WorkspaceSettingsTableCreateCompanionBuilder =
    WorkspaceSettingsCompanion Function({
      required String workspaceId,
      Value<int> historyRetentionDays,
      Value<int> historyMaximumCount,
      Value<int> responsePreviewBytes,
      Value<bool> productionStrictMode,
      Value<int> realtimeRetentionDays,
      Value<int> realtimeMaximumCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WorkspaceSettingsTableUpdateCompanionBuilder =
    WorkspaceSettingsCompanion Function({
      Value<String> workspaceId,
      Value<int> historyRetentionDays,
      Value<int> historyMaximumCount,
      Value<int> responsePreviewBytes,
      Value<bool> productionStrictMode,
      Value<int> realtimeRetentionDays,
      Value<int> realtimeMaximumCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WorkspaceSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspaceSettingsTable> {
  $$WorkspaceSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get historyRetentionDays => $composableBuilder(
    column: $table.historyRetentionDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get historyMaximumCount => $composableBuilder(
    column: $table.historyMaximumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responsePreviewBytes => $composableBuilder(
    column: $table.responsePreviewBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get productionStrictMode => $composableBuilder(
    column: $table.productionStrictMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realtimeRetentionDays => $composableBuilder(
    column: $table.realtimeRetentionDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realtimeMaximumCount => $composableBuilder(
    column: $table.realtimeMaximumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspaceSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspaceSettingsTable> {
  $$WorkspaceSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get historyRetentionDays => $composableBuilder(
    column: $table.historyRetentionDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get historyMaximumCount => $composableBuilder(
    column: $table.historyMaximumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responsePreviewBytes => $composableBuilder(
    column: $table.responsePreviewBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get productionStrictMode => $composableBuilder(
    column: $table.productionStrictMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realtimeRetentionDays => $composableBuilder(
    column: $table.realtimeRetentionDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realtimeMaximumCount => $composableBuilder(
    column: $table.realtimeMaximumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspaceSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspaceSettingsTable> {
  $$WorkspaceSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get historyRetentionDays => $composableBuilder(
    column: $table.historyRetentionDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get historyMaximumCount => $composableBuilder(
    column: $table.historyMaximumCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responsePreviewBytes => $composableBuilder(
    column: $table.responsePreviewBytes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get productionStrictMode => $composableBuilder(
    column: $table.productionStrictMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realtimeRetentionDays => $composableBuilder(
    column: $table.realtimeRetentionDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realtimeMaximumCount => $composableBuilder(
    column: $table.realtimeMaximumCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkspaceSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspaceSettingsTable,
          WorkspaceSetting,
          $$WorkspaceSettingsTableFilterComposer,
          $$WorkspaceSettingsTableOrderingComposer,
          $$WorkspaceSettingsTableAnnotationComposer,
          $$WorkspaceSettingsTableCreateCompanionBuilder,
          $$WorkspaceSettingsTableUpdateCompanionBuilder,
          (
            WorkspaceSetting,
            BaseReferences<
              _$AppDatabase,
              $WorkspaceSettingsTable,
              WorkspaceSetting
            >,
          ),
          WorkspaceSetting,
          PrefetchHooks Function()
        > {
  $$WorkspaceSettingsTableTableManager(
    _$AppDatabase db,
    $WorkspaceSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspaceSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspaceSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspaceSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> workspaceId = const Value.absent(),
                Value<int> historyRetentionDays = const Value.absent(),
                Value<int> historyMaximumCount = const Value.absent(),
                Value<int> responsePreviewBytes = const Value.absent(),
                Value<bool> productionStrictMode = const Value.absent(),
                Value<int> realtimeRetentionDays = const Value.absent(),
                Value<int> realtimeMaximumCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceSettingsCompanion(
                workspaceId: workspaceId,
                historyRetentionDays: historyRetentionDays,
                historyMaximumCount: historyMaximumCount,
                responsePreviewBytes: responsePreviewBytes,
                productionStrictMode: productionStrictMode,
                realtimeRetentionDays: realtimeRetentionDays,
                realtimeMaximumCount: realtimeMaximumCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workspaceId,
                Value<int> historyRetentionDays = const Value.absent(),
                Value<int> historyMaximumCount = const Value.absent(),
                Value<int> responsePreviewBytes = const Value.absent(),
                Value<bool> productionStrictMode = const Value.absent(),
                Value<int> realtimeRetentionDays = const Value.absent(),
                Value<int> realtimeMaximumCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceSettingsCompanion.insert(
                workspaceId: workspaceId,
                historyRetentionDays: historyRetentionDays,
                historyMaximumCount: historyMaximumCount,
                responsePreviewBytes: responsePreviewBytes,
                productionStrictMode: productionStrictMode,
                realtimeRetentionDays: realtimeRetentionDays,
                realtimeMaximumCount: realtimeMaximumCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspaceSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspaceSettingsTable,
      WorkspaceSetting,
      $$WorkspaceSettingsTableFilterComposer,
      $$WorkspaceSettingsTableOrderingComposer,
      $$WorkspaceSettingsTableAnnotationComposer,
      $$WorkspaceSettingsTableCreateCompanionBuilder,
      $$WorkspaceSettingsTableUpdateCompanionBuilder,
      (
        WorkspaceSetting,
        BaseReferences<
          _$AppDatabase,
          $WorkspaceSettingsTable,
          WorkspaceSetting
        >,
      ),
      WorkspaceSetting,
      PrefetchHooks Function()
    >;
typedef $$GraphqlDraftsTableCreateCompanionBuilder =
    GraphqlDraftsCompanion Function({
      required String id,
      required String workspaceId,
      required String title,
      required String endpoint,
      required String document,
      Value<String?> operationName,
      Value<String> variablesJson,
      Value<String> headersJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GraphqlDraftsTableUpdateCompanionBuilder =
    GraphqlDraftsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> title,
      Value<String> endpoint,
      Value<String> document,
      Value<String?> operationName,
      Value<String> variablesJson,
      Value<String> headersJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GraphqlDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $GraphqlDraftsTable> {
  $$GraphqlDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationName => $composableBuilder(
    column: $table.operationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GraphqlDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $GraphqlDraftsTable> {
  $$GraphqlDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationName => $composableBuilder(
    column: $table.operationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GraphqlDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GraphqlDraftsTable> {
  $$GraphqlDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get document =>
      $composableBuilder(column: $table.document, builder: (column) => column);

  GeneratedColumn<String> get operationName => $composableBuilder(
    column: $table.operationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GraphqlDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GraphqlDraftsTable,
          GraphqlDraft,
          $$GraphqlDraftsTableFilterComposer,
          $$GraphqlDraftsTableOrderingComposer,
          $$GraphqlDraftsTableAnnotationComposer,
          $$GraphqlDraftsTableCreateCompanionBuilder,
          $$GraphqlDraftsTableUpdateCompanionBuilder,
          (
            GraphqlDraft,
            BaseReferences<_$AppDatabase, $GraphqlDraftsTable, GraphqlDraft>,
          ),
          GraphqlDraft,
          PrefetchHooks Function()
        > {
  $$GraphqlDraftsTableTableManager(_$AppDatabase db, $GraphqlDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraphqlDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GraphqlDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GraphqlDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> document = const Value.absent(),
                Value<String?> operationName = const Value.absent(),
                Value<String> variablesJson = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphqlDraftsCompanion(
                id: id,
                workspaceId: workspaceId,
                title: title,
                endpoint: endpoint,
                document: document,
                operationName: operationName,
                variablesJson: variablesJson,
                headersJson: headersJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String title,
                required String endpoint,
                required String document,
                Value<String?> operationName = const Value.absent(),
                Value<String> variablesJson = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GraphqlDraftsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                title: title,
                endpoint: endpoint,
                document: document,
                operationName: operationName,
                variablesJson: variablesJson,
                headersJson: headersJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GraphqlDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GraphqlDraftsTable,
      GraphqlDraft,
      $$GraphqlDraftsTableFilterComposer,
      $$GraphqlDraftsTableOrderingComposer,
      $$GraphqlDraftsTableAnnotationComposer,
      $$GraphqlDraftsTableCreateCompanionBuilder,
      $$GraphqlDraftsTableUpdateCompanionBuilder,
      (
        GraphqlDraft,
        BaseReferences<_$AppDatabase, $GraphqlDraftsTable, GraphqlDraft>,
      ),
      GraphqlDraft,
      PrefetchHooks Function()
    >;
typedef $$GraphqlHistoryTableCreateCompanionBuilder =
    GraphqlHistoryCompanion Function({
      required String id,
      Value<String?> draftId,
      required String workspaceId,
      required String operationType,
      required String summaryJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GraphqlHistoryTableUpdateCompanionBuilder =
    GraphqlHistoryCompanion Function({
      Value<String> id,
      Value<String?> draftId,
      Value<String> workspaceId,
      Value<String> operationType,
      Value<String> summaryJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$GraphqlHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $GraphqlHistoryTable> {
  $$GraphqlHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftId => $composableBuilder(
    column: $table.draftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GraphqlHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $GraphqlHistoryTable> {
  $$GraphqlHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftId => $composableBuilder(
    column: $table.draftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GraphqlHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $GraphqlHistoryTable> {
  $$GraphqlHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get draftId =>
      $composableBuilder(column: $table.draftId, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GraphqlHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GraphqlHistoryTable,
          GraphqlHistoryData,
          $$GraphqlHistoryTableFilterComposer,
          $$GraphqlHistoryTableOrderingComposer,
          $$GraphqlHistoryTableAnnotationComposer,
          $$GraphqlHistoryTableCreateCompanionBuilder,
          $$GraphqlHistoryTableUpdateCompanionBuilder,
          (
            GraphqlHistoryData,
            BaseReferences<
              _$AppDatabase,
              $GraphqlHistoryTable,
              GraphqlHistoryData
            >,
          ),
          GraphqlHistoryData,
          PrefetchHooks Function()
        > {
  $$GraphqlHistoryTableTableManager(
    _$AppDatabase db,
    $GraphqlHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraphqlHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GraphqlHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GraphqlHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> draftId = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> summaryJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphqlHistoryCompanion(
                id: id,
                draftId: draftId,
                workspaceId: workspaceId,
                operationType: operationType,
                summaryJson: summaryJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> draftId = const Value.absent(),
                required String workspaceId,
                required String operationType,
                required String summaryJson,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GraphqlHistoryCompanion.insert(
                id: id,
                draftId: draftId,
                workspaceId: workspaceId,
                operationType: operationType,
                summaryJson: summaryJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GraphqlHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GraphqlHistoryTable,
      GraphqlHistoryData,
      $$GraphqlHistoryTableFilterComposer,
      $$GraphqlHistoryTableOrderingComposer,
      $$GraphqlHistoryTableAnnotationComposer,
      $$GraphqlHistoryTableCreateCompanionBuilder,
      $$GraphqlHistoryTableUpdateCompanionBuilder,
      (
        GraphqlHistoryData,
        BaseReferences<_$AppDatabase, $GraphqlHistoryTable, GraphqlHistoryData>,
      ),
      GraphqlHistoryData,
      PrefetchHooks Function()
    >;
typedef $$GraphqlSavedRequestsTableCreateCompanionBuilder =
    GraphqlSavedRequestsCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> collectionId,
      Value<String?> folderId,
      required String name,
      required String payloadJson,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GraphqlSavedRequestsTableUpdateCompanionBuilder =
    GraphqlSavedRequestsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> collectionId,
      Value<String?> folderId,
      Value<String> name,
      Value<String> payloadJson,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GraphqlSavedRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $GraphqlSavedRequestsTable> {
  $$GraphqlSavedRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GraphqlSavedRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $GraphqlSavedRequestsTable> {
  $$GraphqlSavedRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GraphqlSavedRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GraphqlSavedRequestsTable> {
  $$GraphqlSavedRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GraphqlSavedRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GraphqlSavedRequestsTable,
          GraphqlSavedRequest,
          $$GraphqlSavedRequestsTableFilterComposer,
          $$GraphqlSavedRequestsTableOrderingComposer,
          $$GraphqlSavedRequestsTableAnnotationComposer,
          $$GraphqlSavedRequestsTableCreateCompanionBuilder,
          $$GraphqlSavedRequestsTableUpdateCompanionBuilder,
          (
            GraphqlSavedRequest,
            BaseReferences<
              _$AppDatabase,
              $GraphqlSavedRequestsTable,
              GraphqlSavedRequest
            >,
          ),
          GraphqlSavedRequest,
          PrefetchHooks Function()
        > {
  $$GraphqlSavedRequestsTableTableManager(
    _$AppDatabase db,
    $GraphqlSavedRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraphqlSavedRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GraphqlSavedRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GraphqlSavedRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphqlSavedRequestsCompanion(
                id: id,
                workspaceId: workspaceId,
                collectionId: collectionId,
                folderId: folderId,
                name: name,
                payloadJson: payloadJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> collectionId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                required String name,
                required String payloadJson,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GraphqlSavedRequestsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                collectionId: collectionId,
                folderId: folderId,
                name: name,
                payloadJson: payloadJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GraphqlSavedRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GraphqlSavedRequestsTable,
      GraphqlSavedRequest,
      $$GraphqlSavedRequestsTableFilterComposer,
      $$GraphqlSavedRequestsTableOrderingComposer,
      $$GraphqlSavedRequestsTableAnnotationComposer,
      $$GraphqlSavedRequestsTableCreateCompanionBuilder,
      $$GraphqlSavedRequestsTableUpdateCompanionBuilder,
      (
        GraphqlSavedRequest,
        BaseReferences<
          _$AppDatabase,
          $GraphqlSavedRequestsTable,
          GraphqlSavedRequest
        >,
      ),
      GraphqlSavedRequest,
      PrefetchHooks Function()
    >;
typedef $$GraphqlSchemaSnapshotsTableCreateCompanionBuilder =
    GraphqlSchemaSnapshotsCompanion Function({
      required String id,
      required String workspaceId,
      required String endpointFingerprint,
      required String schemaHash,
      required String snapshotJson,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$GraphqlSchemaSnapshotsTableUpdateCompanionBuilder =
    GraphqlSchemaSnapshotsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> endpointFingerprint,
      Value<String> schemaHash,
      Value<String> snapshotJson,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$GraphqlSchemaSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $GraphqlSchemaSnapshotsTable> {
  $$GraphqlSchemaSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpointFingerprint => $composableBuilder(
    column: $table.endpointFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schemaHash => $composableBuilder(
    column: $table.schemaHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GraphqlSchemaSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $GraphqlSchemaSnapshotsTable> {
  $$GraphqlSchemaSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpointFingerprint => $composableBuilder(
    column: $table.endpointFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schemaHash => $composableBuilder(
    column: $table.schemaHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GraphqlSchemaSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GraphqlSchemaSnapshotsTable> {
  $$GraphqlSchemaSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpointFingerprint => $composableBuilder(
    column: $table.endpointFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schemaHash => $composableBuilder(
    column: $table.schemaHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$GraphqlSchemaSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GraphqlSchemaSnapshotsTable,
          GraphqlSchemaSnapshot,
          $$GraphqlSchemaSnapshotsTableFilterComposer,
          $$GraphqlSchemaSnapshotsTableOrderingComposer,
          $$GraphqlSchemaSnapshotsTableAnnotationComposer,
          $$GraphqlSchemaSnapshotsTableCreateCompanionBuilder,
          $$GraphqlSchemaSnapshotsTableUpdateCompanionBuilder,
          (
            GraphqlSchemaSnapshot,
            BaseReferences<
              _$AppDatabase,
              $GraphqlSchemaSnapshotsTable,
              GraphqlSchemaSnapshot
            >,
          ),
          GraphqlSchemaSnapshot,
          PrefetchHooks Function()
        > {
  $$GraphqlSchemaSnapshotsTableTableManager(
    _$AppDatabase db,
    $GraphqlSchemaSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraphqlSchemaSnapshotsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$GraphqlSchemaSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GraphqlSchemaSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> endpointFingerprint = const Value.absent(),
                Value<String> schemaHash = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphqlSchemaSnapshotsCompanion(
                id: id,
                workspaceId: workspaceId,
                endpointFingerprint: endpointFingerprint,
                schemaHash: schemaHash,
                snapshotJson: snapshotJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String endpointFingerprint,
                required String schemaHash,
                required String snapshotJson,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => GraphqlSchemaSnapshotsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                endpointFingerprint: endpointFingerprint,
                schemaHash: schemaHash,
                snapshotJson: snapshotJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GraphqlSchemaSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GraphqlSchemaSnapshotsTable,
      GraphqlSchemaSnapshot,
      $$GraphqlSchemaSnapshotsTableFilterComposer,
      $$GraphqlSchemaSnapshotsTableOrderingComposer,
      $$GraphqlSchemaSnapshotsTableAnnotationComposer,
      $$GraphqlSchemaSnapshotsTableCreateCompanionBuilder,
      $$GraphqlSchemaSnapshotsTableUpdateCompanionBuilder,
      (
        GraphqlSchemaSnapshot,
        BaseReferences<
          _$AppDatabase,
          $GraphqlSchemaSnapshotsTable,
          GraphqlSchemaSnapshot
        >,
      ),
      GraphqlSchemaSnapshot,
      PrefetchHooks Function()
    >;
typedef $$GrpcDescriptorSnapshotsTableCreateCompanionBuilder =
    GrpcDescriptorSnapshotsCompanion Function({
      required String id,
      required String workspaceId,
      required String fingerprint,
      required String sourceType,
      required String displayName,
      Value<String?> sourceIdentity,
      required Uint8List descriptorBytes,
      required int descriptorByteCount,
      required int fileCount,
      required int serviceCount,
      required DateTime createdAt,
      required DateTime lastUsedAt,
      Value<int> rowid,
    });
typedef $$GrpcDescriptorSnapshotsTableUpdateCompanionBuilder =
    GrpcDescriptorSnapshotsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> fingerprint,
      Value<String> sourceType,
      Value<String> displayName,
      Value<String?> sourceIdentity,
      Value<Uint8List> descriptorBytes,
      Value<int> descriptorByteCount,
      Value<int> fileCount,
      Value<int> serviceCount,
      Value<DateTime> createdAt,
      Value<DateTime> lastUsedAt,
      Value<int> rowid,
    });

final class $$GrpcDescriptorSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GrpcDescriptorSnapshotsTable,
          GrpcDescriptorSnapshot
        > {
  $$GrpcDescriptorSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) => db.workspaces
      .createAlias('grpc_descriptor_snapshots__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GrpcSavedRequestsTable, List<GrpcSavedRequest>>
  _grpcSavedRequestsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.grpcSavedRequests,
    aliasName:
        'grpc_descriptor_snapshots__id__grpc_saved_requests__descriptor_snapshot_id',
  );

  $$GrpcSavedRequestsTableProcessedTableManager get grpcSavedRequestsRefs {
    final manager =
        $$GrpcSavedRequestsTableTableManager(
          $_db,
          $_db.grpcSavedRequests,
        ).filter(
          (f) =>
              f.descriptorSnapshotId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _grpcSavedRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GrpcDraftsTable, List<GrpcDraft>>
  _grpcDraftsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grpcDrafts,
    aliasName:
        'grpc_descriptor_snapshots__id__grpc_drafts__descriptor_snapshot_id',
  );

  $$GrpcDraftsTableProcessedTableManager get grpcDraftsRefs {
    final manager = $$GrpcDraftsTableTableManager($_db, $_db.grpcDrafts).filter(
      (f) => f.descriptorSnapshotId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_grpcDraftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GrpcInvocationHistoryTable,
    List<GrpcInvocationHistoryData>
  >
  _grpcInvocationHistoryRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.grpcInvocationHistory,
    aliasName:
        'grpc_descriptor_snapshots__id__grpc_invocation_history__descriptor_snapshot_id',
  );

  $$GrpcInvocationHistoryTableProcessedTableManager
  get grpcInvocationHistoryRefs {
    final manager =
        $$GrpcInvocationHistoryTableTableManager(
          $_db,
          $_db.grpcInvocationHistory,
        ).filter(
          (f) =>
              f.descriptorSnapshotId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _grpcInvocationHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GrpcDescriptorSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $GrpcDescriptorSnapshotsTable> {
  $$GrpcDescriptorSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIdentity => $composableBuilder(
    column: $table.sourceIdentity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get descriptorBytes => $composableBuilder(
    column: $table.descriptorBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get descriptorByteCount => $composableBuilder(
    column: $table.descriptorByteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileCount => $composableBuilder(
    column: $table.fileCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serviceCount => $composableBuilder(
    column: $table.serviceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> grpcSavedRequestsRefs(
    Expression<bool> Function($$GrpcSavedRequestsTableFilterComposer f) f,
  ) {
    final $$GrpcSavedRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcSavedRequests,
      getReferencedColumn: (t) => t.descriptorSnapshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcSavedRequestsTableFilterComposer(
            $db: $db,
            $table: $db.grpcSavedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grpcDraftsRefs(
    Expression<bool> Function($$GrpcDraftsTableFilterComposer f) f,
  ) {
    final $$GrpcDraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcDrafts,
      getReferencedColumn: (t) => t.descriptorSnapshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcDraftsTableFilterComposer(
            $db: $db,
            $table: $db.grpcDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grpcInvocationHistoryRefs(
    Expression<bool> Function($$GrpcInvocationHistoryTableFilterComposer f) f,
  ) {
    final $$GrpcInvocationHistoryTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.descriptorSnapshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableFilterComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GrpcDescriptorSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrpcDescriptorSnapshotsTable> {
  $$GrpcDescriptorSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIdentity => $composableBuilder(
    column: $table.sourceIdentity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get descriptorBytes => $composableBuilder(
    column: $table.descriptorBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get descriptorByteCount => $composableBuilder(
    column: $table.descriptorByteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileCount => $composableBuilder(
    column: $table.fileCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serviceCount => $composableBuilder(
    column: $table.serviceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrpcDescriptorSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrpcDescriptorSnapshotsTable> {
  $$GrpcDescriptorSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceIdentity => $composableBuilder(
    column: $table.sourceIdentity,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get descriptorBytes => $composableBuilder(
    column: $table.descriptorBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get descriptorByteCount => $composableBuilder(
    column: $table.descriptorByteCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileCount =>
      $composableBuilder(column: $table.fileCount, builder: (column) => column);

  GeneratedColumn<int> get serviceCount => $composableBuilder(
    column: $table.serviceCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> grpcSavedRequestsRefs<T extends Object>(
    Expression<T> Function($$GrpcSavedRequestsTableAnnotationComposer a) f,
  ) {
    final $$GrpcSavedRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcSavedRequests,
          getReferencedColumn: (t) => t.descriptorSnapshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcSavedRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcSavedRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> grpcDraftsRefs<T extends Object>(
    Expression<T> Function($$GrpcDraftsTableAnnotationComposer a) f,
  ) {
    final $$GrpcDraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcDrafts,
      getReferencedColumn: (t) => t.descriptorSnapshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcDraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.grpcDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> grpcInvocationHistoryRefs<T extends Object>(
    Expression<T> Function($$GrpcInvocationHistoryTableAnnotationComposer a) f,
  ) {
    final $$GrpcInvocationHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.descriptorSnapshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GrpcDescriptorSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrpcDescriptorSnapshotsTable,
          GrpcDescriptorSnapshot,
          $$GrpcDescriptorSnapshotsTableFilterComposer,
          $$GrpcDescriptorSnapshotsTableOrderingComposer,
          $$GrpcDescriptorSnapshotsTableAnnotationComposer,
          $$GrpcDescriptorSnapshotsTableCreateCompanionBuilder,
          $$GrpcDescriptorSnapshotsTableUpdateCompanionBuilder,
          (GrpcDescriptorSnapshot, $$GrpcDescriptorSnapshotsTableReferences),
          GrpcDescriptorSnapshot,
          PrefetchHooks Function({
            bool workspaceId,
            bool grpcSavedRequestsRefs,
            bool grpcDraftsRefs,
            bool grpcInvocationHistoryRefs,
          })
        > {
  $$GrpcDescriptorSnapshotsTableTableManager(
    _$AppDatabase db,
    $GrpcDescriptorSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrpcDescriptorSnapshotsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$GrpcDescriptorSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GrpcDescriptorSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> sourceIdentity = const Value.absent(),
                Value<Uint8List> descriptorBytes = const Value.absent(),
                Value<int> descriptorByteCount = const Value.absent(),
                Value<int> fileCount = const Value.absent(),
                Value<int> serviceCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrpcDescriptorSnapshotsCompanion(
                id: id,
                workspaceId: workspaceId,
                fingerprint: fingerprint,
                sourceType: sourceType,
                displayName: displayName,
                sourceIdentity: sourceIdentity,
                descriptorBytes: descriptorBytes,
                descriptorByteCount: descriptorByteCount,
                fileCount: fileCount,
                serviceCount: serviceCount,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String fingerprint,
                required String sourceType,
                required String displayName,
                Value<String?> sourceIdentity = const Value.absent(),
                required Uint8List descriptorBytes,
                required int descriptorByteCount,
                required int fileCount,
                required int serviceCount,
                required DateTime createdAt,
                required DateTime lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => GrpcDescriptorSnapshotsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                fingerprint: fingerprint,
                sourceType: sourceType,
                displayName: displayName,
                sourceIdentity: sourceIdentity,
                descriptorBytes: descriptorBytes,
                descriptorByteCount: descriptorByteCount,
                fileCount: fileCount,
                serviceCount: serviceCount,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrpcDescriptorSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                grpcSavedRequestsRefs = false,
                grpcDraftsRefs = false,
                grpcInvocationHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (grpcSavedRequestsRefs) db.grpcSavedRequests,
                    if (grpcDraftsRefs) db.grpcDrafts,
                    if (grpcInvocationHistoryRefs) db.grpcInvocationHistory,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$GrpcDescriptorSnapshotsTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$GrpcDescriptorSnapshotsTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (grpcSavedRequestsRefs)
                        await $_getPrefetchedData<
                          GrpcDescriptorSnapshot,
                          $GrpcDescriptorSnapshotsTable,
                          GrpcSavedRequest
                        >(
                          currentTable: table,
                          referencedTable:
                              $$GrpcDescriptorSnapshotsTableReferences
                                  ._grpcSavedRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrpcDescriptorSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcSavedRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.descriptorSnapshotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grpcDraftsRefs)
                        await $_getPrefetchedData<
                          GrpcDescriptorSnapshot,
                          $GrpcDescriptorSnapshotsTable,
                          GrpcDraft
                        >(
                          currentTable: table,
                          referencedTable:
                              $$GrpcDescriptorSnapshotsTableReferences
                                  ._grpcDraftsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrpcDescriptorSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcDraftsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.descriptorSnapshotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grpcInvocationHistoryRefs)
                        await $_getPrefetchedData<
                          GrpcDescriptorSnapshot,
                          $GrpcDescriptorSnapshotsTable,
                          GrpcInvocationHistoryData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$GrpcDescriptorSnapshotsTableReferences
                                  ._grpcInvocationHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrpcDescriptorSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcInvocationHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.descriptorSnapshotId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GrpcDescriptorSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrpcDescriptorSnapshotsTable,
      GrpcDescriptorSnapshot,
      $$GrpcDescriptorSnapshotsTableFilterComposer,
      $$GrpcDescriptorSnapshotsTableOrderingComposer,
      $$GrpcDescriptorSnapshotsTableAnnotationComposer,
      $$GrpcDescriptorSnapshotsTableCreateCompanionBuilder,
      $$GrpcDescriptorSnapshotsTableUpdateCompanionBuilder,
      (GrpcDescriptorSnapshot, $$GrpcDescriptorSnapshotsTableReferences),
      GrpcDescriptorSnapshot,
      PrefetchHooks Function({
        bool workspaceId,
        bool grpcSavedRequestsRefs,
        bool grpcDraftsRefs,
        bool grpcInvocationHistoryRefs,
      })
    >;
typedef $$GrpcSavedRequestsTableCreateCompanionBuilder =
    GrpcSavedRequestsCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> collectionId,
      Value<String?> folderId,
      Value<String?> descriptorSnapshotId,
      required String name,
      Value<int> sortOrder,
      required String serviceFullName,
      required String methodName,
      required String methodPath,
      required String invocationKind,
      required String endpointJson,
      required String requestJson,
      required String metadataJson,
      Value<String> certificateReferencesJson,
      Value<int> revision,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GrpcSavedRequestsTableUpdateCompanionBuilder =
    GrpcSavedRequestsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> collectionId,
      Value<String?> folderId,
      Value<String?> descriptorSnapshotId,
      Value<String> name,
      Value<int> sortOrder,
      Value<String> serviceFullName,
      Value<String> methodName,
      Value<String> methodPath,
      Value<String> invocationKind,
      Value<String> endpointJson,
      Value<String> requestJson,
      Value<String> metadataJson,
      Value<String> certificateReferencesJson,
      Value<int> revision,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$GrpcSavedRequestsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GrpcSavedRequestsTable,
          GrpcSavedRequest
        > {
  $$GrpcSavedRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) => db.workspaces
      .createAlias('grpc_saved_requests__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GrpcDescriptorSnapshotsTable _descriptorSnapshotIdTable(
    _$AppDatabase db,
  ) => db.grpcDescriptorSnapshots.createAlias(
    'grpc_saved_requests__descriptor_snapshot_id__grpc_descriptor_snapshots__id',
  );

  $$GrpcDescriptorSnapshotsTableProcessedTableManager?
  get descriptorSnapshotId {
    final $_column = $_itemColumn<String>('descriptor_snapshot_id');
    if ($_column == null) return null;
    final manager = $$GrpcDescriptorSnapshotsTableTableManager(
      $_db,
      $_db.grpcDescriptorSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _descriptorSnapshotIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GrpcDraftsTable, List<GrpcDraft>>
  _grpcDraftsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grpcDrafts,
    aliasName: 'grpc_saved_requests__id__grpc_drafts__source_saved_request_id',
  );

  $$GrpcDraftsTableProcessedTableManager get grpcDraftsRefs {
    final manager = $$GrpcDraftsTableTableManager($_db, $_db.grpcDrafts).filter(
      (f) => f.sourceSavedRequestId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_grpcDraftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GrpcInvocationHistoryTable,
    List<GrpcInvocationHistoryData>
  >
  _grpcInvocationHistoryRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.grpcInvocationHistory,
    aliasName:
        'grpc_saved_requests__id__grpc_invocation_history__saved_request_id',
  );

  $$GrpcInvocationHistoryTableProcessedTableManager
  get grpcInvocationHistoryRefs {
    final manager = $$GrpcInvocationHistoryTableTableManager(
      $_db,
      $_db.grpcInvocationHistory,
    ).filter((f) => f.savedRequestId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _grpcInvocationHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GrpcSavedRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $GrpcSavedRequestsTable> {
  $$GrpcSavedRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceFullName => $composableBuilder(
    column: $table.serviceFullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodPath => $composableBuilder(
    column: $table.methodPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invocationKind => $composableBuilder(
    column: $table.invocationKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certificateReferencesJson => $composableBuilder(
    column: $table.certificateReferencesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableFilterComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> grpcDraftsRefs(
    Expression<bool> Function($$GrpcDraftsTableFilterComposer f) f,
  ) {
    final $$GrpcDraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcDrafts,
      getReferencedColumn: (t) => t.sourceSavedRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcDraftsTableFilterComposer(
            $db: $db,
            $table: $db.grpcDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grpcInvocationHistoryRefs(
    Expression<bool> Function($$GrpcInvocationHistoryTableFilterComposer f) f,
  ) {
    final $$GrpcInvocationHistoryTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.savedRequestId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableFilterComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GrpcSavedRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrpcSavedRequestsTable> {
  $$GrpcSavedRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceFullName => $composableBuilder(
    column: $table.serviceFullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodPath => $composableBuilder(
    column: $table.methodPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invocationKind => $composableBuilder(
    column: $table.invocationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certificateReferencesJson => $composableBuilder(
    column: $table.certificateReferencesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableOrderingComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableOrderingComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcSavedRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrpcSavedRequestsTable> {
  $$GrpcSavedRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get serviceFullName => $composableBuilder(
    column: $table.serviceFullName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get methodPath => $composableBuilder(
    column: $table.methodPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invocationKind => $composableBuilder(
    column: $table.invocationKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get certificateReferencesJson => $composableBuilder(
    column: $table.certificateReferencesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableAnnotationComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> grpcDraftsRefs<T extends Object>(
    Expression<T> Function($$GrpcDraftsTableAnnotationComposer a) f,
  ) {
    final $$GrpcDraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grpcDrafts,
      getReferencedColumn: (t) => t.sourceSavedRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcDraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.grpcDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> grpcInvocationHistoryRefs<T extends Object>(
    Expression<T> Function($$GrpcInvocationHistoryTableAnnotationComposer a) f,
  ) {
    final $$GrpcInvocationHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.savedRequestId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GrpcSavedRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrpcSavedRequestsTable,
          GrpcSavedRequest,
          $$GrpcSavedRequestsTableFilterComposer,
          $$GrpcSavedRequestsTableOrderingComposer,
          $$GrpcSavedRequestsTableAnnotationComposer,
          $$GrpcSavedRequestsTableCreateCompanionBuilder,
          $$GrpcSavedRequestsTableUpdateCompanionBuilder,
          (GrpcSavedRequest, $$GrpcSavedRequestsTableReferences),
          GrpcSavedRequest,
          PrefetchHooks Function({
            bool workspaceId,
            bool descriptorSnapshotId,
            bool grpcDraftsRefs,
            bool grpcInvocationHistoryRefs,
          })
        > {
  $$GrpcSavedRequestsTableTableManager(
    _$AppDatabase db,
    $GrpcSavedRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrpcSavedRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrpcSavedRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrpcSavedRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String?> descriptorSnapshotId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> serviceFullName = const Value.absent(),
                Value<String> methodName = const Value.absent(),
                Value<String> methodPath = const Value.absent(),
                Value<String> invocationKind = const Value.absent(),
                Value<String> endpointJson = const Value.absent(),
                Value<String> requestJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<String> certificateReferencesJson = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrpcSavedRequestsCompanion(
                id: id,
                workspaceId: workspaceId,
                collectionId: collectionId,
                folderId: folderId,
                descriptorSnapshotId: descriptorSnapshotId,
                name: name,
                sortOrder: sortOrder,
                serviceFullName: serviceFullName,
                methodName: methodName,
                methodPath: methodPath,
                invocationKind: invocationKind,
                endpointJson: endpointJson,
                requestJson: requestJson,
                metadataJson: metadataJson,
                certificateReferencesJson: certificateReferencesJson,
                revision: revision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> collectionId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String?> descriptorSnapshotId = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required String serviceFullName,
                required String methodName,
                required String methodPath,
                required String invocationKind,
                required String endpointJson,
                required String requestJson,
                required String metadataJson,
                Value<String> certificateReferencesJson = const Value.absent(),
                Value<int> revision = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GrpcSavedRequestsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                collectionId: collectionId,
                folderId: folderId,
                descriptorSnapshotId: descriptorSnapshotId,
                name: name,
                sortOrder: sortOrder,
                serviceFullName: serviceFullName,
                methodName: methodName,
                methodPath: methodPath,
                invocationKind: invocationKind,
                endpointJson: endpointJson,
                requestJson: requestJson,
                metadataJson: metadataJson,
                certificateReferencesJson: certificateReferencesJson,
                revision: revision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrpcSavedRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                descriptorSnapshotId = false,
                grpcDraftsRefs = false,
                grpcInvocationHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (grpcDraftsRefs) db.grpcDrafts,
                    if (grpcInvocationHistoryRefs) db.grpcInvocationHistory,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$GrpcSavedRequestsTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$GrpcSavedRequestsTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (descriptorSnapshotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.descriptorSnapshotId,
                                    referencedTable:
                                        $$GrpcSavedRequestsTableReferences
                                            ._descriptorSnapshotIdTable(db),
                                    referencedColumn:
                                        $$GrpcSavedRequestsTableReferences
                                            ._descriptorSnapshotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (grpcDraftsRefs)
                        await $_getPrefetchedData<
                          GrpcSavedRequest,
                          $GrpcSavedRequestsTable,
                          GrpcDraft
                        >(
                          currentTable: table,
                          referencedTable: $$GrpcSavedRequestsTableReferences
                              ._grpcDraftsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrpcSavedRequestsTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcDraftsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSavedRequestId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grpcInvocationHistoryRefs)
                        await $_getPrefetchedData<
                          GrpcSavedRequest,
                          $GrpcSavedRequestsTable,
                          GrpcInvocationHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$GrpcSavedRequestsTableReferences
                              ._grpcInvocationHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrpcSavedRequestsTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcInvocationHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savedRequestId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GrpcSavedRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrpcSavedRequestsTable,
      GrpcSavedRequest,
      $$GrpcSavedRequestsTableFilterComposer,
      $$GrpcSavedRequestsTableOrderingComposer,
      $$GrpcSavedRequestsTableAnnotationComposer,
      $$GrpcSavedRequestsTableCreateCompanionBuilder,
      $$GrpcSavedRequestsTableUpdateCompanionBuilder,
      (GrpcSavedRequest, $$GrpcSavedRequestsTableReferences),
      GrpcSavedRequest,
      PrefetchHooks Function({
        bool workspaceId,
        bool descriptorSnapshotId,
        bool grpcDraftsRefs,
        bool grpcInvocationHistoryRefs,
      })
    >;
typedef $$GrpcDraftsTableCreateCompanionBuilder =
    GrpcDraftsCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> sourceSavedRequestId,
      Value<String?> descriptorSnapshotId,
      required String title,
      required String methodIdentityJson,
      required String endpointJson,
      required String requestJson,
      required String metadataJson,
      Value<String> certificateReferencesJson,
      Value<int> revision,
      Value<int> tabOrder,
      Value<bool> dirty,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime lastOpenedAt,
      Value<int> rowid,
    });
typedef $$GrpcDraftsTableUpdateCompanionBuilder =
    GrpcDraftsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> sourceSavedRequestId,
      Value<String?> descriptorSnapshotId,
      Value<String> title,
      Value<String> methodIdentityJson,
      Value<String> endpointJson,
      Value<String> requestJson,
      Value<String> metadataJson,
      Value<String> certificateReferencesJson,
      Value<int> revision,
      Value<int> tabOrder,
      Value<bool> dirty,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> lastOpenedAt,
      Value<int> rowid,
    });

final class $$GrpcDraftsTableReferences
    extends BaseReferences<_$AppDatabase, $GrpcDraftsTable, GrpcDraft> {
  $$GrpcDraftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias('grpc_drafts__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GrpcSavedRequestsTable _sourceSavedRequestIdTable(_$AppDatabase db) =>
      db.grpcSavedRequests.createAlias(
        'grpc_drafts__source_saved_request_id__grpc_saved_requests__id',
      );

  $$GrpcSavedRequestsTableProcessedTableManager? get sourceSavedRequestId {
    final $_column = $_itemColumn<String>('source_saved_request_id');
    if ($_column == null) return null;
    final manager = $$GrpcSavedRequestsTableTableManager(
      $_db,
      $_db.grpcSavedRequests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _sourceSavedRequestIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GrpcDescriptorSnapshotsTable _descriptorSnapshotIdTable(
    _$AppDatabase db,
  ) => db.grpcDescriptorSnapshots.createAlias(
    'grpc_drafts__descriptor_snapshot_id__grpc_descriptor_snapshots__id',
  );

  $$GrpcDescriptorSnapshotsTableProcessedTableManager?
  get descriptorSnapshotId {
    final $_column = $_itemColumn<String>('descriptor_snapshot_id');
    if ($_column == null) return null;
    final manager = $$GrpcDescriptorSnapshotsTableTableManager(
      $_db,
      $_db.grpcDescriptorSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _descriptorSnapshotIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GrpcDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $GrpcDraftsTable> {
  $$GrpcDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodIdentityJson => $composableBuilder(
    column: $table.methodIdentityJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certificateReferencesJson => $composableBuilder(
    column: $table.certificateReferencesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tabOrder => $composableBuilder(
    column: $table.tabOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcSavedRequestsTableFilterComposer get sourceSavedRequestId {
    final $$GrpcSavedRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSavedRequestId,
      referencedTable: $db.grpcSavedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcSavedRequestsTableFilterComposer(
            $db: $db,
            $table: $db.grpcSavedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableFilterComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrpcDraftsTable> {
  $$GrpcDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodIdentityJson => $composableBuilder(
    column: $table.methodIdentityJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certificateReferencesJson => $composableBuilder(
    column: $table.certificateReferencesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tabOrder => $composableBuilder(
    column: $table.tabOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcSavedRequestsTableOrderingComposer get sourceSavedRequestId {
    final $$GrpcSavedRequestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSavedRequestId,
      referencedTable: $db.grpcSavedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcSavedRequestsTableOrderingComposer(
            $db: $db,
            $table: $db.grpcSavedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableOrderingComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableOrderingComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrpcDraftsTable> {
  $$GrpcDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get methodIdentityJson => $composableBuilder(
    column: $table.methodIdentityJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get certificateReferencesJson => $composableBuilder(
    column: $table.certificateReferencesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get tabOrder =>
      $composableBuilder(column: $table.tabOrder, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcSavedRequestsTableAnnotationComposer get sourceSavedRequestId {
    final $$GrpcSavedRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceSavedRequestId,
          referencedTable: $db.grpcSavedRequests,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcSavedRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcSavedRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableAnnotationComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrpcDraftsTable,
          GrpcDraft,
          $$GrpcDraftsTableFilterComposer,
          $$GrpcDraftsTableOrderingComposer,
          $$GrpcDraftsTableAnnotationComposer,
          $$GrpcDraftsTableCreateCompanionBuilder,
          $$GrpcDraftsTableUpdateCompanionBuilder,
          (GrpcDraft, $$GrpcDraftsTableReferences),
          GrpcDraft,
          PrefetchHooks Function({
            bool workspaceId,
            bool sourceSavedRequestId,
            bool descriptorSnapshotId,
          })
        > {
  $$GrpcDraftsTableTableManager(_$AppDatabase db, $GrpcDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrpcDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrpcDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrpcDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> sourceSavedRequestId = const Value.absent(),
                Value<String?> descriptorSnapshotId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> methodIdentityJson = const Value.absent(),
                Value<String> endpointJson = const Value.absent(),
                Value<String> requestJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<String> certificateReferencesJson = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> tabOrder = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrpcDraftsCompanion(
                id: id,
                workspaceId: workspaceId,
                sourceSavedRequestId: sourceSavedRequestId,
                descriptorSnapshotId: descriptorSnapshotId,
                title: title,
                methodIdentityJson: methodIdentityJson,
                endpointJson: endpointJson,
                requestJson: requestJson,
                metadataJson: metadataJson,
                certificateReferencesJson: certificateReferencesJson,
                revision: revision,
                tabOrder: tabOrder,
                dirty: dirty,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> sourceSavedRequestId = const Value.absent(),
                Value<String?> descriptorSnapshotId = const Value.absent(),
                required String title,
                required String methodIdentityJson,
                required String endpointJson,
                required String requestJson,
                required String metadataJson,
                Value<String> certificateReferencesJson = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> tabOrder = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime lastOpenedAt,
                Value<int> rowid = const Value.absent(),
              }) => GrpcDraftsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                sourceSavedRequestId: sourceSavedRequestId,
                descriptorSnapshotId: descriptorSnapshotId,
                title: title,
                methodIdentityJson: methodIdentityJson,
                endpointJson: endpointJson,
                requestJson: requestJson,
                metadataJson: metadataJson,
                certificateReferencesJson: certificateReferencesJson,
                revision: revision,
                tabOrder: tabOrder,
                dirty: dirty,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrpcDraftsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                sourceSavedRequestId = false,
                descriptorSnapshotId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable: $$GrpcDraftsTableReferences
                                        ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$GrpcDraftsTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceSavedRequestId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceSavedRequestId,
                                    referencedTable: $$GrpcDraftsTableReferences
                                        ._sourceSavedRequestIdTable(db),
                                    referencedColumn:
                                        $$GrpcDraftsTableReferences
                                            ._sourceSavedRequestIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (descriptorSnapshotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.descriptorSnapshotId,
                                    referencedTable: $$GrpcDraftsTableReferences
                                        ._descriptorSnapshotIdTable(db),
                                    referencedColumn:
                                        $$GrpcDraftsTableReferences
                                            ._descriptorSnapshotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$GrpcDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrpcDraftsTable,
      GrpcDraft,
      $$GrpcDraftsTableFilterComposer,
      $$GrpcDraftsTableOrderingComposer,
      $$GrpcDraftsTableAnnotationComposer,
      $$GrpcDraftsTableCreateCompanionBuilder,
      $$GrpcDraftsTableUpdateCompanionBuilder,
      (GrpcDraft, $$GrpcDraftsTableReferences),
      GrpcDraft,
      PrefetchHooks Function({
        bool workspaceId,
        bool sourceSavedRequestId,
        bool descriptorSnapshotId,
      })
    >;
typedef $$GrpcInvocationHistoryTableCreateCompanionBuilder =
    GrpcInvocationHistoryCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> savedRequestId,
      Value<String?> descriptorSnapshotId,
      required String invocationKind,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<int?> durationMicroseconds,
      required String endpointJson,
      required String methodIdentityJson,
      required String requestJson,
      required String requestMetadataJson,
      Value<String?> responseJson,
      required String responseHeadersJson,
      required String responseTrailersJson,
      Value<int?> statusCode,
      Value<String?> statusName,
      Value<String?> statusMessage,
      Value<int> requestByteCount,
      Value<int> responseByteCount,
      required String outcome,
      Value<String?> diagnosticCategory,
      Value<int> droppedEventCount,
      required String terminalState,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GrpcInvocationHistoryTableUpdateCompanionBuilder =
    GrpcInvocationHistoryCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> savedRequestId,
      Value<String?> descriptorSnapshotId,
      Value<String> invocationKind,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int?> durationMicroseconds,
      Value<String> endpointJson,
      Value<String> methodIdentityJson,
      Value<String> requestJson,
      Value<String> requestMetadataJson,
      Value<String?> responseJson,
      Value<String> responseHeadersJson,
      Value<String> responseTrailersJson,
      Value<int?> statusCode,
      Value<String?> statusName,
      Value<String?> statusMessage,
      Value<int> requestByteCount,
      Value<int> responseByteCount,
      Value<String> outcome,
      Value<String?> diagnosticCategory,
      Value<int> droppedEventCount,
      Value<String> terminalState,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GrpcInvocationHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GrpcInvocationHistoryTable,
          GrpcInvocationHistoryData
        > {
  $$GrpcInvocationHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) => db.workspaces
      .createAlias('grpc_invocation_history__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GrpcSavedRequestsTable _savedRequestIdTable(_$AppDatabase db) =>
      db.grpcSavedRequests.createAlias(
        'grpc_invocation_history__saved_request_id__grpc_saved_requests__id',
      );

  $$GrpcSavedRequestsTableProcessedTableManager? get savedRequestId {
    final $_column = $_itemColumn<String>('saved_request_id');
    if ($_column == null) return null;
    final manager = $$GrpcSavedRequestsTableTableManager(
      $_db,
      $_db.grpcSavedRequests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedRequestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GrpcDescriptorSnapshotsTable _descriptorSnapshotIdTable(
    _$AppDatabase db,
  ) => db.grpcDescriptorSnapshots.createAlias(
    'grpc_invocation_history__descriptor_snapshot_id__grpc_descriptor_snapshots__id',
  );

  $$GrpcDescriptorSnapshotsTableProcessedTableManager?
  get descriptorSnapshotId {
    final $_column = $_itemColumn<String>('descriptor_snapshot_id');
    if ($_column == null) return null;
    final manager = $$GrpcDescriptorSnapshotsTableTableManager(
      $_db,
      $_db.grpcDescriptorSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _descriptorSnapshotIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $GrpcStoredStreamEventsTable,
    List<GrpcStoredStreamEvent>
  >
  _grpcStoredStreamEventsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.grpcStoredStreamEvents,
    aliasName:
        'grpc_invocation_history__id__grpc_stored_stream_events__session_history_id',
  );

  $$GrpcStoredStreamEventsTableProcessedTableManager
  get grpcStoredStreamEventsRefs {
    final manager =
        $$GrpcStoredStreamEventsTableTableManager(
          $_db,
          $_db.grpcStoredStreamEvents,
        ).filter(
          (f) => f.sessionHistoryId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _grpcStoredStreamEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GrpcInvocationHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $GrpcInvocationHistoryTable> {
  $$GrpcInvocationHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invocationKind => $composableBuilder(
    column: $table.invocationKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMicroseconds => $composableBuilder(
    column: $table.durationMicroseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodIdentityJson => $composableBuilder(
    column: $table.methodIdentityJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestMetadataJson => $composableBuilder(
    column: $table.requestMetadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseHeadersJson => $composableBuilder(
    column: $table.responseHeadersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseTrailersJson => $composableBuilder(
    column: $table.responseTrailersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestByteCount => $composableBuilder(
    column: $table.requestByteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseByteCount => $composableBuilder(
    column: $table.responseByteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosticCategory => $composableBuilder(
    column: $table.diagnosticCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get droppedEventCount => $composableBuilder(
    column: $table.droppedEventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terminalState => $composableBuilder(
    column: $table.terminalState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcSavedRequestsTableFilterComposer get savedRequestId {
    final $$GrpcSavedRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.grpcSavedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcSavedRequestsTableFilterComposer(
            $db: $db,
            $table: $db.grpcSavedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableFilterComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> grpcStoredStreamEventsRefs(
    Expression<bool> Function($$GrpcStoredStreamEventsTableFilterComposer f) f,
  ) {
    final $$GrpcStoredStreamEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcStoredStreamEvents,
          getReferencedColumn: (t) => t.sessionHistoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcStoredStreamEventsTableFilterComposer(
                $db: $db,
                $table: $db.grpcStoredStreamEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GrpcInvocationHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $GrpcInvocationHistoryTable> {
  $$GrpcInvocationHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invocationKind => $composableBuilder(
    column: $table.invocationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMicroseconds => $composableBuilder(
    column: $table.durationMicroseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodIdentityJson => $composableBuilder(
    column: $table.methodIdentityJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestMetadataJson => $composableBuilder(
    column: $table.requestMetadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseHeadersJson => $composableBuilder(
    column: $table.responseHeadersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseTrailersJson => $composableBuilder(
    column: $table.responseTrailersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestByteCount => $composableBuilder(
    column: $table.requestByteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseByteCount => $composableBuilder(
    column: $table.responseByteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosticCategory => $composableBuilder(
    column: $table.diagnosticCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get droppedEventCount => $composableBuilder(
    column: $table.droppedEventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terminalState => $composableBuilder(
    column: $table.terminalState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcSavedRequestsTableOrderingComposer get savedRequestId {
    final $$GrpcSavedRequestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.grpcSavedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrpcSavedRequestsTableOrderingComposer(
            $db: $db,
            $table: $db.grpcSavedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableOrderingComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableOrderingComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcInvocationHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrpcInvocationHistoryTable> {
  $$GrpcInvocationHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invocationKind => $composableBuilder(
    column: $table.invocationKind,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMicroseconds => $composableBuilder(
    column: $table.durationMicroseconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpointJson => $composableBuilder(
    column: $table.endpointJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get methodIdentityJson => $composableBuilder(
    column: $table.methodIdentityJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestJson => $composableBuilder(
    column: $table.requestJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestMetadataJson => $composableBuilder(
    column: $table.requestMetadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseHeadersJson => $composableBuilder(
    column: $table.responseHeadersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseTrailersJson => $composableBuilder(
    column: $table.responseTrailersJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestByteCount => $composableBuilder(
    column: $table.requestByteCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responseByteCount => $composableBuilder(
    column: $table.responseByteCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get diagnosticCategory => $composableBuilder(
    column: $table.diagnosticCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get droppedEventCount => $composableBuilder(
    column: $table.droppedEventCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get terminalState => $composableBuilder(
    column: $table.terminalState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GrpcSavedRequestsTableAnnotationComposer get savedRequestId {
    final $$GrpcSavedRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.savedRequestId,
          referencedTable: $db.grpcSavedRequests,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcSavedRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcSavedRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$GrpcDescriptorSnapshotsTableAnnotationComposer get descriptorSnapshotId {
    final $$GrpcDescriptorSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.descriptorSnapshotId,
          referencedTable: $db.grpcDescriptorSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcDescriptorSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcDescriptorSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> grpcStoredStreamEventsRefs<T extends Object>(
    Expression<T> Function($$GrpcStoredStreamEventsTableAnnotationComposer a) f,
  ) {
    final $$GrpcStoredStreamEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.grpcStoredStreamEvents,
          getReferencedColumn: (t) => t.sessionHistoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcStoredStreamEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcStoredStreamEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GrpcInvocationHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrpcInvocationHistoryTable,
          GrpcInvocationHistoryData,
          $$GrpcInvocationHistoryTableFilterComposer,
          $$GrpcInvocationHistoryTableOrderingComposer,
          $$GrpcInvocationHistoryTableAnnotationComposer,
          $$GrpcInvocationHistoryTableCreateCompanionBuilder,
          $$GrpcInvocationHistoryTableUpdateCompanionBuilder,
          (GrpcInvocationHistoryData, $$GrpcInvocationHistoryTableReferences),
          GrpcInvocationHistoryData,
          PrefetchHooks Function({
            bool workspaceId,
            bool savedRequestId,
            bool descriptorSnapshotId,
            bool grpcStoredStreamEventsRefs,
          })
        > {
  $$GrpcInvocationHistoryTableTableManager(
    _$AppDatabase db,
    $GrpcInvocationHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrpcInvocationHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$GrpcInvocationHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GrpcInvocationHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> savedRequestId = const Value.absent(),
                Value<String?> descriptorSnapshotId = const Value.absent(),
                Value<String> invocationKind = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> durationMicroseconds = const Value.absent(),
                Value<String> endpointJson = const Value.absent(),
                Value<String> methodIdentityJson = const Value.absent(),
                Value<String> requestJson = const Value.absent(),
                Value<String> requestMetadataJson = const Value.absent(),
                Value<String?> responseJson = const Value.absent(),
                Value<String> responseHeadersJson = const Value.absent(),
                Value<String> responseTrailersJson = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<String?> statusMessage = const Value.absent(),
                Value<int> requestByteCount = const Value.absent(),
                Value<int> responseByteCount = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String?> diagnosticCategory = const Value.absent(),
                Value<int> droppedEventCount = const Value.absent(),
                Value<String> terminalState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrpcInvocationHistoryCompanion(
                id: id,
                workspaceId: workspaceId,
                savedRequestId: savedRequestId,
                descriptorSnapshotId: descriptorSnapshotId,
                invocationKind: invocationKind,
                startedAt: startedAt,
                completedAt: completedAt,
                durationMicroseconds: durationMicroseconds,
                endpointJson: endpointJson,
                methodIdentityJson: methodIdentityJson,
                requestJson: requestJson,
                requestMetadataJson: requestMetadataJson,
                responseJson: responseJson,
                responseHeadersJson: responseHeadersJson,
                responseTrailersJson: responseTrailersJson,
                statusCode: statusCode,
                statusName: statusName,
                statusMessage: statusMessage,
                requestByteCount: requestByteCount,
                responseByteCount: responseByteCount,
                outcome: outcome,
                diagnosticCategory: diagnosticCategory,
                droppedEventCount: droppedEventCount,
                terminalState: terminalState,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> savedRequestId = const Value.absent(),
                Value<String?> descriptorSnapshotId = const Value.absent(),
                required String invocationKind,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> durationMicroseconds = const Value.absent(),
                required String endpointJson,
                required String methodIdentityJson,
                required String requestJson,
                required String requestMetadataJson,
                Value<String?> responseJson = const Value.absent(),
                required String responseHeadersJson,
                required String responseTrailersJson,
                Value<int?> statusCode = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<String?> statusMessage = const Value.absent(),
                Value<int> requestByteCount = const Value.absent(),
                Value<int> responseByteCount = const Value.absent(),
                required String outcome,
                Value<String?> diagnosticCategory = const Value.absent(),
                Value<int> droppedEventCount = const Value.absent(),
                required String terminalState,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GrpcInvocationHistoryCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                savedRequestId: savedRequestId,
                descriptorSnapshotId: descriptorSnapshotId,
                invocationKind: invocationKind,
                startedAt: startedAt,
                completedAt: completedAt,
                durationMicroseconds: durationMicroseconds,
                endpointJson: endpointJson,
                methodIdentityJson: methodIdentityJson,
                requestJson: requestJson,
                requestMetadataJson: requestMetadataJson,
                responseJson: responseJson,
                responseHeadersJson: responseHeadersJson,
                responseTrailersJson: responseTrailersJson,
                statusCode: statusCode,
                statusName: statusName,
                statusMessage: statusMessage,
                requestByteCount: requestByteCount,
                responseByteCount: responseByteCount,
                outcome: outcome,
                diagnosticCategory: diagnosticCategory,
                droppedEventCount: droppedEventCount,
                terminalState: terminalState,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrpcInvocationHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                savedRequestId = false,
                descriptorSnapshotId = false,
                grpcStoredStreamEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (grpcStoredStreamEventsRefs) db.grpcStoredStreamEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$GrpcInvocationHistoryTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$GrpcInvocationHistoryTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (savedRequestId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.savedRequestId,
                                    referencedTable:
                                        $$GrpcInvocationHistoryTableReferences
                                            ._savedRequestIdTable(db),
                                    referencedColumn:
                                        $$GrpcInvocationHistoryTableReferences
                                            ._savedRequestIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (descriptorSnapshotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.descriptorSnapshotId,
                                    referencedTable:
                                        $$GrpcInvocationHistoryTableReferences
                                            ._descriptorSnapshotIdTable(db),
                                    referencedColumn:
                                        $$GrpcInvocationHistoryTableReferences
                                            ._descriptorSnapshotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (grpcStoredStreamEventsRefs)
                        await $_getPrefetchedData<
                          GrpcInvocationHistoryData,
                          $GrpcInvocationHistoryTable,
                          GrpcStoredStreamEvent
                        >(
                          currentTable: table,
                          referencedTable:
                              $$GrpcInvocationHistoryTableReferences
                                  ._grpcStoredStreamEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrpcInvocationHistoryTableReferences(
                                db,
                                table,
                                p0,
                              ).grpcStoredStreamEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionHistoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GrpcInvocationHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrpcInvocationHistoryTable,
      GrpcInvocationHistoryData,
      $$GrpcInvocationHistoryTableFilterComposer,
      $$GrpcInvocationHistoryTableOrderingComposer,
      $$GrpcInvocationHistoryTableAnnotationComposer,
      $$GrpcInvocationHistoryTableCreateCompanionBuilder,
      $$GrpcInvocationHistoryTableUpdateCompanionBuilder,
      (GrpcInvocationHistoryData, $$GrpcInvocationHistoryTableReferences),
      GrpcInvocationHistoryData,
      PrefetchHooks Function({
        bool workspaceId,
        bool savedRequestId,
        bool descriptorSnapshotId,
        bool grpcStoredStreamEventsRefs,
      })
    >;
typedef $$GrpcStoredStreamEventsTableCreateCompanionBuilder =
    GrpcStoredStreamEventsCompanion Function({
      required String id,
      required String sessionHistoryId,
      required int sequenceNumber,
      required String direction,
      required String category,
      required DateTime occurredAt,
      Value<String?> decodedPayloadJson,
      Value<int> rawByteCount,
      Value<Uint8List?> retainedRawBytes,
      Value<int?> statusCode,
      Value<String?> statusText,
      Value<String?> decodeFailureCategory,
      Value<int> rowid,
    });
typedef $$GrpcStoredStreamEventsTableUpdateCompanionBuilder =
    GrpcStoredStreamEventsCompanion Function({
      Value<String> id,
      Value<String> sessionHistoryId,
      Value<int> sequenceNumber,
      Value<String> direction,
      Value<String> category,
      Value<DateTime> occurredAt,
      Value<String?> decodedPayloadJson,
      Value<int> rawByteCount,
      Value<Uint8List?> retainedRawBytes,
      Value<int?> statusCode,
      Value<String?> statusText,
      Value<String?> decodeFailureCategory,
      Value<int> rowid,
    });

final class $$GrpcStoredStreamEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GrpcStoredStreamEventsTable,
          GrpcStoredStreamEvent
        > {
  $$GrpcStoredStreamEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GrpcInvocationHistoryTable _sessionHistoryIdTable(
    _$AppDatabase db,
  ) => db.grpcInvocationHistory.createAlias(
    'grpc_stored_stream_events__session_history_id__grpc_invocation_history__id',
  );

  $$GrpcInvocationHistoryTableProcessedTableManager get sessionHistoryId {
    final $_column = $_itemColumn<String>('session_history_id')!;

    final manager = $$GrpcInvocationHistoryTableTableManager(
      $_db,
      $_db.grpcInvocationHistory,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionHistoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GrpcStoredStreamEventsTableFilterComposer
    extends Composer<_$AppDatabase, $GrpcStoredStreamEventsTable> {
  $$GrpcStoredStreamEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decodedPayloadJson => $composableBuilder(
    column: $table.decodedPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rawByteCount => $composableBuilder(
    column: $table.rawByteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get retainedRawBytes => $composableBuilder(
    column: $table.retainedRawBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusText => $composableBuilder(
    column: $table.statusText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decodeFailureCategory => $composableBuilder(
    column: $table.decodeFailureCategory,
    builder: (column) => ColumnFilters(column),
  );

  $$GrpcInvocationHistoryTableFilterComposer get sessionHistoryId {
    final $$GrpcInvocationHistoryTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionHistoryId,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableFilterComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcStoredStreamEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrpcStoredStreamEventsTable> {
  $$GrpcStoredStreamEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decodedPayloadJson => $composableBuilder(
    column: $table.decodedPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rawByteCount => $composableBuilder(
    column: $table.rawByteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get retainedRawBytes => $composableBuilder(
    column: $table.retainedRawBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusText => $composableBuilder(
    column: $table.statusText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decodeFailureCategory => $composableBuilder(
    column: $table.decodeFailureCategory,
    builder: (column) => ColumnOrderings(column),
  );

  $$GrpcInvocationHistoryTableOrderingComposer get sessionHistoryId {
    final $$GrpcInvocationHistoryTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionHistoryId,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableOrderingComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcStoredStreamEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrpcStoredStreamEventsTable> {
  $$GrpcStoredStreamEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decodedPayloadJson => $composableBuilder(
    column: $table.decodedPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rawByteCount => $composableBuilder(
    column: $table.rawByteCount,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get retainedRawBytes => $composableBuilder(
    column: $table.retainedRawBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusText => $composableBuilder(
    column: $table.statusText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decodeFailureCategory => $composableBuilder(
    column: $table.decodeFailureCategory,
    builder: (column) => column,
  );

  $$GrpcInvocationHistoryTableAnnotationComposer get sessionHistoryId {
    final $$GrpcInvocationHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionHistoryId,
          referencedTable: $db.grpcInvocationHistory,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrpcInvocationHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.grpcInvocationHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GrpcStoredStreamEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrpcStoredStreamEventsTable,
          GrpcStoredStreamEvent,
          $$GrpcStoredStreamEventsTableFilterComposer,
          $$GrpcStoredStreamEventsTableOrderingComposer,
          $$GrpcStoredStreamEventsTableAnnotationComposer,
          $$GrpcStoredStreamEventsTableCreateCompanionBuilder,
          $$GrpcStoredStreamEventsTableUpdateCompanionBuilder,
          (GrpcStoredStreamEvent, $$GrpcStoredStreamEventsTableReferences),
          GrpcStoredStreamEvent,
          PrefetchHooks Function({bool sessionHistoryId})
        > {
  $$GrpcStoredStreamEventsTableTableManager(
    _$AppDatabase db,
    $GrpcStoredStreamEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrpcStoredStreamEventsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$GrpcStoredStreamEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GrpcStoredStreamEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionHistoryId = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> decodedPayloadJson = const Value.absent(),
                Value<int> rawByteCount = const Value.absent(),
                Value<Uint8List?> retainedRawBytes = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<String?> statusText = const Value.absent(),
                Value<String?> decodeFailureCategory = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrpcStoredStreamEventsCompanion(
                id: id,
                sessionHistoryId: sessionHistoryId,
                sequenceNumber: sequenceNumber,
                direction: direction,
                category: category,
                occurredAt: occurredAt,
                decodedPayloadJson: decodedPayloadJson,
                rawByteCount: rawByteCount,
                retainedRawBytes: retainedRawBytes,
                statusCode: statusCode,
                statusText: statusText,
                decodeFailureCategory: decodeFailureCategory,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionHistoryId,
                required int sequenceNumber,
                required String direction,
                required String category,
                required DateTime occurredAt,
                Value<String?> decodedPayloadJson = const Value.absent(),
                Value<int> rawByteCount = const Value.absent(),
                Value<Uint8List?> retainedRawBytes = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<String?> statusText = const Value.absent(),
                Value<String?> decodeFailureCategory = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrpcStoredStreamEventsCompanion.insert(
                id: id,
                sessionHistoryId: sessionHistoryId,
                sequenceNumber: sequenceNumber,
                direction: direction,
                category: category,
                occurredAt: occurredAt,
                decodedPayloadJson: decodedPayloadJson,
                rawByteCount: rawByteCount,
                retainedRawBytes: retainedRawBytes,
                statusCode: statusCode,
                statusText: statusText,
                decodeFailureCategory: decodeFailureCategory,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrpcStoredStreamEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionHistoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionHistoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionHistoryId,
                                referencedTable:
                                    $$GrpcStoredStreamEventsTableReferences
                                        ._sessionHistoryIdTable(db),
                                referencedColumn:
                                    $$GrpcStoredStreamEventsTableReferences
                                        ._sessionHistoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GrpcStoredStreamEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrpcStoredStreamEventsTable,
      GrpcStoredStreamEvent,
      $$GrpcStoredStreamEventsTableFilterComposer,
      $$GrpcStoredStreamEventsTableOrderingComposer,
      $$GrpcStoredStreamEventsTableAnnotationComposer,
      $$GrpcStoredStreamEventsTableCreateCompanionBuilder,
      $$GrpcStoredStreamEventsTableUpdateCompanionBuilder,
      (GrpcStoredStreamEvent, $$GrpcStoredStreamEventsTableReferences),
      GrpcStoredStreamEvent,
      PrefetchHooks Function({bool sessionHistoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$RequestsTableTableManager get requests =>
      $$RequestsTableTableManager(_db, _db.requests);
  $$RequestHeadersTableTableManager get requestHeaders =>
      $$RequestHeadersTableTableManager(_db, _db.requestHeaders);
  $$RequestQueryParamsTableTableManager get requestQueryParams =>
      $$RequestQueryParamsTableTableManager(_db, _db.requestQueryParams);
  $$RequestBodiesTableTableManager get requestBodies =>
      $$RequestBodiesTableTableManager(_db, _db.requestBodies);
  $$EnvironmentsTableTableManager get environments =>
      $$EnvironmentsTableTableManager(_db, _db.environments);
  $$EnvironmentVariablesTableTableManager get environmentVariables =>
      $$EnvironmentVariablesTableTableManager(_db, _db.environmentVariables);
  $$RequestHistoryTableTableManager get requestHistory =>
      $$RequestHistoryTableTableManager(_db, _db.requestHistory);
  $$ResponseSnapshotsTableTableManager get responseSnapshots =>
      $$ResponseSnapshotsTableTableManager(_db, _db.responseSnapshots);
  $$WebSocketSessionsTableTableManager get webSocketSessions =>
      $$WebSocketSessionsTableTableManager(_db, _db.webSocketSessions);
  $$AiAnalysesTableTableManager get aiAnalyses =>
      $$AiAnalysesTableTableManager(_db, _db.aiAnalyses);
  $$RequestDraftsTableTableManager get requestDrafts =>
      $$RequestDraftsTableTableManager(_db, _db.requestDrafts);
  $$RealtimeConfigurationsTableTableManager get realtimeConfigurations =>
      $$RealtimeConfigurationsTableTableManager(
        _db,
        _db.realtimeConfigurations,
      );
  $$RealtimeDraftsTableTableManager get realtimeDrafts =>
      $$RealtimeDraftsTableTableManager(_db, _db.realtimeDrafts);
  $$RealtimeHistoryTableTableManager get realtimeHistory =>
      $$RealtimeHistoryTableTableManager(_db, _db.realtimeHistory);
  $$AiPreferencesTableTableManager get aiPreferences =>
      $$AiPreferencesTableTableManager(_db, _db.aiPreferences);
  $$WorkspaceSettingsTableTableManager get workspaceSettings =>
      $$WorkspaceSettingsTableTableManager(_db, _db.workspaceSettings);
  $$GraphqlDraftsTableTableManager get graphqlDrafts =>
      $$GraphqlDraftsTableTableManager(_db, _db.graphqlDrafts);
  $$GraphqlHistoryTableTableManager get graphqlHistory =>
      $$GraphqlHistoryTableTableManager(_db, _db.graphqlHistory);
  $$GraphqlSavedRequestsTableTableManager get graphqlSavedRequests =>
      $$GraphqlSavedRequestsTableTableManager(_db, _db.graphqlSavedRequests);
  $$GraphqlSchemaSnapshotsTableTableManager get graphqlSchemaSnapshots =>
      $$GraphqlSchemaSnapshotsTableTableManager(
        _db,
        _db.graphqlSchemaSnapshots,
      );
  $$GrpcDescriptorSnapshotsTableTableManager get grpcDescriptorSnapshots =>
      $$GrpcDescriptorSnapshotsTableTableManager(
        _db,
        _db.grpcDescriptorSnapshots,
      );
  $$GrpcSavedRequestsTableTableManager get grpcSavedRequests =>
      $$GrpcSavedRequestsTableTableManager(_db, _db.grpcSavedRequests);
  $$GrpcDraftsTableTableManager get grpcDrafts =>
      $$GrpcDraftsTableTableManager(_db, _db.grpcDrafts);
  $$GrpcInvocationHistoryTableTableManager get grpcInvocationHistory =>
      $$GrpcInvocationHistoryTableTableManager(_db, _db.grpcInvocationHistory);
  $$GrpcStoredStreamEventsTableTableManager get grpcStoredStreamEvents =>
      $$GrpcStoredStreamEventsTableTableManager(
        _db,
        _db.grpcStoredStreamEvents,
      );
}
