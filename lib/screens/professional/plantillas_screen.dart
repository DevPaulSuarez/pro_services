import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/plantilla_cotizacion.dart';
import 'package:pro_services/services/plantilla_service.dart';

class PlantillasScreen extends StatefulWidget {
  const PlantillasScreen({super.key, required this.token});
  final String token;

  @override
  State<PlantillasScreen> createState() => _PlantillasScreenState();
}

class _PlantillasScreenState extends State<PlantillasScreen> {
  late Future<List<PlantillaCotizacion>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = PlantillaService.getMias(widget.token);
  }

  void _reload() {
    setState(() {
      _futuro = PlantillaService.getMias(widget.token);
    });
  }

  Future<void> _confirmarEliminar(PlantillaCotizacion p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar plantilla'),
        content: Text('¿Eliminás "${p.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await PlantillaService.eliminar(widget.token, p.id);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  void _abrirFormulario({PlantillaCotizacion? plantilla}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PlantillaForm(
        token: widget.token,
        plantilla: plantilla,
        onSaved: () {
          Navigator.pop(ctx);
          _reload();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Mis Plantillas'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            ),
            onPressed: () => MyApp.of(context).toggleTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<PlantillaCotizacion>>(
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
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No tenés plantillas. ¡Creá una para agilizar tus cotizaciones!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          onPressed: () => _abrirFormulario(plantilla: p),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded,
                              size: 20, color: Colors.red),
                          onPressed: () => _confirmarEliminar(p),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                            label:
                                'Mano de obra: S/ ${p.manoObra.toStringAsFixed(2)}'),
                        _InfoChip(
                            label:
                                'Materiales: S/ ${p.materiales.toStringAsFixed(2)}'),
                        _InfoChip(
                            label:
                                'Traslado: S/ ${p.traslado.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: S/ ${p.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (p.observaciones != null &&
                        p.observaciones!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        p.observaciones!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}

// ─── Form Bottom Sheet ────────────────────────────────────────────────────────

class _PlantillaForm extends StatefulWidget {
  const _PlantillaForm({
    required this.token,
    required this.onSaved,
    this.plantilla,
  });

  final String token;
  final PlantillaCotizacion? plantilla;
  final VoidCallback onSaved;

  @override
  State<_PlantillaForm> createState() => _PlantillaFormState();
}

class _PlantillaFormState extends State<_PlantillaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _manoObra;
  late final TextEditingController _materiales;
  late final TextEditingController _traslado;
  late final TextEditingController _observaciones;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.plantilla;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _manoObra = TextEditingController(
        text: p != null ? p.manoObra.toString() : '');
    _materiales = TextEditingController(
        text: p != null ? p.materiales.toString() : '');
    _traslado = TextEditingController(
        text: p != null ? p.traslado.toString() : '');
    _observaciones =
        TextEditingController(text: p?.observaciones ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _manoObra.dispose();
    _materiales.dispose();
    _traslado.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final nombre = _nombre.text.trim();
      final manoObra = double.tryParse(_manoObra.text) ?? 0;
      final materiales = double.tryParse(_materiales.text) ?? 0;
      final traslado = double.tryParse(_traslado.text) ?? 0;
      final obs = _observaciones.text.trim().isEmpty
          ? null
          : _observaciones.text.trim();

      if (widget.plantilla == null) {
        await PlantillaService.crear(
          widget.token,
          nombre: nombre,
          manoObra: manoObra,
          materiales: materiales,
          traslado: traslado,
          observaciones: obs,
        );
      } else {
        await PlantillaService.actualizar(
          widget.token,
          widget.plantilla!.id,
          nombre: nombre,
          manoObra: manoObra,
          materiales: materiales,
          traslado: traslado,
          observaciones: obs,
        );
      }
      if (!mounted) return;
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.plantilla != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Editar Plantilla' : 'Nueva Plantilla',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombre,
              decoration:
                  const InputDecoration(labelText: 'Nombre *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _manoObra,
              decoration:
                  const InputDecoration(labelText: 'Mano de obra (S/)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _materiales,
              decoration:
                  const InputDecoration(labelText: 'Materiales (S/)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _traslado,
              decoration:
                  const InputDecoration(labelText: 'Traslado (S/)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observaciones,
              decoration:
                  const InputDecoration(labelText: 'Observaciones'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardar,
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

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
