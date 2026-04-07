import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/resena_cliente.dart';

class ResenaClienteService {
  static const String _base = 'http://localhost:5099';

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
    required int idUsuario,
    required int idProyecto,
    required int puntaje,
    String? comentario,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/ResenaCliente'),
      headers: _headers(token),
      body: jsonEncode({
        'idUsuario': idUsuario,
        'idProyecto': idProyecto,
        'puntaje': puntaje,
        'comentario': ?comentario,
      }),
    );
    _checkStatus(res);
    return (jsonDecode(res.body)['id'] as int?) ?? 0;
  }

  static Future<List<ResenaCliente>> getPorUsuario(int idUsuario) async {
    final res = await http.get(
      Uri.parse('$_base/api/ResenaCliente/PorUsuario/$idUsuario'),
    );
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => ResenaCliente.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<List<ResenaCliente>> getPorProfesional(String token, int idProfesional) async {
    final res = await http.get(
      Uri.parse('$_base/api/ResenaCliente/PorProfesional/$idProfesional'),
      headers: _headers(token),
    );
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => ResenaCliente.fromJson(j as Map<String, dynamic>)).toList();
  }
}
