import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance.dart';
import '../models/session.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceRecord> _history = [];
  List<Session> _activeSessions = [];
  List<Session> _pastSessions = [];
  bool _loading = false;
  String? _error;

  List<AttendanceRecord> get history => _history;
  List<Session> get activeSessions => _activeSessions;
  List<Session> get pastSessions => _pastSessions;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    // Use the new simplified personal history endpoint
    await fetchPersonalHistory();
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
          final now = DateTime.now();
          
          // Split sessions into active and past
          final userOrgSessions = allPublicSessions.where((session) => 
            session.orgId == userOrgId
          ).toList();
          
          _activeSessions = userOrgSessions.where((session) {
            final isActive = session.isActive;
            final isNotExpired = session.endTime.isAfter(now);

            print('   🔍 Session: ${session.sessionName}');
            print('      - Active: $isActive');
            print('      - End Time: ${session.endTime}');
            print('      - Current Time: $now');
            print('      - Not Expired: $isNotExpired');

            return isActive && isNotExpired;
          }).toList();

          _pastSessions = userOrgSessions.where((session) {
            final isExpired = session.endTime.isBefore(now) || !session.isActive;
            return isExpired;
          }).toList();

          print(
            '✅ Filtered to ${_activeSessions.length} active sessions and ${_pastSessions.length} past sessions for user organization',
          );
        } else {
          // If no user org, show all active, non-expired sessions
          final now = DateTime.now();
          _activeSessions = allPublicSessions
              .where((session) => session.isActive && session.endTime.isAfter(now))
              .toList();
          _pastSessions = allPublicSessions
              .where((session) => session.endTime.isBefore(now) || !session.isActive)
              .toList();
          print(
            '✅ Showing ${_activeSessions.length} active sessions and ${_pastSessions.length} past sessions (no org filter)',
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

          final allSessions = sessionsData.map((e) => Session.fromJson(e)).toList();
          
          // Apply time-based filtering for truly active sessions
          final now = DateTime.now();
          _activeSessions = allSessions.where((session) {
            final isTimeActive = now.isAfter(session.startTime) && now.isBefore(session.endTime);
            return isTimeActive;
          }).toList();

          // Store past sessions (expired but within last 7 days)
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          _pastSessions = allSessions.where((session) {
            final isExpired = now.isAfter(session.endTime);
            final isRecent = session.endTime.isAfter(sevenDaysAgo);
            return isExpired && isRecent;
          }).toList();

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

            // Filter sessions by user's organization and time-based active status
            final now = DateTime.now();
            _activeSessions = allSessions.where((session) {
              final isTimeActive = now.isAfter(session.startTime) && now.isBefore(session.endTime);
              final isActiveStatus = session.isActive;

              // If user org is null, we'll show ALL active sessions as a fallback
              final matchesOrg =
                  userOrgId == null || session.orgId == userOrgId;

              print('   🔍 Session: ${session.sessionName}');
              print('      - Time Active: $isTimeActive (${session.startTime} - ${session.endTime})');
              print('      - Status Active: $isActiveStatus');
              print('      - Session Org: ${session.orgId}');
              print('      - User Org: $userOrgId');
              print('      - Matches: $matchesOrg');

              return isTimeActive && isActiveStatus && matchesOrg;
            }).toList();

            // Store past sessions (expired but within last 7 days for recent history)
            final sevenDaysAgo = now.subtract(const Duration(days: 7));
            _pastSessions = allSessions.where((session) {
              final isExpired = now.isAfter(session.endTime);
              final isRecent = session.endTime.isAfter(sevenDaysAgo);
              final matchesOrg = userOrgId == null || session.orgId == userOrgId;
              
              return isExpired && isRecent && matchesOrg;
            }).toList();

            print(
              '✅ Filtered to ${_activeSessions.length} active sessions and ${_pastSessions.length} past sessions for user org',
            );
          } else {
            print(
              '❌ All endpoints failed: ${response['message'] ?? 'Unknown error'}',
            );
          }
        }
      }

      // Resolve organization location for sessions that don't have location data
      await _resolveSessionLocations();

      // Sort sessions: Active sessions first (most important for students), then by newest first
      _activeSessions.sort((a, b) {
        // First priority: Active status (active sessions first)
        if (a.isActive != b.isActive) {
          return b.isActive ? 1 : -1; // Active sessions first
        }
        // Second priority: Start time (newest first within same active status)
        return b.startTime.compareTo(a.startTime);
      });

      print('📅 Sessions sorted: Active sessions first, then newest first');
      print('✅ Final session list:');
      for (var session in _activeSessions) {
        print(
          '   📍 ${session.sessionName} - Active: ${session.isActive} - Location: (${session.locationLat}, ${session.locationLon}) - Start: ${session.startTime}',
        );
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

  /// Resolve organization location for sessions that don't have location data
  Future<void> _resolveSessionLocations() async {
    try {
      // Check if any sessions need organization location
      bool needsOrgLocation = _activeSessions.any(
        (session) => !session.hasValidLocation,
      );

      if (!needsOrgLocation) {
        print('✅ All sessions have valid location data');
        return;
      }

      print(
        '🔍 Some sessions missing location, fetching organization location...',
      );

      // Fetch organization location
      final orgLocation = await fetchOrganizationLocation();

      if (orgLocation != null &&
          orgLocation['location'] != null &&
          orgLocation['location']['latitude'] != null &&
          orgLocation['location']['longitude'] != null) {
        final orgLat = (orgLocation['location']['latitude']).toDouble();
        final orgLon = (orgLocation['location']['longitude']).toDouble();
        final orgRadius = (orgLocation['location']['radius'] ?? 100).toDouble();

        print(
          '📍 Using organization location: ($orgLat, $orgLon) with radius ${orgRadius}m',
        );

        // Update sessions that don't have location with organization location
        _activeSessions = _activeSessions.map((session) {
          if (!session.hasValidLocation) {
            print(
              '   🔄 Updating ${session.sessionName} with organization location',
            );
            return session.withOrganizationLocation(
              orgLat: orgLat,
              orgLon: orgLon,
              orgRadius: orgRadius,
            );
          }
          return session;
        }).toList();

        print(
          '✅ Updated ${_activeSessions.where((s) => !s.hasValidLocation).length} sessions with organization location',
        );
      } else {
        print(
          '⚠️ No organization location found, using default location (Kolkata)',
        );

        // Fallback to Kolkata coordinates
        const defaultLat = 22.5726;
        const defaultLon = 88.3639;
        const defaultRadius = 100.0;

        _activeSessions = _activeSessions.map((session) {
          if (!session.hasValidLocation) {
            return session.withOrganizationLocation(
              orgLat: defaultLat,
              orgLon: defaultLon,
              orgRadius: defaultRadius,
            );
          }
          return session;
        }).toList();
      }
    } catch (e) {
      print('💥 Error resolving session locations: $e');
      // Continue with existing sessions even if location resolution fails
    }
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

  /// Mark attendance using the new simplified system
  /// Replaces both check-in and check-out with a single unified endpoint
  Future<Map<String, dynamic>?> markAttendance(
    String sessionId,
    double latitude,
    double longitude, {
    double? altitude,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'session_id': sessionId,
        'latitude': latitude, // Send as number, not string
        'longitude': longitude, // Send as number, not string
      };

      // Add altitude if provided
      if (altitude != null) {
        body['altitude'] = altitude; // Send as number, not string
      }

      print('🚀 Marking attendance with data: $body');

      final response = await ApiService.post(
        '/simple/mark-attendance',
        body: body,
      );

      print('📡 Mark attendance response: ${response.toString()}');

      _loading = false;

      if (response['success'] == true) {
        final attendanceData = response['data'];
        print('✅ Attendance marked successfully!');
        print('   Status: ${attendanceData['status']}');
        print('   Distance: ${attendanceData['distance']}m');
        print('   Organization: ${attendanceData['organization']}');

        _error = null;
        _loading = false;
        notifyListeners();

        // Refresh attendance history after UI update
        Future.microtask(() => fetchHistory());
        
        return attendanceData;
      } else {
        _error = response['message'] ?? 'Failed to mark attendance';
        _handleAttendanceError(response);
        _loading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _loading = false;
      _error = 'Error marking attendance: $e';
      print('💥 Exception while marking attendance: $e');
      notifyListeners();
      return null;
    }
  }

  /// Handle specific attendance errors based on error codes
  void _handleAttendanceError(Map<String, dynamic> response) {
    final errorCode = response['error_code'];
    final details = response['details'];

    switch (errorCode) {
      case 'LOCATION_TOO_FAR':
        if (details != null) {
          final distance = details['distance'];
          final maxAllowed = details['max_allowed'];
          _error =
              'You are too far from the session location (${distance}m away, max allowed: ${maxAllowed}m)';
        }
        break;
      case 'SESSION_ENDED':
        if (details != null) {
          _error =
              'This session has already ended and is no longer accepting attendance';
        }
        break;
      case 'AUTHENTICATION_REQUIRED':
        _error = 'Please log in to mark attendance';
        break;
      case 'UNAUTHORIZED_ACCESS':
        _error =
            'You do not have permission to mark attendance for this session';
        break;
      default:
        _error = response['message'] ?? 'Failed to mark attendance';
    }
  }

  /// Get personal attendance history using simplified endpoint
  Future<void> fetchPersonalHistory({
    int limit = 50,
    int days = 30,
    String? status,
  }) async {
    _loading = true;
    _error = null;
    
    // Use microtask to avoid setState during build
    Future.microtask(() => notifyListeners());

    try {
      String path = '/simple/my-attendance?limit=$limit&days=$days';
      if (status != null) {
        path += '&status=$status';
      }

      print('🔍 Fetching personal attendance history: $path');

      final response = await ApiService.get(path);
      print('📡 Personal history response: ${response.toString()}');

      _loading = false;

      if (response['success'] == true) {
        _history = (response['data'] as List)
            .map((e) => AttendanceRecord.fromJson(e))
            .toList();
        _error = null;
        print('✅ Successfully fetched ${_history.length} attendance records');
      } else {
        _error = response['message'] ?? 'Failed to fetch attendance history';
        print('❌ Failed to fetch history: $_error');
      }
    } catch (e) {
      _loading = false;
      _error = 'Error fetching attendance history: $e';
      print('💥 Exception while fetching history: $e');
    }
    
    // Use microtask to avoid setState during build
    Future.microtask(() => notifyListeners());
  }

  /// Get organization attendance (admin/teacher only) with student details
  Future<List<Map<String, dynamic>>> fetchOrganizationAttendance(
    String orgId, {
    int limit = 100,
    String? date,
    String? sessionId,
  }) async {
    try {
      String path = '/simple/attendance/$orgId?limit=$limit';
      if (date != null) {
        path += '&date=$date';
      }
      if (sessionId != null) {
        path += '&session_id=$sessionId';
      }

      print('🔍 Fetching organization attendance: $path');

      final response = await ApiService.get(path);
      print('📡 Organization attendance response: ${response.toString()}');

      if (response['success'] == true) {
        final attendanceList = response['data'] as List;
        print(
          '✅ Successfully fetched ${attendanceList.length} organization attendance records',
        );
        return attendanceList.cast<Map<String, dynamic>>();
      } else {
        _error =
            response['message'] ?? 'Failed to fetch organization attendance';
        print('❌ Failed to fetch organization attendance: $_error');
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error fetching organization attendance: $e';
      print('💥 Exception while fetching organization attendance: $e');
      notifyListeners();
      return [];
    }
  }

  /// Get session attendance with student details (teacher view)
  Future<List<Map<String, dynamic>>> fetchSessionAttendance(
    String sessionId, {
    bool includeStudentDetails = true,
  }) async {
    try {
      String path = '/simple/session/$sessionId/attendance';
      if (includeStudentDetails) {
        path += '?include_student_details=true';
      }

      print('🔍 Fetching session attendance: $path');

      final response = await ApiService.get(path);
      print('📡 Session attendance response: ${response.toString()}');

      if (response['success'] == true) {
        final attendanceList = response['data'] as List;
        print(
          '✅ Successfully fetched ${attendanceList.length} session attendance records',
        );
        return attendanceList.cast<Map<String, dynamic>>();
      } else {
        _error = response['message'] ?? 'Failed to fetch session attendance';
        print('❌ Failed to fetch session attendance: $_error');
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error fetching session attendance: $e';
      print('💥 Exception while fetching session attendance: $e');
      notifyListeners();
      return [];
    }
  }

  /// Fetch organization location data
  Future<Map<String, dynamic>?> fetchOrganizationLocation() async {
    try {
      final response = await ApiService.get('/simple/company/location');

      if (response['success'] == true) {
        print('✅ Organization location fetched: ${response['data']}');
        return response['data'];
      } else {
        print('❌ No organization location found: ${response['message']}');
        return null;
      }
    } catch (e) {
      print('💥 Error fetching organization location: $e');
      return null;
    }
  }

  /// Create organization location (admin only)
  Future<Map<String, dynamic>?> createOrganizationLocation({
    required double latitude,
    required double longitude,
    required String name,
    int radius = 100,
    String? address,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'latitude': latitude
            .toString(), // Convert to string for backend compatibility
        'longitude': longitude
            .toString(), // Convert to string for backend compatibility
        'name': name,
        'radius': radius
            .toString(), // Convert to string for backend compatibility
      };

      if (address != null) {
        body['address'] = address;
      }

      print('🚀 Creating organization location: $body');

      final response = await ApiService.post(
        '/simple/company/create',
        body: body,
      );

      print('📡 Create location response: ${response.toString()}');

      _loading = false;

      if (response['success'] == true) {
        final locationData = response['data'];
        print('✅ Organization location created successfully!');
        _error = null;
        notifyListeners();
        return locationData;
      } else {
        _error =
            response['message'] ?? 'Failed to create organization location';
        print('❌ Failed to create location: $_error');
        notifyListeners();
        return null;
      }
    } catch (e) {
      _loading = false;
      _error = 'Error creating organization location: $e';
      print('💥 Exception while creating location: $e');
      notifyListeners();
      return null;
    }
  }

  @Deprecated('Use markAttendance() instead')
  Future<bool> checkIn(String sessionId, double lat, double lon) async {
    final result = await markAttendance(sessionId, lat, lon);
    return result != null;
  }

  @Deprecated('Use markAttendance() instead')
  Future<bool> checkOut(String recordId, double lat, double lon) async {
    // The new system doesn't require separate check-out
    // This is kept for backwards compatibility
    return true;
  }
}
