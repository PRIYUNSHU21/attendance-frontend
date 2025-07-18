import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/session.dart';
import '../models/user.dart';
import '../models/organization.dart';
import 'auth_provider.dart';

class AdminProvider extends ChangeNotifier {
  final AuthProvider? authProvider;

  Map<String, dynamic>? _dashboardStats;
  List<User> _users = [];
  List<Organization> _organizations = [];
  List<Session> _sessions = [];
  bool _loading = false;
  String? _error;

  AdminProvider({this.authProvider});

  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<User> get users => _users;
  List<Organization> get organizations => _organizations;
  List<Session> get sessions => _sessions;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchDashboardStats() async {
    _loading = true;
    notifyListeners();
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

  Future<void> fetchUsers() async {
    _loading = true;
    notifyListeners();
    final response = await ApiService.get('/admin/users');
    _loading = false;
    if (response['success'] == true) {
      _users = (response['data'] as List)
          .map((userData) => User.fromJson(userData))
          .toList();
      _error = null;
    } else {
      _error = response['message'];
    }
    notifyListeners();
  }

  Future<void> fetchOrganizations() async {
    _loading = true;
    notifyListeners();

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
    notifyListeners();

    try {
      final response = await ApiService.get('/admin/sessions');
      _loading = false;

      if (response['success'] == true) {
        _sessions = (response['data'] as List)
            .map((sessionData) => Session.fromJson(sessionData))
            .toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to fetch sessions';
      }
    } catch (e) {
      _loading = false;
      _error = 'Error fetching sessions: $e';
    }
    notifyListeners();
  }

  Future<bool> createSession({
    required String sessionName,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required double locationLat,
    required double locationLon,
    required double locationRadius,
  }) async {
    _loading = true;
    notifyListeners();

    final response = await ApiService.post(
      '/admin/sessions',
      body: {
        'session_name': sessionName,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'location_lat': locationLat,
        'location_lon': locationLon,
        'location_radius': locationRadius,
      },
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

  Future<bool> updateSession(
    String sessionId, {
    String? sessionName,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    double? locationLat,
    double? locationLon,
    double? locationRadius,
    bool? isActive,
  }) async {
    _loading = true;
    notifyListeners();

    final body = <String, dynamic>{};
    if (sessionName != null) body['session_name'] = sessionName;
    if (description != null) body['description'] = description;
    if (startTime != null) body['start_time'] = startTime.toIso8601String();
    if (endTime != null) body['end_time'] = endTime.toIso8601String();
    if (locationLat != null) body['location_lat'] = locationLat;
    if (locationLon != null) body['location_lon'] = locationLon;
    if (locationRadius != null) body['location_radius'] = locationRadius;
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

        // Log the deletion results for debugging
        print('🗑️ Organization deletion completed:');
        print('  - Organization: ${deletionData['organization']}');
        print('  - Users deleted: ${deletionData['users']}');
        print('  - Sessions deleted: ${deletionData['attendance_sessions']}');
        print('  - Records deleted: ${deletionData['attendance_records']}');
        print(
          '  - User sessions invalidated: ${deletionData['invalidated_sessions']}',
        );

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

        // Log the soft deletion results for debugging
        print('📦 Organization soft deletion completed:');
        print('  - Organization: ${softDeleteData['name']}');
        print(
          '  - Status: ${softDeleteData['is_active'] ? 'Active' : 'Inactive'}',
        );
        print(
          '  - Sessions invalidated: ${softDeleteData['invalidated_sessions']}',
        );

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
}
