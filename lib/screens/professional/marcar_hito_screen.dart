import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/hito_servicio.dart';
import 'package:pro_services/services/hito_service.dart';

class MarcarHitoScreen extends StatefulWidget {
  final String token;
  final int proyectoId;
  final String usuarioEmail;

  const MarcarHitoScreen({
    super.key,
    required this.token,
    required this.proyectoId,
    required this.usuarioEmail,
  });

  @override
  State<MarcarHitoScreen> createState() => _MarcarHitoScreenState();
}

class _MarcarHitoScreenState extends State<MarcarHitoScreen> {
  late Future<List<HitoServicio>> _hitosFuture;
  bool _guardando = false;

  static const _hitosConfig = [
    _HitoConfig(
      key:    'en_camino',
      label:  'En camino',
      icono:  Icons.directions_run_rounded,
    ),
    _HitoConfig(
      key:    'llegue',
      label:  'Llegué',
      icono:  Icons.location_on_rounded,
    ),
    _HitoConfig(
      key:    'trabajando',
      label:  'Trabajando',
      icono:  Icons.construction_rounded,
    ),
    _HitoConfig(
      key:    'listo_revision',
      label:  'Listo para revisión',
      icono:  Icons.task_alt_rounded,
    ),
    _HitoConfig(
      key:    'completado',
      label:  'Completado',
      icono:  Icons.check_circle_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _hitosFuture = HitoService.getHitos(widget.token, widget.proyectoId);
  }

  Future<void> _confirmarHito(
      BuildContext ctx, String hitoKey, String hitoLabel) async {
    final descripcionCtrl = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Marcar: $hitoLabel',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Confirmás este estado del servicio?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descripcionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Descripción opcional...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _guardando = true);
    try {
      await HitoService.marcarHito(
        widget.token,
        widget.proyectoId,
        hito:             hitoKey,
        descripcion:      descripcionCtrl.text.trim().isEmpty
            ? null
            : descripcionCtrl.text.trim(),
        usuarioCreacion:  widget.usuarioEmail,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hito "$hitoLabel" registrado'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      setState(_load);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar hito: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final bgColor       = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg        = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

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
          'Estado del servicio',
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
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
            ),
            onPressed: () => MyApp.of(context).toggleTheme(),
          ),
        ],
      ),
      body: FutureBuilder<List<HitoServicio>>(
        future: _hitosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _guardando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: 'Error al cargar hitos: ${snapshot.error}',
              onRetry: () => setState(_load),
            );
          }

          final hitos      = snapshot.data ?? [];
          final completados = {for (final h in hitos) h.hito};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Encabezado ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.3 : 0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.engineering_rounded,
                            color: Color(0xFF6366F1), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proyecto #${widget.proyectoId.toString().padLeft(4, '0')}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${completados.length} de ${_hitosConfig.length} hitos completados',
                              style: TextStyle(
                                  fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Instrucción ────────────────────────────────────────
                Text(
                  'Tocá un botón para actualizar el estado del servicio',
                  style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),

                // ── Botones de hitos ───────────────────────────────────
                ...List.generate(_hitosConfig.length, (i) {
                  final cfg      = _hitosConfig[i];
                  final isDone   = completados.contains(cfg.key);
                  final hito     = isDone
                      ? hitos.firstWhere((h) => h.hito == cfg.key)
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HitoButton(
                      config:        cfg,
                      isDone:        isDone,
                      isDark:        isDark,
                      cardBg:        cardBg,
                      textPrimary:   textPrimary,
                      textSecondary: textSecondary,
                      fechaHito:     hito?.fechaHito,
                      onTap: isDone
                          ? null
                          : () => _confirmarHito(context, cfg.key, cfg.label),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Botón de hito individual ───────────────────────────────────────────────────

class _HitoConfig {
  final String key;
  final String label;
  final IconData icono;
  const _HitoConfig({
    required this.key,
    required this.label,
    required this.icono,
  });
}

class _HitoButton extends StatelessWidget {
  final _HitoConfig config;
  final bool isDone;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final String? fechaHito;
  final VoidCallback? onTap;

  const _HitoButton({
    required this.config,
    required this.isDone,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    this.fechaHito,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF6366F1);
    final greyColor   = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final bgColor     = isDone
        ? accentColor.withValues(alpha: 0.1)
        : greyColor.withValues(alpha: 0.3);
    final borderColor = isDone ? accentColor : greyColor;
    final labelColor  = isDone ? accentColor : textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: onTap != null ? cardBg : bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isDone ? 1.5 : 1),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone
                    ? accentColor
                    : greyColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(config.icono, size: 22,
                  color: isDone ? Colors.white : textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                  if (isDone && fechaHito != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      fechaHito!,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600),
                    ),
                  ] else if (onTap != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Tocar para marcar',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (isDone)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 22)
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: textSecondary, size: 22)
            else
              Icon(Icons.lock_outline_rounded,
                  color: greyColor, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
