import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/proyecto.dart';
import 'package:pro_services/screens/professional/perfil_cliente_screen.dart';
import 'package:pro_services/services/proyecto_service.dart';

class SolicitudesEntrantesScreen extends StatefulWidget {
  final String token;
  const SolicitudesEntrantesScreen({super.key, required this.token});

  @override
  State<SolicitudesEntrantesScreen> createState() =>
      _SolicitudesEntrantesScreenState();
}

class _SolicitudesEntrantesScreenState
    extends State<SolicitudesEntrantesScreen> {
  late Future<List<Proyecto>> _future;
  final Map<int, bool> _accionando = {};

  @override
  void initState() {
    super.initState();
    _future = ProyectoService.getProyectos(widget.token, estado: 'Pendiente');
  }

  void _reload() => setState(() {
        _future =
            ProyectoService.getProyectos(widget.token, estado: 'Pendiente');
      });

  Future<void> _aceptar(Proyecto proyecto) async {
    setState(() => _accionando[proyecto.id] = true);
    try {
      await ProyectoService.aceptar(widget.token, proyecto.id);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud aceptada'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _accionando.remove(proyecto.id));
    }
  }

  Future<void> _rechazar(Proyecto proyecto) async {
    setState(() => _accionando[proyecto.id] = true);
    try {
      await ProyectoService.rechazar(widget.token, proyecto.id);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud rechazada'),
          backgroundColor: Color(0xFF64748B),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _accionando.remove(proyecto.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;

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
          'Solicitudes entrantes',
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
      body: FutureBuilder<List<Proyecto>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              mensaje: snap.error.toString(),
              onReintentar: _reload,
            );
          }
          final proyectos = snap.data!;
          if (proyectos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 56, color: textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'No tenés solicitudes pendientes',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: proyectos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final proyecto = proyectos[i];
              return _SolicitudCard(
                proyecto: proyecto,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accionando: _accionando[proyecto.id] ?? false,
                onAceptar: () => _aceptar(proyecto),
                onRechazar: () => _rechazar(proyecto),
                token: widget.token,
              );
            },
          );
        },
      ),
    );
  }
}

// ── Tarjeta de solicitud ──────────────────────────────────────────────────────

class _SolicitudCard extends StatelessWidget {
  final Proyecto proyecto;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final bool accionando;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;
  final String token;

  const _SolicitudCard({
    required this.proyecto,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.accionando,
    required this.onAceptar,
    required this.onRechazar,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + nombre + servicio
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    const Color(0xFF6366F1).withValues(alpha: 0.15),
                child: Text(
                  proyecto.cliente.isNotEmpty
                      ? proyecto.cliente[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PerfilClienteScreen(
                            token: token,
                            idCliente: proyecto.idUsuario,
                          ),
                        ),
                      ),
                      child: Text(
                        proyecto.cliente,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      proyecto.servicio,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Descripción
          Text(
            proyecto.descripcion,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Ubicación + presupuesto
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  proyecto.ubicacion,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.attach_money_rounded,
                  size: 14, color: Color(0xFF10B981)),
              Text(
                '\$${proyecto.presupuesto.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Fecha
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13, color: textSecondary),
              const SizedBox(width: 4),
              Text(
                proyecto.fecha,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Botones Rechazar / Aceptar
          accionando
              ? const Center(
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: onRechazar,
                        child: const Text(
                          'Rechazar',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: onAceptar,
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _ErrorView({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
