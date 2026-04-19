import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/venta.dart';

class VentaService {
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

  static Future<List<Venta>> getMisVentas(String token) async {
    final res = await http.get(
      Uri.parse('$_base/api/HistorialVentas/me'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Venta.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<List<Venta>> getMisCobros(String token) async {
    final res = await http.get(
      Uri.parse('$_base/api/HistorialVentas/mis-cobros'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Venta.fromJson(j as Map<String, dynamic>)).toList();
  }
}
