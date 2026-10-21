import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/models/mascota.dart';

class PetsServiceException implements Exception {
  const PetsServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Cliente HTTP para el módulo de mascotas de NestJS.
class PetsService {
  PetsService._();

  /// Obtiene los encabezados con el token JWT.
  static Future<Map<String, String>> _obtenerHeaders() async {

    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw const PetsServiceException(
        'Tu sesión no tiene un token guardado. '
        'Cierra sesión e inicia sesión nuevamente.',
      );
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

    /// Convierte una ruta de foto en una URL completa.
  /// Convierte la ruta de la imagen en una URL completa.
  static String? urlFoto(String? image) {
    if (image == null || image.trim().isEmpty) {
      return null;
    }

    final url = image.trim();

    if (url.startsWith('https://') ||
        url.startsWith('http://')) {
      return url;
    }

    final origin = ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/$'),
      '',
    );

    return url.startsWith('/')
        ? '$origin$url'
        : '$origin/$url';
  }
  
  // REGISTRO DE MASCOTAS
  static Future<Map<String, dynamic>> registrarMascota({
    required String nombre,
    required String especie,
    required String raza,
    required String sexo,
    required int edad,
    required double peso,
  }) async {

    final token = await TokenStorage.getToken();

    if (token == null) {
      throw const PetsServiceException(
        'Tu sesión no tiene un token guardado. Cierra sesión e inicia sesión nuevamente.',
      );
    }

    Uri.parse('${ApiConfig.baseUrl}/pets');
    final body = <String, dynamic>{
      'nombrePet': nombre,
      'especie': especie,
      'raza': raza,
      'sexo': sexo,
      'edad': edad,
      'peso': peso,
    };

    late http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/pets'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const PetsServiceException(
        'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const PetsServiceException(
        'No se pudo conectar con el backend. Comprueba la dirección y que NestJS esté ejecutándose.',
      );
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    }

    if (response.statusCode == 401) {
      throw const PetsServiceException(
        'Tu sesión expiró o el token no es válido. Inicia sesión nuevamente.',
      );
    }

    var message = 'No se pudo registrar la mascota (HTTP ${response.statusCode}).';
    if (decoded is Map<String, dynamic> && decoded['message'] != null) {
      final serverMessage = decoded['message'];
      message = serverMessage is List
          ? serverMessage.join('\n')
          : serverMessage.toString();
    }
    throw PetsServiceException(message);
  }

  /// Obtiene todas las mascotas del usuario autenticado.
  static Future<List<Mascota>> obtenerMascotas() async {
     final headers = await _obtenerHeaders();

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/pets'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 401) {
        throw const PetsServiceException(
          'Tu sesión expiró. Inicia sesión de nuevo.',
        );
      }

      if (response.statusCode != 200) {
        throw PetsServiceException(
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
        throw const PetsServiceException(
          'Respuesta inesperada del servidor.',
        );
      }

      return data.map<Mascota>((elemento) {
        return Mascota.fromJson(
          Map<String, dynamic>.from(elemento as Map),
        );
      }).toList();

    } on PetsServiceException {

      rethrow;

    } on SocketException {

      throw const PetsServiceException(
        'Sin conexión con el servidor.',
      );

    } on TimeoutException {

      throw const PetsServiceException(
        'El servidor tardó demasiado en responder.',
      );

    } on FormatException {

      throw const PetsServiceException(
        'El servidor devolvió una respuesta inválida.',
      );

    }
  }


  static String _mensajeError(
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
