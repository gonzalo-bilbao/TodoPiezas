import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class FavoritosProvider extends ChangeNotifier {
  Set<int> _ids = {};
  Set<int> get ids => _ids;

  String? _token; // si hay sesión
  bool _loaded = false;

  bool isFavorito(int piezaId) => _ids.contains(piezaId);

  FavoritosProvider() {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('favoritos_local') ?? [];
    _ids = raw.map(int.parse).toSet();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoritos_local',
      _ids.map((e) => e.toString()).toList(),
    );
  }

  /// Cuando el usuario inicia sesión, se carga la lista del backend.
  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      try {
        final remoteIds = await ApiService.getFavoritos(token);
        _ids.addAll(remoteIds);
        // Sincronizar los locales al remoto
        for (final id in _ids) {
          await ApiService.addFavorito(token, id);
        }
        await _saveLocal();
        notifyListeners();
      } catch (_) {
        // si falla el backend, seguimos con locales
      }
    }
  }

  Future<void> toggle(int piezaId) async {
    if (!_loaded) await _loadLocal();
    if (_ids.contains(piezaId)) {
      _ids.remove(piezaId);
      if (_token != null) {
        try {
          await ApiService.removeFavorito(_token!, piezaId);
        } catch (_) {}
      }
    } else {
      _ids.add(piezaId);
      if (_token != null) {
        try {
          await ApiService.addFavorito(_token!, piezaId);
        } catch (_) {}
      }
    }
    await _saveLocal();
    notifyListeners();
  }
}
