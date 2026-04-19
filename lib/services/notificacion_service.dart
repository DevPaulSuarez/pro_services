import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/notificacion.dart';

class NotificacionService {
  static const String _base = AppConfig.apiBase;

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  static Future<List<Notificacion>> getMias(String token, {int pagina = 1}) async {
    final res = await http.get(
      Uri.parse('$_base/api/Notificacion/me?pagina=$pagina'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final data = jsonDecode(res.body);
    final items = data['items'] as List? ?? (data is List ? data : []);
    return items.map((j) => Notificacion.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<int> contarNoLeidas(String token) async {
    final res = await http.get(
      Uri.parse('$_base/api/Notificacion/me/no-leidas-count'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final data = jsonDecode(res.body);
    return data['count'] as int? ?? 0;
  }

  static Future<void> marcarLeida(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/api/Notificacion/$id/leer'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }

  static Future<void> leerTodas(String token) async {
    final res = await http.patch(
      Uri.parse('$_base/api/Notificacion/leer-todas'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }
}
