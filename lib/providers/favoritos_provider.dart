import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pieza.dart';
import '../services/api_service.dart';

class FavoritosProvider extends ChangeNotifier {
  Set<int> _ids = {};
  Set<int> get ids => _ids;

  /// Cache de las piezas favoritas ya cargadas, para no volver a pedirlas
  /// cada vez que se renderiza el carrusel del buscador.
  List<Pieza> _piezas = [];
  List<Pieza> get piezas => _piezas;
  bool _piezasLoading = false;
  bool get piezasLoading => _piezasLoading;
  Set<int> _idsCacheados = {};

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
    _ensurePiezasCached();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoritos_local',
      _ids.map((e) => e.toString()).toList(),
    );
  }

  /// Carga las piezas que aún no estén cacheadas. No hace nada si los
  /// IDs en cache coinciden con los actuales.
  Future<void> _ensurePiezasCached() async {
    if (_idsCacheados.length == _ids.length && _idsCacheados.containsAll(_ids)) {
      return;
    }
    if (_ids.isEmpty) {
      _piezas = [];
      _idsCacheados = {};
      notifyListeners();
      return;
    }
    _piezasLoading = true;
    notifyListeners();
    try {
      _piezas = await ApiService.getPiezasByIds(_ids.toList());
      _idsCacheados = Set.from(_ids);
    } catch (_) {
      // sin red o error: dejamos lo anterior
    } finally {
      _piezasLoading = false;
      notifyListeners();
    }
  }

  /// Cuando el usuario inicia sesión, se carga la lista del backend.
  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      try {
        final remoteIds = await ApiService.getFavoritos(token);
        _ids.addAll(remoteIds);
        for (final id in _ids) {
          await ApiService.addFavorito(token, id);
        }
        await _saveLocal();
        notifyListeners();
        _ensurePiezasCached();
      } catch (_) {}
    }
  }

  Future<void> toggle(int piezaId) async {
    if (!_loaded) await _loadLocal();
    if (_ids.contains(piezaId)) {
      _ids.remove(piezaId);
      _piezas.removeWhere((p) => p.id == piezaId);
      _idsCacheados.remove(piezaId);
      if (_token != null) {
        try {
          await ApiService.removeFavorito(_token!, piezaId);
        } catch (_) {}
      }
    } else {
      _ids.add(piezaId);
      _idsCacheados = {}; // forzar recarga para incluir la nueva
      if (_token != null) {
        try {
          await ApiService.addFavorito(_token!, piezaId);
        } catch (_) {}
      }
    }
    await _saveLocal();
    notifyListeners();
    _ensurePiezasCached();
  }
}
