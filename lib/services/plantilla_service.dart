import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/plantilla_cotizacion.dart';

class PlantillaService {
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

  static Future<List<PlantillaCotizacion>> getMias(String token) async {
    final res = await http.get(
      Uri.parse('$_base/api/PlantillaCotizacion/me'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => PlantillaCotizacion.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<int> crear(
    String token, {
    required String nombre,
    required double manoObra,
    required double materiales,
    required double traslado,
    String? observaciones,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/PlantillaCotizacion/me'),
      headers: _headers(token),
      body: jsonEncode({
        'nombre': nombre,
        'manoObra': manoObra,
        'materiales': materiales,
        'traslado': traslado,
        'observaciones': ?observaciones,
      }),
    );
    AppConfig.checkStatus(res);
    return (jsonDecode(res.body)['id'] as int?) ?? 0;
  }

  static Future<void> actualizar(
    String token,
    int id, {
    required String nombre,
    required double manoObra,
    required double materiales,
    required double traslado,
    String? observaciones,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/api/PlantillaCotizacion/me/$id'),
      headers: _headers(token),
      body: jsonEncode({
        'id': id,
        'nombre': nombre,
        'manoObra': manoObra,
        'materiales': materiales,
        'traslado': traslado,
        'observaciones': ?observaciones,
      }),
    );
    AppConfig.checkStatus(res);
  }

  static Future<void> eliminar(String token, int id) async {
    final res = await http.delete(
      Uri.parse('$_base/api/PlantillaCotizacion/me/$id'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }
}
