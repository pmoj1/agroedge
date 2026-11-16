// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildMapWidget({
  required double lat,
  required double lng,
  required String label,
  bool isDark = false,
}) {
  final cleanLatStr = lat.toString().replaceAll('.', '_').replaceAll('-', '_');
  final cleanLngStr = lng.toString().replaceAll('.', '_').replaceAll('-', '_');
  final viewId =
      'leaflet-map-$cleanLatStr-$cleanLngStr-${isDark ? "dark" : "light"}';
  final containerId = 'map-container-$viewId';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final element = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..id = containerId;

    _injectLeafletResources();

    Future.delayed(const Duration(milliseconds: 150), () {
      final tileUrl = isDark
          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
          : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      final attribution = isDark
          ? '© OpenStreetMap, © CartoDB'
          : '© OpenStreetMap';

      final scriptText =
          '''
        if (typeof L !== "undefined") {
          var container = document.getElementById("$containerId");
          if (container) {
            // Check if map is already initialized
            if (container._leaflet_map) {
              container._leaflet_map.remove();
            }
            var map = L.map(container).setView([$lat, $lng], 13);
            container._leaflet_map = map;
            L.tileLayer('$tileUrl', {
              maxZoom: 19,
              attribution: '$attribution'
            }).addTo(map);
            L.marker([$lat, $lng]).addTo(map).bindPopup("$label").openPopup();
          }
        }
      ''';
      final script = html.ScriptElement()..text = scriptText;
      html.document.body?.append(script);
    });

    return element;
  });

  return HtmlElementView(viewType: viewId);
}

Widget buildMapPickerWidget({
  required double initialLat,
  required double initialLng,
  required void Function(double lat, double lng) onLocationSelected,
  bool isDark = false,
}) {
  final cleanLatStr = initialLat
      .toString()
      .replaceAll('.', '_')
      .replaceAll('-', '_');
  final cleanLngStr = initialLng
      .toString()
      .replaceAll('.', '_')
      .replaceAll('-', '_');
  final viewId =
      'leaflet-picker-$cleanLatStr-$cleanLngStr-${isDark ? "dark" : "light"}';
  final containerId = 'map-container-$viewId';
  final callbackName = 'onMapPinDropped_$viewId';

  // Bind Dart callback to JS global context
  js.context[callbackName] = (double lat, double lng) {
    onLocationSelected(lat, lng);
  };

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final element = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..id = containerId;

    _injectLeafletResources();

    Future.delayed(const Duration(milliseconds: 150), () {
      final tileUrl = isDark
          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
          : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      final attribution = isDark
          ? '© OpenStreetMap, © CartoDB'
          : '© OpenStreetMap';

      final scriptText =
          '''
        if (typeof L !== "undefined") {
          var container = document.getElementById("$containerId");
          if (container) {
            if (container._leaflet_map) {
              container._leaflet_map.remove();
            }
            var map = L.map(container).setView([$initialLat, $initialLng], 12);
            container._leaflet_map = map;
            L.tileLayer('$tileUrl', {
              maxZoom: 19,
              attribution: '$attribution'
            }).addTo(map);

            var marker = L.marker([$initialLat, $initialLng], {
              draggable: true
            }).addTo(map);

            function updateCoords(lat, lng) {
              if (window['$callbackName']) {
                window['$callbackName'](lat, lng);
              }
            }

            marker.on('dragend', function(e) {
              var position = marker.getLatLng();
              updateCoords(position.lat, position.lng);
            });

            map.on('click', function(e) {
              marker.setLatLng(e.latlng);
              updateCoords(e.latlng.lat, e.latlng.lng);
            });
          }
        }
      ''';
      final script = html.ScriptElement()..text = scriptText;
      html.document.body?.append(script);
    });

    return element;
  });

  return HtmlElementView(viewType: viewId);
}

void _injectLeafletResources() {
  final loaded = html.document.querySelector('script[src*="leaflet.js"]');
  if (loaded != null) return;

  final link = html.LinkElement()
    ..rel = 'stylesheet'
    ..href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
  html.document.head?.append(link);

  final script = html.ScriptElement()
    ..src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
  html.document.head?.append(script);
}
