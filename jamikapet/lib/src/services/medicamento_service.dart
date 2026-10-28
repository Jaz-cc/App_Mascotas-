import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/models/medicamento.dart';
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';

class MedicamentoService {
  MedicamentoService._();

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
    return Uri.parse('${ApiConfig.baseUrl}/medicamentos$ruta');
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

  // REGISTRAR MEDICAMENTO
  static Future<Medicamento> registrarMedicamento(
    Medicamento medicamento,
  ) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .post(
          _url(''),
          headers: headers,
          body: jsonEncode({
            'mascotaId': medicamento.mascotaId,
            'nombre': medicamento.nombre,
            'dosis': medicamento.dosis,
            'frecuencia': medicamento.frecuencia,
            'horaAdministracion': medicamento.horaAdministracion,
            'fechaInicio':
                medicamento.fechaInicio.toIso8601String().split('T').first,
            'fechaFinalizacion': medicamento.fechaFinalizacion
                .toIso8601String()
                .split('T')
                .first,
            'indicaciones': medicamento.indicaciones,
            'veterinario': medicamento.veterinario,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Medicamento.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw _errorRespuesta(response);
  }

  // OBTENER TODOS LOS MEDICAMENTOS DEL USUARIO
  static Future<List<Medicamento>> obtenerMedicamentos() async {
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
            (item) => Medicamento.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw _errorRespuesta(response);
  }

  // OBTENER MEDICAMENTOS DE UNA MASCOTA
  static Future<List<Medicamento>> obtenerPorMascota(
    String mascotaId,
  ) async {
    final headers = await _obtenerHeaders();
    final id = int.parse(mascotaId);

    final response = await http
        .get(
          _url('/mascota/$id'),
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
            (item) => Medicamento.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw _errorRespuesta(response);
  }

  // ACTUALIZAR MEDICAMENTO
  static Future<Medicamento> actualizarMedicamento(
    Medicamento medicamento,
  ) async {
    if (medicamento.id == null) {
      throw Exception('El medicamento no tiene un ID válido.');
    }

    final headers = await _obtenerHeaders();

    final response = await http
        .put(
          _url('/${medicamento.id}'),
          headers: headers,
          body: jsonEncode({
            'mascotaId': medicamento.mascotaId,
            'nombre': medicamento.nombre,
            'dosis': medicamento.dosis,
            'frecuencia': medicamento.frecuencia,
            'horaAdministracion': medicamento.horaAdministracion,
            'fechaInicio':
                medicamento.fechaInicio.toIso8601String().split('T').first,
            'fechaFinalizacion': medicamento.fechaFinalizacion
                .toIso8601String()
                .split('T')
                .first,
            'indicaciones': medicamento.indicaciones,
            'veterinario': medicamento.veterinario,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Medicamento.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw _errorRespuesta(response);
  }

  // ELIMINAR MEDICAMENTO
  static Future<void> eliminarMedicamento(int id) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .delete(
          _url('/$id'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw _errorRespuesta(response);
    }
  }
}