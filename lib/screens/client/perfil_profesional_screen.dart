import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/profesional.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilProfesionalScreen extends StatelessWidget {
  final Profesional profesional;
  final Color catColor;

  const PerfilProfesionalScreen({
    super.key,
    required this.profesional,
    required this.catColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final btnColor = isDark ? const Color(0xFF64748B) : const Color(0xFF111827);
    final chipBg = catColor.withValues(alpha: isDark ? 0.18 : 0.1);

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
          'Perfil del profesional',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header del perfil ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: catColor.withValues(alpha: 0.15),
                    child: Text(
                      profesional.nombre[0],
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: catColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profesional.nombre,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profesional.especialidad,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: catColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Badge de disponibilidad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: profesional.disponibleAhora
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: profesional.disponibleAhora
                                ? const Color(0xFF10B981)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          profesional.disponibleAhora
                              ? 'Disponible ahora'
                              : 'No disponible',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: profesional.disponibleAhora
                                ? const Color(0xFF10B981)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFFFBBF24),
                        value: profesional.calificacion.toStringAsFixed(1),
                        label: 'Calificación',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      _Divider(isDark: isDark),
                      _Stat(
                        icon: Icons.work_outline_rounded,
                        iconColor: catColor,
                        value: '${profesional.trabajosRealizados}',
                        label: 'Trabajos',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Botones de acción rápida
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: btnColor,
                              side: BorderSide(color: btnColor),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                            label: const Text('Contactar',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: catColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.request_quote_rounded, size: 16),
                            label: const Text('Cotización',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Sobre mí ---
            _Section(
              title: 'Sobre mí',
              cardBg: cardBg,
              isDark: isDark,
              child: Text(
                profesional.sobreMi,
                style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),

            // --- Info de contacto ---
            _Section(
              title: 'Información',
              cardBg: cardBg,
              isDark: isDark,
              child: Column(
                children: [
                  // Ubicación + botón Maps
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: catColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(profesional.ubicacion,
                            style: TextStyle(fontSize: 13, color: textSecondary)),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final query = Uri.encodeComponent(profesional.ubicacion);
                          final uri = Uri.parse('https://maps.google.com/?q=$query');
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_rounded, size: 13, color: catColor),
                              const SizedBox(width: 4),
                              Text('Maps',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: catColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.attach_money_rounded,
                    iconColor: catColor,
                    text: '\$${profesional.precioPorHora.toStringAsFixed(0)} / hora',
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    iconColor: catColor,
                    text: profesional.horarioDisponibilidad,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    iconColor: catColor,
                    text: profesional.telefono,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.email_rounded,
                    iconColor: catColor,
                    text: profesional.correo,
                    textSecondary: textSecondary,
                  ),
                  if (profesional.sitioWeb != null) ...[
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.language_rounded,
                      iconColor: catColor,
                      text: profesional.sitioWeb!,
                      textSecondary: textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Habilidades ---
            _Section(
              title: 'Habilidades',
              cardBg: cardBg,
              isDark: isDark,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profesional.habilidades.map((h) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    h,
                    style: TextStyle(
                      fontSize: 12,
                      color: catColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // --- Reseñas recientes ---
            _Section(
              title: 'Reseñas más recientes',
              cardBg: cardBg,
              isDark: isDark,
              child: Column(
                children: [
                  _ResenaItem(
                    autor: 'María López',
                    fecha: 'Hace 2 días',
                    texto: 'Excelente profesional, muy puntual y el trabajo quedó perfecto. Lo recomiendo sin dudarlo.',
                    estrellas: 5,
                    isDark: isDark,
                    catColor: catColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  _ResenaItem(
                    autor: 'Carlos Ruiz',
                    fecha: 'Hace 1 semana',
                    texto: 'Muy buen servicio, resolvió el problema rápidamente y a buen precio.',
                    estrellas: 4,
                    isDark: isDark,
                    catColor: catColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  _ResenaItem(
                    autor: 'Lucía Torres',
                    fecha: 'Hace 2 semanas',
                    texto: 'Profesional, ordenado y con muy buen trato. El resultado superó mis expectativas.',
                    estrellas: 5,
                    isDark: isDark,
                    catColor: catColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- CTA contratar ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: catColor.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Text(
                    '¿Listo para contratar?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Contáctate con ${profesional.nombre} y empieza hoy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Enviar mensaje',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color textPrimary;
  final Color textSecondary;

  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
        Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Color cardBg;
  final bool isDark;

  const _Section({
    required this.title,
    required this.child,
    required this.cardBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

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
          Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textSecondary;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: textSecondary)),
      ],
    );
  }
}

class _ResenaItem extends StatelessWidget {
  final String autor;
  final String fecha;
  final String texto;
  final int estrellas;
  final bool isDark;
  final Color catColor;
  final Color textPrimary;
  final Color textSecondary;

  const _ResenaItem({
    required this.autor,
    required this.fecha,
    required this.texto,
    required this.estrellas,
    required this.isDark,
    required this.catColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: catColor.withValues(alpha: 0.15),
              child: Text(
                autor[0],
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: catColor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(autor,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                  Text(fecha, style: TextStyle(fontSize: 11, color: textSecondary)),
                ],
              ),
            ),
            Row(
              children: List.generate(5, (i) => Icon(
                Icons.star_rounded,
                size: 13,
                color: i < estrellas
                    ? const Color(0xFFFBBF24)
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              )),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(texto, style: TextStyle(fontSize: 12, color: textSecondary, height: 1.4)),
      ],
    );
  }
}
