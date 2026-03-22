import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';

// ── Modelo mock ────────────────────────────────────────────────────────────────
class _Solicitud {
  final int id;
  final String profesional;
  final String servicio;
  final String descripcion;
  final String fecha;
  final double presupuesto;
  final String estado;

  const _Solicitud({
    required this.id,
    required this.profesional,
    required this.servicio,
    required this.descripcion,
    required this.fecha,
    required this.presupuesto,
    required this.estado,
  });
}

const _mock = [
  _Solicitud(
    id: 1,
    profesional: 'Andres Molina',
    servicio: 'Electricista',
    descripcion: 'Instalación de tomacorrientes en sala y cocina.',
    fecha: '14 Mar 2026',
    presupuesto: 280,
    estado: 'aceptado',
  ),
  _Solicitud(
    id: 2,
    profesional: 'Luis Herrera',
    servicio: 'Plomería',
    descripcion: 'Reparación de tubería con fuga en el baño principal.',
    fecha: '12 Mar 2026',
    presupuesto: 150,
    estado: 'pendiente',
  ),
  _Solicitud(
    id: 3,
    profesional: 'Sara Gómez',
    servicio: 'Pintura',
    descripcion: 'Pintura de fachada exterior, dos pisos.',
    fecha: '05 Mar 2026',
    presupuesto: 600,
    estado: 'completado',
  ),
  _Solicitud(
    id: 4,
    profesional: 'Jorge Ruiz',
    servicio: 'Carpintería',
    descripcion: 'Fabricación de closet empotrado en habitación principal.',
    fecha: '01 Mar 2026',
    presupuesto: 420,
    estado: 'rechazado',
  ),
];

// ── Pantalla ───────────────────────────────────────────────────────────────────
class MisSolicitudesScreen extends StatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  State<MisSolicitudesScreen> createState() => _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState extends State<MisSolicitudesScreen> {
  String _filtro = 'Todos';

  static const _filtros = [
    ('Todos', ''),
    ('Pendiente', 'pendiente'),
    ('En progreso', 'aceptado'),
    ('Completado', 'completado'),
    ('Rechazado', 'rechazado'),
  ];

  List<_Solicitud> get _filtradas => _filtro == 'Todos'
      ? _mock
      : _mock.where((s) {
          final match = _filtros.firstWhere((f) => f.$1 == _filtro).$2;
          return s.estado == match;
        }).toList();

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pendiente':  return const Color(0xFFF59E0B);
      case 'aceptado':   return const Color(0xFF6366F1);
      case 'completado': return const Color(0xFF22C55E);
      case 'rechazado':  return const Color(0xFFEF4444);
      default:           return Colors.grey;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':  return 'Pendiente';
      case 'aceptado':   return 'En progreso';
      case 'completado': return 'Completado';
      case 'rechazado':  return 'Rechazado';
      default:           return estado;
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':  return Icons.access_time_rounded;
      case 'aceptado':   return Icons.autorenew_rounded;
      case 'completado': return Icons.task_alt_rounded;
      case 'rechazado':  return Icons.cancel_rounded;
      default:           return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor       = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg        = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final lista = _filtradas;

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
        title: Text('Mis solicitudes',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A))),
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
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: activo
                              ? const Color(0xFF6366F1)
                              : (isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(f.$1,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: activo
                                    ? Colors.white
                                    : textSecondary)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Lista ──────────────────────────────────────────────────────────
          Expanded(
            child: lista.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 52, color: textSecondary),
                        const SizedBox(height: 12),
                        Text('Sin solicitudes en esta categoría',
                            style: TextStyle(
                                fontSize: 14, color: textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final s = lista[i];
                      final color = _estadoColor(s.estado);
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
                            // Cabecera
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: color.withValues(alpha: 0.15),
                                  child: Text(s.profesional[0],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: color)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(s.profesional,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: textPrimary)),
                                      const SizedBox(height: 2),
                                      Text(s.servicio,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: color)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(_estadoIcon(s.estado),
                                          size: 11, color: color),
                                      const SizedBox(width: 4),
                                      Text(_estadoLabel(s.estado),
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: color)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Descripción
                            Text(s.descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                    height: 1.4)),
                            const SizedBox(height: 12),
                            // Info inferior
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 13, color: textSecondary),
                                const SizedBox(width: 4),
                                Text(s.fecha,
                                    style: TextStyle(
                                        fontSize: 12, color: textSecondary)),
                                const Spacer(),
                                Icon(Icons.attach_money_rounded,
                                    size: 14,
                                    color: const Color(0xFF22C55E)),
                                Text(
                                  s.presupuesto.toStringAsFixed(0),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF22C55E)),
                                ),
                                const SizedBox(width: 4),
                                Text('presupuesto',
                                    style: TextStyle(
                                        fontSize: 11, color: textSecondary)),
                              ],
                            ),
                            // Banner completado
                            if (s.estado == 'completado') ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.task_alt_rounded,
                                        size: 14, color: Color(0xFF22C55E)),
                                    SizedBox(width: 6),
                                    Text('Trabajo completado exitosamente',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF22C55E))),
                                  ],
                                ),
                              ),
                            ],
                            // Banner rechazado
                            if (s.estado == 'rechazado') ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.cancel_rounded,
                                        size: 14, color: Color(0xFFEF4444)),
                                    SizedBox(width: 6),
                                    Text('El profesional no pudo atenderte',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEF4444))),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
