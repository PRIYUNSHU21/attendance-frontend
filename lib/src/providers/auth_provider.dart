import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool get isAuthenticated => _user != null && _token != null;
  User? get user => _user;
  String? get token => _token;
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      final userData = prefs.getString('user');
      if (userData != null) {
        _user = User.fromJsonString(userData);
      }
    }
    notifyListeners();
  }
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );
      if (response['success'] == true) {
        // The backend returns 'jwt_token' not 'token'
        _token = response['data']['jwt_token'];
        _user = User.fromJson(response['data']['user']);
        // Debug print user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', _user!.toJsonString());
        notifyListeners();
        return true;
      } else {
        return response['message'] ?? 'Login failed';
      }
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }
  Future<dynamic> register(
    String name,
    String email,
    String password,
    String role,
    String orgId,
  ) async {
    try {
      final response = await ApiService.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'org_id': orgId,
        },
      );
      if (response['success'] == true) {
        return true;
      } else {
        String errorMessage = response['message'] ?? 'Registration failed';
        // Handle specific foreign key error
        if (errorMessage.contains('foreign key constraint') ||
            errorMessage.contains('org_id')) {
          errorMessage =
              'Organization not found. Please select a valid organization.';
        }
        return errorMessage;
      }
    } catch (e) {
      return 'Registration failed: ${e.toString()}';
    }
  }
  Future<dynamic> registerAdmin(
    String name,
    String email,
    String password,
    String orgName,
    String orgDescription,
    String orgContactEmail,
  ) async {
    try {
      // Step 1: Create organization using public endpoint (no auth required)
      final orgResponse = await ApiService.postPublic(
        '/auth/public/organizations',
        body: {
          'name': orgName,
          'description': orgDescription,
          'contact_email': orgContactEmail,
        },
      );
      if (orgResponse['success'] == true) {
        final orgId = orgResponse['data']['org_id'];
        // Step 2: Create first admin for the organization using public endpoint
        final adminResponse = await ApiService.postPublic(
          '/auth/public/admin',
          body: {
            'name': name,
            'email': email,
            'password': password,
            'org_id': orgId,
          },
        );
        if (adminResponse['success'] == true) {
          return true;
        } else {
          print(
            'DEBUG ADMIN REG: Admin registration failed: ${adminResponse['message']}',
          );
          // Return the full response for detailed error handling
          return adminResponse;
        }
      } else {
        print(
          'DEBUG ADMIN REG: Organization creation failed: ${orgResponse['message']}',
        );
        // Return the full response for detailed error handling
        return orgResponse;
      }
    } catch (e) {
      return 'Admin registration failed: ${e.toString()}';
    }
  }
  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    notifyListeners();
  }
  /// Auto-logout when session is invalidated (e.g., due to organization deletion)
  Future<void> handleSessionInvalidation({String? reason}) async {
    await logout();
  }
  /// Check if the response indicates session invalidation and handle it
  bool handleApiResponse(Map<String, dynamic> response) {
    if (response['session_invalidated'] == true) {
      handleSessionInvalidation(reason: response['message']);
      return true; // Indicates session was invalidated
    }
    return false; // Normal response
  }
}
