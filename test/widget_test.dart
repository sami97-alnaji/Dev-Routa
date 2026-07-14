import 'package:devroute_ai_studio/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows DevRoute workspace shell', (tester) async {
    await tester.pumpWidget(const DevRouteApp());
    await tester.pumpAndSettle();
    expect(find.text('DevRoute AI Studio'), findsOneWidget);
  });
}
