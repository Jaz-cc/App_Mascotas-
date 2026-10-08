class Medicamento {
  final String? id;
  final String mascotaId;
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

  factory Medicamento.fromJson(Map json) {
    return Medicamento(
      id: json['id'],
      mascotaId: json['mascotaId'] ?? '',
      nombre: json['nombre'] ?? '',
      dosis: json['dosis'] ?? '',
      frecuencia: json['frecuencia'] ?? '',
      horaAdministracion: json['horaAdministracion'] ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFinalizacion: DateTime.parse(json['fechaFinalizacion']),
      indicaciones: json['indicaciones'] ?? '',
      veterinario: json['veterinario'] ?? '',
    );
  }

  Map toJson() {
    return {
      'id': id,
      'mascotaId': mascotaId,
      'nombre': nombre,
      'dosis': dosis,
      'frecuencia': frecuencia,
      'horaAdministracion': horaAdministracion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFinalizacion': fechaFinalizacion.toIso8601String(),
      'indicaciones': indicaciones,
      'veterinario': veterinario,
    };
  }
}