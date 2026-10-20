enum TipoNotificacion {
  vacuna,
  medicamento,
  cita,
  desparasitacion,
  anomalia;

  String get valorApi {
    switch (this) {
      case TipoNotificacion.vacuna:
        return 'vacuna';
      case TipoNotificacion.medicamento:
        return 'medicamento';
      case TipoNotificacion.cita:
        return 'cita';
      case TipoNotificacion.desparasitacion:
        return 'desparasitacion';
      case TipoNotificacion.anomalia:
        return 'anomalia';
    }
  }

  static TipoNotificacion desdeTexto(String? valor) {
    switch ((valor ?? '').toLowerCase().trim()) {
      case 'vacuna':
        return TipoNotificacion.vacuna;
      case 'medicamento':
        return TipoNotificacion.medicamento;
      case 'cita':
        return TipoNotificacion.cita;
      case 'desparasitacion':
      case 'desparasitación':
        return TipoNotificacion.desparasitacion;
      case 'anomalia':
      case 'anomalía':
        return TipoNotificacion.anomalia;
      default:
        return TipoNotificacion.anomalia;
    }
  }
}

enum FiltroNotificacion {
  todas,
  pendientes,
  atendidas,
}

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

    final String nombreMascota = mascotaJson is Map
        ? (mascotaJson['nombre'] ?? '').toString()
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
        json['mascotaId'] ?? json['mascota_id'],
      ),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      mascota: nombreMascota,
      fechaProgramada: _leerFecha(fechaValor),
      fecha: _formatearFecha(fechaValor),
      tipo: TipoNotificacion.desdeTexto(
        (json['tipo'] ?? json['tipoNotificacion'] ?? json['tipo_notificacion'])
            ?.toString(),
      ),
      creadaEn: _leerFecha(
        json['creadaEn'] ?? json['creada_en'] ?? json['createdAt'],
      ),
      atendida: _leerBooleano(
        json['atendida'] ?? json['leida'] ?? json['leída'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mascotaId': mascotaId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo.valorApi,
      'fechaProgramada': fechaProgramada?.toIso8601String(),
      'atendida': atendida,
    };
  }

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

    return '$dia/$mes/${local.year}';
  }
}
