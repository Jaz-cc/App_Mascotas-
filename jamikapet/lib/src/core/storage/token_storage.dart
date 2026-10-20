import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT de sesión de forma segura en el dispositivo.
class TokenStorage {
  TokenStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jamika_pet_jwt';

  static Future<void> saveToken(String token) async {
    final limpio = token.trim().replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '');
    if (limpio.isEmpty) {
      throw const FormatException('El servidor no devolvió un token válido.');
    }
    await _storage.write(key: _tokenKey, value: limpio);
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.trim().isEmpty) return null;
    return token.trim().replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '');
  }

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
