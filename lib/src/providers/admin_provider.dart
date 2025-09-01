import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/session.dart';
import '../models/user.dart';
import '../models/organization.dart';
import 'auth_provider.dart';
import 'attendance_provider.dart';

class AdminProvider extends ChangeNotifier {
  final AuthProvider? authProvider;

  Map<String, dynamic>? _dashboardStats;
  List<User> _users = [];
  List<Organization> _organizations = [];
  List<Session> _sessions = [];
  bool _loading = false;
  String? _error;

  AdminProvider({this.authProvider});

  // Format datetime for backend (no milliseconds, no timezone)
  String formatDateTimeForBackend(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}T'
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<User> get users => _users;
  List<Organization> get organizations => _organizations;
  List<Session> get sessions => _sessions;
  bool get loading => _loading;
  String? get error => _error;

  // Add debugging method to show current state
  void debugCurrentState() {
    print('=== AdminProvider Debug State ===');
    print('Loading: $_loading');
    print('Error: $_error');
    print('Users count: ${_users.length}');
    print('Organizations count: ${_organizations.length}');
    print('Sessions count: ${_sessions.length}');
    if (_users.isNotEmpty) {
      print('Sample user: ${_users.first.name} (${_users.first.role})');
    }
    print('================================');
  }

  Future<void> fetchDashboardStats() async {
    _loading = true;
    // Don't call notifyListeners here to avoid setState during build
    final response = await ApiService.get('/admin/dashboard/stats');
    _loading = false;
    if (response['success'] == true) {
      _dashboardStats = response['data'];
      _error = null;
    } else {
      _error = response['message'];
    }
    notifyListeners();
  }

  /// Fetches the student list using the CORRECT working endpoint from API guide.
  /// Endpoint: GET /admin/students?page=1&per_page=20
  /// This works for both admins and teachers - teachers see their org students
  Future<void> fetchStudents({int page = 1, int perPage = 20}) async {
    _loading = true;
    _error = null;
    notifyListeners(); // show spinner

    try {
      print('🔍 Using CORRECT endpoint: /admin/students');
      final response = await ApiService.get(
        '/admin/students?page=$page&per_page=$perPage',
      );

      _loading = false;

      if (response['success'] == true) {
        // API Guide shows response format: data.students array, not direct data array
        final studentsData = response['data'];
        if (studentsData != null && studentsData['students'] != null) {
          _users = (studentsData['students'] as List)
              .map((json) => User.fromJson(json))
              .toList();

          // Log pagination info from API response
          final pagination = studentsData['pagination'];
          if (pagination != null) {
            print(
              '📊 Pagination: Page ${pagination['page']} of ${pagination['total_pages']}, Total: ${pagination['total']}',
            );
          }

          print('✅ Loaded ${_users.length} students using /admin/students');
        } else {
          _users = [];
          print('⚠️ No students data in response');
        }
        _error = null;
      } else {
        _error = response['message'] ?? 'Unknown error';
        print('❌ API error: $_error');
      }
    } catch (e) {
      _loading = false;
      _error = 'Network/API error: $e';
      print('💥 Exception: $e');
    }

    notifyListeners(); // refresh UI
  }

  /// Fetches students for teachers - tries multiple endpoints
  /// Teachers may not have admin access, so we try organization-specific endpoints
  Future<void> fetchStudentsForTeacher() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic>? response;

      // Try different endpoints - START with the working one from API guide
      List<String> endpoints = [
        '/admin/students', // CORRECT working endpoint from API guide
        '/users?role=student', // Public users endpoint
        '/attendance/students', // Attendance-related students
        '/organization/students', // Organization students
        '/teacher/students', // Teacher-specific endpoint
      ];

      for (String endpoint in endpoints) {
        try {
          print('🔍 Trying endpoint for teacher: $endpoint');
          response = await ApiService.get(
            endpoint,
          ).timeout(const Duration(seconds: 10));

          if (response['success'] == true && response['data'] != null) {
            print('✅ Success with teacher endpoint: $endpoint');
            break;
          }
        } catch (e) {
          print('❌ Failed teacher endpoint $endpoint: $e');
          continue;
        }
      }

      _loading = false;

