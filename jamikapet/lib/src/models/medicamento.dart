class Medicamento {
  final int? id;
  final int mascotaId;
  final String nombre;
  final String dosis;
  final String frecuencia;
  final String horaAdministracion;
  final DateTime fechaInicio;
  final DateTime fechaFinalizacion;
  final String indicaciones;
  final String veterinario;

  Medicamento({
    this.id,
    required this.mascotaId,
    required this.nombre,
    required this.dosis,
    required this.frecuencia,
    required this.horaAdministracion,
    required this.fechaInicio,
    required this.fechaFinalizacion,
    required this.indicaciones,
    required this.veterinario,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id'] == null
          ? null
          : (json['id'] as num).toInt(),
      mascotaId: (json['mascotaId'] as num).toInt(),
      nombre: json['nombre']?.toString() ?? '',
      dosis: json['dosis']?.toString() ?? '',
      frecuencia: json['frecuencia']?.toString() ?? '',
      horaAdministracion:
          json['horaAdministracion']?.toString() ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio'].toString()),
      fechaFinalizacion:
          DateTime.parse(json['fechaFinalizacion'].toString()),
      indicaciones: json['indicaciones']?.toString() ?? '',
      veterinario: json['veterinario']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mascotaId': mascotaId,
      'nombre': nombre,
      'dosis': dosis,
      'frecuencia': frecuencia,
      'horaAdministracion': horaAdministracion,
      'fechaInicio': fechaInicio.toIso8601String().split('T').first,
      'fechaFinalizacion':
          fechaFinalizacion.toIso8601String().split('T').first,
      'indicaciones': indicaciones,
      'veterinario': veterinario,
    };
  }
}