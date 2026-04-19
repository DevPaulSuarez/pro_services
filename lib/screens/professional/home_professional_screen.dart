import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/ingreso_mes.dart';
import 'package:pro_services/models/profesional.dart';
import 'package:pro_services/models/proyecto.dart';
import 'package:pro_services/screens/auth/login_screen.dart' show LoginScreen;
import 'package:pro_services/screens/professional/detalle_proyecto_screen.dart';
import 'package:pro_services/screens/professional/editar_perfil_screen.dart';
import 'package:pro_services/screens/professional/enviar_cotizacion_screen.dart';
import 'package:pro_services/screens/professional/horarios_screen.dart';
import 'package:pro_services/screens/professional/solicitudes_entrantes_screen.dart';
import 'package:pro_services/screens/professional/solicitudes_disponibles_screen.dart';
import 'package:pro_services/services/ingreso_service.dart';
import 'package:pro_services/services/perfil_profesional_service.dart';
import 'package:pro_services/models/resena.dart';
import 'package:pro_services/services/proyecto_service.dart';
import 'package:pro_services/services/resena_service.dart';
import 'package:pro_services/services/disponibilidad_service.dart';
import 'package:pro_services/services/notificacion_service.dart';
import 'notificaciones_screen.dart';
import 'conversaciones_screen.dart';
import 'dashboard_screen.dart';
import 'plantillas_screen.dart';
import 'mis_cobros_screen.dart';

// ─── (mock eliminado — datos vienen del API) ─────────────────────────────────

// ─── Screen ──────────────────────────────────────────────────────────────────

class HomeProfessionalScreen extends StatefulWidget {
  final String token;
  final String nombre;
  const HomeProfessionalScreen({super.key, required this.token, required this.nombre});

  @override
  State<HomeProfessionalScreen> createState() => _HomeProfessionalScreenState();
}

class _HomeProfessionalScreenState extends State<HomeProfessionalScreen> {
  late Future<Profesional> _perfilFuturo;
  late Future<List<Proyecto>> _proyectosFuturo;
  late Future<int> _pendientesFuture;
  late Future<IngresoMes> _ingresosFuture;

  bool _disponible = false;
  int _tabIndex = 0;
  int _noLeidasCount = 0;

