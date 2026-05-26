import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _usernameKey = 'username';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  String? _cachedUsername;

  bool get _isWeb => kIsWeb;

  Future<void> loadTokens() async {
    if (_isWeb) {
      _cachedAccessToken = web.window.localStorage.getItem(_accessTokenKey);
      _cachedRefreshToken = web.window.localStorage.getItem(_refreshTokenKey);
      _cachedUsername = web.window.localStorage.getItem(_usernameKey);
    } else {
      _cachedAccessToken = await _secureStorage.read(key: _accessTokenKey);
      _cachedRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
      _cachedUsername = await _secureStorage.read(key: _usernameKey);
    }
  }

  Future<String?> get accessToken async {
    if (_cachedAccessToken != null) return _cachedAccessToken;

    if (_isWeb) {
      return web.window.localStorage.getItem(_accessTokenKey);
    } else {
      return await _secureStorage.read(key: _accessTokenKey);
    }
  }

  Future<String?> get refreshToken async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;

    if (_isWeb) {
      return web.window.localStorage.getItem(_refreshTokenKey);
    } else {
      return await _secureStorage.read(key: _refreshTokenKey);
    }
  }

  Future<String?> get username async {
    if (_cachedUsername != null) return _cachedUsername;

    if (_isWeb) {
      return web.window.localStorage.getItem(_usernameKey);
    } else {
      return await _secureStorage.read(key: _usernameKey);
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;

    if (_isWeb) {
      // On web, consider encrypting the tokens before storing
      // For production, use a library like `encrypt` to encrypt tokens
      web.window.localStorage.setItem(_accessTokenKey, accessToken);
      web.window.localStorage.setItem(_refreshTokenKey, refreshToken);
    } else {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> saveUsername(String name) async {
    _cachedUsername = name;

    if (_isWeb) {
      web.window.localStorage.setItem(_usernameKey, name);
    } else {
      await _secureStorage.write(key: _usernameKey, value: name);
    }
  }

  Future<void> clearAll() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedUsername = null;

    if (_isWeb) {
      web.window.localStorage.removeItem(_accessTokenKey);
      web.window.localStorage.removeItem(_refreshTokenKey);
      web.window.localStorage.removeItem(_usernameKey);
    } else {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _usernameKey);
    }
  }

  bool get hasTokensSync =>
      _cachedAccessToken != null && _cachedRefreshToken != null;
}
