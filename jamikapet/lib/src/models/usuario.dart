class Usuario {
  final String? id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? direccion;
  final String? fotoUrl;
  final String? token;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.direccion,
    this.fotoUrl,
    this.token,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? json['_id'],
      nombre: json['nombre'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? json['phone'],
      direccion: json['direccion'] ?? json['address'],
      fotoUrl: json['fotoUrl'] ?? json['avatar'],
      token: json['access_token'] ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'fotoUrl': fotoUrl,
    };
  }
}