      if (response != null && response['success'] == true) {
        // Handle both response formats: direct array or nested with students array
        List<dynamic> userData;

        if (response['data'] is List) {
          // Direct array format
          userData = response['data'] as List<dynamic>;
        } else if (response['data']['students'] != null) {
          // Nested format from API guide
          userData = response['data']['students'] as List<dynamic>;
        } else {
          userData = [];
        }

        _users = userData.map((data) => User.fromJson(data)).toList();
        _error = null;
        print('✅ Loaded ${_users.length} students for teacher from backend');
      } else {
        _error =
            'No students found. You may not have permission to view students.';
        print('❌ All teacher endpoints failed to return student data');
      }
    } catch (e) {
      _loading = false;
      _error = 'Failed to fetch students: $e';
      print('🚨 Error fetching students for teacher: $e');
    }

    notifyListeners();
  }

  /* Future<void> fetchUsers() async {
    _loading = true;
    // Don't call notifyListeners here to avoid setState during build

    try {
      // Try different endpoints that might be supported by the backend
      Map<String, dynamic> response;

      try {
        // First try with proper pagination
        response = await ApiService.get('/admin/users?limit=100&offset=0');
      } catch (e) {
        // If that fails, try without pagination
        try {
          response = await ApiService.get('/admin/users');
        } catch (e2) {
          // If that fails, try students-specific endpoint
          response = await ApiService.get('/admin/students');
        }
      }

      _loading = false;
      if (response['success'] == true) {
        _users = (response['data'] as List)
            .map((userData) => User.fromJson(userData))
            .toList();
        _error = null;
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _loading = false;
      _error = 'Failed to fetch users: $e';
      print('🚨 Error fetching users: $e');
    }
    notifyListeners();
  }*/

  // Try alternative endpoints to get real users - FALLBACK METHOD
  Future<void> fetchRealUsers() async {
    _loading = true;
    notifyListeners();

    try {
      Map<String, dynamic>? response;

      // Try multiple endpoints to find working one
      List<String> endpoints = [
        '/users', // Simple users endpoint
        '/auth/users', // Auth users endpoint
        '/attendance/users', // Attendance users endpoint
        '/admin/organization/users', // Organization users
        '/public/users', // Public users endpoint
      ];

      for (String endpoint in endpoints) {
        try {
          print('🔍 Trying endpoint: $endpoint');
          response = await ApiService.get(
            endpoint,
          ).timeout(const Duration(seconds: 10));

          if (response['success'] == true && response['data'] != null) {
            print('✅ Success with endpoint: $endpoint');
            break;
          }
        } catch (e) {
          print('❌ Failed endpoint $endpoint: $e');
          continue;
        }
      }

      if (response != null && response['success'] == true) {
        final List<dynamic> userData = response['data'] as List<dynamic>;
        _users = userData.map((data) => User.fromJson(data)).toList();
        _error = null;
        print('✅ Loaded ${_users.length} real users from backend');
      } else {
        throw Exception('All endpoints failed to return user data');
      }

      _loading = false;
    } catch (e) {
      _loading = false;
      _error = 'Failed to fetch real users: $e';
      print('🚨 Error fetching real users: $e');
      // Don't fallback to mock data - let user see the error
    }
    notifyListeners();
  }

  Future<void> fetchOrganizations() async {
    _loading = true;
    // Don't call notifyListeners here to avoid setState during build

    final response = await ApiService.get('/admin/organizations');
    _loading = false;

    if (response['success'] == true) {
      _organizations = (response['data'] as List)
          .map((orgData) => Organization.fromJson(orgData))
          .toList();
      _error = null;
    } else {
      _error = response['message'];
    }
    notifyListeners();
  }

  Future<void> fetchSessions() async {
    _loading = true;
    _error = null;
    notifyListeners(); // Show loading state immediately

    try {
      // Use the WORKING endpoint that's being used in teacher dashboard
      print('🔍 Using WORKING endpoint: /attendance/public-sessions');
      final response = await ApiService.get('/attendance/public-sessions');
      _loading = false;

      if (response['success'] == true) {
        // Convert response to Session objects
        _sessions = (response['data'] as List)
            .map((sessionData) => Session.fromJson(sessionData))
            .toList();

        // Sort sessions: Active sessions first, then by newest first (start time descending)
        _sessions.sort((a, b) {
          // First sort by active status (active sessions first)
          if (a.isActive != b.isActive) {
            return b.isActive ? 1 : -1; // b.isActive first
          }
          // Then sort by start time (newest first)
          return b.startTime.compareTo(a.startTime);
        });

        _error = null;
        print('✅ Loaded ${_sessions.length} sessions using working endpoint');
      } else {
        _error = response['message'] ?? 'Failed to fetch sessions';
        print('❌ API error: $_error');
      }
    } catch (e) {
      _loading = false;
      _error = 'Error fetching sessions: $e';
      print('💥 Exception: $e');
    }
    notifyListeners(); // Update UI after operation completes
  }

  /// Fetch details for a specific session using the new backend endpoint
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

  Future<bool> createSession({
    required String sessionName,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    // Optional custom location parameters for individual session locations
    double? customLat,
    double? customLon,
    double? customRadius,
  }) async {
    _loading = true;
    // Don't call notifyListeners here to avoid setState during build

    try {
      final sessionData = <String, dynamic>{
        'session_name': sessionName,
        'description': description,
        'start_time': formatDateTimeForBackend(startTime),
        'end_time': formatDateTimeForBackend(endTime),
      };

      // Priority: Custom location > Organization location > No location
      if (customLat != null && customLon != null) {
        // Use custom session location - backend expects number format
        sessionData['latitude'] = customLat;
        sessionData['longitude'] = customLon;
        sessionData['radius'] = customRadius ?? 100;

        print(
          '📍 Using custom session location: ($customLat, $customLon) '
          'radius: ${customRadius ?? 100}m',
        );
      } else {
        // Fallback to organization location (existing logic)
        print('🔍 Fetching organization location for session creation...');
        final attendanceProvider = AttendanceProvider();
        final orgLocation = await attendanceProvider
            .fetchOrganizationLocation();

        // Add organization location to session if available
        if (orgLocation != null &&
            orgLocation['location'] != null &&
            orgLocation['location']['latitude'] != null &&
            orgLocation['location']['longitude'] != null) {
          // Backend expects number format, not string
          sessionData['latitude'] = (orgLocation['location']['latitude'])
              .toDouble();
          sessionData['longitude'] = (orgLocation['location']['longitude'])
              .toDouble();
          sessionData['radius'] = (orgLocation['location']['radius'] ?? 100)
              .toDouble();

          print(
            '📍 Including organization location in session: '
            '(${orgLocation['location']['latitude']}, ${orgLocation['location']['longitude']}) '
            'radius: ${orgLocation['location']['radius'] ?? 100}m',
          );
        } else {
          print(
            '⚠️ No organization location found, session will be created without location data',
          );
        }
      }

      print('🚀 Creating session with data: $sessionData');

      final response = await ApiService.post(
        '/admin/sessions',
        body: sessionData,
      );

      print('📡 Session creation response: ${response.toString()}');

      _loading = false;
      if (response['success'] == true) {
        _error = null;
        print('✅ Session created successfully!');
        // Refresh sessions list
        fetchSessions();
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        print('❌ Session creation failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loading = false;
      _error = 'Error creating session: $e';
      print('❌ Exception during session creation: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSession(
    String sessionId, {
    String? sessionName,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    // Removed location parameters as per backend schema changes
    // double? locationLat,
    // double? locationLon,
    // double? locationRadius,
    bool? isActive,
  }) async {
    _loading = true;
    notifyListeners();

    final body = <String, dynamic>{};
    if (sessionName != null) body['session_name'] = sessionName;
    if (description != null) body['description'] = description;
    if (startTime != null)
      body['start_time'] = formatDateTimeForBackend(startTime);
    if (endTime != null) body['end_time'] = formatDateTimeForBackend(endTime);
    // Removed location field assignments as per backend schema changes
    // if (locationLat != null) body['location_lat'] = locationLat;
    // if (locationLon != null) body['location_lon'] = locationLon;
    // if (locationRadius != null) body['location_radius'] = locationRadius;
    if (isActive != null) body['is_active'] = isActive;

    final response = await ApiService.put(
      '/admin/sessions/$sessionId',
      body: body,
    );

    _loading = false;
    if (response['success'] == true) {
      _error = null;
      // Refresh sessions list
      fetchSessions();
      notifyListeners();
      return true;
    } else {
      _error = response['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSession(String sessionId) async {
    _loading = true;
    notifyListeners();

    final response = await ApiService.delete('/admin/sessions/$sessionId');

    _loading = false;
    if (response['success'] == true) {
      _error = null;
      // Refresh sessions list
      fetchSessions();
      notifyListeners();
      return true;
    } else {
      _error = response['message'];
      notifyListeners();
      return false;
    }
  }

  // Organization management methods
  Future<bool> createOrganization({
    required String name,
    required String description,
    String? contactEmail,
  }) async {
    // Use the smart creation method that handles both admin and public endpoints
    return await createOrganizationSmart(
      name: name,
      description: description,
      contactEmail: contactEmail,
    );
  }

  Future<bool> updateOrganization(
    String orgId, {
    String? name,
    String? description,
  }) async {
    _loading = true;
    notifyListeners();

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;

    final response = await ApiService.put(
      '/admin/organizations/$orgId',
      body: body,
    );

    _loading = false;
    if (response['success'] == true) {
      _error = null;
      // Refresh organizations list
      fetchOrganizations();
      notifyListeners();
      return true;
    } else {
      _error = response['message'];
      notifyListeners();
      return false;
    }
  }

  // Organization deletion preview (Phase 1)
  Future<Map<String, dynamic>?> getDeletePreview(String orgId) async {
    _loading = true;
    notifyListeners();

    try {
      // Use DELETE with empty body for preview mode (as per backend guide)
      final response = await ApiService.delete(
        '/admin/organizations/$orgId',
        body: {}, // Empty body = preview mode
      );

      _loading = false;
      if (response['success'] == true) {
        _error = null;
        notifyListeners();
        return response['data'];
      } else {
        _error = response['message'] ?? 'Failed to get deletion preview';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _loading = false;
      _error = 'Failed to get deletion preview: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Organization deletion confirmation (Phase 2)
  Future<Map<String, dynamic>?> deleteOrganization(String orgId) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.delete(
        '/admin/organizations/$orgId',
        body: {'confirm_deletion': true}, // Confirmation for actual deletion
      );

      _loading = false;

      if (response['success'] == true) {
        _error = null;
        // Extract enhanced deletion data
        final deletionData = response['data'];

        // Refresh organizations list
        fetchOrganizations();
        notifyListeners();
        return deletionData;
      } else {
        // Check for session invalidation first and handle it
        if (response['session_invalidated'] == true) {
          _error = 'Your session has expired. Please log in again.';

          // Properly handle session invalidation by logging out the user
          if (authProvider != null) {
            authProvider!.handleSessionInvalidation(
              reason: 'Organization deletion invalidated your session',
            );
          }

          notifyListeners();
          return null;
        }

        // Enhanced error handling for different types of failures
        String errorMessage =
            response['message'] ?? 'Failed to delete organization';

        // Handle specific database constraint violations
        if (errorMessage.contains('ForeignKeyViolation') ||
            errorMessage.contains('foreign key constraint') ||
            errorMessage.contains('invalidated_sessions')) {
          _error =
              'Cannot delete organization due to active user sessions. '
              'Try using "Deactivate Organization" instead, which safely '
              'preserves data while disabling access.';
        }
        // Handle permission errors
        else if (errorMessage.contains('403') ||
            errorMessage.contains('permission')) {
          _error = 'You do not have permission to delete this organization.';
        }
        // Handle not found errors
        else if (errorMessage.contains('404') ||
            errorMessage.contains('not found')) {
          _error = 'Organization not found or has already been deleted.';
        }
        // Generic error
        else {
          _error = errorMessage;
        }

        notifyListeners();
        return null;
      }
    } catch (e) {
      _loading = false;
      String errorStr = e.toString();

      // Enhanced error handling for exceptions
      if (errorStr.contains('ForeignKeyViolation') ||
          errorStr.contains('foreign key constraint') ||
          errorStr.contains('invalidated_sessions')) {
        _error =
            'Database Error: Cannot delete organization due to existing references. '
            'This is a backend issue that needs to be fixed. '
            'As a workaround, try "Deactivate Organization" instead.';
      } else if (errorStr.contains('SocketException') ||
          errorStr.contains('NetworkException')) {
        _error =
            'Network error: Please check your internet connection and try again.';
      } else if (errorStr.contains('TimeoutException')) {
        _error = 'Request timeout: The server is taking too long to respond.';
      } else {
        _error = 'Failed to delete organization: $errorStr';
      }

      notifyListeners();
      return null;
    }
  }

  // Soft delete organization (safer alternative)
  Future<Map<String, dynamic>?> softDeleteOrganization(String orgId) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.put(
        '/admin/organizations/$orgId/soft-delete',
      );

      _loading = false;

      if (response['success'] == true) {
        _error = null;
        // Extract enhanced soft deletion data
        final softDeleteData = response['data'];

        // Refresh organizations list
        fetchOrganizations();
        notifyListeners();
        return softDeleteData;
      } else {
        _error = response['message'] ?? 'Failed to deactivate organization';

        // Handle session invalidation
        if (response['session_invalidated'] == true) {
          _error = 'Your session has expired. Please log in again.';

          // Properly handle session invalidation by logging out the user
          if (authProvider != null) {
            authProvider!.handleSessionInvalidation(
              reason: 'Organization soft-deletion invalidated your session',
            );
          }
        }

        notifyListeners();
        return null;
      }
    } catch (e) {
      _loading = false;
      _error = 'Failed to deactivate organization: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Public organization management methods (for onboarding)
  List<Organization> _publicOrganizations = [];
  List<Organization> get publicOrganizations => _publicOrganizations;

  /// Fetch all organizations publicly (no authentication required)
  /// Used for listing organizations during registration/onboarding
  Future<void> fetchPublicOrganizations() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.getPublic('/auth/public/organizations');
      _loading = false;

      if (response['success'] == true) {
        _publicOrganizations = (response['data'] as List)
            .map((orgData) => Organization.fromJson(orgData))
            .toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to fetch public organizations';
      }
    } catch (e) {
      _loading = false;
      _error = 'Error fetching public organizations: $e';
    }
    notifyListeners();
  }

  /// Create a new organization publicly (no authentication required)
  /// Used during initial organization setup
  Future<Organization?> createPublicOrganization({
    required String name,
    required String description,
    required String contactEmail,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.postPublic(
        '/auth/public/organizations',
        body: {
          'name': name,
          'description': description,
          'contact_email': contactEmail,
        },
      );

      _loading = false;

      if (response['success'] == true) {
        final newOrg = Organization.fromJson(response['data']);
        _error = null;

        // Refresh the public organizations list
        await fetchPublicOrganizations();

        notifyListeners();
        return newOrg;
      } else {
        _error = response['message'] ?? 'Failed to create organization';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _loading = false;
      _error = 'Error creating organization: $e';
      notifyListeners();
      return null;
    }
  }

  /// Create the first admin user for an organization (no authentication required)
  /// Only works if the organization has no existing admin
  Future<Map<String, dynamic>?> createFirstAdmin({
    required String name,
    required String email,
    required String password,
    required String orgId,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.postPublic(
        '/auth/public/admin',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'org_id': orgId,
        },
      );

      _loading = false;

      if (response['success'] == true) {
        _error = null;
        notifyListeners();
        return response['data'];
      } else {
        _error = response['message'] ?? 'Failed to create admin';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _loading = false;
      _error = 'Error creating admin: $e';
      notifyListeners();
      return null;
    }
  }

  /// Complete onboarding flow: Create organization + first admin
  /// Returns admin user data if successful, null if failed
  Future<Map<String, dynamic>?> completeOrganizationOnboarding({
    required String orgName,
    required String orgDescription,
    required String orgContactEmail,
    required String adminName,
    required String adminEmail,
    required String adminPassword,
  }) async {
    try {
      // Step 1: Create the organization
      final organization = await createPublicOrganization(
        name: orgName,
        description: orgDescription,
        contactEmail: orgContactEmail,
      );

      if (organization == null) {
        return null; // Error is already set in createPublicOrganization
      }

      // Step 2: Create the first admin for the organization
      final admin = await createFirstAdmin(
        name: adminName,
        email: adminEmail,
        password: adminPassword,
        orgId: organization.orgId,
      );

      if (admin == null) {
        _error =
            'Organization created but failed to create admin. You can try creating an admin later.';
        notifyListeners();
        return null;
      }

      return admin;
    } catch (e) {
      _error = 'Error during onboarding: $e';
      notifyListeners();
      return null;
    }
  }

  /// Enhanced organization creation with smart fallback
  /// Tries admin endpoint first, falls back to public endpoint if not authenticated
  Future<bool> createOrganizationSmart({
    required String name,
    required String description,
    String? contactEmail,
  }) async {
    _loading = true;
    notifyListeners();

    // Try the admin endpoint first (for existing authenticated admins)
    final adminResponse = await ApiService.post(
      '/admin/organizations',
      body: {
        'name': name,
        'description': description,
        if (contactEmail != null) 'contact_email': contactEmail,
      },
    );

    if (adminResponse['success'] == true) {
      _error = null;
      await fetchOrganizations(); // Refresh admin organizations
      _loading = false;
      notifyListeners();
      return true;
    }

    // If admin endpoint failed due to authentication, try public endpoint
    if (adminResponse['message']?.contains('Authentication') == true ||
        adminResponse['message']?.contains('401') == true) {
      if (contactEmail == null) {
        _error = 'Contact email is required for public organization creation';
        _loading = false;
        notifyListeners();
        return false;
      }

      final publicOrg = await createPublicOrganization(
        name: name,
        description: description,
        contactEmail: contactEmail,
      );

      if (publicOrg != null) {
        _error = null;
        _loading = false;
        notifyListeners();
        return true;
      }
    }

    // Both methods failed
    _error = adminResponse['message'] ?? 'Failed to create organization';
    _loading = false;
    notifyListeners();
    return false;
  }

  // User management methods for admin-only features
  Future<List<Map<String, dynamic>>> getAllUsers(String orgId) async {
    _loading = true;
    notifyListeners();

    try {
      // Try to get real users from API
      final response = await ApiService.get('/admin/organization/$orgId/users');

      _loading = false;
      notifyListeners();

      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('API returned error: ${response['message']}');
      }
    } catch (e) {
      _error = 'Failed to load real users: $e';
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Fetch students from the current user's organization
  /// This method is suitable for teachers who should only see their organization's students
  Future<void> fetchOrganizationStudents() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to get students from the user's organization
      Map<String, dynamic>? response;

      // Try organization-specific endpoints - START with the working one
      List<String> orgEndpoints = [
        '/admin/students', // CORRECT working endpoint from API guide
        '/organization/users?role=student', // Organization students
        '/users?role=student', // All students (filtered by org on backend)
        '/attendance/organization/students', // Attendance org students
      ];

      for (String endpoint in orgEndpoints) {
        try {
          print('🔍 Trying organization endpoint: $endpoint');
          response = await ApiService.get(
            endpoint,
          ).timeout(const Duration(seconds: 10));

          if (response['success'] == true && response['data'] != null) {
            print('✅ Success with organization endpoint: $endpoint');
            break;
          }
        } catch (e) {
          print('❌ Failed organization endpoint $endpoint: $e');
          continue;
        }
      }

      _loading = false;

      if (response != null && response['success'] == true) {
        List<dynamic> userData;

        // Handle both response formats: direct array or nested with students array
        if (response['data'] is List) {
          // Direct array format
          userData = response['data'] as List<dynamic>;
        } else if (response['data']['students'] != null) {
          // Nested format from API guide
          userData = response['data']['students'] as List<dynamic>;
        } else {
          userData = [];
        }

        // Filter for students only (in case backend returns all users)
        _users = userData
            .map((data) => User.fromJson(data))
            .where((user) => user.role == 'student')
            .toList();
        _error = null;
        print('✅ Loaded ${_users.length} organization students');
      } else {
        _error = 'No students found in your organization.';
        print('❌ All organization endpoints failed');
      }
    } catch (e) {
      _loading = false;
      _error = 'Failed to fetch organization students: $e';
      print('🚨 Error fetching organization students: $e');
    }

    notifyListeners();
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    _loading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call when backend is ready
      // final response = await ApiService.put('/admin/users/$userId/role', {
      //   'role': newRole,
      // });

      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update user role: $e';
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
}
