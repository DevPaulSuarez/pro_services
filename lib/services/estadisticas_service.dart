import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/estadistica_precio.dart';

class EstadisticasService {
  static const _base = AppConfig.apiBase;

  static Future<EstadisticaPrecio?> getPrecioPromedio(
    String token, {
    int? tipoProfesionId,
    int? tipoServicioId,
  }) async {
    final params = <String, String>{};
    if (tipoProfesionId != null) {
      params['tipoProfesionId'] = tipoProfesionId.toString();
    }
    if (tipoServicioId != null) {
      params['tipoServicioId'] = tipoServicioId.toString();
    }

    final uri = Uri.parse('$_base/estadisticas/precio-promedio')
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await http.get(uri, headers: _headers(token));
    if (res.statusCode == 404) return null;
    AppConfig.checkStatus(res);
    return EstadisticaPrecio.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
