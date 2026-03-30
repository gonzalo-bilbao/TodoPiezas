import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/pieza.dart';
import '../models/desguace.dart';

class ApiService {
  static const String _base = AppConstants.apiBaseUrl;
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── AUTH ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login.php'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Error al iniciar sesión');
    }
    return data;
  }

  // ── PIEZAS (CLIENTE) ──────────────────────────────────────────────────────

  static Future<List<Pieza>> searchPiezas({
    String? marca,
    String? modelo,
    int? anyo,
    String? categoria,
    String? color,
    String? estado,
  }) async {
    final params = <String, String>{};
    if (marca != null && marca.isNotEmpty) params['marca'] = marca;
    if (modelo != null && modelo.isNotEmpty) params['modelo'] = modelo;
    if (anyo != null) params['anyo'] = anyo.toString();
    if (categoria != null && categoria.isNotEmpty) params['categoria'] = categoria;
    if (color != null && color.isNotEmpty) params['color'] = color;
    if (estado != null && estado.isNotEmpty) params['estado'] = estado;

    final uri = Uri.parse('$_base/piezas/search.php')
        .replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) throw Exception('Error al buscar piezas');
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => Pieza.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Pieza> getPieza(int id) async {
    final res = await http.get(
      Uri.parse('$_base/piezas/get.php?id=$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Pieza no encontrada');
    return Pieza.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── PIEZAS (ADMIN) ────────────────────────────────────────────────────────

  static Future<List<Pieza>> getAdminPiezas(int desguaceId) async {
    final res = await http.get(
      Uri.parse('$_base/piezas/list.php?desguace_id=$desguaceId'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Error al cargar inventario');
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => Pieza.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> createPieza(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_base/piezas/create.php'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 201) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Error al crear pieza');
    }
  }

  static Future<void> updatePieza(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/piezas/update.php?id=$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Error al actualizar pieza');
    }
  }

  static Future<void> deletePieza(int id) async {
    final res = await http.delete(
      Uri.parse('$_base/piezas/delete.php?id=$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Error al eliminar pieza');
  }

  // ── DESGUACES ─────────────────────────────────────────────────────────────

  static Future<List<Desguace>> getDesguaces() async {
    final res = await http.get(
      Uri.parse('$_base/desguaces/list.php'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Error al cargar desguaces');
    final List<dynamic> data = jsonDecode(res.body);
    return data
        .map((e) => Desguace.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> getDesguace(int id) async {
    final res = await http.get(
      Uri.parse('$_base/desguaces/get.php?id=$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Error al cargar perfil');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> updateDesguace(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/desguaces/update.php?id=$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) throw Exception('Error al actualizar desguace');
  }
}
