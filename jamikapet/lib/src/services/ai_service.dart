import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';

class IaService {
  IaService._();

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
    return Uri.parse('${ApiConfig.baseUrl}/ai$ruta');
  }

  static Exception _errorRespuesta(http.Response response) {
    String mensaje = 'Error al procesar la respuesta de la IA.';

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

  // ENVIAR CONSULTA 
  static Future<String> enviarConsulta(String prompt) async {
    final headers = await _obtenerHeaders();

    final response = await http
        .post(
          _url('/chat'),
          headers: headers,
          body: jsonEncode({'prompt': prompt}),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] ?? data['mensaje'] ?? data['response'] ?? 'Sin respuesta';
    }

    throw _errorRespuesta(response);
  }

  // ENVIAR CONSULTA CON IMAGEN
  static Future<String> enviarConsultaConImagen({
    required Uint8List imageBytes,
    required String mimeType,
    String prompt = '',
  }) async {
    final headers = await _obtenerHeaders();
    // En multipart NO se define Content-Type manualmente:
    // http lo genera con el boundary correcto.
    headers.remove('Content-Type');

    final extension = mimeType.split('/').last; // jpeg, png, webp

    final request = http.MultipartRequest('POST', _url('/chat/image'))
      ..headers.addAll(headers)
      ..fields['prompt'] = prompt
      ..files.add(
        http.MultipartFile.fromBytes(
          'image', // debe coincidir con FileInterceptor('image')
          imageBytes,
          filename: 'mascota.$extension',
          contentType: MediaType.parse(mimeType),
        ),
      );

    // El backend tiene hasta 60s para imágenes, así que damos más margen
    final streamed = await request.send().timeout(const Duration(seconds: 180));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] ?? 'Sin respuesta';
    }

    throw _errorRespuesta(response);
  }
}