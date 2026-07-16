import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift_game/app.dart';

void main() {
  testWidgets('DriftApp startup smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DriftApp(),
      ),
    );

    // Verify that the title "DRIFT" is shown on the menu screen.
    expect(find.text('DRIFT'), findsOneWidget);
    expect(find.text('TAP TO START'), findsOneWidget);
  });
}
