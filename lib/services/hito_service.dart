import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/hito_servicio.dart';

class HitoService {
  static const _base = AppConfig.apiBase;

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  static Future<List<HitoServicio>> getHitos(
      String token, int proyectoId) async {
    final res = await http.get(
      Uri.parse('$_base/proyectos/$proyectoId/hitos'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => HitoServicio.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> marcarHito(
    String token,
    int proyectoId, {
    required String hito,
    String? descripcion,
    required String usuarioCreacion,
  }) async {
    final body = <String, dynamic>{
      'idProyecto':       proyectoId,
      'hito':             hito,
      'usuarioCreacion':  usuarioCreacion,
    };
    if (descripcion != null && descripcion.isNotEmpty) {
      body['descripcion'] = descripcion;
    }
    final res = await http.post(
      Uri.parse('$_base/proyectos/$proyectoId/hitos'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    AppConfig.checkStatus(res);
  }
}
