import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/profesional.dart';

class PerfilProfesionalService {
  static const _base = 'https://TU_API_BASE_URL';

  /// Obtener perfil del profesional autenticado.
  static Future<Profesional> getMe(String token) async {
    final res = await http.get(
      Uri.parse('$_base/profesionales/me'),
      headers: _headers(token),
    );
    _checkStatus(res);
    return Profesional.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Actualizar perfil del profesional.
  static Future<void> updateMe(
    String token, {
    required String nombre,
    required String especialidad,
    required String bio,
    required String ciudad,
    required String telefono,
    required String correo,
    required double precioPorHora,
    required List<String> habilidades,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/profesionales/me'),
      headers: _headers(token),
      body: jsonEncode({
        'nombre': nombre,
        'especialidad': especialidad,
        'sobre_mi': bio,
        'ubicacion': ciudad,
        'telefono': telefono,
        'correo': correo,
        'precio_por_hora': precioPorHora,
        'habilidades': habilidades,
      }),
    );
    _checkStatus(res);
  }

  /// Subir foto de perfil.
  static Future<void> subirFoto(
      String token, List<int> bytes, String nombre) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_base/profesionales/me/foto'),
    )
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..files.add(http.MultipartFile.fromBytes('foto', bytes,
          filename: nombre));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _checkStatus(res);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
