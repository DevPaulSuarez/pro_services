import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/cotizacion.dart';

class CotizacionService {
  static const _base = AppConfig.apiBase;

  /// Cotizaciones de un usuario autenticado.
  static Future<List<Cotizacion>> getPorUsuario(
      String token, int idUsuario) async {
    final res = await http.get(
      Uri.parse('$_base/api/Cotizacion/PorUsuario/$idUsuario'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => Cotizacion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cotizaciones de un profesional.
  static Future<List<Cotizacion>> getPorProfesional(
      String token, int idProfesional) async {
    final res = await http.get(
      Uri.parse('$_base/api/Cotizacion/PorProfesional/$idProfesional'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => Cotizacion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Aceptar una cotización.
  static Future<void> aceptar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/api/Cotizacion/$id/aceptar'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }

  /// Rechazar una cotización.
  static Future<void> rechazar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/api/Cotizacion/$id/rechazar'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }

  /// Crear una cotización (profesional → cliente).
  static Future<void> crear(
    String token, {
    required int idUsuario,
    required int idProfesional,
    required double precioTotal,
    required String observaciones,
    required String fechaServicio,
    required String horaInicio,
    required String horaFin,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/Cotizacion'),
      headers: _headers(token),
      body: jsonEncode({
        'idUsuario': idUsuario,
        'idProfesional': idProfesional,
        'idTipoServicio': 1,
        'fechaServicio': fechaServicio,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'precioPropuesto': precioTotal,
        'observaciones': observaciones,
        'usuarioCreacion': 'app',
      }),
    );
    AppConfig.checkStatus(res);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
