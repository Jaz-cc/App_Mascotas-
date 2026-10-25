class Usuario {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String phone;
  final String? image;
  final String? notificationToken;

  const Usuario({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.phone,
    this.image,
    this.notificationToken,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: _int(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['telefono'] ?? '').toString(),
      image: _foto(
        json['image'] ??
        json['fotoUrl'] ??
        json['foto_url'] ??
        json['imageUrl'] ??
        json['image_url'],
      ),
      notificationToken: (json['notification_token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'phone': phone,
        'image': image,
        'notification_token': notificationToken,
      };

  static int? _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _foto(dynamic value) {
    if (value == null) return null;

    final url = value.toString().trim();
    if (url.isEmpty) return null;

    return url;
  }
}
