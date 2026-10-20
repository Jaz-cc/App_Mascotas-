import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';

class PetsServiceException implements Exception {
  const PetsServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Cliente HTTP para el módulo de mascotas de NestJS.
class PetsService {
  PetsService._();

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

    final uri = Uri.parse('${ApiConfig.baseUrl}/pets');
    final body = <String, dynamic>{
      'nombre': nombre,
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
            uri,
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
}
