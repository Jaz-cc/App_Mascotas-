
class Mascota {
  final int id;
  final int userId;
  final String nombrePet;
  final String especie;
  final String raza;
  final String sexo;
  final int edad;
  final double peso;
  final String? image;

  const Mascota({
    required this.id,
    required this.userId,
    required this.nombrePet,
    required this.especie,
    required this.raza,
    required this.sexo,
    required this.edad,
    required this.peso,
    this.image,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: _int(json['id']),
      userId: _int(
        json['usuarioId'] ?? json['usuario_id'],
      ),
      nombrePet: (json['nombrePet'] ?? '').toString(),
      especie: (json['especie'] ?? '').toString(),
      raza: (json['raza'] ?? '').toString(),
      sexo: (json['sexo'] ?? '').toString(),
      edad: _int(json['edad']),
      peso: _double(json['peso']),
      image: _foto(
        json['image'] ??
        json['fotoUrl'] ??
        json['foto_url'] ??
        json['imageUrl'] ??
        json['image_url'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombrePet': nombrePet,
        'especie': especie,
        'raza': raza,
        'sexo': sexo,
        'edad': edad,
        'peso': peso,
        'image': image,
        'user_id': userId,
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
