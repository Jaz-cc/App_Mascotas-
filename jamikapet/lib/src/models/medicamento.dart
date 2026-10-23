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
  final bool esActivo;

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
    this.esActivo = true,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id'] ?? json['_id'],
      mascotaId: json['mascotaId'] ?? '',
      nombre: json['nombre'] ?? '',
      dosis: json['dosis'] ?? '',
      frecuencia: json['frecuencia'] ?? '',
      horaAdministracion: json['horaAdministracion'] ?? json['horarios'] ?? '',
      fechaInicio: json['fechaInicio'] != null 
          ? DateTime.parse(json['fechaInicio']) 
          : DateTime.now(),
      fechaFinalizacion: json['fechaFinalizacion'] != null 
          ? DateTime.parse(json['fechaFinalizacion']) 
          : DateTime.now(),
      indicaciones: json['indicaciones'] ?? '',
      veterinario: json['veterinario'] ?? '',
      esActivo: json['esActivo'] ?? true,
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
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFinalizacion': fechaFinalizacion.toIso8601String(),
      'indicaciones': indicaciones,
      'veterinario': veterinario,
      'esActivo': esActivo,
    };
  }
}