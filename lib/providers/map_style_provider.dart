import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapStyle {
  final String id;
  final String name;
  final String urlTemplate;
  final IconData icon;
  final List<String>? subdomains;

  const MapStyle({
    required this.id,
    required this.name,
    required this.urlTemplate,
    required this.icon,
    this.subdomains,
  });
}

class MapStyleProvider extends ChangeNotifier {
  static const styles = [
    MapStyle(
      id: 'osm',
      name: 'Estándar',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      icon: Icons.map,
    ),
    MapStyle(
      id: 'satellite',
      name: 'Satélite',
      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      icon: Icons.satellite_alt,
    ),
    MapStyle(
      id: 'dark',
      name: 'Oscuro',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
      icon: Icons.dark_mode,
      subdomains: ['a', 'b', 'c', 'd'],
    ),
  ];

  String _currentId = 'osm';
  String get currentId => _currentId;

  MapStyle get current => styles.firstWhere(
        (s) => s.id == _currentId,
        orElse: () => styles.first,
      );

  MapStyleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentId = prefs.getString('map_style') ?? 'osm';
    notifyListeners();
  }

  Future<void> setStyle(String id) async {
    _currentId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('map_style', id);
  }
}
