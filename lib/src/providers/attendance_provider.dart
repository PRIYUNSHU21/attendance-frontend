import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance.dart';
import '../models/session.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceRecord> _history = [];
  List<Session> _activeSessions = [];
  bool _loading = false;
  String? _error;

  List<AttendanceRecord> get history => _history;
  List<Session> get activeSessions => _activeSessions;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _loading = true;
    notifyListeners();
    final response = await ApiService.get('/attendance/my-history');
    _loading = false;
    if (response['success'] == true) {
      _history = (response['data'] as List)
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();
      _error = null;
    } else {
      _error = response['message'];
    }
    notifyListeners();
  }

  Future<void> fetchActiveSessions() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Fetching active sessions using NEW public endpoint...');

      // Get current user info for debugging and organization filtering
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      String? userOrgId;
      String? userName;
      String? userEmail;
      String? userRole;

      if (userData != null) {
        final userJson = jsonDecode(userData);
        // Try different possible organization ID field names
        userOrgId =
            userJson['organization_id'] ??
            userJson['org_id'] ??
            userJson['orgId'];
        userName = userJson['name'];
        userEmail = userJson['email'];
        userRole = userJson['role'];

        print('👤 Current user: $userName ($userEmail)');
        print('🏢 User organization: $userOrgId');
        print('🔑 User role: $userRole');
      }

      // ✅ NEW: Use the public endpoint (no authentication required)
      print('🔍 Trying NEW public endpoint: /attendance/public-sessions');
      var response = await ApiService.getPublic('/attendance/public-sessions');
      print('📡 Public endpoint response status: Success');
      print('📡 Public endpoint raw response: ${response.toString()}');

      if (response['success'] == true) {
        final allPublicSessions = (response['data'] as List)
            .map((e) => Session.fromJson(e))
            .toList();

        print('📊 Found ${allPublicSessions.length} total public sessions');

        // Filter sessions by user's organization if available
        if (userOrgId != null) {
          _activeSessions = allPublicSessions.where((session) {
            final isActive = session.isActive;
            final matchesOrg = session.orgId == userOrgId;

            print('   🔍 Session: ${session.sessionName}');
            print('      - Active: $isActive');
            print('      - Session Org: ${session.orgId}');
            print('      - User Org: $userOrgId');
            print('      - Matches: $matchesOrg');

            return isActive && matchesOrg;
          }).toList();

          print(
            '✅ Filtered to ${_activeSessions.length} sessions for user organization',
          );
        } else {
          // If no user org, show all active sessions
          _activeSessions = allPublicSessions
              .where((session) => session.isActive)
              .toList();
          print(
            '✅ Showing ${_activeSessions.length} active sessions (no org filter)',
          );
        }

        for (var session in _activeSessions) {
          print(
            '   - ${session.sessionName} (ID: ${session.sessionId}, Org: ${session.orgId})',
          );
        }
      } else {
        // Fallback to old authenticated endpoints if public endpoint fails
        print(
          '🔄 Public endpoint failed, falling back to authenticated endpoints...',
        );

        // Try authenticated student endpoint first
        if (userOrgId != null) {
          print('🔍 Trying authenticated endpoint with org_id parameter...');
          response = await ApiService.get(
            '/attendance/active-sessions?org_id=$userOrgId',
          );
          print('📡 Org-specific response: ${response.toString()}');
        }

        // If that didn't work, try the standard authenticated endpoint
        if (!response['success'] || (response['data'] as List).isEmpty) {
          response = await ApiService.get('/attendance/active-sessions');
          print('📡 Student endpoint response: ${response.toString()}');
        }

        if (response['success'] == true &&
            (response['data'] as List).isNotEmpty) {
          // Authenticated student endpoint worked
          final sessionsData = response['data'] as List;
          print(
            '📊 Found ${sessionsData.length} sessions from authenticated endpoint',
          );

          _activeSessions = sessionsData
              .map((e) => Session.fromJson(e))
              .toList();

          print(
            '✅ Successfully parsed ${_activeSessions.length} sessions from authenticated endpoint',
          );
          for (var session in _activeSessions) {
            print(
              '   - ${session.sessionName} (ID: ${session.sessionId}, Org: ${session.orgId})',
            );
          }
        } else {
          // Last fallback: try admin endpoint
          print(
            '🔄 Authenticated endpoints failed, trying admin endpoint fallback...',
          );

          response = await ApiService.get('/admin/sessions');
          print('📡 Admin endpoint response: ${response.toString()}');

          if (response['success'] == true) {
            final allSessions = (response['data'] as List)
                .map((e) => Session.fromJson(e))
                .toList();

            print(
              '📊 Found ${allSessions.length} total sessions from admin endpoint',
            );

            // Filter sessions by user's organization and active status
            _activeSessions = allSessions.where((session) {
              final isActive = session.isActive;

              // If user org is null, we'll show ALL active sessions as a fallback
              final matchesOrg =
                  userOrgId == null || session.orgId == userOrgId;

              print('   🔍 Session: ${session.sessionName}');
              print('      - Active: $isActive');
              print('      - Session Org: ${session.orgId}');
              print('      - User Org: $userOrgId');
              print('      - Matches: $matchesOrg');

              return isActive && matchesOrg;
            }).toList();

            print(
              '✅ Filtered to ${_activeSessions.length} active sessions for user org',
            );
          } else {
            print(
              '❌ All endpoints failed: ${response['message'] ?? 'Unknown error'}',
            );
          }
        }
      }

      _loading = false;
      _error = null;
    } catch (e) {
      _loading = false;
      _error = 'Error fetching active sessions: $e';
      print('💥 Exception while fetching sessions: $e');
    }
    notifyListeners();
  }

  /// Fetch details for a specific session using the new public endpoint
  Future<Session?> fetchSessionDetails(String sessionId) async {
    try {
      final response = await ApiService.get('/attendance/sessions/$sessionId');
      
      if (response['success'] == true) {
        return Session.fromJson(response['data']);
      } else {
        _error = response['message'] ?? 'Failed to fetch session details';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error fetching session details: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> checkIn(String sessionId, double lat, double lon) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/attendance/check-in',
        body: {'session_id': sessionId, 'lat': lat, 'lon': lon},
      );
      _loading = false;

      if (response['success'] == true) {
        await fetchHistory();
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Failed to check in';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loading = false;
      _error = 'Error checking in: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut(String recordId, double lat, double lon) async {
    _loading = true;
    notifyListeners();
    final response = await ApiService.post(
      '/attendance/check-out',
      body: {'record_id': recordId, 'lat': lat, 'lon': lon},
    );
    _loading = false;
    if (response['success'] == true) {
      await fetchHistory();
      _error = null;
      return true;
    } else {
      _error = response['message'];
      notifyListeners();
      return false;
    }
  }
}
