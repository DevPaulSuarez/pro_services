import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/mensaje.dart';

class MensajeService {
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

  static Future<List<Mensaje>> getMensajes(String token, int proyectoId) async {
    final res = await http.get(
      Uri.parse('$_base/api/proyecto/$proyectoId/mensaje'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Mensaje.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<Mensaje> enviar(String token, int proyectoId, String mensaje) async {
    final res = await http.post(
      Uri.parse('$_base/api/proyecto/$proyectoId/mensaje'),
      headers: _headers(token),
      body: jsonEncode({'mensaje': mensaje}),
    );
    AppConfig.checkStatus(res);
    // El backend devuelve { id: N } al crear; necesitamos recargar
    return Mensaje(
      id: (jsonDecode(res.body)['id'] as int?) ?? 0,
      idProyecto: proyectoId,
      idEmisor: 0,
      tipoEmisor: '',
      mensaje: mensaje,
      esLeido: false,
      fecha: '',
    );
  }
}
