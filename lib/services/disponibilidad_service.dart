import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/slot_disponible.dart';

class DisponibilidadService {
  static const _base = AppConfig.apiBase;

  /// Retorna los slots de disponibilidad de un profesional para un mes dado.
  /// [mes]: formato 'YYYY-MM'
  static Future<List<SlotDisponible>> getDisponibilidad(
    String token,
    int profesionalId,
    String mes,
  ) async {
    final uri = Uri.parse('$_base/api/HorarioProfesional/$profesionalId/disponibilidad')
        .replace(queryParameters: {'mes': mes});
    final res = await http.get(uri, headers: _headers(token));
    AppConfig.checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body) as List;
    return data
        .map((e) => SlotDisponible.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Actualiza el switch manual de disponibilidad del profesional autenticado.
  static Future<void> setDisponibleManual(String token, bool disponible) async {
    final res = await http.put(
      Uri.parse('$_base/profesionales/me/disponibilidad'),
      headers: _headers(token),
      body: jsonEncode({'disponibleManual': disponible}),
    );
    AppConfig.checkStatus(res);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
