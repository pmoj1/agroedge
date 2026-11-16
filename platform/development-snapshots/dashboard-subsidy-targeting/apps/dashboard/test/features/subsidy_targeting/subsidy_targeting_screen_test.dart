import 'package:agroedge_dashboard/features/subsidy_targeting/subsidy_targeting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    // The screen has a 1024px minimum width; the default 800x600 test
    // surface is narrower than that and causes spurious overflow errors.
    tester.view.physicalSize = const Size(1440, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SubsidyTargetingScreen()),
      ),
    );
  }

  testWidgets('shows the sample data chip and summary totals for the default season',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('SAMPLE DATA'), findsOneWidget);
    // 2026/27 sample totals: qualified 820, received 579, gap 241.
    expect(find.text('820'), findsOneWidget);
    expect(find.text('579'), findsOneWidget);
    expect(find.text('241'), findsOneWidget);
  });

  testWidgets('filtering to a district with no gap shows the empty state',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('All districts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tonota').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fully received').last);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No qualified-but-not-received farmers match the current filters.',
      ),
      findsOneWidget,
    );
  });
}
