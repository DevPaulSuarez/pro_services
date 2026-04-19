import 'dart:convert';
import 'package:http/http.dart' as http;

class AppConfig {
  // Cambia esta IP cuando te conectes a otra red
  static const String _host = '192.168.12.9';

  static const String apiBase = 'http://$_host:5002';

  /// Parsea el cuerpo del error y lanza solo el mensaje limpio.
  static void checkStatus(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    String mensaje = 'Error inesperado. Intenta de nuevo.';
    try {
      final body = jsonDecode(res.body);
      if (body is Map) {
        mensaje =
            body['mensaje'] as String? ??
            body['message'] as String? ??
            body['error'] as String? ??
            body['title'] as String? ??
            mensaje;
      } else if (body is String && body.isNotEmpty) {
        mensaje = body;
      }
    } catch (_) {}
    throw Exception(mensaje);
  }
}
