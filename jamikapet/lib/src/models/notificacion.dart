enum TipoNotificacion {
  vacuna('vacuna'),
  medicamento('medicamento'),
  cita('cita'),
  desparasitacion('desparasitacion'),
  anomalia('anomalia');

  final String valorApi;
  const TipoNotificacion(this.valorApi);

  /// Convierte el texto del backend en enum, tolerando mayúsculas y tildes.
  static TipoNotificacion desdeTexto(String? texto) {
    final normalizado = (texto ?? '')
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    for (final tipo in TipoNotificacion.values) {
      if (tipo.valorApi == normalizado) return tipo;
    }

    // Valor por defecto si el backend envía algo desconocido.
    return TipoNotificacion.cita;
  }
}

enum FiltroNotificacion { todas, pendientes, atendidas }

class Notificacion {
  final int id;
  final int? mascotaId;
  final String titulo;
  final String descripcion;
  final String mascota;
  final DateTime? fechaProgramada;
  final String fecha;
  final TipoNotificacion tipo;
  final DateTime? creadaEn;
  bool atendida;

  Notificacion({
    required this.id,
    this.mascotaId,
    required this.titulo,
    required this.descripcion,
    required this.mascota,
    this.fechaProgramada,
    required this.fecha,
    required this.tipo,
    this.creadaEn,
    this.atendida = false,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    final mascotaJson = json['mascota'];

    // El backend utiliza nombrePet en la entidad Pet.
    final String nombreMascota = mascotaJson is Map
        ? (mascotaJson['nombrePet'] ??
                mascotaJson['nombre'] ??
                '')
            .toString()
        : (json['nombreMascota'] ??
                json['nombre_mascota'] ??
                (mascotaJson is String ? mascotaJson : ''))
            .toString();

    final fechaValor = json['fechaProgramada'] ??
        json['fecha_programada'] ??
        json['fecha'];

    return Notificacion(
      id: _leerInt(json['id']),
      mascotaId: _leerNullableInt(
        json['mascotaId'] ??
            json['mascota_id'] ??
            (mascotaJson is Map ? mascotaJson['id'] : null),
      ),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['mensaje'] ??
              json['descripcion'] ??
              '')
          .toString(),
      mascota: nombreMascota.isEmpty ? 'Sin mascota' : nombreMascota,
      fechaProgramada: _leerFecha(fechaValor),
      fecha: _formatearFecha(fechaValor),
      tipo: TipoNotificacion.desdeTexto(
        (json['tipo'] ??
                json['tipoNotificacion'] ??
                json['tipo_notificacion'])
            ?.toString(),
      ),
      creadaEn: _leerFecha(
        json['created_at'] ??
            json['createdAt'] ??
            json['creadaEn'] ??
            json['creada_en'],
      ),
      atendida: _leerBooleano(json['atendida']),
    );
  }

  Map<String, dynamic> toJson() => {
    'mascotaId': mascotaId,
    'titulo': titulo,
    'mensaje': descripcion,
    'tipo': tipo.valorApi,
    'fecha_programada': fechaProgramada?.toIso8601String(),
    'atendida': atendida,
  };

  static int _leerInt(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static int? _leerNullableInt(dynamic valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toInt();
    return int.tryParse(valor.toString());
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }

  static bool _leerBooleano(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;

    final texto = valor?.toString().toLowerCase().trim();

    return texto == 'true' ||
        texto == '1' ||
        texto == 'atendida' ||
        texto == 'leida' ||
        texto == 'leída';
  }

  static String _formatearFecha(dynamic valor) {
    if (valor == null || valor.toString().isEmpty) {
      return 'Sin fecha';
    }

    final fecha = DateTime.tryParse(valor.toString());
    if (fecha == null) return valor.toString();

    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');

    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${local.year} $hora:$minuto';
  }
}
