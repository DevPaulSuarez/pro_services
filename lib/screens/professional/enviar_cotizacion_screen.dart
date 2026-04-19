import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pro_services/config.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/proyecto.dart';
import 'package:pro_services/models/plantilla_cotizacion.dart';
import 'package:pro_services/services/plantilla_service.dart';

class EnviarCotizacionScreen extends StatefulWidget {
  final String token;
  final Proyecto proyecto;

  const EnviarCotizacionScreen({
    super.key,
    required this.token,
    required this.proyecto,
  });

  @override
  State<EnviarCotizacionScreen> createState() => _EnviarCotizacionScreenState();
}

class _EnviarCotizacionScreenState extends State<EnviarCotizacionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _manoObraCtrl    = TextEditingController();
  final _materialesCtrl  = TextEditingController();
  final _trasladoCtrl    = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  bool _enviando = false;
  List<PlantillaCotizacion> _plantillas = [];

  double get _total =>
      (double.tryParse(_manoObraCtrl.text) ?? 0) +
      (double.tryParse(_materialesCtrl.text) ?? 0) +
      (double.tryParse(_trasladoCtrl.text) ?? 0);

  @override
  void initState() {
    super.initState();
    _cargarPlantillas();
  }

  Future<void> _cargarPlantillas() async {
    try {
      final list = await PlantillaService.getMias(widget.token);
      if (mounted) setState(() => _plantillas = list);
    } catch (_) {}
  }

  void _mostrarPlantillas() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView.builder(
          itemCount: _plantillas.length,
          itemBuilder: (ctx, i) {
            final p = _plantillas[i];
            return ListTile(
              title: Text(p.nombre),
              subtitle: Text('Total: S/ ${p.total.toStringAsFixed(2)}'),
              onTap: () {
                Navigator.pop(ctx);
                _aplicarPlantilla(p);
              },
            );
          },
        );
      },
    );
  }

  void _aplicarPlantilla(PlantillaCotizacion plantilla) {
    setState(() {
      _manoObraCtrl.text = plantilla.manoObra.toStringAsFixed(2);
      _materialesCtrl.text = plantilla.materiales.toStringAsFixed(2);
      _trasladoCtrl.text = plantilla.traslado.toStringAsFixed(2);
      _observacionesCtrl.text = plantilla.observaciones ?? '';
    });
  }

  @override
  void dispose() {
    _manoObraCtrl.dispose();
    _materialesCtrl.dispose();
    _trasladoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _fechaSeleccionada = fecha);
  }

  Future<void> _seleccionarHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (hora != null) setState(() => _horaInicio = hora);
  }

  Future<void> _seleccionarHoraFin() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (hora != null) setState(() => _horaFin = hora);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná una fecha del servicio'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await _enviarCotizacion(widget.token, {
        'idUsuario': widget.proyecto.idUsuario,
        'idProfesional': 0, // el backend lo extrae del claim
        'idTipoServicio': 1,
        'fechaServicio': _formatDate(_fechaSeleccionada!),
        'horaInicio': _horaInicio != null
            ? _formatTime(_horaInicio!)
            : '08:00:00',
        'horaFin': _horaFin != null ? _formatTime(_horaFin!) : '18:00:00',
        'precioPropuesto': _total,
        'observaciones': _observacionesCtrl.text.trim(),
        'usuarioCreacion': 'app',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cotización enviada al cliente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  static Future<void> _enviarCotizacion(
      String token, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBase}/api/Cotizacion'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade300;

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
          'Enviar cotización',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info del proyecto ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
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
                    Row(
                      children: [
                        const Icon(Icons.work_outline_rounded,
                            size: 16, color: Color(0xFF6366F1)),
                        const SizedBox(width: 6),
                        Text(
                          'Detalles del proyecto',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.build_rounded,
                      label: 'Servicio',
                      value: widget.proyecto.servicio,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.person_rounded,
                      label: 'Cliente',
                      value: widget.proyecto.cliente,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    if (widget.proyecto.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.notes_rounded,
                        label: 'Descripción',
                        value: widget.proyecto.descripcion,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Costos ──────────────────────────────────────────────────
              Text(
                'Desglose de costos',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_plantillas.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.playlist_add_check_rounded),
                  label: const Text('Usar plantilla'),
                  onPressed: _mostrarPlantillas,
                ),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  children: [
                    _Field(
                      ctrl: _manoObraCtrl,
                      label: 'Mano de obra (USD)',
                      icon: Icons.handyman_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      onChanged: (_) => setState(() {}),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Campo requerido'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      ctrl: _materialesCtrl,
                      label: 'Materiales (USD)',
                      icon: Icons.inventory_2_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      ctrl: _trasladoCtrl,
                      label: 'Traslado / viáticos (USD)',
                      icon: Icons.directions_car_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      ctrl: _observacionesCtrl,
                      label: 'Observaciones',
                      icon: Icons.comment_rounded,
                      maxLines: 3,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Total ────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total a cobrar:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '\$${_total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Fecha y horario ──────────────────────────────────────────
              Text(
                'Fecha y horario del servicio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  children: [
                    // Fecha
                    GestureDetector(
                      onTap: _seleccionarFecha,
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
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: Color(0xFF6366F1)),
                            const SizedBox(width: 10),
                            Text(
                              _fechaSeleccionada != null
                                  ? _formatDate(_fechaSeleccionada!)
                                  : 'Seleccionar fecha',
                              style: TextStyle(
                                fontSize: 13,
                                color: _fechaSeleccionada != null
                                    ? textPrimary
                                    : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Hora inicio
                    GestureDetector(
                      onTap: _seleccionarHoraInicio,
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
                              _horaInicio != null
                                  ? 'Inicio: ${_formatTime(_horaInicio!)}'
                                  : 'Seleccionar hora inicio',
                              style: TextStyle(
                                fontSize: 13,
                                color: _horaInicio != null
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
                      onTap: _seleccionarHoraFin,
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
                              _horaFin != null
                                  ? 'Fin: ${_formatTime(_horaFin!)}'
                                  : 'Seleccionar hora fin',
                              style: TextStyle(
                                fontSize: 13,
                                color: _horaFin != null
                                    ? textPrimary
                                    : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Botón enviar ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _enviando ? null : _enviar,
                  icon: _enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    _enviando ? 'Enviando...' : 'Enviar cotización',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required bool isDark,
    required Color cardBg,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 13, color: textPrimary),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: textSecondary),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}
