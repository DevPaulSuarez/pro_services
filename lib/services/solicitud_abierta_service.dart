import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/solicitud_abierta.dart';

class SolicitudAbiertaService {
  static const _base = AppConfig.apiBase;

  /// Publica una nueva solicitud abierta (cliente busca profesional).
  static Future<void> crear(
    String token, {
    required String titulo,
    required String descripcion,
    required int tipoProfesionId,
    double? presupuestoMax,
    String? ubicacion,
    String? fechaLimite,
    bool esUrgente = false,
  }) async {
    final body = <String, dynamic>{
      'titulo': titulo,
      'descripcion': descripcion,
      'idTipoProfesion': tipoProfesionId,
      'esUrgente': esUrgente,
      'presupuestoMax': ?presupuestoMax,
      if (ubicacion != null && ubicacion.isNotEmpty) 'ubicacion': ubicacion,
      'fechaLimite': ?fechaLimite,
    };
    final res = await http.post(
      Uri.parse('$_base/solicitudes-abiertas'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    AppConfig.checkStatus(res);
  }

  /// Solicitudes abiertas publicadas por el cliente autenticado.
  static Future<List<SolicitudAbierta>> getMis(String token) async {
    final res = await http.get(
      Uri.parse('$_base/solicitudes-abiertas/mis'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => SolicitudAbierta.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Solicitudes abiertas visibles para el profesional autenticado.
  static Future<List<SolicitudAbierta>> getDisponibles(String token) async {
    final res = await http.get(
      Uri.parse('$_base/solicitudes-abiertas/disponibles'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => SolicitudAbierta.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cierra una solicitud abierta (solo el cliente dueño puede hacerlo).
  static Future<void> cerrar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/solicitudes-abiertas/$id/cerrar'),
      headers: _headers(token),
      body: jsonEncode({}),
    );
    AppConfig.checkStatus(res);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
