import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/desguace.dart';
import '../services/api_service.dart';

/// Carga en segundo plano datos que se usarán inmediatamente al navegar.
/// El usuario no espera por estos: cuando llegue a la pantalla, ya están listos.
class PreloadProvider extends ChangeNotifier {
  List<Desguace> desguaces = [];
  Position? userPosition;
  bool desguacesReady = false;
  bool positionReady = false;

  /// Lanza todas las precargas en paralelo. Se llama al arrancar la app.
  Future<void> startBackgroundPreload() async {
    // No esperamos a que terminen — corren en segundo plano
    _loadDesguaces();
    _loadPosition();
  }

  Future<void> _loadDesguaces() async {
    try {
      desguaces = await ApiService.getDesguaces();
      desguacesReady = true;
      notifyListeners();
    } catch (_) {
      // si falla, las pantallas que lo necesiten harán su propia carga
    }
  }

  Future<void> _loadPosition() async {
    try {
      final ok = await Geolocator.isLocationServiceEnabled();
      if (!ok) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;
      userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 15));
      positionReady = true;
      notifyListeners();
    } catch (_) {}
  }

  void invalidateDesguaces() {
    desguacesReady = false;
    _loadDesguaces();
  }
}
