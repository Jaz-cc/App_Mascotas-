import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/models/consulta.dart';

class CitasService {
  CitasService._();

  static Future<Map<String, String>> _obtenerHeaders() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa. Inicia sesión nuevamente.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String get _baseUrl => '${ApiConfig.baseUrl}/citas';

  static dynamic _procesarRespuesta(http.Response response) {
    dynamic data;

    try {
      data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;
    } catch (_) {
      data = response.body;
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    String mensaje = 'Error al comunicarse con el servidor.';

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is List) {
        mensaje = message.join(', ');
      } else if (message is String) {
        mensaje = message;
      }
    }

    throw Exception(
      'Error ${response.statusCode}: $mensaje',
    );
  }

  // Registrar una cita.
  static Future<Consulta> registrarCita(Consulta cita) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: headers,
          body: jsonEncode(cita.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _procesarRespuesta(response);

    return Consulta.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  // Obtener todas las citas del usuario autenticado.
  static Future<List<Consulta>> obtenerCitas() async {
    final headers = await _obtenerHeaders();

    final response = await http
        .get(
          Uri.parse(_baseUrl),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    final data = _procesarRespuesta(response);

    return (data as List)
        .map(
          (item) => Consulta.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  // Obtener las citas de una mascota.
  static Future<List<Consulta>> obtenerCitasPorMascota(
    int mascotaId,
  ) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .get(
          Uri.parse('$_baseUrl/mascota/$mascotaId'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    final data = _procesarRespuesta(response);

    return (data as List)
        .map(
          (item) => Consulta.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  // Obtener una cita específica.
  static Future<Consulta> obtenerCita(int id) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .get(
          Uri.parse('$_baseUrl/$id'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    final data = _procesarRespuesta(response);

    return Consulta.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  // Actualizar una cita.
  static Future<Consulta> actualizarCita(
    int id,
    Map<String, dynamic> cambios,
  ) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .patch(
          Uri.parse('$_baseUrl/$id'),
          headers: headers,
          body: jsonEncode(cambios),
        )
        .timeout(ApiConfig.timeout);

    final data = _procesarRespuesta(response);

    return Consulta.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  // Eliminar una cita.
  static Future<void> eliminarCita(int id) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .delete(
          Uri.parse('$_baseUrl/$id'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    _procesarRespuesta(response);
  }
}