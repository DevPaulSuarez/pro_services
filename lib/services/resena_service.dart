import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/resena.dart';

class ResenaService {
  static const _base = AppConfig.apiBase;

  /// Reseñas de un profesional — endpoint público, no requiere token.
  static Future<List<Resena>> getPorProfesional(int idProfesional) async {
    final res = await http.get(
      Uri.parse('$_base/api/Resena/PorProfesional/$idProfesional'),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Resena.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Crear una reseña para un profesional. Requiere token de usuario (SoloUsuario).
  static Future<void> crear(
    String token, {
    required int idProfesional,
    required int idUsuario,
    required String titulo,
    required String descripcion,
    required int puntaje,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/Resena'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'idProfesional': idProfesional,
        'idUsuario': idUsuario,
        'titulo': titulo,
        'descripcion': descripcion,
        'puntaje': puntaje,
        'usuarioCreacion': 'app',
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
