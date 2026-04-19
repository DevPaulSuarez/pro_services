import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/solicitud_cliente.dart';

class SolicitudService {
  static const _base = AppConfig.apiBase;

  /// Solicitudes enviadas por el cliente autenticado.
  static Future<List<SolicitudCliente>> getMisSolicitudes(String token) async {
    final res = await http.get(
      Uri.parse('$_base/clientes/me/solicitudes'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => SolicitudCliente.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crear nueva solicitud de servicio (cliente → profesional).
  static Future<void> crear(
    String token, {
    required int profesionalId,
    required String servicio,
    required String descripcion,
    required String ubicacion,
    required double presupuesto,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/proyectos'),
      headers: _headers(token),
      body: jsonEncode({
        'profesional_id': profesionalId,
        'servicio': servicio,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'presupuesto': presupuesto,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
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
