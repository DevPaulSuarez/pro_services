import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ErrorLogService {
  static const _base = AppConfig.apiBase;
  static final List<Map<String, dynamic>> _pendientes = [];
  static String? _token;
  static String? _userEmail;

  /// Configura el token y email del usuario actual (llamar post-login)
  static void configurar({String? token, String? email}) {
    _token = token;
    _userEmail = email;
  }

  /// Registra un error. No lanza excepciones — es fire-and-forget.
  static Future<void> registrar({
    required String error,
    String? stackTrace,
    String? screen,
    String? action,
    String level = 'Error',
    int? statusCode,
  }) async {
    final body = {
      'error': error,
      'stackTrace': stackTrace,
      'screen': screen,
      'action': action,
      'platform': 'Flutter',
      'level': level,
      'statusCode': statusCode,
      'userEmail': _userEmail ?? 'anonymous',
    };

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
      final res = await http.post(
        Uri.parse('$_base/api/error-log'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Enviar pendientes si hay
        _enviarPendientes();
      } else {
        _guardarLocal(body);
      }
    } catch (_) {
      _guardarLocal(body);
    }
  }

  static void _guardarLocal(Map<String, dynamic> body) {
    if (_pendientes.length < 100) _pendientes.add(body);
  }

  static Future<void> _enviarPendientes() async {
    if (_pendientes.isEmpty) return;
    final copia = List<Map<String, dynamic>>.from(_pendientes);
    _pendientes.clear();
    for (final body in copia) {
      try {
        await http.post(
          Uri.parse('$_base/api/error-log'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      } catch (_) {
        _guardarLocal(body);
        break; // si falla, parar y guardar el resto
      }
    }
  }

  /// Cantidad de errores pendientes de enviar
  static int get pendientes => _pendientes.length;
}
