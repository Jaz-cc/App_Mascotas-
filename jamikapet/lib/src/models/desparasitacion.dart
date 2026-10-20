
class Desparasitacion {
  final int id;
  final int mascotaId;
  final String nombre;
  final String producto;
  final DateTime? fechaAplicacion;
  final DateTime? proximaDosis;
  final String estado;

  const Desparasitacion({
    required this.id,
    required this.mascotaId,
    required this.nombre,
    required this.producto,
    required this.fechaAplicacion,
    required this.proximaDosis,
    required this.estado,
  });

  factory Desparasitacion.fromJson(Map<String, dynamic> json) {
    return Desparasitacion(
      id: _entero(json['id']),
      mascotaId: _entero(
        json['mascotaId'] ?? json['mascota_id'],
      ),
      nombre: (json['nombre'] ?? 'Desparasitación').toString(),
      producto: (json['producto'] ?? '').toString(),
      fechaAplicacion: _fecha(
        json['fechaAplicacion'] ??
        json['fecha_aplicacion'] ??
        json['fecha'],
      ),
      proximaDosis: _fecha(
        json['proximaDosis'] ??
        json['proxima_dosis'] ??
        json['proxima'],
      ),
      estado: (json['estado'] ?? 'Pendiente').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mascotaId': mascotaId,
        'nombre': nombre,
        'producto': producto,
        'fechaAplicacion': fechaAplicacion?.toIso8601String(),
        'proximaDosis': proximaDosis?.toIso8601String(),
        'estado': estado,
      };

  static int _entero(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null || valor.toString().isEmpty) return null;
    return DateTime.tryParse(valor.toString());
  }
}
