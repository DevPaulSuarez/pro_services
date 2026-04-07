import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/notificacion.dart';
import 'package:pro_services/services/notificacion_service.dart';
import 'package:pro_services/screens/client/chat_proyecto_screen.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key, required this.token});
  final String token;

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<Notificacion>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = NotificacionService.getMias(widget.token, pagina: 1);
  }

  void _reload() {
    setState(() {
      _futuro = NotificacionService.getMias(widget.token, pagina: 1);
    });
  }

  Future<void> _marcarTodas() async {
    try {
      await NotificacionService.leerTodas(widget.token);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _marcarUna(Notificacion n) async {
    if (n.esLeida) return;
    try {
      await NotificacionService.marcarLeida(widget.token, n.id);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _navegar(Notificacion n) {
    if (n.tipo == 'mensaje' && n.idReferencia != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatProyectoScreen(
            token: widget.token,
            proyectoId: n.idReferencia!,
            nombreProfesional: 'Proyecto #${n.idReferencia}',
          ),
        ),
      );
    }
    if (!n.esLeida) _marcarUna(n);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Marcar todas', style: TextStyle(fontSize: 13)),
            onPressed: _marcarTodas,
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
      body: FutureBuilder<List<Notificacion>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(onRetry: _reload);
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tenés notificaciones',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final n = items[index];
              return _NotificacionCard(
                notificacion: n,
                isDark: isDark,
                cardColor: cardColor,
                onMarcar: () => _marcarUna(n),
                onTap: () => _navegar(n),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificacionCard extends StatelessWidget {
  const _NotificacionCard({
    required this.notificacion,
    required this.isDark,
    required this.cardColor,
    required this.onMarcar,
    required this.onTap,
  });

  final Notificacion notificacion;
  final bool isDark;
  final Color cardColor;
  final VoidCallback onMarcar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFF2563EB);
    final unreadBorder = !notificacion.esLeida
        ? Border.all(color: accentColor.withValues(alpha: 0.5), width: 1)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: notificacion.esLeida
              ? cardColor
              : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF)),
          borderRadius: BorderRadius.circular(12),
          border: unreadBorder,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          leading: CircleAvatar(
            backgroundColor: accentColor.withValues(alpha: 0.15),
            child: Icon(
              Icons.notifications_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          title: Text(
            notificacion.titulo,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                notificacion.mensaje,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                notificacion.fecha,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onMarcar,
                child: Icon(
                  notificacion.esLeida
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: notificacion.esLeida
                      ? Colors.green.shade400
                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 56,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar los datos',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
