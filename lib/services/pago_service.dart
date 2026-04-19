import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/pago.dart';

class PagoService {
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

  /// POST /pagos/iniciar — crea un pago capturando el cargo con Culqi.
  static Future<Pago> iniciarPago(
    String token, {
    required int idProfesional,
    required double monto,
    required String tokenCulqi,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/pagos/iniciar'),
      headers: _headers(token),
      body: jsonEncode({
        'idProfesional': idProfesional,
        'monto': monto,
        'moneda': 'PEN',
        'tokenCulqi': tokenCulqi,
      }),
    );
    AppConfig.checkStatus(res);
    return Pago.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// POST /pagos/{id}/liberar — libera el pago al profesional.
  static Future<void> liberarPago(String token, int idPago) async {
    final res = await http.post(
      Uri.parse('$_base/pagos/$idPago/liberar'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }

  /// POST /pagos/{id}/reembolsar — reembolsa el pago al cliente.
  static Future<void> reembolsarPago(String token, int idPago) async {
    final res = await http.post(
      Uri.parse('$_base/pagos/$idPago/reembolsar'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
  }

  /// GET /pagos/mis — lista los pagos realizados por el cliente autenticado.
  static Future<List<Pago>> getMisPagos(String token) async {
    final res = await http.get(
      Uri.parse('$_base/pagos/mis'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Pago.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /pagos/mis-cobros — lista los cobros recibidos por el profesional autenticado.
  static Future<List<Pago>> getMisCobros(String token) async {
    final res = await http.get(
      Uri.parse('$_base/pagos/mis-cobros'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Pago.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
