
class Mascota {
  final int id;
  final int usuarioId;
  final String nombre;
  final String tipo;
  final String raza;
  final String genero;
  final int edad;
  final double peso;
  final String? image;

  const Mascota({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.tipo,
    required this.raza,
    required this.genero,
    required this.edad,
    required this.peso,
    this.image,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: _int(json['id']),
      usuarioId: _int(
        json['usuarioId'] ?? json['usuario_id'],
      ),
      nombre: (json['nombre'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      raza: (json['raza'] ?? '').toString(),
      genero: (json['genero'] ?? '').toString(),
      edad: _int(json['edad']),
      peso: _double(json['peso']),
      image: _foto(
        json['fotoUrl'] ??
        json['foto_url'] ??
        json['imageUrl'] ??
        json['image_url'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': usuarioId,
        'nombrePet': nombre,
        'tipo': tipo,
        'raza': raza,
        'genero': genero,
        'edad': edad,
        'peso': peso,
        'image': image,
      };

  static int _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static String? _foto(dynamic value) {
    if (value == null) return null;

    final url = value.toString().trim();
    if (url.isEmpty) return null;

    return url;
  }
}
