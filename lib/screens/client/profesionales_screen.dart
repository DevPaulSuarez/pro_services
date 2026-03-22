import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/profesional.dart';
import 'package:pro_services/models/tipo_profesion.dart';
import 'package:pro_services/services/profesional_service.dart';
import 'package:pro_services/screens/client/perfil_profesional_screen.dart';

class ProfesionalesScreen extends StatefulWidget {
  final TipoProfesion categoria;

  const ProfesionalesScreen({super.key, required this.categoria});

  @override
  State<ProfesionalesScreen> createState() => _ProfesionalesScreenState();
}

class _ProfesionalesScreenState extends State<ProfesionalesScreen> {
  late Future<List<Profesional>> _future;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _future = ProfesionalService.getPorCategoria(widget.categoria.id);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
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
    if (_query.isEmpty) return lista;
    return lista.where((p) =>
        p.nombre.toLowerCase().contains(_query) ||
        p.especialidad.toLowerCase().contains(_query)).toList();
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
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search_rounded,
                  color: isDark ? Colors.grey.shade300 : const Color(0xFF0F172A)),
              onPressed: _abrirBusqueda,
            ),
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
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: profesionales.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ProfesionalCard(
                            profesional: profesionales[index],
                            catColor: catColor,
                            isDark: isDark,
                            cardBg: cardBg,
                          );
                        },
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

  const _ProfesionalCard({
    required this.profesional,
    required this.catColor,
    required this.isDark,
    required this.cardBg,
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: catColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profesional.nombre,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(profesional.especialidad,
                        style: TextStyle(fontSize: 12, color: catColor, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: const Color(0xFFFBBF24)),
                        const SizedBox(width: 3),
                        Text(profesional.calificacion.toStringAsFixed(1),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary)),
                        const SizedBox(width: 10),
                        Icon(Icons.work_outline_rounded, size: 13, color: textSecondary),
                        const SizedBox(width: 3),
                        Text('${profesional.trabajosRealizados} trabajos',
                            style: TextStyle(fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.location_on_rounded, size: 14, color: catColor),
            const SizedBox(width: 4),
            Text(profesional.ubicacion, style: TextStyle(fontSize: 12, color: textSecondary)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.attach_money_rounded, size: 14, color: catColor),
            const SizedBox(width: 4),
            Text('\$${profesional.precioPorHora.toStringAsFixed(0)}/hora',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.schedule_rounded, size: 14, color: catColor),
            const SizedBox(width: 4),
            Text(profesional.horarioDisponibilidad, style: TextStyle(fontSize: 12, color: textSecondary)),
          ]),
          const SizedBox(height: 10),
          Text('Habilidades',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profesional.habilidades.map((h) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(20)),
              child: Text(h, style: TextStyle(fontSize: 11, color: catColor, fontWeight: FontWeight.w500)),
            )).toList(),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfilProfesionalScreen(
                          profesional: profesional,
                          catColor: catColor,
                        ),
                      ),
                    ),
                    child: const Text('Ver perfil',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                    onPressed: () {},
                    child: const Text('Contratar',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
