import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/cotizacion.dart';
import 'package:pro_services/models/foto_proyecto.dart';
import 'package:pro_services/models/solicitud_cliente.dart';
import 'package:pro_services/screens/client/chat_proyecto_screen.dart';
import 'package:pro_services/screens/client/comparar_cotizaciones_screen.dart';
import 'package:pro_services/screens/client/crear_disputa_screen.dart';
import 'package:pro_services/screens/client/crear_resena_screen.dart';
import 'package:pro_services/screens/client/pago_screen.dart';
import 'package:pro_services/screens/client/tracking_servicio_screen.dart';
import 'package:pro_services/services/cotizacion_service.dart';
import 'package:pro_services/services/foto_proyecto_service.dart';
import 'package:pro_services/services/pago_service.dart';
import 'package:pro_services/services/proyecto_service.dart';

class DetalleSolicitudScreen extends StatefulWidget {
  final String token;
  final SolicitudCliente solicitud;
  final int? idUsuario;
  final int? idProfesional;

  const DetalleSolicitudScreen({
    super.key,
    required this.token,
    required this.solicitud,
    this.idUsuario,
    this.idProfesional,
  });

  @override
  State<DetalleSolicitudScreen> createState() =>
      _DetalleSolicitudScreenState();
}

class _DetalleSolicitudScreenState extends State<DetalleSolicitudScreen> {
  Future<List<Cotizacion>>? _cotizacionesFuture;
  bool _liberandoPago = false;

  @override
  void initState() {
    super.initState();
    if (widget.idUsuario != null) {
      _cotizacionesFuture = CotizacionService.getPorUsuario(
          widget.token, widget.idUsuario!);
    }
  }

  void _reload() {
    if (widget.idUsuario != null) {
      setState(() {
        _cotizacionesFuture = CotizacionService.getPorUsuario(
            widget.token, widget.idUsuario!);
      });
    }
  }

