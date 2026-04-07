import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/tipo_profesion.dart';
import 'package:pro_services/screens/professional/solicitar_verificacion_screen.dart';
import 'package:pro_services/services/perfil_profesional_service.dart';
import 'package:pro_services/services/tipo_profesion_service.dart';
import 'package:pro_services/services/ubicacion_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final String token;
  const EditarPerfilScreen({super.key, required this.token});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl    = TextEditingController();
  final _bioCtrl       = TextEditingController();
  final _precioCtrl    = TextEditingController();
  final _telefonoCtrl  = TextEditingController();
  final _correoCtrl    = TextEditingController();
  final _ciudadCtrl    = TextEditingController();
  final _habilidadCtrl = TextEditingController();
  final _aniosCtrl     = TextEditingController();

  List<String> _habilidades = [];
  List<TipoProfesion> _tiposProfesion = [];
  String? _especialidadSeleccionada;
  bool _cargando = true;
  bool _guardando = false;
  bool _guardandoUbicacion = false;
  bool _ubicacionActualizada = false;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
    _cargarPerfil();
  }

  Future<void> _cargarTipos() async {
    try {
      final tipos = await TipoProfesionService.getTipos();
      if (!mounted) return;
      setState(() => _tiposProfesion = tipos);
    } catch (_) {}
  }

  Future<void> _cargarPerfil() async {
    try {
      final perfil = await PerfilProfesionalService.getMe(widget.token);
      if (!mounted) return;
      _nombreCtrl.text    = perfil.nombre;
      _bioCtrl.text       = perfil.sobreMi;
      _precioCtrl.text    = perfil.precioPorHora.toStringAsFixed(0);
      _telefonoCtrl.text  = perfil.telefono;
      _correoCtrl.text    = perfil.correo;
      _ciudadCtrl.text    = perfil.ubicacion;
      _habilidades        = List<String>.from(perfil.habilidades);
      _aniosCtrl.text     = perfil.aniosExperiencia.toString();
      setState(() {
        _especialidadSeleccionada =
            perfil.especialidad.isNotEmpty ? perfil.especialidad : null;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _bioCtrl.dispose();
    _precioCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _ciudadCtrl.dispose();
    _habilidadCtrl.dispose();
    _aniosCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await PerfilProfesionalService.updateMe(
        widget.token,
        nombre:          _nombreCtrl.text.trim(),
        especialidad:    _especialidadSeleccionada ?? '',
        bio:             _bioCtrl.text.trim(),
        ciudad:          _ciudadCtrl.text.trim(),
        telefono:        _telefonoCtrl.text.trim(),
        correo:          _correoCtrl.text.trim(),
        precioPorHora:   double.tryParse(_precioCtrl.text) ?? 0,
        habilidades:     _habilidades,
        aniosExperiencia: int.tryParse(_aniosCtrl.text) ?? 0,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _actualizarUbicacion() async {
    setState(() => _guardandoUbicacion = true);
    try {
      // Coordenadas hardcodeadas por ahora (Lima, Perú).
      // En producción se reemplaza por geolocator una vez configurados los permisos nativos.
      const double latSimulada = -12.0464;
      const double lonSimulada = -77.0428;
      await UbicacionService.actualizarUbicacion(
        widget.token,
        latitud: latSimulada,
        longitud: lonSimulada,
      );
      if (!mounted) return;
      setState(() => _ubicacionActualizada = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación actualizada correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar ubicación: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardandoUbicacion = false);
    }
  }

  void _agregarHabilidad() {
    final texto = _habilidadCtrl.text.trim();
    if (texto.isEmpty || _habilidades.contains(texto)) return;
    setState(() {
      _habilidades.add(texto);
      _habilidadCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg    = isDark ? const Color(0xFF1E293B) : Colors.white;
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
        title: Text('Editar perfil',
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
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Foto de perfil ─────────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      child: const Text('A',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6366F1))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Toca el ícono para cambiar la foto',
                    style: TextStyle(fontSize: 12, color: textSecondary)),
              ),
              const SizedBox(height: 24),

              // ── Información personal ───────────────────────────────────────
              _SectionLabel(label: 'Información personal', textPrimary: textPrimary),
              const SizedBox(height: 12),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  children: [
                    _Field(
                      ctrl: _nombreCtrl,
                      label: 'Nombre completo',
                      icon: Icons.person_rounded,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _tiposProfesion.any((t) => t.nombre == _especialidadSeleccionada)
                          ? _especialidadSeleccionada
                          : null,
                      style: TextStyle(fontSize: 13, color: textPrimary),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Especialidad / Profesión',
                        labelStyle: TextStyle(fontSize: 13, color: textSecondary),
                        prefixIcon: const Icon(Icons.work_rounded,
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
                      items: _tiposProfesion
                          .where((t) => t.nombre.isNotEmpty)
                          .fold<Map<String, TipoProfesion>>({}, (map, t) {
                            map.putIfAbsent(t.nombre, () => t);
                            return map;
                          })
                          .values
                          .map((t) => DropdownMenuItem<String>(
                                value: t.nombre,
                                child: Text(t.nombre,
                                    style: TextStyle(
                                        fontSize: 13, color: textPrimary)),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _especialidadSeleccionada = val),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      ctrl: _aniosCtrl,
                      label: 'Años de experiencia',
                      icon: Icons.timeline_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      ctrl: _bioCtrl,
                      label: 'Descripción / Bio',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      ctrl: _ciudadCtrl,
                      label: 'Ubicación / Ciudad',
                      icon: Icons.location_on_rounded,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Contacto ───────────────────────────────────────────────────
              _SectionLabel(label: 'Contacto', textPrimary: textPrimary),
              const SizedBox(height: 12),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  children: [
                    _Field(
                      ctrl: _telefonoCtrl,
                      label: 'Teléfono',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      ctrl: _correoCtrl,
                      label: 'Correo electrónico',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo requerido';
                        if (!v.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Tarifa ─────────────────────────────────────────────────────
              _SectionLabel(label: 'Tarifa', textPrimary: textPrimary),
              const SizedBox(height: 12),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: _Field(
                  ctrl: _precioCtrl,
                  label: 'Precio por hora (USD)',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
              ),
              const SizedBox(height: 20),

              // ── Habilidades ────────────────────────────────────────────────
              _SectionLabel(label: 'Habilidades', textPrimary: textPrimary),
              const SizedBox(height: 12),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _habilidades
                          .map((h) => Chip(
                                label: Text(h,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6366F1))),
                                backgroundColor:
                                    const Color(0xFF6366F1).withValues(alpha: 0.1),
                                side: BorderSide(
                                    color: const Color(0xFF6366F1)
                                        .withValues(alpha: 0.3)),
                                deleteIcon: const Icon(Icons.close_rounded,
                                    size: 14, color: Color(0xFF6366F1)),
                                onDeleted: () =>
                                    setState(() => _habilidades.remove(h)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _habilidadCtrl,
                            style: TextStyle(fontSize: 13, color: textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Nueva habilidad...',
                              hintStyle: TextStyle(
                                  fontSize: 13, color: textSecondary),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
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
                                borderSide: const BorderSide(
                                    color: Color(0xFF6366F1)),
                              ),
                            ),
                            onFieldSubmitted: (_) => _agregarHabilidad(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _agregarHabilidad,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_rounded,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Ubicación ──────────────────────────────────────────────────
              _SectionLabel(label: 'Ubicación y cobertura', textPrimary: textPrimary),
              const SizedBox(height: 12),
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ubicacionActualizada
                          ? '✓ Ubicación actualizada'
                          : 'Tu ubicación ayuda a los clientes a encontrarte',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _guardandoUbicacion ? null : _actualizarUbicacion,
                        icon: _guardandoUbicacion
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.my_location_rounded, size: 18),
                        label: const Text('Actualizar mi ubicación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Verificación ───────────────────────────────────────────────
              _card(
                isDark: isDark,
                cardBg: cardBg,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_user_rounded,
                      color: Color(0xFF6366F1)),
                  title: Text(
                    'Verificar mi perfil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Subí documentos para obtener el badge',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SolicitarVerificacionScreen(token: widget.token),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Botón guardar ──────────────────────────────────────────────
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
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar cambios',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
      {required bool isDark,
      required Color cardBg,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textPrimary;
  const _SectionLabel({required this.label, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textPrimary));
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
