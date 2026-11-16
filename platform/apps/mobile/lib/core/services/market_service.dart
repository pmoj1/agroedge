import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/market_price.dart';

/// Market price service that fetches crop prices from country-specific
/// sources. Falls back to curated static data when the network is unavailable.
///
/// Supported countries (ISO-2):
///   ZW – Zimbabwe  (GMB Zimbabwe scrape / World Food Programme ADAM)
///   ZM – Zambia    (ZNFU market dashboard)
///   ZA – South Africa (SAFEX via World Food Programme)
///   KE – Kenya     (NARIGP / WFP VAM)
///
/// All prices use the WFP VAM Food Security open dataset as the primary
/// machine-readable source (https://dataviz.vam.wfp.org/api).
class MarketService {
  MarketService._();
  static final MarketService instance = MarketService._();

  static const _cacheTtl = Duration(minutes: 30);
  static const _prefKey = 'market_cache_v1';

  // ─── WFP VAM endpoint ────────────────────────────────────────────────────
  //  GET https://api.vam.wfp.org/markets/prices
  //    ?CountryCode=<ISO2>&commodities=<name>&page=1&pageSize=20
  //  Returns JSON array of price observations.
  static const _wfpBase = 'https://api.vam.wfp.org';

  // Country-specific metadata
  static const _countryMeta = <String, _CountryMeta>{
    'ZW': _CountryMeta(name: 'Zimbabwe', currency: 'USD', flag: '🇿🇼'),
    'ZM': _CountryMeta(name: 'Zambia', currency: 'ZMW', flag: '🇿🇲'),
    'ZA': _CountryMeta(name: 'South Africa', currency: 'ZAR', flag: '🇿🇦'),
    'KE': _CountryMeta(name: 'Kenya', currency: 'KES', flag: '🇰🇪'),
    'TZ': _CountryMeta(name: 'Tanzania', currency: 'TZS', flag: '🇹🇿'),
    'MZ': _CountryMeta(name: 'Mozambique', currency: 'MZN', flag: '🇲🇿'),
    'MW': _CountryMeta(name: 'Malawi', currency: 'MWK', flag: '🇲🇼'),
    'BW': _CountryMeta(name: 'Botswana', currency: 'BWP', flag: '🇧🇼'),
  };

  /// Fetch current prices for [crops] in [countryCode] (ISO-2, e.g. "ZW").
  /// Results are cached for 30 minutes.
  Future<List<MarketPrice>> fetchCurrentPrices({
    required List<String> crops,
    required String countryCode,
  }) async {
    var code = countryCode.toUpperCase();
    for (final entry in _countryMeta.entries) {
      if (entry.value.name.toUpperCase() == code) {
        code = entry.key;
        break;
      }
    }
    if (crops.isEmpty) return [];

    // ── try cache first ───────────────────────────────────────────────────
    final cached = await _readCache(code, crops);
    if (cached != null) return cached;

    // ── attempt live fetch ────────────────────────────────────────────────
    try {
      final prices = await _fetchLive(code, crops);
      await _writeCache(code, crops, prices);
      return prices;
    } catch (_) {
      // ── fall back to curated static data ─────────────────────────────
      final fallback = _staticFallback(code, crops);
      // Still cache the fallback so we don't hammer the network
      await _writeCache(code, crops, fallback, ttl: const Duration(minutes: 5));
      return fallback;
    }
  }

  // ─── Live fetch via WFP VAM ───────────────────────────────────────────────
  Future<List<MarketPrice>> _fetchLive(
    String countryCode,
    List<String> crops,
  ) async {
    final meta = _countryMeta[countryCode] ?? const _CountryMeta.unknown();
    final results = <MarketPrice>[];

    for (final crop in crops) {
      final uri = Uri.parse('$_wfpBase/markets/prices').replace(
        queryParameters: {
          'CountryCode': countryCode,
          'commodities': crop,
          'page': '1',
          'pageSize': '5',
        },
      );

      final resp = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        // WFP returns either a list or an object with a "items" array
        final List<dynamic> items = body is List
            ? body
            : (body['items'] as List? ?? body['data'] as List? ?? []);

        if (items.isNotEmpty) {
          final latest = items.first as Map<String, dynamic>;
          final price =
              (latest['mp_price'] as num?)?.toDouble() ??
              (latest['price'] as num?)?.toDouble();
          final unit =
              (latest['um_name'] as String?) ??
              (latest['unit'] as String?) ??
              'kg';
          if (price != null) {
            results.add(
              MarketPrice(
                cropName: _normaliseCropName(crop),
                price: price,
                currency: meta.currency,
                unit: unit.toLowerCase().replaceAll('per ', '').trim(),
                source: 'WFP VAM – ${meta.name}',
                countryCode: countryCode,
                fetchedAt: DateTime.now(),
              ),
            );
            continue;
          }
        }
      }

      // If WFP had no data for this crop, use static fallback for it only
      final fb = _staticFallbackForCrop(countryCode, crop, meta);
      if (fb != null) results.add(fb);
    }

