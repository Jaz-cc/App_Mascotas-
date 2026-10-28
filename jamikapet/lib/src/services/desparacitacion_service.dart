import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/models/desparasitacion.dart';

class DesparasitacionException implements Exception {
  final String mensaje;
  const DesparasitacionException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Producto del catálogo (GET /desparasitaciones).
class ProductoDesparasitante {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? especie;

  const ProductoDesparasitante({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.especie,
  });

  factory ProductoDesparasitante.fromJson(Map<String, dynamic> json) {
    return ProductoDesparasitante(
      id: (json['id'] as num).toInt(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: json['descripcion']?.toString(),
      especie: json['especie']?.toString(),
    );
  }
}

class DesparasitacionService {
  DesparasitacionService._();

  // Controller de Nest: @Controller('desparasitaciones')
  static String get _base => '${ApiConfig.baseUrl}/desparasitaciones';

  static Future<Map<String, String>> _obtenerHeaders() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      throw const DesparasitacionException(
        'Tu sesión no tiene un token guardado. '
        'Cierra sesión e inicia sesión nuevamente.',
      );
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
    };
  }

  /// Ejecuta una petición y traduce los errores técnicos a mensajes claros.
  static Future<T> _ejecutar<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on DesparasitacionException {
      rethrow;
    } on SocketException {
      throw const DesparasitacionException('No hay conexión con el servidor.');
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

  static void _validarRespuesta(
    http.Response response,
    String porDefecto, {
    List<int> permitidos = const [200],
  }) {
    if (response.statusCode == 401) {
      throw const DesparasitacionException(
        'Tu sesión expiró. Inicia sesión de nuevo.',
      );
    }
    if (!permitidos.contains(response.statusCode)) {
      throw DesparasitacionException(_error(response, porDefecto));
    }
  }

  static String _fecha(DateTime d) => d.toIso8601String().split('T').first;

  /// El backend devuelve la entidad DesparasitacionHasPet:
  ///   { id, idProduc, idMascota, fechaAplicacion, proximaDosis, estado,
  ///     desparasitacion: { id, nombre, descripcion, especie } }
  /// Aquí se convierte al formato que espera Desparasitacion.fromJson.
  static Desparasitacion _aModelo(dynamic item) {
    final json = Map<String, dynamic>.from(item as Map);
    final producto = json['desparasitacion'] is Map
        ? Map<String, dynamic>.from(json['desparasitacion'] as Map)
        : <String, dynamic>{};

    return Desparasitacion.fromJson({
      'id': json['id'],
      'mascotaId': json['idMascota'] ?? json['mascotaId'],
      'nombre': 'Desparasitación',
      'producto': producto['nombre'] ?? json['producto'] ?? '',
      'fechaAplicacion': json['fechaAplicacion'],
      'proximaDosis': json['proximaDosis'],
      'estado': json['estado'] ?? 'Pendiente',
    });
  }

  // ------------------------------------------------------------------
  // CATÁLOGO: GET /desparasitaciones
  // ------------------------------------------------------------------
  static Future<List<ProductoDesparasitante>> obtenerProductos() {
    return _ejecutar(() async {
      final headers = await _obtenerHeaders();

      final response = await http
          .get(Uri.parse(_base), headers: headers)
          .timeout(ApiConfig.timeout);

      _validarRespuesta(response, 'No se pudo cargar el catálogo de productos.');

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! List) {
        throw const DesparasitacionException(
          'Respuesta inesperada del servidor.',
        );
      }

      return data
          .map<ProductoDesparasitante>(
            (e) => ProductoDesparasitante.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    });
  }

  // ------------------------------------------------------------------
  // HISTORIAL: GET /desparasitaciones/aplicaciones/mascota/:idMascota
  // ------------------------------------------------------------------
  static Future<List<Desparasitacion>> obtenerPorMascota(int mascotaId) {
    return _ejecutar(() async {
      final headers = await _obtenerHeaders();

      final response = await http
          .get(
            Uri.parse('$_base/aplicaciones/mascota/$mascotaId'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      _validarRespuesta(response, 'No se pudo cargar el historial.');

      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) data = data['data'];

      if (data is! List) {
        throw const DesparasitacionException(
          'Respuesta inesperada del servidor.',
        );
      }

      return data.map<Desparasitacion>(_aModelo).toList();
    });
  }

  // ------------------------------------------------------------------
  // REGISTRAR: POST /desparasitaciones/aplicaciones
  // ------------------------------------------------------------------
  static Future<Desparasitacion> registrar({
    required int mascotaId,
    required int productoId,
    required DateTime fechaAplicacion,
    required DateTime proximaDosis,
    String estado = 'Aplicada',
  }) {
    return _ejecutar(() async {
      final headers = await _obtenerHeaders();

      final response = await http
          .post(
            Uri.parse('$_base/aplicaciones'),
            headers: headers,
            body: jsonEncode({
              'idMascota': mascotaId,
              'idProduc': productoId,
              'fechaAplicacion': _fecha(fechaAplicacion),
              'proximaDosis': _fecha(proximaDosis),
              'estado': estado,
            }),
          )
          .timeout(ApiConfig.timeout);

      _validarRespuesta(
        response,
        'No se pudo registrar el tratamiento.',
        permitidos: const [200, 201],
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) {
        throw const DesparasitacionException(
          'El servidor devolvió una respuesta inválida.',
        );
      }

      return _aModelo(data);
    });
  }

  // ------------------------------------------------------------------
  // ACTUALIZAR: PATCH /desparasitaciones/aplicaciones/:id
  // ------------------------------------------------------------------
  static Future<Desparasitacion> actualizar({
    required int id,
    required int productoId,
    required DateTime fechaAplicacion,
    required DateTime proximaDosis,
    required String estado,
  }) {
    return _ejecutar(() async {
      final headers = await _obtenerHeaders();

      final response = await http
          .patch(
            Uri.parse('$_base/aplicaciones/$id'),
            headers: headers,
            body: jsonEncode({
              'idProduc': productoId,
              'fechaAplicacion': _fecha(fechaAplicacion),
              'proximaDosis': _fecha(proximaDosis),
              'estado': estado,
            }),
          )
          .timeout(ApiConfig.timeout);

      _validarRespuesta(response, 'No se pudo actualizar el tratamiento.');

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) {
        throw const DesparasitacionException(
          'El servidor devolvió una respuesta inválida.',
        );
      }

      return _aModelo(data);
    });
  }

  // ------------------------------------------------------------------
  // DELETE /desparasitaciones/aplicaciones/:id
  // ------------------------------------------------------------------
  static Future<void> eliminar(int id) {
    return _ejecutar(() async {
      final headers = await _obtenerHeaders();

      final response = await http
          .delete(Uri.parse('$_base/aplicaciones/$id'), headers: headers)
          .timeout(ApiConfig.timeout);

      _validarRespuesta(
        response,
        'No se pudo eliminar el tratamiento.',
        permitidos: const [200, 204],
      );
    });
  }

  static String _error(http.Response response, String porDefecto) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data is Map) {
        final mensaje = data['message'] ?? data['mensaje'];

        if (mensaje is String && mensaje.isNotEmpty) return mensaje;
        if (mensaje is List && mensaje.isNotEmpty) return mensaje.join('\n');
      }
    } catch (_) {}

    return porDefecto;
  }
}