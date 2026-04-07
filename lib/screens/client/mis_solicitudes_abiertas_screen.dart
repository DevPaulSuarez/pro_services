import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/solicitud_abierta.dart';
import 'package:pro_services/services/solicitud_abierta_service.dart';

class MisSolicitudesAbiertasScreen extends StatefulWidget {
  final String token;
  const MisSolicitudesAbiertasScreen({super.key, required this.token});

  @override
  State<MisSolicitudesAbiertasScreen> createState() =>
      _MisSolicitudesAbiertasScreenState();
}

class _MisSolicitudesAbiertasScreenState
    extends State<MisSolicitudesAbiertasScreen> {
  String _filtro = 'Todas';
  late Future<List<SolicitudAbierta>> _futuro;

  static const _filtros = [
    ('Todas', ''),
    ('Abiertas', 'abierta'),
    ('En revisión', 'en_revision'),
    ('Cerradas', 'cerrada'),
  ];

  @override
  void initState() {
    super.initState();
    _futuro = SolicitudAbiertaService.getMis(widget.token);
  }

  void _reload() =>
      setState(() => _futuro = SolicitudAbiertaService.getMis(widget.token));

  List<SolicitudAbierta> _filtrar(List<SolicitudAbierta> lista) {
    if (_filtro == 'Todas') return lista;
    final match = _filtros.firstWhere((f) => f.$1 == _filtro).$2;
    return lista.where((s) => s.estadoSolicitud == match).toList();
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'abierta':
        return const Color(0xFF10B981);
      case 'en_revision':
        return const Color(0xFFF59E0B);
      case 'cerrada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case 'abierta':
        return 'Abierta';
      case 'en_revision':
        return 'En revisión';
      case 'cerrada':
        return 'Cerrada';
      default:
        return estado;
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'abierta':
        return Icons.radio_button_checked_rounded;
      case 'en_revision':
        return Icons.hourglass_top_rounded;
      case 'cerrada':
        return Icons.lock_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  Future<void> _cerrarSolicitud(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar solicitud'),
        content: const Text(
          '¿Estás seguro de que querés cerrar esta solicitud? No podrá reabrirse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await SolicitudAbiertaService.cerrar(widget.token, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud cerrada'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mis publicaciones',
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
      body: Column(
        children: [
          // ── Filtros ────────────────────────────────────────────────────────
          Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filtros.map((f) {
                  final activo = _filtro == f.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filtro = f.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: activo
                              ? const Color(0xFF6366F1)
                              : (isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          f.$1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: activo ? Colors.white : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Contenido ──────────────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<SolicitudAbierta>>(
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
                final lista = _filtrar(snap.data!);
                if (lista.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 52,
                          color: textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sin publicaciones en esta categoría',
                          style: TextStyle(fontSize: 14, color: textSecondary),
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
                    final color = _estadoColor(s.estadoSolicitud);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.06,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Fila título + estado ──────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
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
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFEF4444,
                                              ).withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                    const SizedBox(height: 4),
                                    if (s.nombreTipoProfesion != null)
                                      Text(
                                        s.nombreTipoProfesion!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Badge estado
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _estadoIcon(s.estadoSolicitud),
                                      size: 11,
                                      color: color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _estadoLabel(s.estadoSolicitud),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // ── Metadata: presupuesto + fecha ─────────────────
                          Row(
                            children: [
                              if (s.presupuestoMax != null) ...[
                                Icon(
                                  Icons.attach_money_rounded,
                                  size: 14,
                                  color: const Color(0xFF22C55E),
                                ),
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
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                s.fecha,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                              if (s.fechaLimite != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '·',
                                  style: TextStyle(color: textSecondary),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.event_rounded,
                                  size: 13,
                                  color: textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Límite: ${s.fechaLimite!}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // ── Botón cerrar (solo si está abierta) ───────────
                          if (s.estadoSolicitud == 'abierta') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                  side: const BorderSide(
                                    color: Color(0xFFEF4444),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.lock_rounded, size: 14),
                                label: const Text(
                                  'Cerrar solicitud',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: () => _cerrarSolicitud(s.id),
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
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;
  final Color textSecondary;
  const _ErrorView({
    required this.mensaje,
    required this.onRetry,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 12),
        Text(
          'Error al cargar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            mensaje,
            style: TextStyle(fontSize: 12, color: textSecondary),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
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
