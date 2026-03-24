import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = "auth_token";

  // save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // delete token
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
