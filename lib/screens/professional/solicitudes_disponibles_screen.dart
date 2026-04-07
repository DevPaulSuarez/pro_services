import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/solicitud_abierta.dart';
import 'package:pro_services/services/solicitud_abierta_service.dart';

class SolicitudesDisponiblesScreen extends StatefulWidget {
  final String token;
  const SolicitudesDisponiblesScreen({super.key, required this.token});

  @override
  State<SolicitudesDisponiblesScreen> createState() =>
      _SolicitudesDisponiblesScreenState();
}

class _SolicitudesDisponiblesScreenState
    extends State<SolicitudesDisponiblesScreen> {
  late Future<List<SolicitudAbierta>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = SolicitudAbiertaService.getDisponibles(widget.token);
  }

  void _reload() => setState(
      () => _futuro = SolicitudAbiertaService.getDisponibles(widget.token));

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
          'Solicitudes disponibles',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A)),
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
      body: FutureBuilder<List<SolicitudAbierta>>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              mensaje: snap.error.toString(),
              onRetry: _reload,
              textSecondary: textSecondary,
            );
          }
          final lista = snap.data!;
          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 52, color: textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'No hay solicitudes disponibles',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Volvé más tarde',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = lista[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Título + badge urgente ──────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            s.titulo,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        if (s.esUrgente) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'URGENTE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // ── Categoría ───────────────────────────────────────────
                    if (s.nombreTipoProfesion != null)
                      Text(
                        s.nombreTipoProfesion!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // ── Descripción (max 2 líneas) ───────────────────────────
                    Text(
                      s.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 10),

                    // ── Metadata ────────────────────────────────────────────
                    Row(
                      children: [
                        if (s.presupuestoMax != null) ...[
                          const Icon(Icons.attach_money_rounded,
                              size: 14, color: Color(0xFF22C55E)),
                          Text(
                            'Hasta \$${s.presupuestoMax!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (s.fechaLimite != null) ...[
                          Icon(Icons.event_rounded,
                              size: 13, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(s.fechaLimite!,
                              style: TextStyle(
                                  fontSize: 12, color: textSecondary)),
                        ],
                        const Spacer(),
                        if (s.nombreUsuario != null)
                          Row(
                            children: [
                              Icon(Icons.person_rounded,
                                  size: 13, color: textSecondary),
                              const SizedBox(width: 4),
                              Text(s.nombreUsuario!,
                                  style: TextStyle(
                                      fontSize: 12, color: textSecondary)),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Botón cotizar ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text('Cotizar',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Funcionalidad disponible próximamente'),
                              backgroundColor: Color(0xFF6366F1),
                            ),
                          );
                        },
                      ),
                    ),
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

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;
  final Color textSecondary;
  const _ErrorView(
      {required this.mensaje,
      required this.onRetry,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('Error al cargar',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textSecondary)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(mensaje,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
}
