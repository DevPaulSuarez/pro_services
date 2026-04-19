import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/profesional.dart';
import 'package:pro_services/models/tipo_profesion.dart';
import 'package:pro_services/services/profesional_service.dart';
import 'package:pro_services/screens/client/perfil_profesional_screen.dart';
import 'package:pro_services/screens/client/crear_solicitud_screen.dart';
import 'package:pro_services/services/favorito_service.dart';

class ProfesionalesScreen extends StatefulWidget {
  final TipoProfesion categoria;
  final String token;

  const ProfesionalesScreen({
    super.key,
    required this.categoria,
    required this.token,
  });

  @override
  State<ProfesionalesScreen> createState() => _ProfesionalesScreenState();
}

class _ProfesionalesScreenState extends State<ProfesionalesScreen> {
  late Future<List<Profesional>> _future;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  bool _isSearching = false;

  // Filtros
  double _minCalificacion = 0.0;
  double _maxPrecio = 9999.0;
  bool _soloDisponibles = false;

  Set<int> _favoritosIds = {};

  @override
  void initState() {
    super.initState();
    _future = ProfesionalService.getPorCategoria(widget.categoria.id);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    try {
      final ids = await FavoritoService.getIdsFavoritos(widget.token);
      if (mounted) setState(() => _favoritosIds = ids);
    } catch (_) {}
  }

  Future<void> _toggleFavorito(int idProfesional) async {
    try {
      if (_favoritosIds.contains(idProfesional)) {
        await FavoritoService.quitar(widget.token, idProfesional);
        if (mounted) setState(() => _favoritosIds.remove(idProfesional));
      } else {
        await FavoritoService.agregar(widget.token, idProfesional);
        if (mounted) setState(() => _favoritosIds.add(idProfesional));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _abrirBusqueda() {
    setState(() => _isSearching = true);
    Future.microtask(() => _searchFocus.requestFocus());
  }

  void _cerrarBusqueda() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _isSearching = false);
  }

  List<Profesional> _filtrar(List<Profesional> lista) {
    return lista.where((p) {
      if (_query.isNotEmpty &&
          !p.nombre.toLowerCase().contains(_query) &&
          !p.especialidad.toLowerCase().contains(_query)) { return false; }
      if (p.calificacion < _minCalificacion) return false;
      if (p.precioPorHora > _maxPrecio) return false;
      if (_soloDisponibles && !p.disponibleAhora) return false;
      return true;
    }).toList();
  }

  void _mostrarFiltros() {
    // Valores temporales para el sheet
    double tmpMinCal = _minCalificacion;
    double tmpMaxPrecio = _maxPrecio;
    bool tmpSoloDisp = _soloDisponibles;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
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
                        color: textPrimary),
                  ),
                  const SizedBox(height: 20),

