import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../services/api_service.dart';

class VehiculosProvider extends ChangeNotifier {
  List<Vehiculo> vehiculos = [];
  bool loading = false;
  String? error;
  String? _token;

  void setToken(String? token) {
    _token = token;
    if (token == null) {
      vehiculos = [];
      notifyListeners();
    } else {
      load();
    }
  }

  Future<void> load() async {
    if (_token == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      vehiculos = await ApiService.getVehiculos(_token!);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> add({
    String? alias,
    required String marca,
    required String modelo,
    int? anyo,
    String? foto,
  }) async {
    if (_token == null) return false;
    try {
      final v = await ApiService.createVehiculo(
        _token!, alias: alias, marca: marca, modelo: modelo, anyo: anyo, foto: foto,
      );
      vehiculos.add(v);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, {
    String? alias,
    required String marca,
    required String modelo,
    int? anyo,
    String? foto,
  }) async {
    if (_token == null) return false;
    try {
      await ApiService.updateVehiculo(
        _token!, id, alias: alias, marca: marca, modelo: modelo, anyo: anyo, foto: foto,
      );
      await load();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    if (_token == null) return false;
    try {
      await ApiService.deleteVehiculo(_token!, id);
      vehiculos.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
