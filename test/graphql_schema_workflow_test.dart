import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlSchemaSnapshot;
import 'package:devroute_ai_studio/features/graphql/application/graphql_schema_cubit.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_introspection_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_document_parser.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_schema_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_schema_panel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

GraphqlSchemaSnapshot _snapshot({
  required String hash,
  required String userFieldType,
}) => GraphqlSchemaSnapshot(
  hash: hash,
  fetchedAt: DateTime.utc(2026, 7, 21),
  queryRoot: 'Query',
  types: <GraphqlSchemaType>[
    GraphqlSchemaType(
      name: 'Query',
      kind: 'OBJECT',
      description: 'Root query',
      interfaces: const <String>['Node'],
      fields: <GraphqlSchemaField>[
        GraphqlSchemaField(
          name: 'user',
          type: userFieldType,
          args: const <GraphqlSchemaArgument>[
            GraphqlSchemaArgument(
              name: 'id',
              type: 'ID!',
              description: 'User identifier',
            ),
            GraphqlSchemaArgument(
              name: 'locale',
              type: 'String',
              description: 'Optional locale',
            ),
          ],
        ),
      ],
    ),
    const GraphqlSchemaType(
      name: 'Role',
      kind: 'ENUM',
      enumValues: <String>['ADMIN', 'USER'],
    ),
    const GraphqlSchemaType(
      name: 'User',
      kind: 'OBJECT',
      fields: <GraphqlSchemaField>[
        GraphqlSchemaField(name: 'id', type: 'ID!'),
        GraphqlSchemaField(name: 'name', type: 'String'),
      ],
    ),
  ],
);

void main() {
  late AppDatabase database;
  late GraphqlRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = GraphqlRepository(database);
  });

  tearDown(() => database.close());

  test(
    'stored schema snapshot restores fields, args, enums, and interfaces',
    () async {
      final source = _snapshot(hash: 'hash-a', userFieldType: 'User');
      await repository.saveSchemaSnapshot(
        workspaceId: 'workspace',
        endpoint: 'https://example.test/graphql',
        snapshot: source,
      );

      final restored = (await repository.schemaSnapshots('workspace')).single;
      final query = restored.snapshot.types.firstWhere(
        (type) => type.name == 'Query',
      );
      final role = restored.snapshot.types.firstWhere(
        (type) => type.name == 'Role',
      );

      expect(query.interfaces, <String>['Node']);
      expect(query.fields.single.name, 'user');
      expect(query.fields.single.args, hasLength(2));
      expect(query.fields.single.args.first.type, 'ID!');
      expect(query.fields.single.args.last.type, 'String');
      expect(role.enumValues, <String>['ADMIN', 'USER']);
    },
  );

  test('introspection document remains valid GraphQL', () {
    final analysis = GraphqlDocumentParser.analyze(
      GraphqlIntrospectionService.query,
    );
    expect(analysis.isValid, isTrue, reason: analysis.errors.join('\n'));
  });

  test(
    'schema cubit fetches, deduplicates, selects, and deletes snapshots',
    () async {
      var calls = 0;
      final cubit = GraphqlSchemaCubit(
        repository,
        workspaceId: 'workspace',
        fetcher: (request) async {
          calls++;
          return _snapshot(hash: 'hash-a', userFieldType: 'User');
        },
      );

      await cubit.load();
      expect(cubit.state.snapshots, isEmpty);

      const request = GraphqlRequest(
        endpoint: 'https://example.test/graphql',
        document: 'query Current { __typename }',
      );
      await cubit.fetch(request);
      await cubit.fetch(request);

      expect(calls, 2);
      expect(cubit.state.snapshots, hasLength(1));
      expect(cubit.state.active, isNotNull);

      await cubit.delete(cubit.state.active!.id);
      expect(cubit.state.snapshots, isEmpty);

      await cubit.close();
    },
  );

  testWidgets(
    'explores cached schemas, compares snapshots, and generates operation',
    (tester) async {
      final before = await repository.saveSchemaSnapshot(
        workspaceId: 'workspace',
        endpoint: 'https://example.test/graphql',
        snapshot: _snapshot(hash: 'hash-before', userFieldType: 'User'),
      );
      final after = await repository.saveSchemaSnapshot(
        workspaceId: 'workspace',
        endpoint: 'https://example.test/graphql',
        snapshot: _snapshot(hash: 'hash-after', userFieldType: 'String'),
      );

      final cubit = GraphqlSchemaCubit(
        repository,
        workspaceId: 'workspace',
        fetcher: (_) async =>
            _snapshot(hash: 'hash-network', userFieldType: 'User'),
      );
      await cubit.load(preferredId: after.id);

      String? generated;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: GraphqlSchemaPanel(
                request: const GraphqlRequest(
                  endpoint: 'https://example.test/graphql',
                  document: '',
                ),
                onUseOperation: (value) => generated = value,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('graphql-schema-summary-scroll')),
        findsOneWidget,
      );
      expect(find.text('Cached / offline ready'), findsOneWidget);
      expect(
        find.byKey(const Key('graphql-schema-field-Query-user')),
        findsOneWidget,
      );

      final generateButton = find.byKey(
        const Key('graphql-schema-generate-user'),
      );
      await tester.ensureVisible(generateButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(generateButton);
      await tester.pump();

      expect(generated, 'query GeneratedUser(\$id: ID!) { user(id: \$id) }');

      final beforeComparison = find.byKey(
        ValueKey<String>('graphql-schema-compare-${before.id}'),
      );
      final afterComparison = find.byKey(
        ValueKey<String>('graphql-schema-compare-${after.id}'),
      );

      await tester.ensureVisible(beforeComparison);
      await tester.tap(beforeComparison);
      await tester.pump();

      await tester.ensureVisible(afterComparison);
      await tester.tap(afterComparison);
      await tester.pump();

      final diffSummary = find.byKey(const Key('graphql-schema-diff-summary'));
      await tester.ensureVisible(diffSummary);
      await tester.pumpAndSettle();

      expect(diffSummary, findsOneWidget);
      expect(find.text('Breaking candidate'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await cubit.close();
    },
  );
}
