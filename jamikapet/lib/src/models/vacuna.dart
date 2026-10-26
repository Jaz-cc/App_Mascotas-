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
  final EstadoVacuna estado;
  final String? observaciones;

  const Vacuna({
    required this.id,
    required this.mascotaId,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
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
      estado: EstadoVacuna.desdeTexto(
        json['estado'] is String
            ? json['estado'] as String
            : json['estado']?.toString(),
      ),
      observaciones: json['observaciones']?.toString(),
    );
  }

  /// dd/MM/yyyy sin depender del paquete intl.
  String get fechaFormateada {
    final f = fecha?.toLocal();
    if (f == null) return 'Sin fecha';

    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year}';
  }
}
