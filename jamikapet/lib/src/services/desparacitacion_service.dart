import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/models/desparasitacion.dart';

class DesparasitacionException implements Exception {
  final String mensaje;

  const DesparasitacionException(this.mensaje);

  @override
  String toString() => mensaje;
}

class DesparasitacionService {
  static const String origin = 'http://10.0.2.2:3000';
  static const String baseUrl = '$origin/api/desparasitaciones';

  static const Duration _timeout = Duration(seconds: 15);

  final String? token;

  DesparasitacionService({this.token});

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

  Future<List<Desparasitacion>> obtenerPorMascota(
    int mascotaId,
  ) async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'mascotaId': mascotaId.toString(),
        },
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 401) {
        throw const DesparasitacionException(
          'Tu sesión expiró. Inicia sesión de nuevo.',
        );
      }

      if (response.statusCode != 200) {
        throw DesparasitacionException(
          _error(response, 'No se pudo cargar el historial.'),
        );
      }

      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data is Map) {
        data = data['data'] ?? data['desparasitaciones'];
      }

      if (data is! List) {
        throw const DesparasitacionException(
          'Respuesta inesperada del servidor.',
        );
      }

      return data.map<Desparasitacion>((item) {
        return Desparasitacion.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } on DesparasitacionException {
      rethrow;
    } on SocketException {
      throw const DesparasitacionException(
        'No hay conexión con el servidor.',
      );
    } on TimeoutException {
      throw const DesparasitacionException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw const DesparasitacionException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
  }

  Future<Desparasitacion> registrar({
    required int mascotaId,
    required String nombre,
    required String producto,
    required DateTime fechaAplicacion,
    required DateTime proximaDosis,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: _headers,
            body: jsonEncode({
              'mascotaId': mascotaId,
              'nombre': nombre,
              'producto': producto,
              'fechaAplicacion':
                  fechaAplicacion.toIso8601String(),
              'proximaDosis':
                  proximaDosis.toIso8601String(),
              'estado': 'Aplicada',
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 401) {
        throw const DesparasitacionException(
          'Tu sesión expiró. Inicia sesión de nuevo.',
        );
      }

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw DesparasitacionException(
          _error(response, 'No se pudo registrar el tratamiento.'),
        );
      }

      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data is Map) {
        data = data['data'] ?? data['desparasitacion'] ?? data;
      }

      if (data is! Map) {
        throw const DesparasitacionException(
          'El servidor devolvió una respuesta inválida.',
        );
      }

      return Desparasitacion.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DesparasitacionException {
      rethrow;
    } on SocketException {
      throw const DesparasitacionException(
        'No hay conexión con el servidor.',
      );
    } on TimeoutException {
      throw const DesparasitacionException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw const DesparasitacionException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
  }

  String _error(http.Response response, String porDefecto) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data is Map) {
        final mensaje = data['message'] ?? data['mensaje'];

        if (mensaje is String && mensaje.isNotEmpty) {
          return mensaje;
        }

        if (mensaje is List && mensaje.isNotEmpty) {
          return mensaje.join('\n');
        }
      }
    } catch (_) {}

    return porDefecto;
  }
}
