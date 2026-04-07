import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/busqueda_resultado.dart';
import 'package:pro_services/models/profesional.dart';
import 'package:pro_services/services/busqueda_service.dart';
import 'package:pro_services/screens/client/perfil_profesional_screen.dart';

class BusquedaScreen extends StatefulWidget {
  final String token;
  final String nombre;

  const BusquedaScreen({
    super.key,
    required this.token,
    required this.nombre,
  });

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final TextEditingController _queryController = TextEditingController();
  Timer? _timer;
  Future<List<BusquedaResultado>>? _busquedaFuture;

  // Filtros
  double _calificacionMin = 0.0;
  double _precioMax = 500.0;
  bool _soloDisponibles = false;

  @override
  void dispose() {
    _timer?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      _ejecutarBusqueda();
    });
  }

  void _ejecutarBusqueda() {
    final query = _queryController.text.trim();
    setState(() {
      _busquedaFuture = BusquedaService.buscar(
        widget.token,
        query: query.isEmpty ? null : query,
        calificacionMin: _calificacionMin > 0 ? _calificacionMin : null,
        precioMax: _precioMax < 500 ? _precioMax : null,
        soloDisponibles: _soloDisponibles ? true : null,
      );
    });
  }

  void _mostrarFiltros() {
    double tmpCalMin = _calificacionMin;
    double tmpPrecioMax = _precioMax;
    bool tmpSoloDisp = _soloDisponibles;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Calificación mínima
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 6),
                      Text(
                        tmpCalMin == 0
                            ? 'Calificación mínima: Sin filtro'
                            : 'Calificación mínima: ${tmpCalMin.toStringAsFixed(1)}★',
                        style: TextStyle(fontSize: 13, color: textPrimary),
                      ),
                    ],
                  ),
                  Slider(
                    value: tmpCalMin,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: const Color(0xFF6366F1),
                    label: tmpCalMin == 0
                        ? 'Sin filtro'
                        : '${tmpCalMin.toStringAsFixed(1)}★',
                    onChanged: (v) => setSheetState(() => tmpCalMin = v),
                  ),
                  const SizedBox(height: 8),

                  // Precio máximo por hora
                  Row(
                    children: [
                      const Icon(Icons.attach_money_rounded,
                          size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        tmpPrecioMax >= 500
                            ? 'Precio máx/hora: Sin límite'
                            : 'Precio máx/hora: \$${tmpPrecioMax.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 13, color: textPrimary),
                      ),
                    ],
                  ),
                  Slider(
                    value: tmpPrecioMax,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    activeColor: const Color(0xFF10B981),
                    label: tmpPrecioMax >= 500
                        ? 'Sin límite'
                        : '\$${tmpPrecioMax.toStringAsFixed(0)}',
                    onChanged: (v) => setSheetState(() => tmpPrecioMax = v),
                  ),
                  const SizedBox(height: 8),

                  // Solo disponibles
                  Row(
                    children: [
                      Switch(
                        value: tmpSoloDisp,
                        activeThumbColor: const Color(0xFF6366F1),
                        onChanged: (v) =>
                            setSheetState(() => tmpSoloDisp = v),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Solo disponibles ahora',
                        style: TextStyle(fontSize: 13, color: textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // Limpiar
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF374151),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _calificacionMin = 0.0;
                                _precioMax = 500.0;
                                _soloDisponibles = false;
                              });
                              Navigator.pop(ctx);
                              if (_queryController.text.isNotEmpty ||
                                  _busquedaFuture != null) {
                                _ejecutarBusqueda();
                              }
                            },
                            child: const Text('Limpiar'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Aplicar
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _calificacionMin = tmpCalMin;
                                _precioMax = tmpPrecioMax;
                                _soloDisponibles = tmpSoloDisp;
                              });
                              Navigator.pop(ctx);
                              _ejecutarBusqueda();
                            },
                            child: const Text(
                              'Aplicar filtros',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navegarAlPerfil(BuildContext context, BusquedaResultado resultado) {
    // Construimos un Profesional mínimo con los datos disponibles
    final profesional = Profesional(
      id: resultado.id,
      nombre: resultado.nombre,
      especialidad: resultado.especialidad,
      calificacion: resultado.calificacion,
      trabajosRealizados: 0,
      ubicacion: resultado.ubicacion ?? '',
      precioPorHora: resultado.precioPorHora,
      horarioDisponibilidad: '',
      habilidades: const [],
      disponibleAhora: resultado.disponibleAhora,
      telefono: '',
      correo: '',
      sobreMi: '',
      esVerificado: resultado.esVerificado,
      aniosExperiencia: 0,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PerfilProfesionalScreen(
          profesional: profesional,
          catColor: const Color(0xFF6366F1),
          token: widget.token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

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
          'Buscar profesionales',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF0F172A),
            ),
            tooltip: 'Filtros',
            onPressed: _mostrarFiltros,
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
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _queryController,
                autofocus: true,
                onChanged: _onQueryChanged,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Buscá por nombre o especialidad...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                  suffixIcon: _queryController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                          onPressed: () {
                            _queryController.clear();
                            setState(() => _busquedaFuture = null);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Indicadores de filtros activos
          if (_calificacionMin > 0 || _precioMax < 500 || _soloDisponibles)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded,
                      size: 14,
                      color: const Color(0xFF6366F1)),
                  const SizedBox(width: 4),
                  Text(
                    'Filtros activos',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _calificacionMin = 0.0;
                        _precioMax = 500.0;
                        _soloDisponibles = false;
                      });
                      _ejecutarBusqueda();
                    },
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Resultados
          Expanded(
            child: _busquedaFuture == null
                ? _EmptyPrompt(isDark: isDark)
                : FutureBuilder<List<BusquedaResultado>>(
                    future: _busquedaFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _ErrorView(
                          isDark: isDark,
                          onRetry: _ejecutarBusqueda,
                        );
                      }

                      final resultados = snapshot.data!;

                      if (resultados.isEmpty) {
                        return _NoResultados(isDark: isDark);
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: resultados.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ResultadoCard(
                            resultado: resultados[index],
                            isDark: isDark,
                            cardBg: cardBg,
                            onTap: () =>
                                _navegarAlPerfil(context, resultados[index]),
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

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _EmptyPrompt extends StatelessWidget {
  final bool isDark;
  const _EmptyPrompt({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.manage_search_rounded,
            size: 64,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Buscá un profesional\npor nombre o especialidad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultados extends StatelessWidget {
  final bool isDark;
  const _NoResultados({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 56,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin resultados para tu búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Probá con otros términos o ajustá los filtros',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorView({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Error al buscar profesionales',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final BusquedaResultado resultado;
  final bool isDark;
  final Color cardBg;
  final VoidCallback onTap;

  const _ResultadoCard({
    required this.resultado,
    required this.isDark,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    const accentColor = Color(0xFF6366F1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar con inicial
            CircleAvatar(
              radius: 26,
              backgroundColor: accentColor.withValues(alpha: 0.15),
              child: Text(
                resultado.nombre.isNotEmpty ? resultado.nombre[0] : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Datos principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + badge verificado
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resultado.nombre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      if (resultado.nivelVerificacion > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded,
                                  size: 11,
                                  color: Color(0xFF10B981)),
                              const SizedBox(width: 3),
                              Text(
                                'Nivel ${resultado.nivelVerificacion}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Especialidad
                  Text(
                    resultado.especialidad,
                    style: const TextStyle(
                      fontSize: 12,
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Calificación + precio + disponibilidad
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 3),
                      Text(
                        resultado.calificacion.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.attach_money_rounded,
                          size: 14, color: Color(0xFF10B981)),
                      Text(
                        '\$${resultado.precioPorHora.toStringAsFixed(0)}/h',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      if (resultado.disponibleAhora) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Disponible',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Ubicación / distancia
                  if (resultado.ubicacion != null ||
                      resultado.distanciaKm != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13, color: textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          resultado.distanciaKm != null
                              ? '${resultado.distanciaKm!.toStringAsFixed(1)} km'
                              : resultado.ubicacion!,
                          style: TextStyle(
                              fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(Icons.chevron_right_rounded,
                color: isDark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