                  // Calificación mínima
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 16, color: const Color(0xFFFBBF24)),
                      const SizedBox(width: 6),
                      Text(
                        'Calificación mínima: ${tmpMinCal.toStringAsFixed(1)}★',
                        style: TextStyle(fontSize: 13, color: textPrimary),
                      ),
                    ],
                  ),
                  Slider(
                    value: tmpMinCal,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: const Color(0xFF6366F1),
                    label: '${tmpMinCal.toStringAsFixed(1)}★',
                    onChanged: (v) =>
                        setSheetState(() => tmpMinCal = v),
                  ),
                  const SizedBox(height: 8),

                  // Precio máximo
                  Row(
                    children: [
                      Icon(Icons.attach_money_rounded,
                          size: 16, color: const Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        'Precio máx/hora: \$${tmpMaxPrecio >= 9999 ? "Sin límite" : tmpMaxPrecio.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 13, color: textPrimary),
                      ),
                    ],
                  ),
                  Slider(
                    value: tmpMaxPrecio.clamp(0, 500),
                    min: 0,
                    max: 500,
                    divisions: 50,
                    activeColor: const Color(0xFF10B981),
                    label: tmpMaxPrecio >= 500
                        ? 'Sin límite'
                        : '\$${tmpMaxPrecio.toStringAsFixed(0)}',
                    onChanged: (v) => setSheetState(
                        () => tmpMaxPrecio = v >= 500 ? 9999.0 : v),
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
                      Text('Solo disponibles ahora',
                          style:
                              TextStyle(fontSize: 13, color: textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _minCalificacion = tmpMinCal;
                          _maxPrecio = tmpMaxPrecio;
                          _soloDisponibles = tmpSoloDisp;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Aplicar',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color get _catColor {
    try {
      return Color(int.parse('FF${widget.categoria.color}', radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final catColor = _catColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _isSearching ? Icons.close_rounded : Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: _isSearching ? _cerrarBusqueda : () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: true,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o habilidad',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.categoria.nombre,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${widget.categoria.profesionalesRegistrados} profesionales',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: catColor,
                    ),
                  ),
                ],
              ),
        actions: [
          if (!_isSearching) ...[
            IconButton(
              icon: Icon(Icons.tune_rounded,
                  color: isDark
                      ? Colors.grey.shade300
                      : const Color(0xFF0F172A)),
              onPressed: _mostrarFiltros,
            ),
            IconButton(
              icon: Icon(Icons.search_rounded,
                  color: isDark
                      ? Colors.grey.shade300
                      : const Color(0xFF0F172A)),
              onPressed: _abrirBusqueda,
            ),
          ],
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
            ),
            onPressed: () => MyApp.of(context).toggleTheme(),
          ),
        ],
      ),
      body: FutureBuilder<List<Profesional>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('Error al cargar profesionales',
                      style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _future = ProfesionalService.getPorCategoria(
                          widget.categoria.id);
                    }),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final todos = snapshot.data!;
          final profesionales = _filtrar(todos);

          return Column(
            children: [
              Expanded(
                child: profesionales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search_rounded,
                                size: 56,
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _query.isEmpty
                                  ? 'Sin profesionales disponibles'
                                  : 'Sin resultados para "$_query"',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _future = ProfesionalService.getPorCategoria(widget.categoria.id);
                          });
                          await _future;
                        },
                        child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: profesionales.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ProfesionalCard(
                            profesional: profesionales[index],
                            catColor: catColor,
                            isDark: isDark,
                            cardBg: cardBg,
                            token: widget.token,
                            esFavorito: _favoritosIds.contains(profesionales[index].id),
                            onToggleFavorito: () => _toggleFavorito(profesionales[index].id),
                          );
                        },
                      ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfesionalCard extends StatelessWidget {
  final Profesional profesional;
  final Color catColor;
  final bool isDark;
  final Color cardBg;
  final String token;
  final bool esFavorito;
  final VoidCallback onToggleFavorito;

  const _ProfesionalCard({
    required this.profesional,
    required this.catColor,
    required this.isDark,
    required this.cardBg,
    required this.token,
    required this.esFavorito,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final btnColor = isDark ? const Color(0xFFbcbcbc) : const Color(0xFF111827);
    final chipBg = catColor.withValues(alpha: isDark ? 0.18 : 0.1);

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
          // Fila superior: avatar + info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: catColor.withValues(alpha: 0.15),
                child: Text(
                  profesional.nombre[0],
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: catColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profesional.nombre,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(profesional.especialidad,
                        style: TextStyle(
                            fontSize: 12,
                            color: catColor,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 14, color: const Color(0xFFFBBF24)),
                        const SizedBox(width: 3),
                        Text(profesional.calificacion.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textPrimary)),
                        const SizedBox(width: 10),
                        Icon(Icons.work_outline_rounded,
                            size: 13, color: textSecondary),
                        const SizedBox(width: 3),
                        Text('${profesional.trabajosRealizados} trabajos',
                            style: TextStyle(
                                fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: esFavorito ? Colors.red : textSecondary,
                  size: 22,
                ),
                onPressed: onToggleFavorito,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.location_on_rounded, size: 14, color: catColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(profesional.ubicacion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: textSecondary)),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.attach_money_rounded, size: 14, color: catColor),
            const SizedBox(width: 4),
            Text('\$${profesional.precioPorHora.toStringAsFixed(0)}/hora',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary)),
            if (profesional.distanciaKm != null) ...[
              const SizedBox(width: 12),
              const Icon(Icons.location_on_rounded,
                  size: 12, color: Color(0xFF6366F1)),
              const SizedBox(width: 2),
              Text(
                '${profesional.distanciaKm!.toStringAsFixed(1)} km',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.schedule_rounded, size: 14, color: catColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(profesional.horarioDisponibilidad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: textSecondary)),
            ),
          ]),
          const SizedBox(height: 10),
          Text('Habilidades',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textPrimary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profesional.habilidades
                .map((h) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(h,
                          style: TextStyle(
                              fontSize: 11,
                              color: catColor,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: btnColor,
                      side: BorderSide(color: btnColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfilProfesionalScreen(
                          profesional: profesional,
                          catColor: catColor,
                          token: token,
                        ),
                      ),
                    ),
                    child: const Text('Ver perfil',
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CrearSolicitudScreen(
                            token: token,
                            profesional: profesional,
                          ),
                        ),
                      );
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Solicitud enviada exitosamente!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    child: const Text('Contratar',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
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
