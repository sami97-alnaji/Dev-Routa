import 'package:devroute_ai_studio/app.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Windows AI Agents card exposes the restricted Codex controls', (
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
    await tester.tap(find.text('AI Agents').first);
    await tester.pumpAndSettle();
    expect(find.text('Codex'), findsOneWidget);
    expect(find.text('Detect Codex'), findsOneWidget);
    expect(find.text('Open official sign-in'), findsOneWidget);
    expect(find.text('Run connection test'), findsOneWidget);
    expect(find.textContaining('app.capabilities'), findsWidgets);
    expect(find.textContaining('grpc.history.search'), findsWidgets);
    expect(find.text('API key'), findsOneWidget);
    expect(find.text('not used'), findsOneWidget);
  });
}
