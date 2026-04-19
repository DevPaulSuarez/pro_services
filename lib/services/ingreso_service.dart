import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/ingreso_mes.dart';

class IngresoService {
  static const _base = AppConfig.apiBase;

  /// Resumen de ingresos del mes actual para el profesional autenticado.
  static Future<IngresoMes> getIngresosMes(String token) async {
    final res = await http.get(
      Uri.parse('$_base/proyectos/ingresos-mes'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    return IngresoMes.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
