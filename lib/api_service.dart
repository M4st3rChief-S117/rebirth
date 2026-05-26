import 'dart:convert';
import 'package:base_flutter_template/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

class ApiService with ChangeNotifier {
  String baseUrl = "http://localhost:8070/api";
  // TODO:change clientname
  String client = 'clientname';

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final tokenStorage = TokenStorageService();

  String? _username;
  bool _isAuthenticated = false;

  static const Duration _requestTimeout = Duration(seconds: 30);

  String? get username => _username;

  bool get isAuthenticated => _isAuthenticated;

  ApiService() {
    _loadUser();
  }

  Future<String?> _getValidAccessToken() async {
    await tokenStorage.loadTokens();
    final accessToken = await tokenStorage.accessToken;

    if (accessToken == null) return null;

    if (Jwt.isExpired(accessToken) || _isTokenNearExpiry(accessToken)) {
      await refreshAccessToken();
      return await tokenStorage.accessToken;
    }

    return accessToken;
  }

  bool _isTokenNearExpiry(String token) {
    try {
      final payload = Jwt.parseJwt(token);
      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      final timeUntilExpiry = expiry.difference(DateTime.now());

      return timeUntilExpiry.inSeconds > 30;
    } catch (e) {
      return true;
    }
  }

  Future<http.Response> _authenticatedRequest(
    Future<http.Response> Function(String token) requestFunction,
  ) async {
    final token = await _getValidAccessToken();

    if (token == null) {
      await logout();
      throw Exception('Not authenticated');
    }

    try {
      final response = await requestFunction(token).timeout(_requestTimeout);

      // If unauthorized, try one refresh and retry
      if (response.statusCode == 401) {
        await refreshAccessToken();
        final newToken = await tokenStorage.accessToken;

        if (newToken != null) {
          final retryResponse = await requestFunction(
            newToken,
          ).timeout(_requestTimeout);

          if (retryResponse.statusCode == 401) {
            await logout();
            throw Exception('Session expired');
          }

          return retryResponse;
        } else {
          await logout();
          throw Exception('Session expired');
        }
      }

      return response;
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Unable to connect to server');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchApi(String apiCall) async {
    final response = await _authenticatedRequest((token) async {
      return http.get(
        Uri.parse('$baseUrl/$client/$apiCall'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse is List) {
        return jsonResponse
            .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
            .toList();
      } else if (jsonResponse is Map) {
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception('Data key is missing or null');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Map<String, dynamic>>> searchApi(
    String query,
    String apiCall,
  ) async {
    final response = await _authenticatedRequest((token) async {
      return await http.get(
        Uri.parse('$baseUrl/$client/$apiCall/$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    });

    // // print(query);
    // // print(response.body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
            .toList();
      } else if (jsonResponse is Map) {
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception('Data key is missing or null');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> postApi(Map<String, dynamic> apiMap, String apiCall) async {
    final response = await _authenticatedRequest((token) async {
      return await http.post(
        Uri.parse('$baseUrl/$client/$apiCall/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(apiMap),
      );
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        'Failed to create post: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> putApi(
    Map<String, dynamic> apiMap,
    String apiCall,
    String id,
  ) async {
    final response = await _authenticatedRequest((token) async {
      return await http.put(
        Uri.parse('$baseUrl/$client/$apiCall/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(apiMap),
      );
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to create post: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  Future<bool> deleteApi(String apiCall, String id) async {
    final response = await _authenticatedRequest((token) async {
      return await http.delete(
        Uri.parse('$baseUrl/$client/$apiCall/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    });

    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  }

  Future<void> _loadUser() async {
    await tokenStorage.loadTokens(); // Cache values from localStorage

    _username = await tokenStorage.username;
    final accessToken = await tokenStorage.accessToken;
    _isAuthenticated = _username != null && accessToken != null;

    notifyListeners();
  }

  Future<void> _saveUser(String username) async {
    tokenStorage.saveUsername(username);

    _username = username;
    _isAuthenticated = true;

    notifyListeners();
  }

  Future<void> _clearUser() async {
    tokenStorage.clearAll();

    _username = null;
    _isAuthenticated = false;

    notifyListeners();
  }

  Future<bool> submitLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        tokenStorage.saveTokens(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );

        await _saveUser(username);

        return true;
      } else {
        throw Exception('Failed to Login');
      }
    } catch (e) {
      throw Exception('Failed to Login: $e');
    }
  }

  Future<void> refreshAccessToken() async {
    tokenStorage.loadTokens();

    final storedAccessToken = await tokenStorage.accessToken;
    final storedRefreshToken = await tokenStorage.refreshToken;

    if (storedAccessToken != null && Jwt.isExpired(storedAccessToken)) {
      if (storedRefreshToken != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/token/refresh/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': storedRefreshToken}),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final newAccessToken = data['access'];

          tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: storedRefreshToken,
          );

          notifyListeners();
        } else {
          logout(); // Refresh failed
        }
      } else {
        logout(); // No refresh token
      }
    } else if (storedAccessToken == null) {
      logout(); // No token at all
    }
  }

  Future<void> checkTokenAndRedirect() async {
    tokenStorage.loadTokens();

    final storedAccessToken = await tokenStorage.accessToken;

    if (storedAccessToken != null) {
      // Check if the access token is expired
      bool isExpired = Jwt.isExpired(storedAccessToken);

      if (isExpired) {
        logout();
      } else {
        // Token is valid; proceed to main app
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home_page',
          (Route<dynamic> route) => false,
        );
      }
    } else {
      // No access token found; redirect to login screen
      logout();
    }
  }

  Future<void> logout() async {
    tokenStorage.clearAll();
    _clearUser();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> checkAuthentication() async {
    await tokenStorage.loadTokens();
    final token = await tokenStorage.accessToken;

    if (token == null) return false;
    if (Jwt.isExpired(token)) {
      await refreshAccessToken();

      final newToken = await tokenStorage.accessToken;

      return newToken != null && !Jwt.isExpired(newToken);
    }

    return true;
  }
}
