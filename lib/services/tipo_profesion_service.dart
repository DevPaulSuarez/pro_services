import 'package:pro_services/models/tipo_profesion.dart';

class TipoProfesionService {
  static Future<List<TipoProfesion>> getTipos() async {
    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Datos mock — reemplazar con http.get('https://tuapi.com/tipo-profesion')
    final List<Map<String, dynamic>> mockData = [
      {
        'id': 1,
        'nombre': 'Electricidad',
        'descripcion': 'Instalaciones, reparaciones y mantenimiento eléctrico.',
        'icono': 'bolt',
        'color': 'F59E0B',
        'profesionalesRegistrados': 48,
      },
      {
        'id': 2,
        'nombre': 'Plomería',
        'descripcion': 'Tuberías, filtraciones y sistemas de agua.',
        'icono': 'water_drop',
        'color': '3B82F6',
        'profesionalesRegistrados': 35,
      },
      {
        'id': 3,
        'nombre': 'Carpintería',
        'descripcion': 'Muebles a medida, puertas y acabados en madera.',
        'icono': 'handyman',
        'color': '92400E',
        'profesionalesRegistrados': 22,
      },
      {
        'id': 4,
        'nombre': 'Pintura',
        'descripcion': 'Pintura interior y exterior, acabados decorativos.',
        'icono': 'format_paint',
        'color': '10B981',
        'profesionalesRegistrados': 41,
      },
      {
        'id': 5,
        'nombre': 'Limpieza',
        'descripcion': 'Limpieza del hogar, oficinas y espacios comerciales.',
        'icono': 'cleaning_services',
        'color': '8B5CF6',
        'profesionalesRegistrados': 60,
      },
      {
        'id': 6,
        'nombre': 'Jardinería',
        'descripcion': 'Mantenimiento de jardines, poda y paisajismo.',
        'icono': 'yard',
        'color': '16A34A',
        'profesionalesRegistrados': 19,
      },
    ];

    return mockData.map(TipoProfesion.fromJson).toList();
  }
}
