class Consulta {
  final int? id;
  final int mascotaId;
  final String veterinario;
  final String? correo;
  final String motivo;
  final DateTime fecha;
  final String hora;
  final String estado; // 'Pendiente', 'Completada', 'Cancelada'
  final String? notas;

  Consulta({
    this.id,
    required this.mascotaId,
    required this.veterinario,
    this.correo,
    required this.motivo,
    required this.fecha,
    required this.hora,
    this.estado = 'Pendiente',
    this.notas,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      id: json['id'] ?? json['_id'],
      mascotaId: json['mascotaId'] ?? '',
      veterinario: json['veterinario'] ?? '',      
      correo: json['correo'] ?? '',
      motivo: json['motivo'] ?? '',
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha']) 
          : DateTime.now(),
      hora: json['hora'] ?? '',
      estado: json['estado'] ?? 'Pendiente',
      notas: json['notas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mascotaId': mascotaId,
      'veterinario': veterinario,
      'correo': correo,
      'motivo': motivo,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'estado': estado,
      'notas': notas,
    };
  }
}