  Future<void> _irAPantallaPago() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          token: widget.token,
          idProfesional: widget.idProfesional ?? 0,
          monto: widget.solicitud.presupuesto,
          nombreProfesional: widget.solicitud.profesional,
        ),
      ),
    );
    if (resultado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago procesado exitosamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _liberarPago() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Liberar pago'),
        content: const Text(
          '¿Confirmás la liberación del pago al profesional? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Liberar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _liberandoPago = true);
    try {
      // Buscamos el id del pago asociado a esta solicitud usando el idProfesional
      final pagos = await PagoService.getMisPagos(widget.token);
      final pagoAsociado = pagos.where(
        (p) =>
            p.idProfesional == (widget.idProfesional ?? 0) &&
            p.estadoPago == 'capturado',
      );
      if (pagoAsociado.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró un pago capturado para liberar'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
      await PagoService.liberarPago(widget.token, pagoAsociado.first.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago liberado al profesional exitosamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al liberar el pago: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _liberandoPago = false);
    }
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFF59E0B);
      case 'aceptado':
        return const Color(0xFF3B82F6);
      case 'completado':
        return const Color(0xFF22C55E);
      case 'rechazado':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'aceptado':
        return 'En progreso';
      case 'completado':
        return 'Completado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final bgColor       = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg        = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final s             = widget.solicitud;
    final estadoColor   = _estadoColor(s.estado);

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
          'Detalle de solicitud',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sección 1 — Header card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de estado
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _estadoLabel(s.estado),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: estadoColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    s.servicio,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  if (s.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      s.descripcion,
                      style: TextStyle(
                          fontSize: 13, color: textSecondary, height: 1.5),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_rounded, size: 14, color: textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        s.profesional,
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_money_rounded,
                          size: 16, color: const Color(0xFF22C55E)),
                      Text(
                        '\$${s.presupuesto.toStringAsFixed(0)} presupuesto',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                  if (s.fecha.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13, color: textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          s.fecha,
                          style:
                              TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Sección 2 — Timeline visual ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado del proceso',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _TimelineRow(
                    estado: s.estado,
                    isDark: isDark,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Sección 3 — Cotización ────────────────────────────────────
            if (widget.idUsuario != null && _cotizacionesFuture != null) ...[
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
                      'Cotización del profesional',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Cotizacion>>(
                      future: _cotizacionesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('Sin cotización aún',
                              style: TextStyle(
                                  fontSize: 12, color: textSecondary));
                        }
                        final todas = snapshot.data ?? [];
                        // Filtramos cotizaciones relacionadas al profesional de esta solicitud
                        final cotizaciones = widget.idProfesional != null
                            ? todas
                                .where((c) =>
                                    c.idProfesional == widget.idProfesional)
                                .toList()
                            : todas;
                        if (cotizaciones.isEmpty) {
                          return Text('Sin cotización aún',
                              style: TextStyle(
                                  fontSize: 12, color: textSecondary));
                        }
                        final cot = cotizaciones.first;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CotizacionCard(
                              cotizacion: cot,
                              token: widget.token,
                              isDark: isDark,
                              cardBg: cardBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onReload: _reload,
                              solicitud: widget.solicitud,
                            ),
                            // Comparar cotizaciones (si hay 2 o más)
                            if (cotizaciones.length >= 2) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.compare_rounded),
                                label: const Text('Comparar cotizaciones'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CompararCotizacionesScreen(
                                        cotizaciones: cotizaciones,
                                        token: widget.token,
                                      ),
                                    ),
                                  ).then((resultado) {
                                    if (resultado == true) _reload();
                                  });
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Sección 3.5 — Fotos del trabajo (read-only, solo aceptado/completado) ──
            if (s.estado == 'aceptado' || s.estado == 'completado') ...[
              _FotosTrabajoSection(
                token: widget.token,
                proyectoId: s.id,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
            ],

            // ── Sección 4 — Acciones ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Procesar pago + Ver tracking (solo si está en progreso / aceptado)
                if (s.estado == 'aceptado') ...[
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Text('💳',
                          style: TextStyle(fontSize: 16)),
                      label: const Text('Procesar pago',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _irAPantallaPago,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.gps_fixed_rounded, size: 18),
                      label: const Text('Ver tracking',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackingServicioScreen(
                            token:              widget.token,
                            proyectoId:         s.id,
                            nombreProfesional:  s.profesional,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                // Liberar pago (solo si completado)
                if (s.estado == 'completado') ...[
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Text('✅',
                          style: TextStyle(fontSize: 16)),
                      label: _liberandoPago
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Liberar pago',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _liberandoPago ? null : _liberarPago,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                // Reseña (solo si completado)
                if (s.estado == 'completado') ...[
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.star_rounded),
                      label: const Text('Dejar reseña',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CrearResenaScreen(
                            token: widget.token,
                            idProfesional: widget.idProfesional ?? 0,
                            nombreProfesional: s.profesional,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Re-contratar
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Re-contratar'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Re-contratar'),
                          content: const Text(
                              '¿Querés re-contratar a este profesional?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Confirmar'),
                            ),
                          ],
                        ),
                      );
                      if (confirmar != true) return;
                      try {
                        await ProyectoService.reContratar(
                            widget.token, s.id);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Re-contratación creada exitosamente')),
                        );
                        nav.pop(true);
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                // Chat con el profesional
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Chat'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatProyectoScreen(
                          token: widget.token,
                          proyectoId: s.id,
                          nombreProfesional: s.profesional,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Reportar problema
                TextButton.icon(
                  icon: const Icon(Icons.flag_rounded, color: Colors.orange),
                  label: const Text('Reportar problema',
                      style: TextStyle(color: Colors.orange)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CrearDisputaScreen(
                          token: widget.token,
                          proyectoId: s.id,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fotos del trabajo (cliente read-only) ─────────────────────────────────────

class _FotosTrabajoSection extends StatelessWidget {
  final String token;
  final int proyectoId;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const _FotosTrabajoSection({
    required this.token,
    required this.proyectoId,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FotoProyecto>>(
      future: FotoProyectoService.getFotos(token, proyectoId),
      builder: (context, snapshot) {
        // Si está cargando: no mostramos nada (evita flash de layout)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        // Si hay error o lista vacía: no mostramos la sección
        if (snapshot.hasError) return const SizedBox.shrink();
        final fotos = snapshot.data ?? [];
        if (fotos.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(18),
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
              Row(
                children: [
                  const Icon(
                    Icons.photo_library_rounded,
                    size: 16,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fotos del trabajo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${fotos.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length,
                  itemBuilder: (context, index) {
                    final foto = fotos[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < fotos.length - 1 ? 10 : 0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          foto.url,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (_, _, _) => Container(
                            width: 80,
                            height: 80,
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 28,
                              color: textSecondary,
                            ),
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            );
                          },
                        ),
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
  }
}

// ── Timeline ───────────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final String estado;
  final bool isDark;
  final Color textSecondary;

  const _TimelineRow({
    required this.estado,
    required this.isDark,
    required this.textSecondary,
  });

  static const _steps = ['pendiente', 'aceptado', 'en progreso', 'completado'];
  static const _labels = ['Pendiente', 'Aceptado', 'En progreso', 'Completado'];

  int get _currentIndex {
    final lower = estado.toLowerCase();
    if (lower == 'rechazado') return -1;
    final idx = _steps.indexOf(lower);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final ci = _currentIndex;
    const accent = Color(0xFF6366F1);
    final grey = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Row(
      children: List.generate(_steps.length, (i) {
        final isActive = ci >= 0 && i <= ci;
        final isLast = i == _steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? accent : grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive ? Icons.check_rounded : Icons.circle_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive ? accent : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  height: 2,
                  width: 12,
                  color: isActive && ci > i ? accent : grey,
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Cotización Card ────────────────────────────────────────────────────────────

class _CotizacionCard extends StatefulWidget {
  final Cotizacion cotizacion;
  final String token;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onReload;
  final SolicitudCliente solicitud;

  const _CotizacionCard({
    required this.cotizacion,
    required this.token,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.onReload,
    required this.solicitud,
  });

  @override
  State<_CotizacionCard> createState() => _CotizacionCardState();
}

class _CotizacionCardState extends State<_CotizacionCard> {
  bool _procesando = false;

  Future<void> _generarPDF() async {
    final cot = widget.cotizacion;
    final s = widget.solicitud;
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cotización',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Proyecto: ${s.servicio}'),
                pw.Text('Descripción: ${s.descripcion}'),
                pw.SizedBox(height: 20),
                pw.Text('Profesional: ${s.profesional}'),
                pw.Text('Precio propuesto: \$${cot.precioPropuesto.toStringAsFixed(0)}'),
                pw.Text('Estado: ${cot.estadoCotizacion}'),
                if (cot.fechaServicio.isNotEmpty)
                  pw.Text('Fecha de servicio: ${cot.fechaServicio}'),
                if (cot.observaciones.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  pw.Text('Observaciones: ${cot.observaciones}'),
                ],
              ],
            );
          },
        ),
      );
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    }
  }

  Future<void> _accion(Future<void> Function() fn) async {
    setState(() => _procesando = true);
    try {
      await fn();
      if (!mounted) return;
      widget.onReload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cot = widget.cotizacion;
    final isPendiente = cot.estadoCotizacion == 'Pendiente';
    final isAceptado  = cot.estadoCotizacion == 'Aceptado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Precio propuesto
        Row(
          children: [
            Text(
              '\$${cot.precioPropuesto.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: widget.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            if (isAceptado)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aceptada ✓',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ),
          ],
        ),
        if (cot.observaciones.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            cot.observaciones,
            style: TextStyle(
                fontSize: 13, color: widget.textSecondary, height: 1.4),
          ),
        ],
        if (cot.fechaServicio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13, color: widget.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Fecha: ${cot.fechaServicio}',
                style: TextStyle(fontSize: 12, color: widget.textSecondary),
              ),
            ],
          ),
        ],
        if (isPendiente) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _procesando
                        ? null
                        : () => _accion(() =>
                            CotizacionService.aceptar(widget.token, cot.id)),
                    child: _procesando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Aceptar',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _procesando
                        ? null
                        : () => _accion(() =>
                            CotizacionService.rechazar(widget.token, cot.id)),
                    child: const Text('Rechazar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
        // Generar PDF (solo cuando la cotización está aceptada)
        if (isAceptado) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              label: const Text('Generar PDF',
                  style: TextStyle(color: Colors.white)),
              onPressed: _generarPDF,
            ),
          ),
        ],
      ],
    );
  }
}
