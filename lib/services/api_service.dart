import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/pieza.dart';
import '../models/desguace.dart';
import '../models/vehiculo.dart';

class ApiService {
  static String get _base => AppConstants.apiBaseUrl;
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;
  static String? get tokenValue => _token;

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

  static Future<List<Pieza>> getPiezasByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final res = await http.post(
      Uri.parse('$_base/piezas/by_ids.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids}),
    );
    if (res.statusCode != 200) throw Exception('Error al cargar piezas');
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => Pieza.fromJson(e as Map<String, dynamic>)).toList();
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

  // ── PIEZAS PÚBLICAS POR DESGUACE ─────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getDesguacePiezas(int desguaceId) async {
    final res = await http.get(
      Uri.parse('$_base/piezas/by_desguace.php?desguace_id=$desguaceId'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Error al cargar piezas');
    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  // ── SUBIR IMAGEN ──────────────────────────────────────────────────────────

  static Future<String> uploadImage(Uint8List bytes, String filename) async {
    final uri = Uri.parse('$_base/piezas/upload_image.php');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: filename),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) throw Exception('Error al subir imagen');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['imagen'] as String;
  }

  // ── IMPORTAR EXCEL ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> importExcel({
    required String token,
    required List<Map<String, dynamic>> piezas,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/desguaces/import_excel.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'piezas': piezas}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Error al importar Excel');
    }
    return data;
  }

  // ── USUARIOS PARTICULARES ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String nombre,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/usuarios/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nombre': nombre,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Error al registrar');
    }
    return data;
  }

  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/usuarios/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Error al iniciar sesión');
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateUser({
    required String token,
    String? nombre,
    String? foto,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/usuarios/update.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (nombre != null) 'nombre': nombre,
        if (foto != null) 'foto': foto,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Error al actualizar');
    }
    return data;
  }

  static Future<String> uploadUserImage(Uint8List bytes, String filename) async {
    final uri = Uri.parse('$_base/usuarios/upload_image.php');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: filename),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) throw Exception('Error al subir imagen');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['foto'] as String;
  }

  // ── FAVORITOS ─────────────────────────────────────────────────────────────

  static Future<Set<int>> getFavoritos(String token) async {
    final res = await http.get(
      Uri.parse('$_base/favoritos/list.php'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Error al cargar favoritos');
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => int.parse(e.toString())).toSet();
  }

  static Future<void> addFavorito(String token, int piezaId) async {
    await http.post(
      Uri.parse('$_base/favoritos/add.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'pieza_id': piezaId}),
    );
  }

  static Future<void> removeFavorito(String token, int piezaId) async {
    await http.post(
      Uri.parse('$_base/favoritos/remove.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'pieza_id': piezaId}),
    );
  }

  // ── VEHÍCULOS DEL USUARIO ─────────────────────────────────────────────────

  static Future<List<Vehiculo>> getVehiculos(String token) async {
    final res = await http.get(
      Uri.parse('$_base/vehiculos/list.php'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Error al cargar vehículos');
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => Vehiculo.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Vehiculo> createVehiculo(String token, {
    String? alias,
    required String marca,
    required String modelo,
    int? anyo,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/vehiculos/create.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (alias != null) 'alias': alias,
        'marca': marca,
        'modelo': modelo,
        if (anyo != null) 'anyo': anyo,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Error al crear vehículo');
    }
    return Vehiculo.fromJson(data);
  }

  static Future<void> updateVehiculo(String token, int id, {
    String? alias,
    required String marca,
    required String modelo,
    int? anyo,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/vehiculos/update.php?id=$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'alias': alias ?? '',
        'marca': marca,
        'modelo': modelo,
        if (anyo != null) 'anyo': anyo,
      }),
    );
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Error al actualizar');
    }
  }

  static Future<void> deleteVehiculo(String token, int id) async {
    final res = await http.delete(
      Uri.parse('$_base/vehiculos/delete.php?id=$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Error al eliminar');
  }

  // ── ESTADÍSTICAS DESGUACE ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDesguaceStats(int desguaceId) async {
    final res = await http.get(
      Uri.parse('$_base/desguaces/stats.php?desguace_id=$desguaceId'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Error al cargar estadísticas');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
