class Usuario {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String phone;

  const Usuario({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.phone,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: _int(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['telefono'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'phone': phone,
      };

  static int? _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
