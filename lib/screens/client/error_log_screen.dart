import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pro_services/config.dart';
import 'package:pro_services/main.dart';

class ErrorLogScreen extends StatefulWidget {
  final String token;
  const ErrorLogScreen({super.key, required this.token});

  @override
  State<ErrorLogScreen> createState() => _ErrorLogScreenState();
}

class _ErrorLogScreenState extends State<ErrorLogScreen> {
  late Future<List<dynamic>> _errorsFuture;

  @override
  void initState() {
    super.initState();
    _errorsFuture = _getRecientes(widget.token);
  }

  static Future<List<dynamic>> _getRecientes(String token) async {
    final res = await http.get(
      Uri.parse('${AppConfig.apiBase}/api/error-log/recientes?cantidad=50'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode >= 300) throw Exception('Error ${res.statusCode}');
    return jsonDecode(res.body) as List;
  }

  void _reload() {
    setState(() {
      _errorsFuture = _getRecientes(widget.token);
    });
  }

  Color _badgeColor(String level) {
    switch (level.toLowerCase()) {
      case 'fatal':
        return const Color(0xFF991B1B);
      case 'error':
        return const Color(0xFFDC2626);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'info':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Error Log',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            onPressed: _reload,
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark
                  ? const Color(0xFFFBBF24)
                  : const Color(0xFF6366F1),
            ),
            onPressed: () => MyApp.of(context).toggleTheme(),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _errorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar logs',
                    style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final errors = snapshot.data!;

          if (errors.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 56,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Sin errores recientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: errors.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final err = errors[index] as Map<String, dynamic>;
              final level = (err['level'] ?? 'Error') as String;
              final message = (err['error'] ?? '') as String;
              final screen = (err['screen'] ?? '-') as String;
              final timestamp = (err['fechaCreacion'] ?? err['timestamp'] ?? '') as String;
              final cardColor =
                  isDark ? const Color(0xFF1E293B) : Colors.white;
              final textPrimary =
                  isDark ? Colors.white : const Color(0xFF0F172A);
              final textSecondary =
                  isDark ? Colors.grey.shade400 : Colors.grey.shade600;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _badgeColor(level),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            level.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Screen: $screen',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (timestamp.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        timestamp,
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
