import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://attendance-backend-go8h.onrender.com';

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(baseUrl + path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
    );

    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = headers != null && headers.containsKey('Authorization')
        ? null // Don't add token if Authorization header is explicitly provided
        : await _getToken();

    final response = await http.post(
      Uri.parse(baseUrl + path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
      body: jsonEncode(body ?? {}),
    );

    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse(baseUrl + path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
      body: jsonEncode(body ?? {}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse(baseUrl + path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  // Public endpoints for organization onboarding (no authentication required)
  static Future<Map<String, dynamic>> getPublic(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(
      Uri.parse(baseUrl + path),
      headers: {'Content-Type': 'application/json', ...?headers},
    );

    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> postPublic(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + path),
        headers: {'Content-Type': 'application/json', ...?headers},
        body: jsonEncode(body ?? {}),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // Basic token validation - check if it's not expired
      try {
        // Simple JWT token parsing without verification
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Add padding if needed
          String normalizedPayload = payload;
          while (normalizedPayload.length % 4 != 0) {
            normalizedPayload += '=';
          }

          final decoded = utf8.decode(base64Url.decode(normalizedPayload));
          final data = jsonDecode(decoded);
          final exp = data['exp'];

          if (exp != null) {
            final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
            final now = DateTime.now();

            if (now.isAfter(expiry)) {
              await prefs.remove('token');
              await prefs.remove('user');
              return null;
            }
          }
        }
      } catch (e) {
        // Token parsing failed, continue with existing token
      }
    }

    return token;
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      // Handle 401 Unauthorized - Token invalidated (possibly due to org deletion)
      if (response.statusCode == 401) {
        _handleSessionInvalidation(data);
        if (data is Map<String, dynamic>) {
          return {...data, 'success': false, 'session_invalidated': true};
        } else {
          return {
            'success': false,
            'message': 'Your session has expired. Please log in again.',
            'session_invalidated': true,
          };
        }
      }

      // Consider both 200 and 201 as success status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          // Ensure the response is marked as successful if it's not already
          if (!data.containsKey('success')) {
            return {...data, 'success': true};
          }
          return data;
        } else {
          return {'success': false, 'message': 'Invalid response format'};
        }
      } else {
        // For non-success status codes, still try to parse the response
        // but mark it as unsuccessful
        if (data is Map<String, dynamic>) {
          return {...data, 'success': false};
        } else {
          return {
            'success': false,
            'message': 'Request failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Handle session invalidation due to organization deletion or token expiry
  static Future<void> _handleSessionInvalidation(dynamic responseData) async {
    // Clear stored credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
