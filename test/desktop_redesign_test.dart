import 'package:devroute_ai_studio/app.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/features/workspace/presentation/app_shell.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AppDatabase> pumpDesktop(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    int initialSection = 0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      initialSection == 0
          ? DevRouteApp(database: database)
          : MaterialApp(home: AppShell(initialSection: initialSection)),
    );
    await tester.pumpAndSettle();
    return database;
  }

  testWidgets('desktop shell uses expanded sidebar and all destinations', (
    tester,
  ) async {
    await pumpDesktop(tester);

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    for (final label in const [
      'Workspace',
      'Requests',
      'History',
      'Environments',
      'Realtime',
      'GraphQL',
      'gRPC',
      'AI Agents',
      'Settings',
    ]) {
      expect(find.text(label), findsWidgets);
    }

    for (final target in const [
      'Requests',
      'History',
      'Environments',
      'Realtime',
      'GraphQL',
      'gRPC',
      'AI Agents',
      'Settings',
      'Workspace',
    ]) {
      await tester.tap(find.text(target).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'while opening $target');
    }
  });

  testWidgets('desktop shell collapses without mobile bottom navigation', (
    tester,
  ) async {
    await pumpDesktop(tester, size: const Size(1100, 720));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byTooltip('Expand sidebar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('requests use API client tabs, toolbar, and split panels', (
    tester,
  ) async {
    await pumpDesktop(tester);
    await tester.tap(find.text('Requests').first);
    await tester.pumpAndSettle();

    expect(find.text('Untitled request'), findsWidgets);
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Save'), findsWidgets);
    for (final tab in const [
      'Params',
      'Authorization',
      'Headers',
      'Body',
      'Scripts',
      'Settings',
    ]) {
      expect(find.text(tab), findsWidgets);
    }
    expect(find.text('Response'), findsOneWidget);
    expect(find.text('No response yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'AI Agents desktop layout exposes provider and safe runtime data',
    (tester) async {
      await pumpDesktop(tester);
      await tester.tap(find.text('AI Agents').first);
      await tester.pumpAndSettle();

      expect(find.text('Providers'), findsOneWidget);
      expect(find.text('Claude Code'), findsOneWidget);
      expect(find.text('Google client'), findsOneWidget);
      expect(find.text('Allowed tools'), findsOneWidget);
      expect(find.text('Run output'), findsOneWidget);
      expect(find.text('Audit timeline'), findsOneWidget);
      expect(find.text('Runtime diagnostics'), findsOneWidget);
      expect(find.text('app.capabilities'), findsOneWidget);
      expect(find.text('grpc.history.search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('1280x720 key desktop sections have no render overflow', (
    tester,
  ) async {
    await pumpDesktop(tester, size: const Size(1280, 720));
    for (final target in const ['Requests', 'History', 'AI Agents', 'gRPC']) {
      await tester.tap(find.text(target).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflow in $target');
    }
  });
}
