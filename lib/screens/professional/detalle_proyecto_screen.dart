import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/screens/client/chat_proyecto_screen.dart';
import 'package:pro_services/screens/professional/fotos_proyecto_screen.dart';
import 'package:pro_services/screens/professional/marcar_hito_screen.dart';
import 'package:pro_services/screens/professional/perfil_cliente_screen.dart';
import 'package:pro_services/services/proyecto_service.dart';

class DetalleProyectoScreen extends StatefulWidget {
  final int id;
  final String cliente;
  final String telefono;
  final String correo;
  final String servicio;
  final String descripcion;
  final String ubicacion;
  final String fecha;
  final String fechaInicio;
  final String fechaFin;
  final double presupuesto;
  final String estado;
  final double progreso;
  final String token;
  final int idUsuario;

  const DetalleProyectoScreen({
    super.key,
    required this.id,
    required this.cliente,
    required this.telefono,
    required this.correo,
    required this.servicio,
    required this.descripcion,
    required this.ubicacion,
    required this.fecha,
    required this.fechaInicio,
    required this.fechaFin,
    required this.presupuesto,
    required this.estado,
    required this.progreso,
    required this.token,
    required this.idUsuario,
  });

  @override
  State<DetalleProyectoScreen> createState() => _DetalleProyectoScreenState();
}

class _DetalleProyectoScreenState extends State<DetalleProyectoScreen> {
  final List<String> _notas = [];
  final List<String> _fotos = []; // mock: cada elemento = una foto subida
  bool _completado = false;
  @override
  void initState() {
    super.initState();
  }

  Color get _estadoColor {
    if (_completado) return const Color(0xFF22C55E);
    switch (widget.estado) {
      case 'pendiente':  return const Color(0xFFF59E0B);
      case 'aceptado':   return const Color(0xFF6366F1);
      case 'completado': return const Color(0xFF22C55E);
      case 'rechazado':  return const Color(0xFFEF4444);
      default:           return Colors.grey;
    }
  }

  String get _estadoLabel {
    if (_completado) return 'Completado';
    switch (widget.estado) {
      case 'pendiente':  return 'Pendiente';
      case 'aceptado':   return 'En progreso';
      case 'completado': return 'Completado';
      case 'rechazado':  return 'Rechazado';
      default:           return widget.estado;
    }
  }

  // 1 foto = 25 %, máx 4 fotos = 100 %
  double get _fotoProgreso => (_fotos.length / 4).clamp(0.0, 1.0);

  void _agregarFotoMock() {
    if (_fotos.length >= 4) return;
    setState(() {
      _fotos.add('foto_${_fotos.length + 1}.jpg');
      if (_fotoProgreso >= 1.0) _completado = true;
    });
  }

