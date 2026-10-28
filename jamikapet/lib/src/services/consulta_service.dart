import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/models/consulta.dart';
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';

class ConsultaService {
  ConsultaService._();

  static Future<Map<String, String>> _obtenerHeaders() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'No hay una sesión activa. Inicia sesión nuevamente.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token.startsWith('Bearer ')
          ? token
          : 'Bearer $token',
    };
  }

  static Uri _url(String ruta) {
    return Uri.parse('${ApiConfig.baseUrl}/consultas$ruta');
  }

  static Exception _errorRespuesta(http.Response response) {
    String mensaje = 'Error al comunicarse con el servidor.';

    try {
      final body = jsonDecode(response.body);

      if (body is Map) {
        final message = body['message'];

        if (message is List) {
          mensaje = message.join('\n');
        } else if (message != null) {
          mensaje = message.toString();
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        mensaje = response.body;
      }
    }
    return Exception('$mensaje (HTTP ${response.statusCode})');
  }

  // AGENDAR O REGISTRAR CITA
  static Future<Consulta> registrarConsulta(Consulta consulta) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .post(
          _url(''),
          headers: headers,
          body: jsonEncode({
            'mascotaId': consulta.mascotaId,
            'veterinario': consulta.veterinario,
            'motivo': consulta.motivo,
            'fecha': consulta.fecha.toIso8601String().split('T').first,
            'hora': consulta.hora,
            'estado': consulta.estado,
            'notas': consulta.notas,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Consulta.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw _errorRespuesta(response);
  }

  // OBTENER TODAS LAS CITAS DEL USUARIO
  static Future<List<Consulta>> obtenerConsultas() async {
    final headers = await _obtenerHeaders();

    final response = await http
        .get(_url(''), headers: headers)
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('La respuesta del servidor no es una lista.');
      }

      return data
          .map(
            (item) => Consulta.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw _errorRespuesta(response);
  }

  // OBTENER CITAS DE UNA MASCOTA ESPECÍFICA
  static Future<List<Consulta>> obtenerPorMascota(String mascotaId) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .get(
          _url('/mascota/$mascotaId'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('La respuesta del servidor no es una lista.');
      }

      return data
          .map(
            (item) => Consulta.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw _errorRespuesta(response);
  }

  // CANCELAR O ELIMINAR CONSULTA
  static Future<void> eliminarConsulta(String id) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .delete(
          _url('/$id'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _errorRespuesta(response);
    }
  }
}