
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:jamikapet/src/core/network/api_config.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';

class UsersServiceException implements Exception {
  const UsersServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class UsersService {
  UsersService._();

  // ============================================================
  // URL BASE
  // ============================================================
  static String get _baseUrl =>
      ApiConfig.baseUrl.replaceFirst(RegExp(r'/$'), '');

  // ============================================================
  // HEADERS CON JWT
  // ============================================================
  static Future<Map<String, String>> _obtenerHeaders() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw const UsersServiceException(
        'Tu sesión no tiene un token guardado. '
        'Inicia sesión nuevamente.',
      );
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // URL DE FOTO DE PERFIL
  // ============================================================
  static String? urlFoto(String? image) {
    if (image == null || image.trim().isEmpty) {
      return null;
    }

    final url = image.trim();

    if (url.startsWith('https://') || url.startsWith('http://')) {
      return url;
    }

    return url.startsWith('/')
        ? '$_baseUrl$url'
        : '$_baseUrl/$url';
  }

  // ============================================================
  // REGISTRO DE USUARIO
  // ============================================================
  static Future<Map<String, dynamic>> crearUsuario({
    required Map<String, dynamic> datos,
  }) async {
    final response = await _enviarPeticion(
      () => http.post(
        Uri.parse('$_baseUrl/users'),
        headers: const {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(datos),
      ),
    );

    return _leerRespuesta(
      response,
      mensajePorDefecto: 'No se pudo crear el usuario.',
      codigosExitosos: [200, 201],
    );
  }

  // ============================================================
  // OBTENER TODOS LOS USUARIOS
  // ============================================================
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final headers = await _obtenerHeaders();

    final response = await _enviarPeticion(
      () => http.get(
        Uri.parse('$_baseUrl/users'),
        headers: headers,
      ),
    );

    final data = _leerRespuesta(
      response,
      mensajePorDefecto: 'No se pudieron consultar los usuarios.',
      codigosExitosos: [200],
    );

    dynamic resultado = data['data'] ?? data['users'] ?? data;

    if (resultado is! List) {
      throw const UsersServiceException(
        'El servidor devolvió una lista de usuarios inválida.',
      );
    }

    return resultado.map<Map<String, dynamic>>((usuario) {
      return Map<String, dynamic>.from(usuario as Map);
    }).toList();
  }

  // ============================================================
  // OBTENER USUARIO POR ID
  // ============================================================
  static Future<Map<String, dynamic>> obtenerUsuario({
    required int id,
  }) async {
    final headers = await _obtenerHeaders();

    final response = await _enviarPeticion(
      () => http.get(
        Uri.parse('$_baseUrl/users/$id'),
        headers: headers,
      ),
    );

    return _leerRespuesta(
      response,
      mensajePorDefecto: 'No se pudo consultar el usuario.',
      codigosExitosos: [200],
    );
  }

  // ============================================================
  // SUBIR FOTO DE PERFIL A CLOUDINARY
  // ============================================================
  static Future<String> subirImagenUsuario({
    required XFile imagen,
  }) async {
    final headers = await _obtenerHeaders();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl.replaceFirst(RegExp(r'/$'), '')}/users/upload-image',
    );
      
     try {
      // Leer la imagen como bytes funciona en Web y móvil.
      final bytes = await imagen.readAsBytes();

      final request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = headers['Authorization']!;

      final nombre = imagen.name.toLowerCase();

      final MediaType tipoContenido;

      if (nombre.endsWith('.jpg') || nombre.endsWith('.jpeg')) {
        tipoContenido = MediaType('image', 'jpeg');
      } else if (nombre.endsWith('.png')) {
        tipoContenido = MediaType('image', 'png');
      } else if (nombre.endsWith('.webp')) {
        tipoContenido = MediaType('image', 'webp');
      } else {
        throw const UsersServiceException(
          'Formato no compatible. Selecciona JPG, PNG o WEBP.',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imagen.name,
          contentType: tipoContenido,
        ),
      );

      final streamedResponse = await request
          .send()
          .timeout(ApiConfig.timeout);

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw UsersServiceException(
          _mensajeError(
            response,
            'No se pudo subir la imagen a Cloudinary.',
          ),
        );
      }

      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      final imageUrl = data['image'] as String?;

      if (imageUrl == null || imageUrl.isEmpty) {
        throw const UsersServiceException(
          'El backend no devolvió la URL de la imagen.',
        );
      }

      return imageUrl;
    } on TimeoutException {
      throw const UsersServiceException(
        'La subida de la imagen tardó demasiado.',
      );
    } on http.ClientException {
      throw const UsersServiceException(
        'No se pudo conectar con el servidor.',
      );
    } on FormatException {
      throw const UsersServiceException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
  }

  // ============================================================
  // ACTUALIZAR USUARIO
  // ============================================================
  static Future<Map<String, dynamic>> actualizarUsuario({
    required int id,
    required String nombre,
    required String apellido,
    required String email,
    required String phone,
    XFile? nuevaImagen,
  }) async {
    final headers = await _obtenerHeaders();

    final body = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'phone': phone,
    };

    // Primero se sube la foto y se agrega su URL al DTO.
    if (nuevaImagen != null) {
      body['image'] = await subirImagenUsuario(
        imagen: nuevaImagen,
      );
    }

    final baseUrl = ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/$'),
      '',
    );

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/users/$id'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return <String, dynamic>{};
      }

      throw UsersServiceException(
        _mensajeError(
          response,
          'No se pudo actualizar la mascota.',
        ),
      );
    } on TimeoutException {
      throw const UsersServiceException(
        'El servidor tardó demasiado en responder.',
      );
    } on http.ClientException {
      throw const UsersServiceException(
        'No se pudo conectar con el servidor.',
      );
    }
  }

  // ============================================================
  // PETICIÓN HTTP CON MANEJO DE ERRORES DE CONEXIÓN
  // ============================================================
  static Future<http.Response> _enviarPeticion(
    Future<http.Response> Function() peticion,
  ) async {
    try {
      return await peticion().timeout(ApiConfig.timeout);
    } on UsersServiceException {
      rethrow;
    } on TimeoutException {
      throw const UsersServiceException(
        'El servidor tardó demasiado en responder.',
      );
    } 
  }

  // ============================================================
  // LEER RESPUESTAS HTTP
  // ============================================================
  static Map<String, dynamic> _leerRespuesta(
    http.Response response, {
    required String mensajePorDefecto,
    required List<int> codigosExitosos,
  }) {
    final data = _decodificar(response);

    if (codigosExitosos.contains(response.statusCode)) {
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return <String, dynamic>{};
    }

    if (response.statusCode == 401) {
      throw const UsersServiceException(
        'Tu sesión expiró o no es válida. Inicia sesión nuevamente.',
      );
    }

    throw UsersServiceException(
      _mensajeError(data, mensajePorDefecto),
    );
  }

  static dynamic _decodificar(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  static String _mensajeError(
    dynamic data,
    String mensajePorDefecto,
  ) {
    if (data is Map) {
      final mensaje =
          data['message'] ?? data['mensaje'] ?? data['error'];

      if (mensaje is String && mensaje.isNotEmpty) {
        return mensaje;
      }

      if (mensaje is List && mensaje.isNotEmpty) {
        return mensaje.join('\n');
      }
    }

    return mensajePorDefecto;
  }
}