  static const _accentColor = Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    _perfilFuturo = PerfilProfesionalService.getMe(widget.token)
      ..then((p) {
        if (mounted) setState(() => _disponible = p.disponibleAhora);
      }).catchError((_) {});
    _proyectosFuturo = ProyectoService.getProyectos(widget.token);
    _pendientesFuture = ProyectoService.getProyectos(widget.token, estado: 'Pendiente')
        .then((list) => list.length)
        .catchError((_) => 0);
    _ingresosFuture = IngresoService.getIngresosMes(widget.token)
        .catchError((_) => const IngresoMes(completados: 0, ingresoEstimado: 0, nuevosClientes: 0));
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final count = await NotificacionService.contarNoLeidas(widget.token);
      if (mounted) setState(() => _noLeidasCount = count);
    } catch (_) {}
  }

  void _reload() => setState(() {
        _perfilFuturo = PerfilProfesionalService.getMe(widget.token);
        _proyectosFuturo = ProyectoService.getProyectos(widget.token);
        _pendientesFuture = ProyectoService.getProyectos(widget.token, estado: 'Pendiente')
            .then((list) => list.length)
            .catchError((_) => 0);
        _ingresosFuture = IngresoService.getIngresosMes(widget.token)
            .catchError((_) => const IngresoMes(completados: 0, ingresoEstimado: 0, nuevosClientes: 0));
      });

  double _calcularPorcentaje(Profesional? perfil) {
    if (perfil == null) return 0.0;
    int campos = 0;
    if (perfil.nombre.isNotEmpty) campos++;
    if (perfil.especialidad.isNotEmpty) campos++;
    if (perfil.sobreMi.isNotEmpty) campos++;
    if (perfil.ubicacion.isNotEmpty) campos++;
    if (perfil.telefono.isNotEmpty) campos++;
    if (perfil.correo.isNotEmpty) campos++;
    if (perfil.habilidades.isNotEmpty) campos++;
    if (perfil.precioPorHora > 0) campos++;
    return campos / 8;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return FutureBuilder<Profesional>(
      future: _perfilFuturo,
      builder: (context, perfilSnap) {
        final perfil = perfilSnap.data;
        final nombre = perfil?.nombre ?? '';
        final especialidad = perfil?.especialidad ?? '';
        final correo = perfil?.correo ?? '';

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
                icon: Icon(Icons.chat_bubble_rounded,
                    color: isDark
                        ? Colors.grey.shade300
                        : const Color(0xFF0F172A)),
                tooltip: 'Conversaciones',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConversacionesProfesionalScreen(
                        token: widget.token),
                  ),
                ),
              ),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_rounded),
                    if (_noLeidasCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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
                    MaterialPageRoute(builder: (_) => NotificacionesScreen(token: widget.token)),
                  );
                  _cargarNotificaciones();
                },
              ),
              IconButton(
                icon: Icon(Icons.calendar_month_rounded,
                    color: isDark ? Colors.grey.shade300 : const Color(0xFF0F172A)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HorariosScreen(token: widget.token)),
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings_rounded,
                    color: isDark ? Colors.grey.shade300 : const Color(0xFF0F172A)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditarPerfilScreen(token: widget.token)),
                ).then((_) => _reload()),
              ),
              IconButton(
                icon: Icon(
                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
                ),
                onPressed: () => MyApp.of(context).toggleTheme(),
              ),
              IconButton(
                icon: Icon(Icons.logout_rounded,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
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
                        backgroundColor: _accentColor,
                        child: Text(
                          nombre.isNotEmpty ? nombre[0] : '?',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Usuario: ',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500)),
                      Text(correo,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: perfilSnap.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : perfilSnap.hasError
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('Error al cargar perfil', style: TextStyle(color: textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _reload, child: const Text('Reintentar')),
                      ]),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge solicitudes pendientes
                          FutureBuilder<int>(
                            future: _pendientesFuture,
                            builder: (_, snap) {
                              final count = snap.data ?? 0;
                              if (count == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SolicitudesEntrantesScreen(token: widget.token),
                                    ),
                                  ).then((_) => setState(() {
                                    _pendientesFuture = ProyectoService.getProyectos(widget.token, estado: 'Pendiente')
                                        .then((list) => list.length)
                                        .catchError((_) => 0);
                                  })),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.notifications_active_rounded,
                                            size: 16, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$count solicitud${count > 1 ? 'es' : ''} nueva${count > 1 ? 's' : ''}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.arrow_forward_ios_rounded,
                                            size: 12, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          _ProfileCard(
                            nombre: nombre,
                            especialidad: especialidad,
                            disponible: _disponible,
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onToggle: (val) async {
                              final messenger = ScaffoldMessenger.of(context);
                              setState(() => _disponible = val);
                              try {
                                await DisponibilidadService.setDisponibleManual(
                                    widget.token, val);
                              } catch (e) {
                                if (!mounted) return;
                                setState(() => _disponible = !val);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Error al cambiar disponibilidad: $e'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            porcentaje: _calcularPorcentaje(perfil),
                            onEditPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => EditarPerfilScreen(token: widget.token)),
                            ).then((_) => _reload()),
                          ),
                          const SizedBox(height: 16),
                          _StatsRow(
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            calificacion: perfil?.calificacion ?? 0.0,
                            trabajosRealizados: perfil?.trabajosRealizados ?? 0,
                            precioPorHora: perfil?.precioPorHora ?? 0.0,
                          ),
                          const SizedBox(height: 20),
                          _HabilidadesSection(
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            habilidades: perfil?.habilidades ?? [],
                          ),
                          const SizedBox(height: 20),
                          _EstadisticasMesSection(
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            proyectosFuturo: _proyectosFuturo,
                            ingresosFuture: _ingresosFuture,
                          ),
                          const SizedBox(height: 20),
                          // ── Acceso rápido ──────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _QuickNavButton(
                                  icon: Icons.bar_chart_rounded,
                                  label: 'Dashboard',
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => DashboardScreen(token: widget.token)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _QuickNavButton(
                                  icon: Icons.description_rounded,
                                  label: 'Plantillas',
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PlantillasScreen(token: widget.token)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _QuickNavButton(
                                  icon: Icons.payments_rounded,
                                  label: 'Mis Cobros',
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => MisCobrosScreen(token: widget.token)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // ── Solicitudes disponibles ─────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _QuickNavButton(
                                  icon: Icons.campaign_rounded,
                                  label: 'Solicitudes disponibles',
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SolicitudesDisponiblesScreen(
                                          token: widget.token),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _TabBar(
                            tabIndex: _tabIndex,
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onTabChanged: (i) => setState(() => _tabIndex = i),
                          ),
                          const SizedBox(height: 16),
                          if (_tabIndex == 0)
                            FutureBuilder<List<Proyecto>>(
                              future: _proyectosFuturo,
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snap.hasError) {
                                  return Center(
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      const Icon(Icons.error_outline_rounded, size: 36, color: Colors.redAccent),
                                      const SizedBox(height: 8),
                                      Text('Error al cargar proyectos', style: TextStyle(color: textSecondary)),
                                      TextButton(onPressed: _reload, child: const Text('Reintentar')),
                                    ]),
                                  );
                                }
                                final proyectos = snap.data!;
                                final activos = proyectos.where((p) => p.estado == 'aceptado').toList();
                                final pendientes = proyectos.where((p) => p.estado == 'pendiente').toList();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Proyectos activos',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                                    const SizedBox(height: 2),
                                    Text('Proyectos que están en curso',
                                        style: TextStyle(fontSize: 12, color: textSecondary)),
                                    const SizedBox(height: 10),
                                    if (activos.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text('Sin proyectos activos', style: TextStyle(fontSize: 13, color: textSecondary)),
                                      )
                                    else
                                      ...activos.map((p) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _ProyectoCard(
                                              proyecto: p,
                                              token: widget.token,
                                              isDark: isDark,
                                              cardBg: cardBg,
                                              textPrimary: textPrimary,
                                              textSecondary: textSecondary,
                                              onAccionCompletada: _reload,
                                            ),
                                          )),
                                    const SizedBox(height: 8),
                                    Text('Nuevas solicitudes',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                                    const SizedBox(height: 2),
                                    Text('Cotización pendiente de respuesta',
                                        style: TextStyle(fontSize: 12, color: textSecondary)),
                                    const SizedBox(height: 10),
                                    if (pendientes.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text('Sin solicitudes pendientes', style: TextStyle(fontSize: 13, color: textSecondary)),
                                      )
                                    else
                                      ...pendientes.map((p) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _ProyectoCard(
                                              proyecto: p,
                                              token: widget.token,
                                              isDark: isDark,
                                              cardBg: cardBg,
                                              textPrimary: textPrimary,
                                              textSecondary: textSecondary,
                                              onAccionCompletada: _reload,
                                            ),
                                          )),
                                  ],
                                );
                              },
                            )
                          else if (_tabIndex == 1)
                            _ProyectosTab(
                              isDark: isDark,
                              cardBg: cardBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              token: widget.token,
                            )
                          else
                            _ResenasTab(
                              isDark: isDark,
                              cardBg: cardBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              idProfesional: perfil?.id ?? 0,
                            ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String nombre;
  final String especialidad;
  final bool disponible;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<bool> onToggle;
  final double porcentaje;
  final VoidCallback onEditPressed;

  static const _accent = Color(0xFF6366F1);

  const _ProfileCard({
    required this.nombre,
    required this.especialidad,
    required this.disponible,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.onToggle,
    required this.porcentaje,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
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
          // Fila: avatar + info + switch
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _accent.withValues(alpha: 0.15),
                child: Text(
                  nombre[0],
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _accent),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(especialidad,
                        style: TextStyle(
                            fontSize: 12,
                            color: _accent,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: disponible
                                ? const Color(0xFF22C55E)
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          disponible ? 'Disponible ahora' : 'No disponible',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: disponible
                                ? const Color(0xFF22C55E)
                                : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: disponible,
                onChanged: onToggle,
                activeThumbColor: const Color(0xFF22C55E),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barra de perfil completo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perfil completo',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary),
              ),
              Text(
                '${(porcentaje * 100).round()}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _accent),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 7,
              backgroundColor:
                  _accent.withValues(alpha: isDark ? 0.15 : 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
          const SizedBox(height: 12),
          // Botón editar perfil
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: const BorderSide(color: _accent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit_rounded, size: 15),
              label: const Text('Editar perfil',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Estadísticas del mes ─────────────────────────────────────────────────────

class _EstadisticasMesSection extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Future<List<Proyecto>> proyectosFuturo;
  final Future<IngresoMes> ingresosFuture;

  const _EstadisticasMesSection({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.proyectosFuturo,
    required this.ingresosFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<IngresoMes>(
      future: ingresosFuture,
      builder: (context, ingresoSnap) {
        return FutureBuilder<List<Proyecto>>(
          future: proyectosFuturo,
          builder: (context, proySnap) {
            final cargando = ingresoSnap.connectionState == ConnectionState.waiting ||
                proySnap.connectionState == ConnectionState.waiting;
            final proyectos = proySnap.data ?? [];
            final activos = proyectos.where((p) => p.estado == 'aceptado').length;
            final ingreso = ingresoSnap.data;

            final items = [
              _MesStat(
                icon: Icons.attach_money_rounded,
                iconColor: const Color(0xFF22C55E),
                label: 'Ingreso estimado',
                value: cargando
                    ? '...'
                    : '\$${(ingreso?.ingresoEstimado ?? 0).toStringAsFixed(0)}',
              ),
              _MesStat(
                icon: Icons.pending_actions_rounded,
                iconColor: const Color(0xFF6366F1),
                label: 'Proyectos activos',
                value: cargando ? '...' : '$activos',
              ),
              _MesStat(
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF06B6D4),
                label: 'Nuevos clientes',
                value: cargando
                    ? '...'
                    : '${ingreso?.nuevosClientes ?? 0}',
              ),
              _MesStat(
                icon: Icons.task_alt_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: 'Completados',
                value: cargando
                    ? '...'
                    : '${ingreso?.completados ?? 0}',
              ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas del mes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: items
                      .map((item) => _MesStatCard(
                            stat: item,
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ))
                      .toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MesStat {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MesStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

class _MesStatCard extends StatelessWidget {
  final _MesStat stat;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _MesStatCard({
    required this.stat,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, size: 20, color: stat.iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: TextStyle(fontSize: 11, color: textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Quick nav button ─────────────────────────────────────────────────────────

class _QuickNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color cardBg;
  final VoidCallback onTap;

  static const _accent = Color(0xFF6366F1);

  const _QuickNavButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: _accent),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Habilidades section ──────────────────────────────────────────────────────

class _HabilidadesSection extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final List<String> habilidades;

  static const _accent = Color(0xFF6366F1);

  const _HabilidadesSection({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.habilidades,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = _accent.withValues(alpha: isDark ? 0.18 : 0.1);

    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Habilidades',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Editar',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (habilidades.isEmpty)
            Text('Sin habilidades registradas',
                style: TextStyle(fontSize: 12, color: textSecondary))
          else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: habilidades
                .map((h) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(h,
                          style: TextStyle(
                              fontSize: 12,
                              color: _accent,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Tab bar ──────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final int tabIndex;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<int> onTabChanged;

  static const _accent = Color(0xFF6366F1);


  const _TabBar({
    required this.tabIndex,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'Vista general',
      'Proyectos',
      'Reseñas',
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active
                      ? _accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? Colors.white
                        : textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Proyectos tab ────────────────────────────────────────────────────────────

class _ProyectosTab extends StatefulWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final String token;

  const _ProyectosTab({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.token,
  });

  @override
  State<_ProyectosTab> createState() => _ProyectosTabState();
}

class _ProyectosTabState extends State<_ProyectosTab> {
  String _filtro = 'todos';
  late Future<List<Proyecto>> _futuro;

  static const _filtros = [
    ('todos', 'Todos'),
    ('pendiente', 'Pendiente'),
    ('aceptado', 'En progreso'),
    ('completado', 'Completado'),
    ('rechazado', 'Rechazado'),
  ];

  @override
  void initState() {
    super.initState();
    _futuro = ProyectoService.getProyectos(widget.token);
  }

  void _reload() =>
      setState(() => _futuro = ProyectoService.getProyectos(widget.token));

  Color _filtroColor(String estado) {
    switch (estado) {
      case 'pendiente':  return const Color(0xFFF59E0B);
      case 'aceptado':   return const Color(0xFF6366F1);
      case 'completado': return const Color(0xFF22C55E);
      case 'rechazado':  return const Color(0xFFEF4444);
      default:           return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Proyecto>>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          ));
        }
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 16),
              const Icon(Icons.error_outline_rounded, size: 36, color: Colors.redAccent),
              const SizedBox(height: 8),
              Text('Error al cargar proyectos',
                  style: TextStyle(fontSize: 13, color: widget.textSecondary)),
              TextButton(onPressed: _reload, child: const Text('Reintentar')),
            ]),
          );
        }
        final all = snap.data!;
        final filtered = _filtro == 'todos'
            ? all
            : all.where((s) => s.estado == _filtro).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros horizontales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filtros.map((f) {
                  final key = f.$1;
                  final label = f.$2;
                  final active = _filtro == key;
                  final color = key == 'todos'
                      ? const Color(0xFF6366F1)
                      : _filtroColor(key);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filtro = key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: active
                              ? color
                              : color.withValues(alpha: widget.isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : color,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Sin proyectos para este filtro',
                      style: TextStyle(
                          fontSize: 13, color: widget.textSecondary)),
                ),
              )
            else
              ...filtered.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProyectoDetalleCard(
                      proyecto: s,
                      isDark: widget.isDark,
                      cardBg: widget.cardBg,
                      textPrimary: widget.textPrimary,
                      textSecondary: widget.textSecondary,
                      token: widget.token,
                    ),
                  )),
          ],
        );
      },
    );
  }
}

// ─── Proyecto detalle card ────────────────────────────────────────────────────

class _ProyectoDetalleCard extends StatelessWidget {
  final Proyecto proyecto;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final String token;

  const _ProyectoDetalleCard({
    required this.proyecto,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.token,
  });

  Color get _color {
    switch (proyecto.estado) {
      case 'pendiente':  return const Color(0xFFF59E0B);
      case 'aceptado':   return const Color(0xFF6366F1);
      case 'completado': return const Color(0xFF22C55E);
      case 'rechazado':  return const Color(0xFFEF4444);
      default:           return Colors.grey;
    }
  }

  String get _label {
    switch (proyecto.estado) {
      case 'pendiente':  return 'Pendiente';
      case 'aceptado':   return 'En progreso';
      case 'completado': return 'Completado';
      case 'rechazado':  return 'Rechazado';
      default:           return proyecto.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAceptado = proyecto.estado == 'aceptado';
    final btnColor =
        isDark ? const Color(0xFFbcbcbc) : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.all(14),
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
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _color.withValues(alpha: 0.15),
                child: Text(proyecto.cliente.isNotEmpty ? proyecto.cliente[0] : '?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _color)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(proyecto.cliente,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(proyecto.servicio,
                        style: TextStyle(
                            fontSize: 12,
                            color: _color,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _color)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(proyecto.descripcion,
              style: TextStyle(
                  fontSize: 13, color: textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: textSecondary),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(proyecto.ubicacion,
                      style:
                          TextStyle(fontSize: 12, color: textSecondary))),
              Icon(
                esAceptado
                    ? Icons.calendar_today_rounded
                    : Icons.access_time_rounded,
                size: 13,
                color: textSecondary,
              ),
              const SizedBox(width: 4),
              Text(proyecto.fecha,
                  style: TextStyle(fontSize: 12, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.attach_money_rounded,
                  size: 14, color: const Color(0xFF22C55E)),
              const SizedBox(width: 2),
              Text(
                'Presupuesto: \$${proyecto.presupuesto.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary),
              ),
            ],
          ),
          if (esAceptado) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso del proyecto',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                Text('${(proyecto.progreso * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1))),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: proyecto.progreso,
                minHeight: 7,
                backgroundColor: const Color(0xFF6366F1)
                    .withValues(alpha: isDark ? 0.15 : 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366F1)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: btnColor,
                side: BorderSide(color: btnColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleProyectoScreen(
                    id: proyecto.id,
                    cliente: proyecto.cliente,
                    telefono: proyecto.telefono,
                    correo: proyecto.correo,
                    servicio: proyecto.servicio,
                    descripcion: proyecto.descripcion,
                    ubicacion: proyecto.ubicacion,
                    fecha: proyecto.fecha,
                    fechaInicio: proyecto.fechaInicio,
                    fechaFin: proyecto.fechaFin,
                    presupuesto: proyecto.presupuesto,
                    estado: proyecto.estado,
                    progreso: proyecto.progreso,
                    token: token,
                    idUsuario: proyecto.idUsuario,
                  ),
                ),
              ),
              icon: const Icon(Icons.remove_red_eye_rounded, size: 15),
              label: const Text('Ver detalle',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          if (esAceptado) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnviarCotizacionScreen(
                      token: token,
                      proyecto: proyecto,
                    ),
                  ),
                ),
                icon: const Icon(Icons.request_quote_rounded, size: 16),
                label: const Text('Enviar cotización',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Reseñas tab ──────────────────────────────────────────────────────────────

class _ResenasTab extends StatefulWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final int idProfesional;

  const _ResenasTab({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.idProfesional,
  });

  @override
  State<_ResenasTab> createState() => _ResenasTabState();
}

class _ResenasTabState extends State<_ResenasTab> {
  late Future<List<Resena>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = ResenaService.getPorProfesional(widget.idProfesional);
  }

  void _reload() =>
      setState(() => _futuro = ResenaService.getPorProfesional(widget.idProfesional));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Resena>>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 16),
              const Icon(Icons.error_outline_rounded, size: 36, color: Colors.redAccent),
              const SizedBox(height: 8),
              Text('Error al cargar reseñas',
                  style: TextStyle(fontSize: 13, color: widget.textSecondary)),
              TextButton(onPressed: _reload, child: const Text('Reintentar')),
            ]),
          );
        }
        final resenas = snap.data!;
        if (resenas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.rate_review_outlined, size: 48, color: widget.textSecondary),
                const SizedBox(height: 12),
                Text('Aún no tenés reseñas',
                    style: TextStyle(fontSize: 14, color: widget.textSecondary)),
              ]),
            ),
          );
        }
        return Column(
          children: resenas.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.06),
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
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            const Color(0xFF6366F1).withValues(alpha: 0.15),
                        child: Text(
                            r.nombreUsuario.isNotEmpty ? r.nombreUsuario[0] : '?',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6366F1))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.nombreUsuario,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: widget.textPrimary)),
                            Text(r.fecha,
                                style: TextStyle(
                                    fontSize: 11, color: widget.textSecondary)),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < r.puntaje
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (r.titulo.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(r.titulo,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.textPrimary)),
                  ],
                  const SizedBox(height: 6),
                  Text(r.descripcion,
                      style: TextStyle(
                          fontSize: 13,
                          color: widget.textSecondary,
                          height: 1.4)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final double calificacion;
  final int trabajosRealizados;
  final double precioPorHora;

  const _StatsRow({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.calificacion,
    required this.trabajosRealizados,
    required this.precioPorHora,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFBBF24),
          label: 'Calificación',
          value: calificacion.toStringAsFixed(1),
          isDark: isDark,
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.work_outline_rounded,
          iconColor: const Color(0xFF6366F1),
          label: 'Trabajos',
          value: '$trabajosRealizados',
          isDark: isDark,
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.attach_money_rounded,
          iconColor: const Color(0xFF22C55E),
          label: 'Precio/hora',
          value: '\$${precioPorHora.toStringAsFixed(0)}',
          isDark: isDark,
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Solicitud card ───────────────────────────────────────────────────────────

class _ProyectoCard extends StatefulWidget {
  final Proyecto proyecto;
  final String token;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onAccionCompletada;

  const _ProyectoCard({
    required this.proyecto,
    required this.token,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.onAccionCompletada,
  });

  @override
  State<_ProyectoCard> createState() => _ProyectoCardState();
}

class _ProyectoCardState extends State<_ProyectoCard> {
  bool _cargando = false;

  Color get _estadoColor {
    switch (widget.proyecto.estado) {
      case 'pendiente':  return const Color(0xFFF59E0B);
      case 'aceptado':   return const Color(0xFF6366F1);
      case 'completado': return const Color(0xFF22C55E);
      case 'rechazado':  return const Color(0xFFEF4444);
      default:           return Colors.grey;
    }
  }

  String get _estadoLabel {
    switch (widget.proyecto.estado) {
      case 'pendiente':  return 'Pendiente';
      case 'aceptado':   return 'En progreso';
      case 'completado': return 'Completado';
      case 'rechazado':  return 'Rechazado';
      default:           return widget.proyecto.estado;
    }
  }

  Future<void> _accion(Future<void> Function() fn) async {
    setState(() => _cargando = true);
    try {
      await fn();
      widget.onAccionCompletada();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.proyecto;
    final esPendiente = p.estado == 'pendiente';
    final esAceptado  = p.estado == 'aceptado';
    final btnColor    = widget.isDark ? const Color(0xFFbcbcbc) : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.07),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: _estadoColor.withValues(alpha: 0.15),
                child: Text(
                  p.cliente.isNotEmpty ? p.cliente[0] : '?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _estadoColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.cliente, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.textPrimary)),
                    const SizedBox(height: 2),
                    Text(p.servicio, style: TextStyle(fontSize: 12, color: _estadoColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _estadoColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(_estadoLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _estadoColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(p.descripcion, style: TextStyle(fontSize: 13, color: widget.textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: widget.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text(p.ubicacion, style: TextStyle(fontSize: 12, color: widget.textSecondary))),
              Icon(esAceptado ? Icons.calendar_today_rounded : Icons.access_time_rounded, size: 13, color: widget.textSecondary),
              const SizedBox(width: 4),
              Text(p.fecha, style: TextStyle(fontSize: 12, color: widget.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.attach_money_rounded, size: 14, color: const Color(0xFF22C55E)),
              const SizedBox(width: 2),
              Text('Presupuesto: \$${p.presupuesto.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPrimary)),
            ],
          ),
          if (esAceptado) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso del proyecto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textPrimary)),
                Text('${(p.progreso * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1))),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: p.progreso,
                minHeight: 7,
                backgroundColor: const Color(0xFF6366F1).withValues(alpha: widget.isDark ? 0.15 : 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          ],
          if (esPendiente) ...[
            const SizedBox(height: 12),
            _cargando
                ? const Center(child: SizedBox(height: 28, width: 28, child: CircularProgressIndicator(strokeWidth: 2)))
                : Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _accion(() => ProyectoService.rechazar(widget.token, p.id)),
                            child: const Text('Rechazar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: btnColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _accion(() => ProyectoService.aceptar(widget.token, p.id)),
                            child: const Text('Aceptar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ],
      ),
    );
  }
}
