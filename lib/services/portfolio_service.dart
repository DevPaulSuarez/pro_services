import 'package:pro_services/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_services/models/portfolio_item.dart';

class PortfolioService {
  static const _base = AppConfig.apiBase;

  static Future<List<PortfolioItem>> getPortfolio(
      String token, int profesionalId) async {
    final res = await http.get(
      Uri.parse('$_base/profesionales/$profesionalId/portfolio'),
      headers: _headers(token),
    );
    AppConfig.checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body) as List;
    return data
        .map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
