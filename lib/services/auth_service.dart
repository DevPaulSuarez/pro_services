import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const _base = 'https://TU_API_BASE_URL';

  /// Iniciar sesión. Retorna el token JWT y el rol del usuario.
  static Future<({String token, String rol})> login(String correo, String contrasena) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );
    _checkStatus(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (token: data['token'] as String, rol: data['rol'] as String);
  }

  /// Registrar usuario nuevo.
  static Future<void> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String rol, // 'cliente' | 'profesional'
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'rol': rol,
      }),
    );
    _checkStatus(res);
  }

  /// Cerrar sesión.
  static Future<void> logout(String token) async {
    final res = await http.post(
      Uri.parse('$_base/auth/logout'),
      headers: _headers(token),
    );
    _checkStatus(res);
  }

  /// Renovar token.
  static Future<String> refresh(String token) async {
    final res = await http.post(
      Uri.parse('$_base/auth/refresh'),
      headers: _headers(token),
    );
    _checkStatus(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['token'] as String;
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
