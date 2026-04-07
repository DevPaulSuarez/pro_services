import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/models/cotizacion.dart';
import 'package:pro_services/services/cotizacion_service.dart';

class CompararCotizacionesScreen extends StatelessWidget {
  const CompararCotizacionesScreen({
    super.key,
    required this.cotizaciones,
    required this.token,
  });
  final List<Cotizacion> cotizaciones;
  final String token;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    // Find the index with the lowest precioPropuesto
    int lowestIndex = 0;
    double lowestPrice = cotizaciones.isNotEmpty
        ? cotizaciones[0].precioPropuesto
        : 0.0;
    for (int i = 1; i < cotizaciones.length; i++) {
      if (cotizaciones[i].precioPropuesto < lowestPrice) {
        lowestPrice = cotizaciones[i].precioPropuesto;
        lowestIndex = i;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        title: const Text(
          'Comparar Cotizaciones',
          style: TextStyle(fontWeight: FontWeight.w700),
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
      body: cotizaciones.isEmpty
          ? Center(
              child: Text(
                'No hay cotizaciones para comparar',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cotizaciones.length} cotizaciones disponibles',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Labels column
                                _LabelsColumn(isDark: isDark, cardColor: cardColor),
                                const SizedBox(width: 8),
                                // Cotizacion columns
                                ...List.generate(cotizaciones.length, (i) {
                                  return Row(
                                    children: [
                                      _CotizacionColumn(
                                        cotizacion: cotizaciones[i],
                                        index: i,
                                        isLowest: i == lowestIndex,
                                        isDark: isDark,
                                        cardColor: cardColor,
                                        token: token,
                                      ),
                                      if (i < cotizaciones.length - 1)
                                        const SizedBox(width: 8),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _LabelsColumn extends StatelessWidget {
  const _LabelsColumn({required this.isDark, required this.cardColor});
  final bool isDark;
  final Color cardColor;

  static const _rows = [
    'Profesional',
    'Precio Total',
    'Fecha Servicio',
    'Hora Inicio',
    'Hora Fin',
    'Estado',
    'Observaciones',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _headerCell('Campo', isDark: isDark, isHeader: true),
          ..._rows.map((label) => _labelCell(label, isDark: isDark)),
        ],
      ),
    );
  }
}

class _CotizacionColumn extends StatefulWidget {
  const _CotizacionColumn({
    required this.cotizacion,
    required this.index,
    required this.isLowest,
    required this.isDark,
    required this.cardColor,
    required this.token,
  });

  final Cotizacion cotizacion;
  final int index;
  final bool isLowest;
  final bool isDark;
  final Color cardColor;
  final String token;

  @override
  State<_CotizacionColumn> createState() => _CotizacionColumnState();
}

class _CotizacionColumnState extends State<_CotizacionColumn> {
  bool _isLoading = false;

  Future<void> _seleccionar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar selección'),
        content: const Text('¿Aceptar esta cotización?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);
    try {
      await CotizacionService.aceptar(widget.token, widget.cotizacion.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cotización aceptada')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.isLowest ? Colors.green.shade400 : Colors.transparent;
    final bgColor = widget.isLowest
        ? (widget.isDark
            ? const Color(0xFF052E16).withValues(alpha: 0.6)
            : const Color(0xFFF0FDF4))
        : widget.cardColor;

    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: widget.isLowest ? 2 : 0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _headerCell(
            'Profesional ${widget.index + 1}',
            isDark: widget.isDark,
            isHeader: true,
            isLowest: widget.isLowest,
          ),
          _valueCell(
            'Profesional #${widget.cotizacion.idProfesional}',
            isDark: widget.isDark,
          ),
          _valueCell(
            'S/ ${widget.cotizacion.precioPropuesto.toStringAsFixed(2)}',
            isDark: widget.isDark,
            isHighlight: widget.isLowest,
            isPrice: true,
          ),
          _valueCell(widget.cotizacion.fechaServicio.isEmpty ? '—' : widget.cotizacion.fechaServicio, isDark: widget.isDark),
          _valueCell(widget.cotizacion.horaInicio.isEmpty ? '—' : widget.cotizacion.horaInicio, isDark: widget.isDark),
          _valueCell(widget.cotizacion.horaFin.isEmpty ? '—' : widget.cotizacion.horaFin, isDark: widget.isDark),
          _valueCell(widget.cotizacion.estadoCotizacion, isDark: widget.isDark),
          _valueCell(
            widget.cotizacion.observaciones.isEmpty
                ? '—'
                : widget.cotizacion.observaciones,
            isDark: widget.isDark,
            isLong: true,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isLowest
                      ? Colors.green.shade600
                      : (widget.isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFF111827)),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _seleccionar,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Seleccionar',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _headerCell(
  String text, {
  required bool isDark,
  bool isHeader = false,
  bool isLowest = false,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: isLowest
          ? Colors.green.shade600
          : (isDark ? const Color(0xFF334155) : const Color(0xFF1E293B)),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),
  );
}

Widget _labelCell(String label, {required bool isDark}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 0.5,
        ),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey.shade300 : const Color(0xFF374151),
      ),
    ),
  );
}

Widget _valueCell(
  String value, {
  required bool isDark,
  bool isHighlight = false,
  bool isPrice = false,
  bool isLong = false,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 0.5,
        ),
      ),
    ),
    child: Text(
      value,
      textAlign: TextAlign.center,
      maxLines: isLong ? 3 : 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: isPrice ? 15 : 12,
        fontWeight: isPrice ? FontWeight.w800 : FontWeight.w400,
        color: isHighlight
            ? Colors.green.shade500
            : (isDark ? Colors.white : const Color(0xFF0F172A)),
      ),
    ),
  );
}

