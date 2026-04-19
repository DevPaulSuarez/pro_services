import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/profesional.dart';

class ProfesionalService {
  static const _base = AppConfig.apiBase;

  static Future<List<Profesional>> getPorCategoria(int tipoProfesionId) async {
    final uri = Uri.parse('$_base/profesionales').replace(
      queryParameters: {'categoria_id': tipoProfesionId.toString()},
    );
    final res = await http.get(uri);
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Profesional.fromJson(e as Map<String, dynamic>)).toList();
  }

  static void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
