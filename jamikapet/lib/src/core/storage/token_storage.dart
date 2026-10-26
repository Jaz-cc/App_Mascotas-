import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'jamika_pet_jwt';
  static const String _userKey = 'jamika_pet_user';

  static Future<void> saveToken(String token) async {
    final limpio = token.trim().replaceFirst(
      RegExp(r'^Bearer\s+', caseSensitive: false),
      '',
    );

    if (limpio.isEmpty) {
      throw const FormatException(
        'El servidor no devolvió un token válido.',
      );
    }

    await _storage.write(key: _tokenKey, value: limpio);
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.trim().isEmpty) return null;

    return token.trim().replaceFirst(
      RegExp(r'^Bearer\s+', caseSensitive: false),
      '',
    );
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user),
    );
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final json = await _storage.read(key: _userKey);

    if (json == null || json.isEmpty) return null;

    final decoded = jsonDecode(json);

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return null;
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
