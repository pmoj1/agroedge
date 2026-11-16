import 'package:flutter/material.dart';
import 'map_widget_stub.dart'
    if (dart.library.html) 'map_widget_web.dart'
    as map_impl;

/// Build interactive Leaflet map widget on Web. Fallback on mobile native.
Widget buildLeafletMap({
  required double lat,
  required double lng,
  required String label,
  bool isDark = false,
}) {
  return map_impl.buildMapWidget(
    lat: lat,
    lng: lng,
    label: label,
    isDark: isDark,
  );
}

/// Build interactive Leaflet map picker widget on Web. Fallback on mobile native.
Widget buildLeafletMapPicker({
  required double initialLat,
  required double initialLng,
  required void Function(double lat, double lng) onLocationSelected,
  bool isDark = false,
}) {
  return map_impl.buildMapPickerWidget(
    initialLat: initialLat,
    initialLng: initialLng,
    onLocationSelected: onLocationSelected,
    isDark: isDark,
  );
}
