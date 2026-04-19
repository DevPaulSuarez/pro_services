import 'package:pro_services/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UbicacionService {
  static const _base = AppConfig.apiBase;

  /// Actualiza la ubicación del profesional autenticado
  static Future<void> actualizarUbicacion(
    String token, {
    required double latitud,
    required double longitud,
    int radioCobertura = 10,
  }) async {
    final res = await http.patch(
      Uri.parse('$_base/profesionales/me/ubicacion'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'latitud': latitud,
        'longitud': longitud,
        'radioCobertura': radioCobertura,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Calcula distancia entre dos coordenadas (Haversine, en km)
  static double calcularDistanciaKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dlat = (lat2 - lat1) * 3.141592653589793 / 180;
    final dlon = (lon2 - lon1) * 3.141592653589793 / 180;
    final a = _sin2(dlat / 2) + _cos(lat1) * _cos(lat2) * _sin2(dlon / 2);
    return r * 2 * _asin(_sqrt(a));
  }

  static double _sin2(double x) => _sin(x) * _sin(x);
  static double _sin(double x) => x - x * x * x / 6 + x * x * x * x * x / 120;
  static double _cos(double x) => 1 - x * x / 2 + x * x * x * x / 24;
  static double _asin(double x) => x + x * x * x / 6 + 3 * x * x * x * x * x / 40;
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double r = x;
    for (int i = 0; i < 10; i++) { r = (r + x / r) / 2; }
    return r;
  }
}
