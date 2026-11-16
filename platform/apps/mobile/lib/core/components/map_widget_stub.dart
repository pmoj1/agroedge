import 'package:flutter/material.dart';

Widget buildMapWidget({
  required double lat,
  required double lng,
  required String label,
  bool isDark = false,
}) {
  return Container(
    height: 180,
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: Colors.grey, size: 36),
          const SizedBox(height: 8),
          Text(
            'Coordinates: $lat, $lng',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

Widget buildMapPickerWidget({
  required double initialLat,
  required double initialLng,
  required void Function(double lat, double lng) onLocationSelected,
  bool isDark = false,
}) {
  return Container(
    height: 300,
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: Colors.grey, size: 36),
          const SizedBox(height: 8),
          Text(
            'Interactive Map Picker Fallback: $initialLat, $initialLng',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
