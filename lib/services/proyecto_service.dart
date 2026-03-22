import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/proyecto.dart';
import 'package:pro_services/models/nota.dart';
import 'package:pro_services/models/foto_proyecto.dart';

class ProyectoService {
  static const _base = 'https://TU_API_BASE_URL';

  // ── Proyectos ─────────────────────────────────────────────────────────────

  /// Lista de proyectos del profesional. [estado] es opcional.
  /// Valores: 'pendiente' | 'aceptado' | 'completado' | 'rechazado'
  static Future<List<Proyecto>> getProyectos(String token,
      {String? estado}) async {
    final uri = Uri.parse('$_base/proyectos')
        .replace(queryParameters: estado != null ? {'estado': estado} : null);
    final res = await http.get(uri, headers: _headers(token));
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Proyecto.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Detalle de un proyecto por ID.
  static Future<Proyecto> getById(String token, int id) async {
    final res = await http.get(
      Uri.parse('$_base/proyectos/$id'),
      headers: _headers(token),
    );
    _checkStatus(res);
    return Proyecto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Aceptar una solicitud.
  static Future<void> aceptar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/proyectos/$id/aceptar'),
      headers: _headers(token),
    );
    _checkStatus(res);
  }

  /// Rechazar una solicitud.
  static Future<void> rechazar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/proyectos/$id/rechazar'),
      headers: _headers(token),
    );
    _checkStatus(res);
  }

  /// Marcar como completado.
  static Future<void> completar(String token, int id) async {
    final res = await http.patch(
      Uri.parse('$_base/proyectos/$id/completar'),
      headers: _headers(token),
    );
    _checkStatus(res);
  }

  // ── Notas ─────────────────────────────────────────────────────────────────

  static Future<List<Nota>> getNotas(String token, int proyectoId) async {
    final res = await http.get(
      Uri.parse('$_base/proyectos/$proyectoId/notas'),
      headers: _headers(token),
    );
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Nota.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Nota> agregarNota(
      String token, int proyectoId, String texto) async {
    final res = await http.post(
      Uri.parse('$_base/proyectos/$proyectoId/notas'),
      headers: _headers(token),
      body: jsonEncode({'texto': texto}),
    );
    _checkStatus(res);
    return Nota.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> eliminarNota(
      String token, int proyectoId, int notaId) async {
    final res = await http.delete(
      Uri.parse('$_base/proyectos/$proyectoId/notas/$notaId'),
      headers: _headers(token),
    );
    _checkStatus(res);
  }

  // ── Fotos ─────────────────────────────────────────────────────────────────

  static Future<List<FotoProyecto>> getFotos(
      String token, int proyectoId) async {
    final res = await http.get(
      Uri.parse('$_base/proyectos/$proyectoId/fotos'),
      headers: _headers(token),
    );
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => FotoProyecto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Subir foto como multipart/form-data.
  static Future<FotoProyecto> subirFoto(
      String token, int proyectoId, List<int> bytes, String nombre) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base/proyectos/$proyectoId/fotos'),
    )
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..files.add(http.MultipartFile.fromBytes('foto', bytes,
          filename: nombre));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _checkStatus(res);
    return FotoProyecto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> eliminarFoto(
      String token, int proyectoId, int fotoId) async {
    final res = await http.delete(
      Uri.parse('$_base/proyectos/$proyectoId/fotos/$fotoId'),
      headers: _headers(token),
    );
    _checkStatus(res);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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
