import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pieza.dart';
import '../services/api_service.dart';

class SearchProvider extends ChangeNotifier {
  String? marca;
  String? modelo;
  int? anyo;
  String? categoria;
  String? color;
  String? estado;

  List<Pieza> results = [];
  bool loading = false;
  String? error;
  Position? userPosition;

  void setFilter(String key, dynamic value) {
    if (key == 'marca') {
      marca = value as String?;
      modelo = null; // reset modelo al cambiar marca
    } else if (key == 'modelo') {
      modelo = value as String?;
    } else if (key == 'anyo') {
      anyo = value as int?;
    } else if (key == 'categoria') {
      categoria = value as String?;
    } else if (key == 'color') {
      color = value as String?;
    } else if (key == 'estado') {
      estado = value as String?;
    }
    notifyListeners();
  }

  void clearFilters() {
    marca = modelo = categoria = color = estado = null;
    anyo = null;
    results = [];
    error = null;
    notifyListeners();
  }

  Future<void> search() async {
    if ((marca == null || marca!.isEmpty) &&
        (categoria == null || categoria!.isEmpty)) {
      error = 'Selecciona al menos una marca o categoría';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      await _requestLocation();
      results = await ApiService.searchPiezas(
        marca: marca,
        modelo: modelo,
        anyo: anyo,
        categoria: categoria,
        color: color,
        estado: estado,
      );
      if (userPosition != null) _sortByDistance();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _requestLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 15));
    } catch (_) {
      // Si no hay ubicación, seguimos sin ordenar por distancia
    }
  }

  void _sortByDistance() {
    for (final p in results) {
      p.distancia = Geolocator.distanceBetween(
            userPosition!.latitude,
            userPosition!.longitude,
            p.desguaceLat,
            p.desguaceLng,
          ) /
          1000;
    }
    results.sort((a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0));
  }
}
