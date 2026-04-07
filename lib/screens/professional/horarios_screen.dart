import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/horario.dart';
import 'package:pro_services/services/horario_service.dart';

class HorariosScreen extends StatefulWidget {
  final String token;
  const HorariosScreen({super.key, required this.token});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  late Future<List<Horario>> _future;

  @override
  void initState() {
    super.initState();
    _future = HorarioService.getMiHorario(widget.token);
  }

  void _reload() =>
      setState(() => _future = HorarioService.getMiHorario(widget.token));

  Future<void> _agregarHorario() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int? diaSeleccionado;
    TimeOfDay? horaInicio;
    TimeOfDay? horaFin;
    bool guardando = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final textPrimary =
            isDark ? Colors.white : const Color(0xFF0F172A);
        final textSecondary =
            isDark ? Colors.grey.shade400 : Colors.grey.shade600;
        final borderColor =
            isDark ? Colors.grey.shade700 : Colors.grey.shade300;

        return StatefulBuilder(
          builder: (_, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Agregar horario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Día semana
                  DropdownButtonFormField<int>(
                    initialValue: diaSeleccionado,
                    style: TextStyle(fontSize: 13, color: textPrimary),
                    dropdownColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Día de la semana',
                      labelStyle:
                          TextStyle(fontSize: 13, color: textSecondary),
                      prefixIcon: const Icon(Icons.calendar_today_rounded,
                          size: 18, color: Color(0xFF6366F1)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFF6366F1)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Lunes')),
                      DropdownMenuItem(value: 2, child: Text('Martes')),
                      DropdownMenuItem(value: 3, child: Text('Miércoles')),
                      DropdownMenuItem(value: 4, child: Text('Jueves')),
                      DropdownMenuItem(value: 5, child: Text('Viernes')),
                      DropdownMenuItem(value: 6, child: Text('Sábado')),
                      DropdownMenuItem(value: 7, child: Text('Domingo')),
                    ],
                    onChanged: (v) => setModalState(() => diaSeleccionado = v),
                  ),
                  const SizedBox(height: 14),

                  // Hora inicio
                  GestureDetector(
                    onTap: () async {
                      final t = await showTimePicker(
                        context: sheetCtx,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (t != null) setModalState(() => horaInicio = t);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 18, color: Color(0xFF6366F1)),
                          const SizedBox(width: 10),
                          Text(
                            horaInicio != null
                                ? 'Inicio: ${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}'
                                : 'Hora de inicio',
                            style: TextStyle(
                              fontSize: 13,
                              color: horaInicio != null
                                  ? textPrimary
                                  : textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Hora fin
                  GestureDetector(
                    onTap: () async {
                      final t = await showTimePicker(
                        context: sheetCtx,
                        initialTime: const TimeOfDay(hour: 18, minute: 0),
                      );
                      if (t != null) setModalState(() => horaFin = t);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled_rounded,
                              size: 18, color: Color(0xFF6366F1)),
                          const SizedBox(width: 10),
                          Text(
                            horaFin != null
                                ? 'Fin: ${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}'
                                : 'Hora de fin',
                            style: TextStyle(
                              fontSize: 13,
                              color: horaFin != null
                                  ? textPrimary
                                  : textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: guardando
                          ? null
                          : () async {
                              if (diaSeleccionado == null ||
                                  horaInicio == null ||
                                  horaFin == null) {
                                ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Completá todos los campos'),
                                    backgroundColor: Color(0xFFF59E0B),
                                  ),
                                );
                                return;
                              }
                              setModalState(() => guardando = true);
                              try {
                                final hi =
                                    '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}:00';
                                final hf =
                                    '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}:00';
                                await HorarioService.agregar(
                                  widget.token,
                                  diaSemana: diaSeleccionado!,
                                  horaInicio: hi,
                                  horaFin: hf,
                                );
                                if (sheetCtx.mounted) {
                                  Navigator.pop(sheetCtx);
                                }
                                _reload();
                              } catch (e) {
                                if (sheetCtx.mounted) {
                                  ScaffoldMessenger.of(sheetCtx)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor:
                                          const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              } finally {
                                setModalState(() => guardando = false);
                              }
                            },
                      child: guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Guardar',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF0F172A);
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
          'Mi horario',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        onPressed: _agregarHorario,
        child: const Icon(Icons.add_rounded),
      ),
      body: FutureBuilder<List<Horario>>(
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
          final todos = snap.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 7,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final dia = i + 1;
              final nombres = const [
                '',
                'Lunes',
                'Martes',
                'Miércoles',
                'Jueves',
                'Viernes',
                'Sábado',
                'Domingo'
              ];
              final horariosDia =
                  todos.where((h) => h.diaSemana == dia).toList();
              return _DiaCard(
                diaNombre: nombres[dia],
                horarios: horariosDia,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onEliminar: (id) async {
                  try {
                    await HorarioService.eliminar(widget.token, id);
                    _reload();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ── Día card ──────────────────────────────────────────────────────────────────

class _DiaCard extends StatelessWidget {
  final String diaNombre;
  final List<Horario> horarios;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Future<void> Function(int id) onEliminar;

  const _DiaCard({
    required this.diaNombre,
    required this.horarios,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: horarios.isNotEmpty
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                diaNombre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (horarios.isEmpty)
            Text(
              'Sin horario',
              style: TextStyle(fontSize: 12, color: textSecondary),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: horarios.map((h) {
                final label =
                    '${h.horaInicio.substring(0, 5)} - ${h.horaFin.substring(0, 5)}';
                return Chip(
                  label: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  backgroundColor:
                      const Color(0xFF6366F1).withValues(alpha: 0.1),
                  side: BorderSide(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFF6366F1),
                  ),
                  onDeleted: () => onEliminar(h.id),
                  padding: EdgeInsets.zero,
                );
              }).toList(),
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
