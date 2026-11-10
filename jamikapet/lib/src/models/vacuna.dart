enum EstadoVacuna {
  aplicada('Aplicada'),
  proximaDosis('Próxima dosis'),
  noAplicada('No aplicada');

  final String etiqueta;
  const EstadoVacuna(this.etiqueta);

  static EstadoVacuna desdeTexto(String? texto) {
    final t = (texto ?? '').toLowerCase().replaceAll('_', ' ').trim();

    if (t.contains('prox') || t.contains('próx')) {
      return EstadoVacuna.proximaDosis;
    }
    if (t.startsWith('no ') || t.contains('pend')) {
      return EstadoVacuna.noAplicada;
    }
    if (t.contains('aplic')) {
      return EstadoVacuna.aplicada;
    }

    return EstadoVacuna.noAplicada;
  }
}

class Vacuna {
  final int id;
  final int mascotaId;
  final String nombre;
  final String descripcion;
  final DateTime? fecha;
  final DateTime? proximaDosis;
  final EstadoVacuna estado;
  final String? observaciones;

  const Vacuna({
    required this.id,
    required this.mascotaId,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    this.proximaDosis,
    required this.estado,
    this.observaciones,
  });

  factory Vacuna.fromJson(Map<String, dynamic> json) {
    return Vacuna(
      id: (json['id'] as num).toInt(),
      mascotaId:
          ((json['mascotaId'] ?? json['mascota_id'] ?? 0) as num).toInt(),
      nombre: (json['nombre'] ?? '') as String,
      descripcion: (json['descripcion'] ?? '') as String,
      fecha: json['fecha'] == null
          ? null
          : DateTime.tryParse(json['fecha'].toString()),
      proximaDosis: json['proximaDosis'] == null
          ? null
          : DateTime.tryParse(json['proximaDosis'].toString()),
      estado: EstadoVacuna.desdeTexto(
        json['estado'] is String
            ? json['estado'] as String
            : json['estado']?.toString(),
      ),
      observaciones: json['observaciones']?.toString(),
    );
  }

  /// dd/MM/yyyy sin depender del paquete intl.
  String get fechaFormateada => _formatear(fecha);

  String get proximaDosisFormateada => _formatear(proximaDosis);

  // El backend manda solo la fecha (YYYY-MM-DD), no se convierte de zona.
  static String _formatear(DateTime? f) {
    if (f == null) return 'Sin fecha';

    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year}';
  }
}
