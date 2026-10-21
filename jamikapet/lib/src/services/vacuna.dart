import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/models/vacuna.dart';
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/services/pets_service.dart';

class VacunaService {
  static const Duration _timeout = Duration(seconds: 15);

  final String? token;
  VacunaService({this.token});

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<List<Vacuna>> obtenerVacunas(int mascotaId) async {
    try {
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/vacunas')
          .replace(queryParameters: {'mascotaId': mascotaId.toString()});

      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 401) {
        throw const PetsServiceException('Tu sesión expiró. Inicia sesión de nuevo.');
      }
      if (response.statusCode != 200) {
        throw PetsServiceException(_mensajeError(response, 'No se pudieron consultar las vacunas.'));
      }

      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) data = data['data'] ?? data['vacunas'];
      if (data is! List) {
        throw const PetsServiceException('Respuesta inesperada del servidor.');
      }

      return data
          .map((e) => Vacuna.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on SocketException {
      throw const PetsServiceException('Sin conexión con el servidor.');
    } on TimeoutException {
      throw const PetsServiceException('El servidor tardó demasiado en responder.');
    }
  }

  String _mensajeError(http.Response r, String porDefecto) {
    try {
      final body = jsonDecode(utf8.decode(r.bodyBytes));
      if (body is Map) {
        final msg = body['message'] ?? body['mensaje'] ?? body['error'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {}
    return porDefecto;
  }
}