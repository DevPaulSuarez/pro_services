import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/screens/auth/login_screen.dart' show LoginScreen;
import 'package:pro_services/screens/professional/detalle_proyecto_screen.dart';
import 'package:pro_services/screens/professional/editar_perfil_screen.dart';

// ─── Mock data ───────────────────────────────────────────────────────────────

class _Solicitud {
  final int id;
  final String cliente;
  final String servicio;
  final String descripcion;
  final String ubicacion;
  final String fecha;
  final double presupuesto;
  final String estado; // 'pendiente' | 'aceptado' | 'completado'
  final double progreso; // 0.0 – 1.0, solo relevante para 'aceptado'

  const _Solicitud({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.descripcion,
    required this.ubicacion,
    required this.fecha,
    required this.presupuesto,
    required this.estado,
    this.progreso = 0.0,
  });
}

final _solicitudesMock = [
  const _Solicitud(
    id: 1,
    cliente: 'María López',
    servicio: 'Instalación eléctrica',
    descripcion: 'Necesito instalar 4 puntos de luz en sala y comedor.',
    ubicacion: 'Bogotá, Chapinero',
    fecha: 'Hoy, 10:30 am',
    presupuesto: 120.0,
    estado: 'pendiente',
  ),
  const _Solicitud(
    id: 2,
    cliente: 'Juan Pérez',
    servicio: 'Reparación de corto',
    descripcion: 'Se fue la luz de un circuito en la cocina.',
    ubicacion: 'Bogotá, Usaquén',
    fecha: '14 Mar 2026',
    presupuesto: 80.0,
    estado: 'aceptado',
    progreso: 0.6,
  ),
  const _Solicitud(
    id: 3,
    cliente: 'Sandra Ruiz',
    servicio: 'Tablero eléctrico',
    descripcion: 'Revisión completa del tablero y cambio de breakers.',
    ubicacion: 'Bogotá, Suba',
    fecha: '10 Mar 2026',
    presupuesto: 200.0,
    estado: 'completado',
    progreso: 1.0,
  ),
  const _Solicitud(
    id: 4,
    cliente: 'Felipe Castro',
    servicio: 'Iluminación LED',
    descripcion: 'Cambio de luminarias a LED en oficina de 3 ambientes.',
    ubicacion: 'Bogotá, Teusaquillo',
    fecha: 'Ayer, 11:00 am',
    presupuesto: 150.0,
    estado: 'rechazado',
  ),
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class HomeProfessionalScreen extends StatefulWidget {
  const HomeProfessionalScreen({super.key});

  @override
  State<HomeProfessionalScreen> createState() => _HomeProfessionalScreenState();
}

class _HomeProfessionalScreenState extends State<HomeProfessionalScreen> {
  static const String _nombre = 'Andrés Molina';
  static const String _especialidad = 'Electricista certificado';
  static const String _correo = 'andres.molina@email.com';

  bool _disponible = true;
  int _tabIndex = 0;

  static const _accentColor = Color(0xFF6366F1);

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
            icon: Icon(
              Icons.settings_rounded,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF0F172A),
            ),
            onPressed: () {},
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
                    backgroundColor: _accentColor,
                    child: Text(
                      _nombre[0],
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Usuario: ',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500),
                  ),
                  Text(
                    _correo,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tarjeta de perfil + disponibilidad ──────────────────────────
            _ProfileCard(
              nombre: _nombre,
              especialidad: _especialidad,
              disponible: _disponible,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onToggle: (val) => setState(() => _disponible = val),
            ),
            const SizedBox(height: 16),

            // ── Estadísticas ─────────────────────────────────────────────────
            _StatsRow(
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 20),

            // ── Habilidades ──────────────────────────────────────────────────
            _HabilidadesSection(
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 20),

            // ── Estadísticas del mes ─────────────────────────────────────────
            _EstadisticasMesSection(
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 20),

            // ── Tab bar ───────────────────────────────────────────────────────
            _TabBar(
              tabIndex: _tabIndex,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTabChanged: (i) => setState(() => _tabIndex = i),
            ),
            const SizedBox(height: 16),

            // ── Contenido del tab ────────────────────────────────────────────
            if (_tabIndex == 0) ...[
              // Proyectos activos
              Text('Proyectos activos',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
              const SizedBox(height: 2),
              Text('Proyectos que están en curso',
                  style: TextStyle(fontSize: 12, color: textSecondary)),
              const SizedBox(height: 10),
              ..._solicitudesMock
                  .where((s) => s.estado == 'aceptado')
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SolicitudCard(
                          solicitud: s,
                          isDark: isDark,
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      )),
              const SizedBox(height: 8),
              // Nuevas solicitudes
              Text('Nuevas solicitudes',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
              const SizedBox(height: 2),
              Text('Cotización pendiente de respuesta',
                  style: TextStyle(fontSize: 12, color: textSecondary)),
              const SizedBox(height: 10),
              ..._solicitudesMock
                  .where((s) => s.estado == 'pendiente')
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SolicitudCard(
                          solicitud: s,
                          isDark: isDark,
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      )),
            ] else if (_tabIndex == 1) ...[
              _ProyectosTab(
                isDark: isDark,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ] else ...[
              _ResenasTab(
                isDark: isDark,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ],
          ],
        ),
      ),
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
                '75%',
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
              value: 0.75,
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
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const EditarPerfilScreen())),
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

  const _EstadisticasMesSection({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _MesStat(
        icon: Icons.attach_money_rounded,
        iconColor: const Color(0xFF22C55E),
        label: 'Ingreso mensual',
        value: '\$1,280',
      ),
      _MesStat(
        icon: Icons.pending_actions_rounded,
        iconColor: const Color(0xFF6366F1),
        label: 'Proyectos activos',
        value: '3',
      ),
      _MesStat(
        icon: Icons.people_alt_rounded,
        iconColor: const Color(0xFF06B6D4),
        label: 'Nuevos clientes',
        value: '8',
      ),
      _MesStat(
        icon: Icons.task_alt_rounded,
        iconColor: const Color(0xFFF59E0B),
        label: 'Completados',
        value: '21',
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

// ─── Habilidades section ──────────────────────────────────────────────────────

class _HabilidadesSection extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  static const _accent = Color(0xFF6366F1);

  static const _habilidades = [
    'Instalaciones',
    'Tableros eléctricos',
    'Reparación de cortos',
    'Iluminación LED',
    'Cableado estructurado',
    'Alta tensión',
  ];

  const _HabilidadesSection({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _habilidades
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

  static final _proyectosCount =
      _solicitudesMock.where((s) => s.estado == 'aceptado').length;
  static const _resenasCount = 3;

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
      'Proyectos ($_proyectosCount)',
      'Reseñas ($_resenasCount)',
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

  const _ProyectosTab({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  State<_ProyectosTab> createState() => _ProyectosTabState();
}

class _ProyectosTabState extends State<_ProyectosTab> {
  String _filtro = 'todos';

  static const _filtros = [
    ('todos', 'Todos'),
    ('pendiente', 'Pendiente'),
    ('aceptado', 'En progreso'),
    ('completado', 'Completado'),
    ('rechazado', 'Rechazado'),
  ];

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
    final filtered = _filtro == 'todos'
        ? _solicitudesMock
        : _solicitudesMock.where((s) => s.estado == _filtro).toList();

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
                  solicitud: s,
                  isDark: widget.isDark,
                  cardBg: widget.cardBg,
                  textPrimary: widget.textPrimary,
                  textSecondary: widget.textSecondary,
                ),
              )),
      ],
    );
  }
}

