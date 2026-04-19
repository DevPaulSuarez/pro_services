import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/busqueda_resultado.dart';

class BusquedaService {
  static const _base = AppConfig.apiBase;

  static Future<List<BusquedaResultado>> buscar(
    String token, {
    String? query,
    int? categoriaId,
    double? calificacionMin,
    double? precioMin,
    double? precioMax,
    bool? soloDisponibles,
    double? latitud,
    double? longitud,
  }) async {
    final uri = Uri.parse('$_base/profesionales/buscar').replace(
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (categoriaId != null) 'categoriaId': categoriaId.toString(),
        if (calificacionMin != null) 'calificacionMin': calificacionMin.toString(),
        if (precioMin != null) 'precioMin': precioMin.toString(),
        if (precioMax != null) 'precioMax': precioMax.toString(),
        if (soloDisponibles != null) 'soloDisponibles': soloDisponibles.toString(),
        if (latitud != null) 'latitud': latitud.toString(),
        if (longitud != null) 'longitud': longitud.toString(),
      },
    );
    final res = await http.get(uri, headers: _headers(token));
    AppConfig.checkStatus(res);
    final data = jsonDecode(res.body) as List;
    return data
        .map((e) => BusquedaResultado.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
