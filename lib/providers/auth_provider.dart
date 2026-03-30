import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  String? userName;
  int? desguaceId;
  String? desguaceNombre;
  bool loading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);
      ApiService.setToken(data['token'] as String);
      isLoggedIn = true;
      userName = data['nombre'] as String?;
      desguaceId = int.parse(data['desguace_id'].toString());
      desguaceNombre = data['desguace_nombre'] as String?;
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

  void logout() {
    ApiService.clearToken();
    isLoggedIn = false;
    userName = null;
    desguaceId = null;
    desguaceNombre = null;
    notifyListeners();
  }
}
