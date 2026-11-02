import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/models/notificacion.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';

class NotificacionException implements Exception {
  final String mensaje;

  const NotificacionException(this.mensaje);

  @override
  String toString() => mensaje;
}

class NotificacionService {
  final String? token;

  NotificacionService({this.token});

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final tokenGuardado = token ?? await TokenStorage.getToken();

    if (tokenGuardado != null && tokenGuardado.isNotEmpty) {
      final tokenLimpio = tokenGuardado.replaceFirst(
        RegExp(r'^Bearer\s+', caseSensitive: false),
        '',
      );

      headers['Authorization'] = 'Bearer $tokenLimpio';
    }

    return headers;
  }

  Future<List<Notificacion>> obtenerNotificaciones() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/notificaciones'),
            headers: await _headers(),
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
        throw const NotificacionException(
          'El servidor devolvió un formato de notificaciones inválido.',
        );
      }

      return datos
          .map(
            (item) => Notificacion.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on SocketException {
      throw const NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw const NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw const NotificacionException(
        'La respuesta del servidor no es válida.',
      );
    }
  }

  /// El backend actual solo permite marcar una notificación como leída.
  Future<void> marcarLeida(int id) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/notificaciones/$id/leida'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 20));

      _validarRespuesta(response);
    } on SocketException {
      throw const NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw const NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/notificaciones/leidas'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 20));

      _validarRespuesta(response);
    } on SocketException {
      throw const NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw const NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    }
  }

  Future<void> eliminarNotificacion(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/notificaciones/$id'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 20));

      _validarRespuesta(response);
    } on SocketException {
      throw const NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw const NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    }
  }

  Future<Notificacion> actualizarEstado({
    required int id,
    required bool atendida,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/notificaciones/$id/atendida',
            ),
            headers: await _headers(),
            body: jsonEncode({
              'atendida': atendida,
            }),
          )
          .timeout(const Duration(seconds: 20));

      _validarRespuesta(response);

      final dynamic decoded = jsonDecode(response.body);

      final dynamic datos = decoded is Map
          ? decoded['data'] ??
              decoded['notificacion'] ??
              decoded
          : decoded;

      if (datos is! Map) {
        throw const NotificacionException(
          'No se pudo actualizar la notificación.',
        );
      }

      return Notificacion.fromJson(
        Map<String, dynamic>.from(datos),
      );
    } on SocketException {
      throw const NotificacionException(
        'No se pudo conectar con el servidor.',
      );
    } on TimeoutException {
      throw const NotificacionException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw const NotificacionException(
        'La respuesta del servidor no es válida.',
      );
    }
  }
  
  void _validarRespuesta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
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
    } catch (_) {}

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
