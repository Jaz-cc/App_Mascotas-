import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jamikapet/src/models/mascota.dart';

class MascotaException implements Exception {
  final String mensaje;

  const MascotaException(this.mensaje);

  @override
  String toString() => mensaje;
}

class MascotaService {
  static const String origin = 'http://10.0.2.2:3000';

  // Si NestJS tiene configurado el prefijo global /api.
  static const String baseUrl = '$origin/api';

  static const Duration _timeout = Duration(seconds: 15);

  final String? token;

  MascotaService({this.token});

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

  static String? urlFoto(String? fotoUrl) {
    if (fotoUrl == null || fotoUrl.trim().isEmpty) {
      return null;
    }

    final url = fotoUrl.trim();

    if (url.startsWith('https://') || url.startsWith('http://')) {
      return url;
    }

    return url.startsWith('/')
        ? '$origin$url'
        : '$origin/$url';
  }

  /// Obtiene todas las mascotas del usuario autenticado.
  Future<List<Mascota>> obtenerMascotas() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/mascotas'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 401) {
        throw const MascotaException(
          'Tu sesión expiró. Inicia sesión de nuevo.',
        );
      }

      if (response.statusCode != 200) {
        throw MascotaException(
          _mensajeError(
            response,
            'No se pudieron consultar las mascotas.',
          ),
        );
      }

      dynamic data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (data is Map) {
        data = data['data'] ?? data['mascotas'];
      }

      if (data is! List) {
        throw const MascotaException(
          'Respuesta inesperada del servidor.',
        );
      }

      return data.map<Mascota>((elemento) {
        return Mascota.fromJson(
          Map<String, dynamic>.from(elemento as Map),
        );
      }).toList();
    } on MascotaException {
      rethrow;
    } on SocketException {
      throw const MascotaException(
        'Sin conexión con el servidor.',
      );
    } on TimeoutException {
      throw const MascotaException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw const MascotaException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
  }

  Future<Mascota> registrarMascota({
    required String nombre,
    required String tipo,
    required String raza,
    required String genero,
    required int edad,
    required double peso,
    File? foto,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/mascotas'),
      );

      request.headers.addAll(_headers);

      request.fields.addAll({
        'nombre': nombre,
        'tipo': tipo,
        'raza': raza,
        'genero': genero,
        'edad': edad.toString(),
        'peso': peso.toString(),
      });

      if (foto != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            foto.path,
          ),
        );
      }

      final streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 30));

      final response = await http.Response
          .fromStream(streamedResponse)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw const MascotaException(
          'Tu sesión expiró. Inicia sesión de nuevo.',
        );
      }

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw MascotaException(
          _mensajeError(
            response,
            'No se pudo registrar la mascota.',
          ),
        );
      }

      dynamic data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (data is Map) {
        data = data['data'] ?? data['mascota'] ?? data;
      }

      if (data is! Map) {
        throw const MascotaException(
          'El servidor no devolvió los datos de la mascota.',
        );
      }

      return Mascota.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on MascotaException {
      rethrow;
    } on SocketException {
      throw const MascotaException(
        'Sin conexión con el servidor.',
      );
    } on TimeoutException {
      throw const MascotaException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw const MascotaException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
  }

  String _mensajeError(
    http.Response response,
    String porDefecto,
  ) {
    try {
      final body = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (body is Map) {
        final mensaje =
            body['message'] ?? body['mensaje'] ?? body['error'];

        if (mensaje is String && mensaje.isNotEmpty) {
          return mensaje;
        }

        if (mensaje is List && mensaje.isNotEmpty) {
          return mensaje.join('\n');
        }
      }
    } catch (_) {
      // Se utiliza el mensaje predeterminado.
    }

    return porDefecto;
  }
}
