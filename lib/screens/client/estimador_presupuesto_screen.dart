import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/estadistica_precio.dart';
import 'package:pro_services/models/tipo_profesion.dart';
import 'package:pro_services/services/estadisticas_service.dart';
import 'package:pro_services/services/tipo_profesion_service.dart';

class EstimadorPresupuestoScreen extends StatefulWidget {
  const EstimadorPresupuestoScreen({super.key, required this.token});
  final String token;

  @override
  State<EstimadorPresupuestoScreen> createState() =>
      _EstimadorPresupuestoScreenState();
}

class _EstimadorPresupuestoScreenState
    extends State<EstimadorPresupuestoScreen> {
  late Future<List<TipoProfesion>> _tiposFuturo;

  final TextEditingController _horasCtrl = TextEditingController();
  final TextEditingController _precioHoraCtrl = TextEditingController();
  final TextEditingController _materialesCtrl = TextEditingController();
  final TextEditingController _trasladoCtrl = TextEditingController();

  TipoProfesion? _selectedTipo;

  EstadisticaPrecio? _estadistica;
  bool _cargandoEstadistica = false;

  double _horas = 0;
  double _precioHora = 0;
  double _materiales = 0;
  double _traslado = 0;

  @override
  void initState() {
    super.initState();
    _tiposFuturo = TipoProfesionService.getTipos();
  }

  @override
  void dispose() {
    _horasCtrl.dispose();
    _precioHoraCtrl.dispose();
    _materialesCtrl.dispose();
    _trasladoCtrl.dispose();
    super.dispose();
  }

  double get _total => (_horas * _precioHora) + _materiales + _traslado;
  double get _manoObra => _horas * _precioHora;

  Future<void> _cargarEstadistica(int tipoProfesionId) async {
    setState(() {
      _cargandoEstadistica = true;
      _estadistica = null;
    });
    try {
      final result = await EstadisticasService.getPrecioPromedio(
        widget.token,
        tipoProfesionId: tipoProfesionId,
      );
      if (!mounted) return;
      setState(() => _estadistica = result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _estadistica = null);
    } finally {
      if (mounted) setState(() => _cargandoEstadistica = false);
    }
  }

  void _resetear() {
    setState(() {
      _horasCtrl.clear();
      _precioHoraCtrl.clear();
      _materialesCtrl.clear();
      _trasladoCtrl.clear();
      _horas = 0;
      _precioHora = 0;
      _materiales = 0;
      _traslado = 0;
      _selectedTipo = null;
      _estadistica = null;
      _cargandoEstadistica = false;
    });
  }

  double _parseField(String val) {
    return double.tryParse(val.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        title: const Text(
          'Estimador de Presupuesto',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Resetear', style: TextStyle(fontSize: 13)),
            onPressed: _resetear,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de servicio
            _SectionCard(
              isDark: isDark,
              cardColor: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.work_outline_rounded,
                    label: 'Tipo de Servicio',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<TipoProfesion>>(
                    future: _tiposFuturo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final tipos = snapshot.data ?? [];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<TipoProfesion>(
                            value: _selectedTipo,
                            hint: Text(
                              'Seleccioná un tipo de servicio',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 14),
                            ),
                            isExpanded: true,
                            dropdownColor: cardColor,
                            items: tipos
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t.nombre,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: textPrimary)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() => _selectedTipo = val);
                              if (val != null) _cargarEstadistica(val.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  // Reference range (catalog)
                  if (_selectedTipo != null &&
                      (_selectedTipo!.presupuestoMinimo != null ||
                          _selectedTipo!.presupuestoMaximo != null)) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF052E16).withValues(alpha: 0.5)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade400.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: Colors.green.shade500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Rango habitual: S/ ${_selectedTipo!.presupuestoMinimo?.toStringAsFixed(0) ?? '?'} - S/ ${_selectedTipo!.presupuestoMaximo?.toStringAsFixed(0) ?? '?'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Referencia de mercado histórica
                  if (_selectedTipo != null) ...[
                    const SizedBox(height: 10),
                    _MercadoWidget(
                      estadistica: _estadistica,
                      cargando: _cargandoEstadistica,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Mano de obra
            _SectionCard(
              isDark: isDark,
              cardColor: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.schedule_rounded,
                    label: 'Mano de Obra',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _NumericField(
                          controller: _horasCtrl,
                          label: 'Horas estimadas',
                          hint: 'ej. 4',
                          isDark: isDark,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onChanged: (val) => setState(
                              () => _horas = _parseField(val)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumericField(
                          controller: _precioHoraCtrl,
                          label: 'Precio por hora (S/)',
                          hint: 'ej. 50',
                          isDark: isDark,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onChanged: (val) => setState(
                              () => _precioHora = _parseField(val)),
                        ),
                      ),
                    ],
                  ),
                  if (_manoObra > 0) ...[
                    const SizedBox(height: 8),
                    _SubtotalRow(
                      label: 'Subtotal mano de obra',
                      value: _manoObra,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Otros costos
            _SectionCard(
              isDark: isDark,
              cardColor: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.receipt_long_rounded,
                    label: 'Otros Costos',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _NumericField(
                    controller: _materialesCtrl,
                    label: 'Materiales estimados (S/)',
                    hint: 'ej. 120.00',
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onChanged: (val) =>
                        setState(() => _materiales = _parseField(val)),
                  ),
                  const SizedBox(height: 12),
                  _NumericField(
                    controller: _trasladoCtrl,
                    label: 'Traslado (S/)',
                    hint: 'ej. 20.00',
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onChanged: (val) =>
                        setState(() => _traslado = _parseField(val)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E3A5F),
                          const Color(0xFF1E2D4A),
                        ]
                      : [
                          const Color(0xFF2563EB),
                          const Color(0xFF1D4ED8),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Presupuesto Estimado',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'S/ ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  if (_total > 0) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    _TotalBreakdownRow(
                        label: 'Mano de obra', value: _manoObra),
                    const SizedBox(height: 6),
                    _TotalBreakdownRow(
                        label: 'Materiales', value: _materiales),
                    const SizedBox(height: 6),
                    _TotalBreakdownRow(
                        label: 'Traslado', value: _traslado),
                  ],
                  if (_selectedTipo != null &&
                      _total > 0 &&
                      (_selectedTipo!.presupuestoMaximo != null)) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    _RangeComparison(
                        tipo: _selectedTipo!, total: _total),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.cardColor,
    required this.child,
  });

  final bool isDark;
  final Color cardColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: TextStyle(fontSize: 14, color: textPrimary),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textSecondary, fontSize: 13),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubtotalRow extends StatelessWidget {
  const _SubtotalRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          'S/ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _TotalBreakdownRow extends StatelessWidget {
  const _TotalBreakdownRow({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Text(
          'S/ ${value.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RangeComparison extends StatelessWidget {
  const _RangeComparison({required this.tipo, required this.total});
  final TipoProfesion tipo;
  final double total;

  @override
  Widget build(BuildContext context) {
    final min = tipo.presupuestoMinimo;
    final max = tipo.presupuestoMaximo;
    String msg;
    IconData icon;

    if (max != null && total > max) {
      msg = 'Por encima del rango habitual';
      icon = Icons.arrow_upward_rounded;
    } else if (min != null && total < min) {
      msg = 'Por debajo del rango habitual';
      icon = Icons.arrow_downward_rounded;
    } else {
      msg = 'Dentro del rango habitual';
      icon = Icons.check_circle_rounded;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          msg,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MercadoWidget extends StatelessWidget {
  const _MercadoWidget({
    required this.estadistica,
    required this.cargando,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  final EstadisticaPrecio? estadistica;
  final bool cargando;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF6366F1),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Cargando referencia de mercado…',
              style: TextStyle(fontSize: 12, color: Color(0xFF6366F1)),
            ),
          ],
        ),
      );
    }

    if (estadistica == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded,
                  size: 16, color: Color(0xFF6366F1)),
              const SizedBox(width: 6),
              const Text(
                'Referencia de mercado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'S/ ${estadistica!.min.toStringAsFixed(0)} – S/ ${estadistica!.max.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          Text(
            'Promedio: S/ ${estadistica!.promedio.toStringAsFixed(0)} • ${estadistica!.cantidadMuestras} cotizaciones',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

