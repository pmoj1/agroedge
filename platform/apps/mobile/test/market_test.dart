import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agroedge_mobile/core/services/market_service.dart';
import 'package:agroedge_mobile/features/market/market_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MarketService Tests', () {
    test(
      'Static fallback pricing returns correct default crops for ZW',
      () async {
        final service = MarketService.instance;
        final prices = await service.fetchCurrentPrices(
          crops: ['maize', 'tomatoes', 'nonexistent_crop'],
          countryCode: 'ZW',
        );

        expect(prices.length, 3);

        final maize = prices.firstWhere((p) => p.cropName == 'Maize');
        expect(maize.price, 600.0);
        expect(maize.currency, 'USD');
        expect(maize.unit, 'mt');
        expect(maize.source, contains('GMB Zimbabwe'));

        final tomatoes = prices.firstWhere((p) => p.cropName == 'Tomatoes');
        expect(tomatoes.price, 0.45);
        expect(tomatoes.currency, 'USD');
        expect(tomatoes.unit, 'kg');

        // Generic fallback crop
        final unavailable = prices.firstWhere(
          (p) => p.cropName == 'Nonexistent_crop',
        );
        expect(unavailable.price, 0.0);
        expect(unavailable.source, 'Price unavailable');
      },
    );

    test(
      'Static fallback pricing returns correct default crops for ZM',
      () async {
        final service = MarketService.instance;
        final prices = await service.fetchCurrentPrices(
          crops: ['maize'],
          countryCode: 'ZM',
        );

        expect(prices.length, 1);
        final maize = prices.first;
        expect(maize.price, 2800.0);
        expect(maize.currency, 'ZMW');
        expect(maize.unit, 'mt');
      },
    );
  });

  group('MarketScreen Widget Tests', () {
    testWidgets('MarketScreen shows empty state if no profile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MarketScreen(profilesFuture: Future.value(<FarmProfile>[])),
        ),
      );

      await tester.pump();
      await tester.idle();
      await tester.pump();

      expect(find.text('Set up your farm first'), findsOneWidget);
    });

    testWidgets('MarketScreen shows empty state if profile has no crops', (
      tester,
    ) async {
      final profile = FarmProfile(
        farmName: 'Test Farm',
        country: 'ZW',
        primaryCrop: '',
        secondaryCrop: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MarketScreen(profilesFuture: Future.value([profile])),
        ),
      );

      await tester.pump();
      await tester.idle();
      await tester.pump();

      expect(find.text('No crops registered'), findsOneWidget);
    });

    testWidgets('MarketScreen shows prices list if crops registered', (
      tester,
    ) async {
      final profile = FarmProfile(
        farmName: 'My Zimbabwe Farm',
        country: 'ZW',
        primaryCrop: 'Maize',
        secondaryCrop: 'Tomatoes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MarketScreen(profilesFuture: Future.value([profile])),
        ),
      );

      await tester.pump(); // Start fetching
      await tester.idle(); // Resolve Future
      await tester.pump(); // Rebuild with resolved Future
      await tester.pump(
        const Duration(milliseconds: 200),
      ); // Let entry delay timers fire

      expect(find.text('Maize'), findsOneWidget);
      expect(find.text('Tomatoes'), findsOneWidget);
      expect(find.text('USD 600.00'), findsOneWidget); // Maize price formatted
      expect(find.text('USD 0.45'), findsOneWidget); // Tomato price formatted
    });
  });
}
