import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/models/usuario.dart';

class AuthException implements Exception {
  final String mensaje;

  const AuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/auth';
  static const Duration _timeout = Duration(seconds: 15);

  Future<Usuario> registrarUsuario({
    required String nombre,
    required String apellido,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'nombre': nombre,
              'apellido': apellido,
              'email': email,
              'phone': phone,
              'password': password,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AuthException(
          _mensajeError(response, 'No se pudo registrar el usuario.'),
        );
      }

      if (response.bodyBytes.isEmpty) {
        throw const AuthException(
          'El servidor confirmó el registro, pero no devolvió el usuario.',
        );
      }

      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        data = data['data'] ?? data['usuario'] ?? data['user'] ?? data;
      }

      if (data is! Map) {
        throw const AuthException(
          'El servidor devolvió una respuesta inválida.',
        );
      }

      final usuario = Usuario.fromJson(Map<String, dynamic>.from(data));
      if (usuario.nombre.isEmpty ||
          usuario.apellido.isEmpty ||
          usuario.email.isEmpty ||
          usuario.phone.isEmpty) {
        throw const AuthException(
          'El servidor no devolvió los datos del usuario registrado.',
        );
      }

      return usuario;
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const AuthException('No hay conexión con el servidor.');
    } on TimeoutException {
      throw const AuthException('El servidor tardó demasiado en responder.');
    } on FormatException {
      throw const AuthException('El servidor devolvió una respuesta inválida.');
    }
  }

  String _mensajeError(http.Response response, String porDefecto) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        final mensaje = data['message'] ?? data['mensaje'] ?? data['error'];
        if (mensaje is String && mensaje.isNotEmpty) return mensaje;
        if (mensaje is List && mensaje.isNotEmpty) {
          return mensaje.join('\n');
        }
      }
    } on FormatException {
      return porDefecto;
    }

    return porDefecto;
  }
}
