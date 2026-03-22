import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_services/main.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreCtrl       = TextEditingController(text: 'Andres Molina');
  final _especialidadCtrl = TextEditingController(text: 'Electricista certificado');
  final _bioCtrl          = TextEditingController(
      text: 'Profesional con más de 8 años de experiencia en instalaciones eléctricas residenciales e industriales.');
  final _precioCtrl       = TextEditingController(text: '45');
  final _telefonoCtrl     = TextEditingController(text: '+57 300 123 4567');
  final _correoCtrl       = TextEditingController(text: 'andres.molina@email.com');
  final _ciudadCtrl       = TextEditingController(text: 'Bogotá, Colombia');

  // Habilidades
  final List<String> _habilidades = [
    'Instalaciones eléctricas',
    'Mantenimiento',
    'Redes industriales',
    'Domótica',
  ];
  final _habilidadCtrl = TextEditingController();

  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _especialidadCtrl.dispose();
    _bioCtrl.dispose();
    _precioCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _ciudadCtrl.dispose();
    _habilidadCtrl.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perfil actualizado correctamente'),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
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
      body: Form(
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
                    _Field(
                      ctrl: _especialidadCtrl,
                      label: 'Especialidad / Profesión',
                      icon: Icons.work_rounded,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Campo requerido' : null,
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