  void _mostrarDialogoNota(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva nota',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe tu nota aquí...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final texto = ctrl.text.trim();
              if (texto.isNotEmpty) {
                setState(() => _notas.add(texto));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final btnColor = isDark ? const Color(0xFFbcbcbc) : const Color(0xFF111827);
    final esAceptado = widget.estado == 'aceptado' && !_completado;
    final esPendiente = widget.estado == 'pendiente';

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
          'Detalle del proyecto',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header del proyecto ─────────────────────────────────────────
            Container(
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
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: _estadoColor.withValues(alpha: 0.15),
                        child: Text(
                          widget.cliente[0],
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _estadoColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.cliente,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PerfilClienteScreen(
                                        token: widget.token,
                                        idCliente: widget.idUsuario,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF6366F1)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: const Text(
                                      'Ver cliente',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(widget.servicio,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: _estadoColor,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined,
                                    size: 12, color: textSecondary),
                                const SizedBox(width: 4),
                                Text(widget.telefono,
                                    style: TextStyle(
                                        fontSize: 12, color: textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.email_outlined,
                                    size: 12, color: textSecondary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(widget.correo,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12, color: textSecondary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _estadoColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _estadoLabel,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _estadoColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ContactBtn(
                          icon: Icons.phone_rounded,
                          label: 'Llamar',
                          color: const Color(0xFF22C55E),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ContactBtn(
                          icon: Icons.chat_rounded,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ContactBtn(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          color: const Color(0xFF6366F1),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progreso (solo aceptado)
                  if (esAceptado) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progreso del proyecto',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textPrimary)),
                        Text('${(widget.progreso * 100).toInt()}%',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6366F1))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: widget.progreso,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF6366F1)
                            .withValues(alpha: isDark ? 0.15 : 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimado de finalización: 20 Mar 2026',
                      style:
                          TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Descripción ──────────────────────────────────────────────────
            _Section(
              title: 'Descripción',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.descripcion,
                    style: TextStyle(
                        fontSize: 14, color: textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          icon: Icons.play_circle_outline_rounded,
                          iconColor: const Color(0xFF6366F1),
                          label: 'Fecha de inicio',
                          value: widget.fechaInicio,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoRow(
                          icon: Icons.flag_outlined,
                          iconColor: const Color(0xFF22C55E),
                          label: 'Fecha de fin',
                          value: widget.fechaFin,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Información ──────────────────────────────────────────────────
            _Section(
              title: 'Información',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: 'Ubicación del trabajo',
                    value: widget.ubicacion,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Fecha y hora de aceptación',
                    value: widget.fecha,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.attach_money_rounded,
                    iconColor: const Color(0xFF22C55E),
                    label: 'Presupuesto del trabajo',
                    value: '\$${widget.presupuesto.toStringAsFixed(0)}',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.tag_rounded,
                    iconColor: textSecondary,
                    label: 'ID del proyecto',
                    value: '#PRO-${widget.id.toString().padLeft(4, '0')}',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.payment_rounded,
                    iconColor: const Color(0xFF22C55E),
                    label: 'Estado del pago',
                    value: 'Pendiente de pago',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Actividad reciente ───────────────────────────────────────────
            _Section(
              title: 'Actividad reciente',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              child: Column(
                children: [
                  _ActividadItem(
                    texto: 'Solicitud recibida del cliente',
                    fecha: widget.fecha,
                    color: const Color(0xFF6366F1),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  if (widget.estado != 'pendiente') ...[
                    _ActividadItem(
                      texto: widget.estado == 'rechazado'
                          ? 'Solicitud rechazada'
                          : 'Solicitud aceptada — proyecto iniciado',
                      fecha: widget.fecha,
                      color: widget.estado == 'rechazado'
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF22C55E),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                  if (widget.estado == 'completado' || _completado)
                    _ActividadItem(
                      texto: 'Proyecto completado exitosamente',
                      fecha: widget.fecha,
                      color: const Color(0xFF22C55E),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Notas del proyecto ────────────────────────────────────────────
            if (esAceptado || widget.estado == 'completado' || _completado)
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notas del proyecto',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary)),
                      if (!_completado && widget.estado != 'completado')
                        GestureDetector(
                          onTap: () => _mostrarDialogoNota(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.add_rounded,
                                    size: 14, color: Color(0xFF6366F1)),
                                SizedBox(width: 4),
                                Text('Agregar',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6366F1))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_notas.isEmpty)
                    Text('Sin notas aún. Toca "Agregar" para añadir una.',
                        style: TextStyle(fontSize: 13, color: textSecondary))
                  else
                    ...List.generate(_notas.length, (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6366F1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_notas[i],
                                    style: TextStyle(
                                        fontSize: 13, color: textPrimary)),
                              ),
                              if (!_completado && widget.estado != 'completado')
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _notas.removeAt(i)),
                                  child: Icon(Icons.close_rounded,
                                      size: 16, color: textSecondary),
                                ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Acciones ─────────────────────────────────────────────────────
            if (esAceptado || widget.estado == 'completado' || _completado)
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Acciones',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textPrimary)),
                  const SizedBox(height: 14),
                  // Barra de progreso de fotos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Evidencia fotográfica',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary)),
                      Text('${_fotos.length}/4 fotos',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _completado
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF6366F1))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      child: LinearProgressIndicator(
                        value: _fotoProgreso,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _completado
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _completado
                        ? '¡Todas las fotos subidas! Proyecto marcado como completado.'
                        : 'Sube fotos del trabajo para actualizar el progreso.',
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                  const SizedBox(height: 14),
                  // Fotos subidas (miniaturas mock)
                  if (_fotos.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fotos
                          .map((f) => Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.3)),
                                ),
                                child: const Icon(
                                    Icons.image_rounded,
                                    size: 26,
                                    color: Color(0xFF6366F1)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                  ],
                  // Botón subir foto (mock local)
                  if (!_completado && widget.estado != 'completado')
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _fotos.length < 4 ? _agregarFotoMock : null,
                        icon: const Icon(Icons.camera_alt_rounded, size: 16),
                        label: const Text('Subir foto del trabajo',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Botón gestionar fotos tipadas (antes / durante / después)
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FotosProyectoScreen(
                              token: widget.token,
                              proyectoId: widget.id,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.photo_library_rounded, size: 16),
                      label: const Text('Gestionar fotos del proyecto',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (_completado) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.task_alt_rounded,
                              color: Color(0xFF22C55E), size: 18),
                          const SizedBox(width: 8),
                          Text('Proyecto marcado como completado',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF22C55E))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Botones de acción ────────────────────────────────────────────
            if (esPendiente) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Rechazar',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(context);
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Aceptar proyecto',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800)),
                              content: const Text(
                                  '¿Confirmás que querés aceptar este proyecto?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancelar')),
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Aceptar')),
                              ],
                            ),
                          );
                          if (confirmar != true) return;
                          try {
                            await ProyectoService.aceptar(
                                widget.token, widget.id);
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('Proyecto aceptado')),
                            );
                            nav.pop(true);
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text('Aceptar',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (esAceptado) ...[
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(context);
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Completar proyecto',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        content: const Text(
                            '¿Confirmás que el trabajo fue finalizado?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar')),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Confirmar')),
                        ],
                      ),
                    );
                    if (confirmar != true) return;
                    try {
                      await ProyectoService.completar(
                          widget.token, widget.id);
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Proyecto completado')),
                      );
                      nav.pop(true);
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.task_alt_rounded, size: 18),
                  label: const Text('Marcar como completado',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MarcarHitoScreen(
                        token:          widget.token,
                        proyectoId:     widget.id,
                        usuarioEmail:   'profesional',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.gps_fixed_rounded, size: 18),
                  label: const Text('Actualizar estado',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: btnColor,
                  side: BorderSide(color: btnColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatProyectoScreen(
                        token: widget.token,
                        proyectoId: widget.id,
                        nombreProfesional: widget.cliente,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Contactar al cliente',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _Section({
    required this.title,
    required this.child,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textPrimary)),
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
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(fontSize: 11, color: textSecondary)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActividadItem extends StatelessWidget {
  final String texto;
  final String fecha;
  final Color color;
  final Color textPrimary;
  final Color textSecondary;

  const _ActividadItem({
    required this.texto,
    required this.fecha,
    required this.color,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 24,
                color: color.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                const SizedBox(height: 2),
                Text(fecha,
                    style:
                        TextStyle(fontSize: 11, color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
