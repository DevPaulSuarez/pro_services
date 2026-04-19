import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pro_services/config.dart';
import 'package:pro_services/main.dart';

class SolicitarVerificacionScreen extends StatefulWidget {
  final String token;

  const SolicitarVerificacionScreen({super.key, required this.token});

  @override
  State<SolicitarVerificacionScreen> createState() =>
      _SolicitarVerificacionScreenState();
}

class _SolicitarVerificacionScreenState
    extends State<SolicitarVerificacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identidadCtrl = TextEditingController();
  final _tituloCtrl = TextEditingController();

  bool _enviando = false;

  @override
  void dispose() {
    _identidadCtrl.dispose();
    _tituloCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final res = await http.post(
        Uri.parse(
            '${AppConfig.apiBase}/profesionales/me/solicitar-verificacion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'documentoIdentidadUrl': _identidadCtrl.text.trim(),
          if (_tituloCtrl.text.trim().isNotEmpty)
            'tituloUrl': _tituloCtrl.text.trim(),
        }),
      );
      if (!mounted) return;
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documentos enviados correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Solicitar verificación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Niveles de verificación ──────────────────────────────────
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveles de verificación',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _NivelItem(
                      icon: Icons.phone_android_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      nivel: 'Nivel 1',
                      descripcion: 'Teléfono verificado',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 12),
                    _NivelItem(
                      icon: Icons.verified_user_rounded,
                      iconColor: const Color(0xFF10B981),
                      nivel: 'Nivel 2',
                      descripcion: 'Identidad verificada (DNI/Pasaporte)',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 12),
                    _NivelItem(
                      icon: Icons.workspace_premium_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      nivel: 'Nivel 3',
                      descripcion: 'Título profesional verificado',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Documentos ───────────────────────────────────────────────
              Text(
                'Documentos',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  children: [
                    _UrlField(
                      ctrl: _identidadCtrl,
                      label: 'URL del documento de identidad',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      requerido: true,
                    ),
                    const SizedBox(height: 14),
                    _UrlField(
                      ctrl: _tituloCtrl,
                      label: 'URL del título profesional',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      requerido: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Nota informativa ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: Color(0xFF6366F1)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tus documentos serán revisados en 24-48hs. '
                        'Recibirás una notificación cuando el proceso finalice.',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Botón enviar ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _enviando ? null : _enviar,
                  icon: _enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    _enviando ? 'Enviando...' : 'Enviar documentos',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
      {required bool isDark,
      required Color cardBg,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _NivelItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String nivel;
  final String descripcion;
  final Color textPrimary;
  final Color textSecondary;

  const _NivelItem({
    required this.icon,
    required this.iconColor,
    required this.nivel,
    required this.descripcion,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nivel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
            Text(
              descripcion,
              style: TextStyle(fontSize: 13, color: textPrimary),
            ),
          ],
        ),
      ],
    );
  }
}

class _UrlField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final bool requerido;

  const _UrlField({
    required this.ctrl,
    required this.label,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.requerido,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.url,
      style: TextStyle(fontSize: 13, color: textPrimary),
      validator: requerido
          ? (v) {
              if (v == null || v.trim().isEmpty) return 'Campo requerido';
              if (!v.trim().startsWith('http')) return 'Debe ser una URL válida';
              return null;
            }
          : (v) {
              if (v != null &&
                  v.trim().isNotEmpty &&
                  !v.trim().startsWith('http')) {
                return 'Debe ser una URL válida';
              }
              return null;
            },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: textSecondary),
        hintText: 'https://...',
        hintStyle: TextStyle(fontSize: 13, color: textSecondary.withValues(alpha: 0.6)),
        prefixIcon: const Icon(Icons.link_rounded,
            size: 18, color: Color(0xFF6366F1)),
        suffixText: requerido ? null : 'Opcional',
        suffixStyle: TextStyle(fontSize: 11, color: textSecondary),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}
