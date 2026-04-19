import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/horario.dart';

class HorarioService {
  static const _base = AppConfig.apiBase;

  /// Lista de horarios del profesional autenticado.
  static Future<List<Horario>> getMiHorario(String token) async {
    final res = await http.get(
      Uri.parse('$_base/api/HorarioProfesional/me'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Horario.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Agregar un bloque horario al profesional autenticado.
  static Future<void> agregar(
    String token, {
    required int diaSemana,
    required String horaInicio,
    required String horaFin,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/HorarioProfesional/me'),
      headers: _headers(token),
      body: jsonEncode({
        'diaSemana': diaSemana,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
      }),
    );
    AppConfig.checkStatus(res);
  }

  /// Eliminar un bloque horario por ID (soft delete).
  static Future<void> eliminar(String token, int id) async {
    final res = await http.delete(
      Uri.parse('$_base/api/HorarioProfesional/me/$id'),
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
