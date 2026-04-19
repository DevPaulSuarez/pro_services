import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/foto_proyecto.dart';

class FotoProyectoService {
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

  /// GET /proyectos/{id}/fotos?tipo=antes|durante|despues
  static Future<List<FotoProyecto>> getFotos(
    String token,
    int proyectoId, {
    String? tipo,
  }) async {
    final uri = Uri.parse('$_base/proyectos/$proyectoId/fotos').replace(
      queryParameters: tipo != null ? {'tipo': tipo} : null,
    );
    final res = await http.get(uri, headers: _headers(token));
    AppConfig.checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => FotoProyecto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /proyectos/{id}/fotos — sube URL + tipo + descripción
  static Future<void> subirFoto(
    String token,
    int proyectoId, {
    required String url,
    required String tipo,
    String? descripcion,
    String usuarioCreacion = 'profesional',
  }) async {
    final res = await http.post(
      Uri.parse('$_base/proyectos/$proyectoId/fotos'),
      headers: _headers(token),
      body: jsonEncode({
        'idProyecto': proyectoId,
        'url': url,
        'tipoFoto': tipo,
        'descripcion': descripcion,
        'usuarioCreacion': usuarioCreacion,
      }),
    );
    AppConfig.checkStatus(res);
  }
}
