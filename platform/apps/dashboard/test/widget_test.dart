import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agroedge_dashboard/main.dart';

void main() {
  testWidgets('Dashboard smoke test — app mounts without error',
      (WidgetTester tester) async {
    // Set desktop screen size to prevent layout overflows
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1920, 1080);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AgroEdgeDashboardApp());

    // Pump by 1 second to let delayed initialization futures resolve
    await tester.pump(const Duration(seconds: 1));

    // The masthead title and breadcrumb are present in the static N=3 layout.
    expect(find.text('Temo Letlotlo'), findsNWidgets(2));
  });
}
