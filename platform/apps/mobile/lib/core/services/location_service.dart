import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationDetails {
  LocationDetails({
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.district,
    required this.region,
    required this.countryCode,
    required this.timezone,
  });

  final double lat;
  final double lng;
  final String placeName;
  final String district;
  final String region;
  final String countryCode;
  final String timezone;

  String serialize() {
    return '$placeName|$timezone|$district|$region';
  }

  static ({String placeName, String timezone, String district, String region})
  deserialize(String data) {
    final parts = data.split('|');
    return (
      placeName: parts[0],
      timezone: parts.length > 1 ? parts[1] : 'UTC',
      district: parts.length > 2 ? parts[2] : '',
      region: parts.length > 3 ? parts[3] : '',
    );
  }
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Geocode location names using Open-Meteo Geocoding API.
  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search'
        '?name=${Uri.encodeComponent(query)}&count=5&language=en&format=json',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final results = json['results'] as List?;
        if (results != null) {
          return results.map((r) => r as Map<String, dynamic>).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Reverse-geocode location coordinates using OSM Nominatim.
  Future<LocationDetails?> reverseGeocode(double lat, double lng) async {
    String placeName = 'Unknown Location';
    String district = '';
    String regionName = '';
    String countryCode = 'ZW';
    String timezone = 'UTC';

    try {
      // 1. Nominatim Reverse-Geocoding (Requires custom User-Agent)
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1',
      );
      final resp = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'AgroEdgePlatform/1.0 (agroedgeoff@gmail.com)',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        placeName = json['display_name'] as String? ?? 'Selected Point';
        final address = json['address'] as Map<String, dynamic>?;
        if (address != null) {
          district =
              address['county'] as String? ??
              address['suburb'] as String? ??
              '';
          regionName =
              address['state'] as String? ?? address['region'] as String? ?? '';
          countryCode = (address['country_code'] as String? ?? 'ZW')
              .toUpperCase();
        }
      }
    } catch (_) {}

    try {
      // 2. Fetch Timezone from Open-Meteo Forecast API
      final tzUri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&timezone=auto&forecast_days=1',
      );
      final tzResp = await http.get(tzUri).timeout(const Duration(seconds: 8));
      if (tzResp.statusCode == 200) {
        final tzJson = jsonDecode(tzResp.body) as Map<String, dynamic>;
        timezone = tzJson['timezone'] as String? ?? 'UTC';
      }
    } catch (_) {}

    return LocationDetails(
      lat: lat,
      lng: lng,
      placeName: placeName,
      district: district,
      region: regionName,
      countryCode: countryCode,
      timezone: timezone,
    );
  }
}
