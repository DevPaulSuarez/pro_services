import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/perfil_cliente_publico.dart';

class PerfilClienteService {
  static const _base = AppConfig.apiBase;

  static Future<PerfilClientePublico> getPerfil(
      String token, int idCliente) async {
    final res = await http.get(
      Uri.parse('$_base/clientes/$idCliente/perfil-publico'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    return PerfilClientePublico.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
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
