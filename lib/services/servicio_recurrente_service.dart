import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/servicio_recurrente.dart';

class ServicioRecurrenteService {
  static const _base = AppConfig.apiBase;

  /// Servicios recurrentes creados por el cliente autenticado.
  static Future<List<ServicioRecurrente>> getMis(String token) async {
    final res = await http.get(
      Uri.parse('$_base/servicios-recurrentes/mis'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final data = jsonDecode(res.body) as List;
    return data
        .map((json) =>
            ServicioRecurrente.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Servicios recurrentes asignados al profesional autenticado.
  static Future<List<ServicioRecurrente>> getMisAsignados(String token) async {
    final res = await http.get(
      Uri.parse('$_base/servicios-recurrentes/mis-asignados'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final data = jsonDecode(res.body) as List;
    return data
        .map((json) =>
            ServicioRecurrente.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Crear un nuevo servicio recurrente.
  static Future<void> crear(String token, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$_base/servicios-recurrentes'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    AppConfig.checkStatus(res);
  }

  /// Pausar un servicio recurrente por id.
  static Future<void> pausar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/servicios-recurrentes/$id/pausar'),
      headers: _headers(token),
      body: jsonEncode(<String, dynamic>{}),
    );
    AppConfig.checkStatus(res);
  }

  /// Cancelar un servicio recurrente por id.
  static Future<void> cancelar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/servicios-recurrentes/$id/cancelar'),
      headers: _headers(token),
      body: jsonEncode(<String, dynamic>{}),
    );
    AppConfig.checkStatus(res);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
