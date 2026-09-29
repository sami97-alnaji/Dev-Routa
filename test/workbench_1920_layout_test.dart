import 'package:devroute_ai_studio/app.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/core/theme/app_theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = <({String name, String tooltip, Finder Function() marker})>[
    (name: 'Requests', tooltip: 'Requests', marker: _requestsMarker),
    (name: 'GraphQL', tooltip: 'GraphQL', marker: _graphqlMarker),
    (name: 'gRPC', tooltip: 'gRPC', marker: _grpcMarker),
    (name: 'Realtime', tooltip: 'Realtime', marker: _realtimeMarker),
    (name: 'AI Agents', tooltip: 'AI Agents', marker: _agentsMarker),
  ];

  for (final theme in <ThemeMode>[ThemeMode.dark, ThemeMode.light]) {
    for (final item in cases) {
      testWidgets('1920x1080 ${theme.name} ${item.name} layout is stable', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1;
        DevRouteAppearance.mode.value = theme;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(() => DevRouteAppearance.mode.value = ThemeMode.system);
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);

        await tester.pumpWidget(DevRouteApp(database: database));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'initial layout');
        await tester.tap(find.byTooltip(item.tooltip));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'navigation frame');
        await tester.pumpAndSettle();

        expect(item.marker(), findsWidgets);
        expect(tester.takeException(), isNull, reason: 'settled layout');
      });
    }
  }

  testWidgets('1024px keeps the workspace explorer available', (tester) async {
    tester.view.physicalSize = const Size(1024, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(DevRouteApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Explorer'), findsOneWidget);
    expect(find.byKey(const Key('workbench-explorer-filter')), findsOneWidget);
    expect(find.byTooltip('Requests'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('1440px keeps the explorer and request workbench stable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(DevRouteApp(database: database));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('Untitled request'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('800px remains a compact desktop workspace', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(DevRouteApp(database: database));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Requests'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('command palette filters available workspace actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(DevRouteApp(database: database));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Command palette (Ctrl+K)'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('command-palette-filter')),
      'gRPC',
    );
    await tester.pumpAndSettle();

    expect(find.text('Open gRPC'), findsOneWidget);
    expect(find.text('Open GraphQL'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Finder _requestsMarker() => find.text('Request name');
Finder _graphqlMarker() => find.text('Endpoint');
Finder _grpcMarker() => find.text('gRPC');
Finder _realtimeMarker() => find.byKey(const Key('realtime-url'));
Finder _agentsMarker() => find.text('Codex');