    return results;
  }

  // ─── Static fallback prices (sourced from published GMB / public reports) ─
  // Prices are indicative only; shown with clear source attribution.
  static const _staticPrices = <String, Map<String, _StaticPrice>>{
    'ZW': {
      'maize': _StaticPrice(600, 'USD', 'mt', 'GMB Zimbabwe (indicative)'),
      'tomatoes': _StaticPrice(0.45, 'USD', 'kg', 'GMB Zimbabwe (indicative)'),
      'soya beans': _StaticPrice(650, 'USD', 'mt', 'GMB Zimbabwe (indicative)'),
      'wheat': _StaticPrice(400, 'USD', 'mt', 'GMB Zimbabwe (indicative)'),
      'groundnuts': _StaticPrice(900, 'USD', 'mt', 'GMB Zimbabwe (indicative)'),
      'cotton': _StaticPrice(0.55, 'USD', 'kg', 'GMB Zimbabwe (indicative)'),
      'sunflower': _StaticPrice(580, 'USD', 'mt', 'GMB Zimbabwe (indicative)'),
      'sorghum': _StaticPrice(320, 'USD', 'mt', 'GMB Zimbabwe (indicative)'),
    },
    'ZM': {
      'maize': _StaticPrice(2800, 'ZMW', 'mt', 'ZNFU Zambia (indicative)'),
      'tomatoes': _StaticPrice(6.5, 'ZMW', 'kg', 'ZNFU Zambia (indicative)'),
      'soya beans': _StaticPrice(7200, 'ZMW', 'mt', 'ZNFU Zambia (indicative)'),
      'wheat': _StaticPrice(4500, 'ZMW', 'mt', 'ZNFU Zambia (indicative)'),
      'groundnuts': _StaticPrice(8000, 'ZMW', 'mt', 'ZNFU Zambia (indicative)'),
    },
    'ZA': {
      'maize': _StaticPrice(
        3800,
        'ZAR',
        'mt',
        'SAFEX South Africa (indicative)',
      ),
      'tomatoes': _StaticPrice(
        12,
        'ZAR',
        'kg',
        'SAFEX South Africa (indicative)',
      ),
      'wheat': _StaticPrice(
        4200,
        'ZAR',
        'mt',
        'SAFEX South Africa (indicative)',
      ),
      'soya beans': _StaticPrice(
        9000,
        'ZAR',
        'mt',
        'SAFEX South Africa (indicative)',
      ),
      'sunflower': _StaticPrice(
        7500,
        'ZAR',
        'mt',
        'SAFEX South Africa (indicative)',
      ),
    },
    'KE': {
      'maize': _StaticPrice(38, 'KES', 'kg', 'NCPB Kenya (indicative)'),
      'tomatoes': _StaticPrice(60, 'KES', 'kg', 'NCPB Kenya (indicative)'),
      'wheat': _StaticPrice(52, 'KES', 'kg', 'NCPB Kenya (indicative)'),
      'beans': _StaticPrice(120, 'KES', 'kg', 'NCPB Kenya (indicative)'),
    },
  };

  List<MarketPrice> _staticFallback(String countryCode, List<String> crops) {
    final meta = _countryMeta[countryCode] ?? const _CountryMeta.unknown();
    final results = <MarketPrice>[];
    for (final crop in crops) {
      final mp = _staticFallbackForCrop(countryCode, crop, meta);
      if (mp != null) results.add(mp);
    }
    return results;
  }

  MarketPrice? _staticFallbackForCrop(
    String countryCode,
    String crop,
    _CountryMeta meta,
  ) {
    final byCountry = _staticPrices[countryCode] ?? {};
    final key = crop.toLowerCase().trim();

    // exact match
    if (byCountry.containsKey(key)) {
      final s = byCountry[key]!;
      return MarketPrice(
        cropName: _normaliseCropName(crop),
        price: s.price,
        currency: s.currency,
        unit: s.unit,
        source: s.source,
        countryCode: countryCode,
        fetchedAt: DateTime.now(),
      );
    }

    // partial match (e.g. "white maize" → "maize")
    for (final entry in byCountry.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        final s = entry.value;
        return MarketPrice(
          cropName: _normaliseCropName(crop),
          price: s.price,
          currency: s.currency,
          unit: s.unit,
          source: s.source,
          countryCode: countryCode,
          fetchedAt: DateTime.now(),
        );
      }
    }

    // generic fallback — show a "price not available" placeholder
    return MarketPrice(
      cropName: _normaliseCropName(crop),
      price: 0,
      currency: meta.currency,
      unit: 'kg',
      source: 'Price unavailable',
      countryCode: countryCode,
      fetchedAt: DateTime.now(),
    );
  }

  // ─── Cache helpers ────────────────────────────────────────────────────────
  String _cacheKey(String country, List<String> crops) =>
      '${_prefKey}_${country}_${crops.join(",")}';

  Future<List<MarketPrice>?> _readCache(
    String country,
    List<String> crops,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(country, crops));
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.parse(map['ts'] as String);
      if (DateTime.now().difference(ts) > _cacheTtl) return null;
      final items = (map['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(_priceFromMap)
          .toList();
      return items;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(
    String country,
    List<String> crops,
    List<MarketPrice> prices, {
    Duration? ttl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'ts': DateTime.now().toIso8601String(),
        'items': prices.map(_priceToMap).toList(),
      };
      await prefs.setString(_cacheKey(country, crops), jsonEncode(map));
    } catch (_) {}
  }

  Map<String, dynamic> _priceToMap(MarketPrice p) => {
    'crop': p.cropName,
    'price': p.price,
    'currency': p.currency,
    'unit': p.unit,
    'source': p.source,
    'country': p.countryCode,
    'ts': p.fetchedAt.toIso8601String(),
  };

  MarketPrice _priceFromMap(Map<String, dynamic> m) => MarketPrice(
    cropName: m['crop'] as String,
    price: (m['price'] as num).toDouble(),
    currency: m['currency'] as String,
    unit: m['unit'] as String,
    source: m['source'] as String,
    countryCode: m['country'] as String,
    fetchedAt: DateTime.parse(m['ts'] as String),
  );

  String _normaliseCropName(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  /// Returns the flag emoji for a country code or name
  static String flagFor(String? countryCode) {
    if (countryCode == null) return '🌍';
    var code = countryCode.toUpperCase();
    for (final entry in _countryMeta.entries) {
      if (entry.value.name.toUpperCase() == code) {
        code = entry.key;
        break;
      }
    }
    return _countryMeta[code]?.flag ?? '🌍';
  }

  /// Returns the country name for a country code or name
  static String countryNameFor(String? countryCode) {
    if (countryCode == null) return 'Unknown';
    final codeUpper = countryCode.toUpperCase();
    if (_countryMeta.containsKey(codeUpper)) {
      return _countryMeta[codeUpper]!.name;
    }
    for (final entry in _countryMeta.entries) {
      if (entry.value.name.toUpperCase() == codeUpper) {
        return entry.value.name;
      }
    }
    return countryCode; // fallback to the input if it is already a full country name
  }
}

class _CountryMeta {
  const _CountryMeta({
    required this.name,
    required this.currency,
    required this.flag,
  });
  const _CountryMeta.unknown()
    : name = 'Unknown',
      currency = 'USD',
      flag = '🌍';
  final String name;
  final String currency;
  final String flag;
}

class _StaticPrice {
  const _StaticPrice(this.price, this.currency, this.unit, this.source);
  final double price;
  final String currency;
  final String unit;
  final String source;
}
