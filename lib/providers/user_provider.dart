import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_particular.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  UsuarioParticular? usuario;
  String? token;
  bool loading = false;
  String? error;

  bool get isLoggedIn => usuario != null && token != null;

  UserProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('user_token');
    final data = prefs.getString('user_data');
    if (t != null && data != null) {
      try {
        usuario = UsuarioParticular.fromJson(jsonDecode(data));
        token = t;
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (usuario != null && token != null) {
      await prefs.setString('user_token', token!);
      await prefs.setString('user_data', jsonEncode({
        'id': usuario!.id,
        'email': usuario!.email,
        'nombre': usuario!.nombre,
        'foto': usuario!.foto,
        'marca': usuario!.marca,
        'modelo': usuario!.modelo,
        'anyo': usuario!.anyo,
      }));
    } else {
      await prefs.remove('user_token');
      await prefs.remove('user_data');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    String? marca,
    String? modelo,
    int? anyo,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await ApiService.registerUser(
        email: email,
        password: password,
        nombre: nombre,
        marca: marca,
        modelo: modelo,
        anyo: anyo,
      );
      token = data['token'] as String;
      usuario = UsuarioParticular.fromJson(data['usuario']);
      await _saveToPrefs();
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await ApiService.loginUser(email, password);
      token = data['token'] as String;
      usuario = UsuarioParticular.fromJson(data['usuario']);
      await _saveToPrefs();
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    usuario = null;
    token = null;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? nombre,
    String? marca,
    String? modelo,
    int? anyo,
    String? foto,
  }) async {
    if (!isLoggedIn) return false;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await ApiService.updateUser(
        token: token!,
        nombre: nombre,
        marca: marca,
        modelo: modelo,
        anyo: anyo,
        foto: foto,
      );
      usuario = UsuarioParticular.fromJson(data);
      await _saveToPrefs();
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
