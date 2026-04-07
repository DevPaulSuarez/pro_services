import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/tipo_profesion.dart';
import 'package:pro_services/services/solicitud_abierta_service.dart';
import 'package:pro_services/services/tipo_profesion_service.dart';

class CrearSolicitudAbiertaScreen extends StatefulWidget {
  final String token;
  const CrearSolicitudAbiertaScreen({super.key, required this.token});

  @override
  State<CrearSolicitudAbiertaScreen> createState() =>
      _CrearSolicitudAbiertaScreenState();
}

class _CrearSolicitudAbiertaScreenState
    extends State<CrearSolicitudAbiertaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloCtrl       = TextEditingController();
  final _descripcionCtrl  = TextEditingController();
  final _presupuestoCtrl  = TextEditingController();
  final _ubicacionCtrl    = TextEditingController();

  TipoProfesion? _categoriaSeleccionada;
  DateTime? _fechaLimite;
  bool _esUrgente = false;
  bool _guardando = false;

  late Future<List<TipoProfesion>> _tiposFuture;

  @override
  void initState() {
    super.initState();
    _tiposFuture = TipoProfesionService.getTipos();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _presupuestoCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  Future<void> _pickFechaLimite() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _fechaLimite = picked);
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná una categoría'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await SolicitudAbiertaService.crear(
        widget.token,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        tipoProfesionId: _categoriaSeleccionada!.id,
        presupuestoMax: _presupuestoCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_presupuestoCtrl.text.trim()),
        ubicacion: _ubicacionCtrl.text.trim().isEmpty
            ? null
            : _ubicacionCtrl.text.trim(),
        fechaLimite: _fechaLimite?.toIso8601String(),
        esUrgente: _esUrgente,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud publicada!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final bgColor       = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg        = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor   = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

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
          'Publicar solicitud',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ────────────────────────────────────────────────────
              _Field(
                ctrl: _tituloCtrl,
                label: 'Título de la solicitud',
                icon: Icons.title_rounded,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                borderColor: borderColor,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── Descripción ───────────────────────────────────────────────
              _Field(
                ctrl: _descripcionCtrl,
                label: 'Descripción del trabajo',
                icon: Icons.notes_rounded,
                maxLines: 4,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                borderColor: borderColor,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── Categoría (dropdown con FutureBuilder) ────────────────────
              FutureBuilder<List<TipoProfesion>>(
                future: _tiposFuture,
                builder: (context, snap) {
                  final tipos = snap.data ?? [];
                  return DropdownButtonFormField<TipoProfesion>(
                    initialValue: _categoriaSeleccionada,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: snap.connectionState == ConnectionState.waiting
                          ? 'Cargando categorías...'
                          : 'Categoría',
                      labelStyle:
                          TextStyle(fontSize: 13, color: textSecondary),
                      prefixIcon: const Icon(Icons.category_rounded,
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
                    dropdownColor: cardBg,
                    style: TextStyle(fontSize: 13, color: textPrimary),
                    items: tipos
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.nombre,
                                  style: TextStyle(
                                      fontSize: 13, color: textPrimary)),
                            ))
                        .toList(),
                    onChanged: tipos.isEmpty
                        ? null
                        : (v) =>
                            setState(() => _categoriaSeleccionada = v),
                    validator: (_) => _categoriaSeleccionada == null
                        ? 'Seleccioná una categoría'
                        : null,
                  );
                },
              ),
              const SizedBox(height: 14),

              // ── Presupuesto máximo (opcional) ─────────────────────────────
              _Field(
                ctrl: _presupuestoCtrl,
                label: 'Presupuesto máximo (opcional)',
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'))
                ],
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                borderColor: borderColor,
              ),
              const SizedBox(height: 14),

              // ── Ubicación (opcional) ──────────────────────────────────────
              _Field(
                ctrl: _ubicacionCtrl,
                label: 'Ubicación (opcional)',
                icon: Icons.location_on_rounded,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                borderColor: borderColor,
              ),
              const SizedBox(height: 14),

              // ── Fecha límite (opcional) ───────────────────────────────────
              GestureDetector(
                onTap: _pickFechaLimite,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 18, color: Color(0xFF6366F1)),
                      const SizedBox(width: 10),
                      Text(
                        _fechaLimite != null
                            ? _formatDate(_fechaLimite!)
                            : 'Fecha límite (opcional)',
                        style: TextStyle(
                          fontSize: 13,
                          color: _fechaLimite != null
                              ? textPrimary
                              : textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (_fechaLimite != null)
                        GestureDetector(
                          onTap: () => setState(() => _fechaLimite = null),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Es urgente (Switch) ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.priority_high_rounded,
                        size: 18, color: Color(0xFFEF4444)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Urgente',
                        style:
                            TextStyle(fontSize: 13, color: textPrimary),
                      ),
                    ),
                    Switch(
                      value: _esUrgente,
                      activeThumbColor: const Color(0xFFEF4444),
                      onChanged: (v) => setState(() => _esUrgente = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Botón publicar ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _guardando ? null : _publicar,
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Publicar solicitud',
                          style: TextStyle(
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
}

// ── _Field ─────────────────────────────────────────────────────────────────────

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
