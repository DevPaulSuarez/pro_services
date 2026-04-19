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
    _futuro = NotificacionService.getMias(widget.token);
  }

  void _reload() {
    setState(() {
      _futuro = NotificacionService.getMias(widget.token);
    });
  }

  Future<void> _marcarLeida(int id) async {
    try {
      await NotificacionService.marcarLeida(widget.token, id);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
    if (!n.esLeida) _marcarLeida(n.id);
  }

  Future<void> _leerTodas() async {
    try {
      await NotificacionService.leerTodas(widget.token);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: _leerTodas,
            child: Text(
              'Marcar todas',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
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
            return _ErrorView(
              error: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No tenés notificaciones',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final n = items[index];
              final highlightColor = isDark
                  ? const Color(0xFF1E3A5F)
                  : const Color(0xFFEFF6FF);
              return GestureDetector(
                onTap: () => _navegar(n),
                child: Container(
                  decoration: BoxDecoration(
                    color: n.esLeida ? cardColor : highlightColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: n.esLeida
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_rounded,
                      color: n.esLeida
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      n.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          n.mensaje,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            n.fecha,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      n.esLeida
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: n.esLeida
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
