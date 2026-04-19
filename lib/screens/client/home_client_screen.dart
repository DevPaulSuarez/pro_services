import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/tipo_profesion.dart';
import 'package:pro_services/services/tipo_profesion_service.dart';
import 'package:pro_services/services/notificacion_service.dart';
import 'package:pro_services/screens/auth/login_screen.dart' show LoginScreen;
import 'package:pro_services/screens/client/profesionales_screen.dart';
import 'package:pro_services/screens/client/mis_solicitudes_screen.dart';
import 'package:pro_services/screens/client/notificaciones_screen.dart';
import 'package:pro_services/screens/client/conversaciones_screen.dart';
import 'package:pro_services/screens/client/favoritos_screen.dart';
import 'package:pro_services/screens/client/estimador_presupuesto_screen.dart';
import 'package:pro_services/screens/client/historial_pagos_screen.dart';
import 'package:pro_services/screens/client/crear_solicitud_abierta_screen.dart';
import 'package:pro_services/screens/client/mis_solicitudes_abiertas_screen.dart';
import 'package:pro_services/screens/client/busqueda_screen.dart';
import 'package:pro_services/screens/client/mis_servicios_recurrentes_screen.dart';

// Mapeo de clave de icono (viene del API) → IconData
IconData _resolveIcon(String key) {
  const map = <String, IconData>{
    // originales
    'bolt': Icons.bolt_rounded,
    'water_drop': Icons.water_drop_rounded,
    'handyman': Icons.handyman_rounded,
    'format_paint': Icons.format_paint_rounded,
    'cleaning_services': Icons.cleaning_services_rounded,
    'yard': Icons.yard_rounded,
    'build': Icons.build_rounded,
    'home_repair_service': Icons.home_repair_service_rounded,
    'ac_unit': Icons.ac_unit_rounded,
    'security': Icons.security_rounded,
    // claves del API
    'electrical_services': Icons.electrical_services_rounded,
    'plumbing': Icons.plumbing_rounded,
    'carpenter': Icons.handyman_rounded,
    'lock': Icons.lock_rounded,
    'construction': Icons.construction_rounded,
    'grass': Icons.grass_rounded,
    'computer': Icons.computer_rounded,
    'gas_meter': Icons.gas_meter_rounded,
    'code': Icons.code_rounded,
  };
  return map[key] ?? Icons.work_outline_rounded;
}

// Convierte hex string "F59E0B" → Color
Color _resolveColor(String hex) {
  try {
    return Color(int.parse('FF$hex', radix: 16));
  } catch (_) {
    return Colors.blueGrey;
  }
}

class HomeClientScreen extends StatefulWidget {
  final String token;
  final String nombre;
  const HomeClientScreen({super.key, required this.token, required this.nombre});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  late Future<List<TipoProfesion>> _tiposFuture;
  int _noLeidasCount = 0;

  @override
  void initState() {
    super.initState();
    _tiposFuture = TipoProfesionService.getTipos();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final count = await NotificacionService.contarNoLeidas(widget.token);
      if (mounted) setState(() => _noLeidasCount = count);
    } catch (_) {}
  }

  void _reload() {
    setState(() {
      _tiposFuture = TipoProfesionService.getTipos();
    });
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
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [const Color(0xFFF0F0F0), const Color(0xFFD0D5D7)]
                : [const Color(0xFF000000), const Color(0xFF01143D)],
          ).createShader(bounds),
          child: const Text(
            'ProServicios',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            tooltip: 'Buscar profesionales',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BusquedaScreen(
                  token: widget.token,
                  nombre: widget.nombre,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_rounded,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            tooltip: 'Conversaciones',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ConversacionesClienteScreen(token: widget.token)),
            ),
          ),
          IconButton(
            icon: Icon(Icons.receipt_long_rounded,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            tooltip: 'Mis solicitudes',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => MisSolicitudesScreen(token: widget.token))),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_rounded,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                if (_noLeidasCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _noLeidasCount > 99 ? '99+' : '$_noLeidasCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NotificacionesScreen(token: widget.token)),
              );
              _cargarNotificaciones();
            },
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
          IconButton(
            icon: Icon(Icons.logout_rounded,
                color: isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFF111827),
                    child: Text(
                      widget.nombre[0],
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Contratador: ',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500),
                  ),
                  Text(
                    widget.nombre,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '¿Qué servicio\nnecesitas hoy?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Encuentra profesionales verificados cerca de ti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QuickActionButton(
                    icon: Icons.favorite_rounded,
                    label: 'Favoritos',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FavoritosScreen(token: widget.token)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.calculate_rounded,
                    label: 'Estimador',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              EstimadorPresupuestoScreen(token: widget.token)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.receipt_long_rounded,
                    label: 'Historial',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              HistorialPagosScreen(token: widget.token)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.campaign_rounded,
                    label: 'Publicar',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CrearSolicitudAbiertaScreen(token: widget.token)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.broadcast_on_personal_rounded,
                    label: 'Mis posts',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MisSolicitudesAbiertasScreen(token: widget.token)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.repeat_rounded,
                    label: 'Recurrentes',
                    isDark: isDark,
                    color: const Color(0xFF0EA5E9),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MisServiciosRecurrentesScreen(token: widget.token)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<TipoProfesion>>(
              future: _tiposFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.wifi_off_rounded,
                            size: 48,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('Error al cargar categorías',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600)),
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

                final tipos = snapshot.data!
                    .where((t) => t.profesionalesRegistrados > 0)
                    .toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 310,
                  ),
                  itemCount: tipos.length,
                  itemBuilder: (context, index) {
                    final tipo = tipos[index];
                    return _CategoryCard(tipo: tipo, isDark: isDark);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Color? color;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.grey.shade300 : const Color(0xFF374151);
    final iconColor = color ??
        (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final TipoProfesion tipo;
  final bool isDark;

  const _CategoryCard({required this.tipo, required this.isDark});

  void _navegar(BuildContext context) {
    // Buscar el token desde el ancestro HomeClientScreen
    final homeState = context.findAncestorStateOfType<_HomeClientScreenState>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfesionalesScreen(
          categoria: tipo,
          token: homeState?.widget.token ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = _resolveIcon(tipo.icono);
    final color = _resolveColor(tipo.color);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final btnColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF111827);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 44, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen representativa (tappable)
                GestureDetector(
                  onTap: () => _navegar(context),
                  child: Container(
                    height: 75,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(icon, size: 42, color: color),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tipo.nombre,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 68,
                  child: SingleChildScrollView(
                    child: Text(
                      tipo.descripcion,
                      style: TextStyle(
                          fontSize: 11, color: textSecondary, height: 1.4),
                    ),
                  ),
                ),
                const Spacer(),
                // Botón Ver más
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => _navegar(context),
                    child: const Text('Ver más',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          // Icono + contador en esquina superior
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                Text(
                  '${tipo.profesionalesRegistrados} profesionales',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
