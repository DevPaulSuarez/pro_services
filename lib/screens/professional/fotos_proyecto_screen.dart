import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/foto_proyecto.dart';
import 'package:pro_services/services/foto_proyecto_service.dart';

class FotosProyectoScreen extends StatefulWidget {
  final String token;
  final int proyectoId;

  const FotosProyectoScreen({
    super.key,
    required this.token,
    required this.proyectoId,
  });

  @override
  State<FotosProyectoScreen> createState() => _FotosProyectoScreenState();
}

class _FotosProyectoScreenState extends State<FotosProyectoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Futures independientes para cada tab
  Future<List<FotoProyecto>>? _antesFuture;
  Future<List<FotoProyecto>>? _duranteFuture;
  Future<List<FotoProyecto>>? _despuesFuture;

  static const _tipos = ['antes', 'durante', 'despues'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _recargarTodo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _recargarTodo() {
    setState(() {
      _antesFuture = FotoProyectoService.getFotos(
        widget.token,
        widget.proyectoId,
        tipo: 'antes',
      );
      _duranteFuture = FotoProyectoService.getFotos(
        widget.token,
        widget.proyectoId,
        tipo: 'durante',
      );
      _despuesFuture = FotoProyectoService.getFotos(
        widget.token,
        widget.proyectoId,
        tipo: 'despues',
      );
    });
  }

  void _recargarTabActivo() {
    final tipo = _tipos[_tabController.index];
    setState(() {
      switch (tipo) {
        case 'antes':
          _antesFuture = FotoProyectoService.getFotos(
            widget.token,
            widget.proyectoId,
            tipo: 'antes',
          );
        case 'durante':
          _duranteFuture = FotoProyectoService.getFotos(
            widget.token,
            widget.proyectoId,
            tipo: 'durante',
          );
        case 'despues':
          _despuesFuture = FotoProyectoService.getFotos(
            widget.token,
            widget.proyectoId,
            tipo: 'despues',
          );
      }
    });
  }

  Future<void> _mostrarDialogoAgregarFoto() async {
    final tipoActivo = _tipos[_tabController.index];
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Agregar foto — ${_labelTipo(tipoActivo)}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL de la foto',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Subir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final url = urlCtrl.text.trim();
    if (url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La URL no puede estar vacía'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    try {
      await FotoProyectoService.subirFoto(
        widget.token,
        widget.proyectoId,
        url: url,
        tipo: tipoActivo,
        descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto subida exitosamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _recargarTabActivo();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir la foto: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'antes':
        return 'Antes';
      case 'durante':
        return 'Durante';
      case 'despues':
        return 'Después';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final tabIndicatorColor = const Color(0xFF6366F1);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Fotos del proyecto',
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: tabIndicatorColor,
            labelColor: tabIndicatorColor,
            unselectedLabelColor: textSecondary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.camera_front_rounded, size: 20),
                text: 'Antes',
              ),
              Tab(
                icon: Icon(Icons.camera_rounded, size: 20),
                text: 'Durante',
              ),
              Tab(
                icon: Icon(Icons.camera_rear_rounded, size: 20),
                text: 'Después',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          onPressed: _mostrarDialogoAgregarFoto,
          child: const Icon(Icons.add_a_photo_rounded),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _FotosTabView(
              future: _antesFuture,
              tipo: 'antes',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _FotosTabView(
              future: _duranteFuture,
              tipo: 'durante',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _FotosTabView(
              future: _despuesFuture,
              tipo: 'despues',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab view con FutureBuilder ─────────────────────────────────────────────────

class _FotosTabView extends StatelessWidget {
  final Future<List<FotoProyecto>>? future;
  final String tipo;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _FotosTabView({
    required this.future,
    required this.tipo,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  String get _labelVacio {
    switch (tipo) {
      case 'antes':
        return 'Sin fotos de antes del trabajo';
      case 'durante':
        return 'Sin fotos durante el trabajo';
      case 'despues':
        return 'Sin fotos del resultado final';
      default:
        return 'Sin fotos de este momento';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FotoProyecto>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return _ErrorView(message: snapshot.error.toString());
        }
        final fotos = snapshot.data ?? [];
        if (fotos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 56,
                  color: textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 14),
                Text(
                  _labelVacio,
                  style: TextStyle(fontSize: 14, color: textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tocá el botón + para agregar una foto',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            itemCount: fotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final foto = fotos[index];
              return _FotoCard(
                foto: foto,
                isDark: isDark,
                cardBg: cardBg,
                textSecondary: textSecondary,
              );
            },
          ),
        );
      },
    );
  }
}

// ── Tarjeta de foto ────────────────────────────────────────────────────────────

class _FotoCard extends StatelessWidget {
  final FotoProyecto foto;
  final bool isDark;
  final Color cardBg;
  final Color textSecondary;

  const _FotoCard({
    required this.foto,
    required this.isDark,
    required this.cardBg,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            foto.url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
              child: Icon(
                Icons.broken_image_rounded,
                size: 36,
                color: textSecondary,
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
          if (foto.descripcion != null && foto.descripcion!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  foto.descripcion!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            const Text(
              'Error al cargar las fotos',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
