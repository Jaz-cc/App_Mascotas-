import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jamikapet/src/models/notificacion.dart';

class NotificacionService {
  static const String baseUrl =
      'http://10.0.2.2:3000/api';

  final String? token;

  NotificacionService({this.token});

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Obtiene las notificaciones del usuario autenticado.
  Future<List<Notificacion>> obtenerNotificaciones() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notificaciones'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 20));

      _validarRespuesta(response);

      final dynamic decoded = jsonDecode(response.body);

      final dynamic datos = decoded is List
          ? decoded
          : decoded is Map
              ? decoded['data'] ?? decoded['notificaciones'] ?? []
              : [];

      if (datos is! List) {
        throw NotificacionException(
          'El servidor devolvió un formato de notificaciones inválido.',
        );
      }

      return datos.map((item) {
        return Notificacion.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } on SocketException {
      throw NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw NotificacionException(
        'La respuesta del servidor no es válida.',
      );
    }
  }

  /// Cambia el estado de una notificación.
  ///
  /// Ruta propuesta: PATCH /api/notificaciones/:id
  Future<Notificacion> actualizarEstado({
    required int id,
    required bool atendida,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/notificaciones/$id'),
            headers: _headers,
            body: jsonEncode({'atendida': atendida}),
          )
          .timeout(const Duration(seconds: 20));

      _validarRespuesta(response);

      final dynamic decoded = jsonDecode(response.body);

      final dynamic datos = decoded is Map
          ? decoded['data'] ?? decoded['notificacion'] ?? decoded
          : decoded;

      if (datos is! Map) {
        throw NotificacionException(
          'No se pudo actualizar la notificación.',
        );
      }

      return Notificacion.fromJson(
        Map<String, dynamic>.from(datos),
      );
    } on SocketException {
      throw NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw NotificacionException(
        'La respuesta del servidor no es válida.',
      );
    }
  }

  /// Elimina una notificación.
  ///
  /// Ruta propuesta: DELETE /api/notificaciones/:id
  Future<void> eliminarNotificacion(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/notificaciones/$id'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 20));

      _validarRespuesta(response);
    } on SocketException {
      throw NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    }
  }

  void _validarRespuesta(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String mensaje = 'Error al procesar la notificación.';

    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map) {
        final detalle = decoded['message'] ?? decoded['error'];

        if (detalle is List) {
          mensaje = detalle.join(', ');
        } else if (detalle != null) {
          mensaje = detalle.toString();
        }
      }
    } catch (_) {
      // Se utiliza el mensaje predeterminado.
    }

    if (response.statusCode == 401) {
      mensaje = 'Tu sesión ha expirado. Inicia sesión nuevamente.';
    } else if (response.statusCode == 403) {
      mensaje = 'No tienes permiso para esta acción.';
    } else if (response.statusCode == 404) {
      mensaje = 'No se encontró la notificación solicitada.';
    } else if (response.statusCode >= 500) {
      mensaje = 'Ocurrió un error interno en el servidor.';
    }

    throw NotificacionException(mensaje);
  }
}

class NotificacionException implements Exception {
  final String mensaje;

  const NotificacionException(this.mensaje);

  @override
  String toString() => mensaje;
}