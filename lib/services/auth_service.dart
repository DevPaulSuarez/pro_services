import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const _base = AppConfig.apiBase;

  /// Iniciar sesión. [rol]: 'cliente' | 'profesional'
  static Future<({String token, String rol, String nombre})> login(
    String correo,
    String contrasena, {
    required String rol,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena, 'rol': rol}),
    );
    AppConfig.checkStatus(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final usuario = data['usuario'] as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      rol: usuario['rol'] as String,
      nombre: usuario['nombre'] as String? ?? '',
    );
  }

  /// Registrar usuario nuevo. Retorna el token JWT y el rol (la API lo genera automáticamente).
  /// [rol]: 'cliente' | 'profesional'
  static Future<({String token, String rol, String nombre})> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String rol,
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
    AppConfig.checkStatus(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final usuario = data['usuario'] as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      rol: usuario['rol'] as String,
      nombre: usuario['nombre'] as String? ?? '',
    );
  }

  /// Cerrar sesión. [rol]: 'cliente' | 'profesional'
  static Future<void> logout(String token, {required String rol}) async {
    final endpoint = rol == 'profesional'
        ? '$_base/api/Autenticacion/LogoutProfesional'
        : '$_base/api/Autenticacion/LogoutUsuario';
    final res = await http.post(
      Uri.parse(endpoint),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