// ─── Proyecto detalle card ────────────────────────────────────────────────────

class _ProyectoDetalleCard extends StatelessWidget {
  final _Solicitud solicitud;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _ProyectoDetalleCard({
    required this.solicitud,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  Color get _color {
    switch (solicitud.estado) {
      case 'pendiente':  return const Color(0xFFF59E0B);
      case 'aceptado':   return const Color(0xFF6366F1);
      case 'completado': return const Color(0xFF22C55E);
      case 'rechazado':  return const Color(0xFFEF4444);
      default:           return Colors.grey;
    }
  }

  String get _label {
    switch (solicitud.estado) {
      case 'pendiente':  return 'Pendiente';
      case 'aceptado':   return 'En progreso';
      case 'completado': return 'Completado';
      case 'rechazado':  return 'Rechazado';
      default:           return solicitud.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAceptado = solicitud.estado == 'aceptado';
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
                child: Text(solicitud.cliente[0],
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
                    Text(solicitud.cliente,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(solicitud.servicio,
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
          Text(solicitud.descripcion,
              style: TextStyle(
                  fontSize: 13, color: textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: textSecondary),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(solicitud.ubicacion,
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
              Text(solicitud.fecha,
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
                'Presupuesto: \$${solicitud.presupuesto.toStringAsFixed(0)}',
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
                Text('${(solicitud.progreso * 100).toInt()}%',
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
                value: solicitud.progreso,
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
                    id: solicitud.id,
                    cliente: solicitud.cliente,
                    telefono: '+57 300 123 4567',
                    correo: 'cliente@email.com',
                    servicio: solicitud.servicio,
                    descripcion: solicitud.descripcion,
                    ubicacion: solicitud.ubicacion,
                    fecha: solicitud.fecha,
                    fechaInicio: solicitud.fecha,
                    fechaFin: '30 Mar 2026',
                    presupuesto: solicitud.presupuesto,
                    estado: solicitud.estado,
                    progreso: solicitud.progreso,
                  ),
                ),
              ),
              icon: const Icon(Icons.remove_red_eye_rounded, size: 15),
              label: const Text('Ver detalle',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reseñas tab ──────────────────────────────────────────────────────────────

class _ResenasTab extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _ResenasTab({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const _resenas = [
    (nombre: 'Laura Gómez', fecha: 'Hace 2 días', estrellas: 5,
     texto: 'Excelente trabajo, muy puntual y profesional.'),
    (nombre: 'Carlos Ruiz', fecha: 'Hace 1 semana', estrellas: 5,
     texto: 'Solucionó el problema rápidamente. Muy recomendado.'),
    (nombre: 'Ana Torres', fecha: 'Hace 2 semanas', estrellas: 4,
     texto: 'Buen servicio, dejó todo ordenado al terminar.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _resenas.map((r) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
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
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        const Color(0xFF6366F1).withValues(alpha: 0.15),
                    child: Text(r.nombre[0],
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
                        Text(r.nombre,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textPrimary)),
                        Text(r.fecha,
                            style: TextStyle(
                                fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < r.estrellas
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(r.texto,
                  style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.4)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _StatsRow({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFBBF24),
          label: 'Calificación',
          value: '4.9',
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
          value: '134',
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
          value: '\$45',
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

class _SolicitudCard extends StatelessWidget {
  final _Solicitud solicitud;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _SolicitudCard({
    required this.solicitud,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  Color get _estadoColor {
    switch (solicitud.estado) {
      case 'pendiente':
        return const Color(0xFFF59E0B);
      case 'aceptado':
        return const Color(0xFF6366F1);
      case 'completado':
        return const Color(0xFF22C55E);
      case 'rechazado':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String get _estadoLabel {
    switch (solicitud.estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'aceptado':
        return 'En progreso';
      case 'completado':
        return 'Completado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return solicitud.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final esPendiente = solicitud.estado == 'pendiente';
    final esAceptado = solicitud.estado == 'aceptado';
    final btnColor = isDark ? const Color(0xFFbcbcbc) : const Color(0xFF111827);

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
          // Header: cliente + estado badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _estadoColor.withValues(alpha: 0.15),
                child: Text(
                  solicitud.cliente[0],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _estadoColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(solicitud.cliente,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(solicitud.servicio,
                        style: TextStyle(
                            fontSize: 12,
                            color: _estadoColor,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _estadoColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _estadoLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _estadoColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Descripción
          Text(
            solicitud.descripcion,
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          // Info row: ubicación + fecha/hora
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(solicitud.ubicacion,
                    style: TextStyle(fontSize: 12, color: textSecondary)),
              ),
              Icon(
                esAceptado
                    ? Icons.calendar_today_rounded
                    : Icons.access_time_rounded,
                size: 13,
                color: textSecondary,
              ),
              const SizedBox(width: 4),
              Text(solicitud.fecha,
                  style: TextStyle(fontSize: 12, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          // Presupuesto
          Row(
            children: [
              Icon(Icons.attach_money_rounded,
                  size: 14, color: const Color(0xFF22C55E)),
              const SizedBox(width: 2),
              Text(
                'Presupuesto: \$${solicitud.presupuesto.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary),
              ),
            ],
          ),
          // Barra de progreso solo para aceptados
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
                Text('${(solicitud.progreso * 100).toInt()}%',
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
                value: solicitud.progreso,
                minHeight: 7,
                backgroundColor:
                    const Color(0xFF6366F1).withValues(alpha: isDark ? 0.15 : 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366F1)),
              ),
            ),
          ],
          // Botones solo para pendientes
          if (esPendiente) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text('Rechazar',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text('Aceptar',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
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
