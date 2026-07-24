import 'package:devroute_ai_studio/app.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desktop exposes persisted workspace and full REST editor tabs', (
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
    expect(find.text('Workspace'), findsWidgets);
    await tester.tap(find.text('Requests').first);
    await tester.pumpAndSettle();
    expect(find.text('Request name'), findsOneWidget);
    expect(find.text('Params'), findsOneWidget);
    expect(find.text('Auth'), findsOneWidget);
    expect(find.text('Resolved Preview'), findsOneWidget);
  });

  testWidgets(
    'Android-sized layout protects a dirty request from back navigation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await tester.pumpWidget(DevRouteApp(database: database));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Changed request');
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Discard and exit'), findsOneWidget);
    },
  );

  testWidgets('desktop environment flow creates and edits a local variable', (
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
    await tester.tap(find.text('Environments').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'New'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Local QA');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Local QA'), findsOneWidget);
    await tester.tap(find.text('Local QA'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'HOST');
    await tester.enterText(fields.at(1), 'localhost');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('HOST'), findsOneWidget);
    expect(find.text('localhost'), findsOneWidget);
  });

  testWidgets(
    'desktop realtime exposes independent sessions and history tools',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await tester.pumpWidget(DevRouteApp(database: database));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Realtime').first);
      await tester.pumpAndSettle();
      expect(find.text('Session'), findsOneWidget);
      expect(find.byKey(const Key('realtime-url')), findsOneWidget);
      await tester.tap(find.byTooltip('New independent session (Ctrl+N)'));
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsNWidgets(2));
      await tester.tap(find.text('History').last);
      await tester.pumpAndSettle();
      expect(find.text('Compare selected'), findsOneWidget);
    },
  );

  testWidgets(
    'Android realtime layout has compact config and safe back guard',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await tester.pumpWidget(DevRouteApp(database: database));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Realtime').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('realtime-url')), findsOneWidget);
      expect(
        find.text('Params, Auth, Headers, Body, Settings, Resolved Preview'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('realtime-url')),
        'ws://localhost:8080',
      );
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Leave realtime session?'), findsOneWidget);
    },
  );
}
