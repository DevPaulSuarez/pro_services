import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/disputa.dart';

class DisputaService {
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

  static Future<int> crear(
    String token, {
    required int idProyecto,
    required String motivo,
    required String descripcion,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/Disputa'),
      headers: _headers(token),
      body: jsonEncode({
        'idProyecto': idProyecto,
        'motivo': motivo,
        'descripcion': descripcion,
      }),
    );
    AppConfig.checkStatus(res);
    return (jsonDecode(res.body)['id'] as int?) ?? 0;
  }

  static Future<List<Disputa>> getMias(String token) async {
    final res = await http.get(
      Uri.parse('$_base/api/Disputa/me'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Disputa.fromJson(j as Map<String, dynamic>)).toList();
  }
}
