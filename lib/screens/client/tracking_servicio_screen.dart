import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/hito_servicio.dart';
import 'package:pro_services/services/hito_service.dart';

class TrackingServicioScreen extends StatefulWidget {
  final String token;
  final int proyectoId;
  final String nombreProfesional;

  const TrackingServicioScreen({
    super.key,
    required this.token,
    required this.proyectoId,
    required this.nombreProfesional,
  });

  @override
  State<TrackingServicioScreen> createState() => _TrackingServicioScreenState();
}

class _TrackingServicioScreenState extends State<TrackingServicioScreen> {
  late Future<List<HitoServicio>> _hitosFuture;

  static const _ordenHitos = [
    'en_camino',
    'llegue',
    'trabajando',
    'listo_revision',
    'completado',
  ];

  static const _labels = {
    'en_camino':      'Profesional en camino',
    'llegue':         'Profesional llegó',
    'trabajando':     'Trabajando',
    'listo_revision': 'Listo para revisión',
    'completado':     'Completado',
  };

  static const _iconos = {
    'en_camino':      Icons.directions_run_rounded,
    'llegue':         Icons.location_on_rounded,
    'trabajando':     Icons.construction_rounded,
    'listo_revision': Icons.task_alt_rounded,
    'completado':     Icons.check_circle_rounded,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _hitosFuture = HitoService.getHitos(widget.token, widget.proyectoId);
  }

  void _reload() => setState(_load);

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
          'Seguimiento del servicio',
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: 'Error al cargar el tracking: ${snapshot.error}',
              onRetry: _reload,
            );
          }

          final hitos = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cabecera del profesional ────────────────────────────
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
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              const Color(0xFF6366F1).withValues(alpha: 0.15),
                          child: Icon(Icons.person_rounded,
                              color: const Color(0xFF6366F1), size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.nombreProfesional,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Proyecto #${widget.proyectoId.toString().padLeft(4, '0')}',
                                style: TextStyle(
                                    fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'En progreso',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Timeline ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado del servicio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (hitos.isEmpty)
                          _EmptyTracking(
                              textSecondary: textSecondary)
                        else
                          _TimelineHitos(
                            hitos: hitos,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            ordenHitos: _ordenHitos,
                            labels: _labels,
                            iconos: _iconos,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Botón actualizar ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Actualizar',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Timeline de hitos ──────────────────────────────────────────────────────────

class _TimelineHitos extends StatelessWidget {
  final List<HitoServicio> hitos;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final List<String> ordenHitos;
  final Map<String, String> labels;
  final Map<String, IconData> iconos;

  const _TimelineHitos({
    required this.hitos,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.ordenHitos,
    required this.labels,
    required this.iconos,
  });

  @override
  Widget build(BuildContext context) {
    final completados = {for (final h in hitos) h.hito: h};

    return Column(
      children: List.generate(ordenHitos.length, (i) {
        final key        = ordenHitos[i];
        final isLast     = i == ordenHitos.length - 1;
        final hitoDone   = completados[key];
        final isDone     = hitoDone != null;
        final isNext     = !isDone &&
            (i == 0 || completados.containsKey(ordenHitos[i - 1]));

        const accentColor = Color(0xFF6366F1);
        final greyColor   = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        final dotColor    = isDone ? accentColor : greyColor;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Línea + punto ──────────────────────────────────────
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: dotColor.withValues(
                            alpha: isDone ? 1.0 : 0.2),
                        shape: BoxShape.circle,
                        border: isNext
                            ? Border.all(
                                color: greyColor,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              )
                            : null,
                      ),
                      child: Icon(
                        iconos[key] ?? Icons.circle,
                        size: 18,
                        color: isDone
                            ? Colors.white
                            : (isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isDone ? accentColor : greyColor,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // ── Contenido ──────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 7),
                      Text(
                        labels[key] ?? key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDone ? textPrimary : textSecondary,
                        ),
                      ),
                      if (isDone) ...[
                        const SizedBox(height: 3),
                        Text(
                          hitoDone.fechaHito,
                          style: TextStyle(
                              fontSize: 11, color: accentColor),
                        ),
                        if (hitoDone.descripcion != null &&
                            hitoDone.descripcion!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            hitoDone.descripcion!,
                            style: TextStyle(
                                fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ] else if (isNext) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Pendiente',
                          style: TextStyle(
                              fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Estado vacío ───────────────────────────────────────────────────────────────

class _EmptyTracking extends StatelessWidget {
  final Color textSecondary;
  const _EmptyTracking({required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.location_searching_rounded,
                size: 48, color: textSecondary),
            const SizedBox(height: 12),
            Text(
              'El profesional aún no ha iniciado el servicio',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
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
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFFEF4444))),
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
