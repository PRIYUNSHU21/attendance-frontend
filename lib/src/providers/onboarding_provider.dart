import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/organization.dart';

class OnboardingProvider extends ChangeNotifier {
  List<Organization> _organizations = [];
  bool _loading = false;
  String? _error;

  List<Organization> get organizations => _organizations;
  bool get loading => _loading;
  String? get error => _error;

  /// Fetch all available organizations for user selection during registration
  Future<void> fetchOrganizations() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getPublic('/auth/public/organizations');
      _loading = false;

      if (response['success'] == true) {
        _organizations = (response['data'] as List)
            .map((orgData) => Organization.fromJson(orgData))
            .toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to fetch organizations';
      }
    } catch (e) {
      _loading = false;
      _error = 'Error fetching organizations: $e';
    }
    notifyListeners();
  }

  /// Create a new organization during onboarding
  Future<Organization?> createOrganization({
    required String name,
    required String description,
    required String contactEmail,
  }) async {
    _loading = true;
    _error = null;
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

        // Add the new organization to our list
        _organizations.add(newOrg);
        _error = null;

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

  /// Create the first admin for an organization
  Future<Map<String, dynamic>?> createFirstAdmin({
    required String name,
    required String email,
    required String password,
    required String orgId,
  }) async {
    _loading = true;
    _error = null;
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

  /// Complete organization setup: Create organization + first admin in one flow
  Future<OnboardingResult?> setupNewOrganization({
    required String orgName,
    required String orgDescription,
    required String orgContactEmail,
    required String adminName,
    required String adminEmail,
    required String adminPassword,
  }) async {
    try {
      // Step 1: Create the organization
      final organization = await createOrganization(
        name: orgName,
        description: orgDescription,
        contactEmail: orgContactEmail,
      );

      if (organization == null) {
        return null; // Error is already set
      }

      // Step 2: Create the first admin
      final admin = await createFirstAdmin(
        name: adminName,
        email: adminEmail,
        password: adminPassword,
        orgId: organization.orgId,
      );

      if (admin == null) {
        _error =
            'Organization created successfully, but failed to create admin. '
            'Please try logging in to create an admin account.';
        notifyListeners();
        return OnboardingResult(
          organization: organization,
          admin: null,
          success: false,
        );
      }

      return OnboardingResult(
        organization: organization,
        admin: admin,
        success: true,
      );
    } catch (e) {
      _error = 'Error during organization setup: $e';
      notifyListeners();
      return null;
    }
  }

  /// Check if an organization already has an admin
  /// This is useful to determine if we should show "Create Admin" or "Join Organization" options
  Future<bool> organizationHasAdmin(String orgId) async {
    try {
      // Try to create a dummy admin to see if it fails due to existing admin
      final response = await ApiService.postPublic(
        '/auth/public/admin',
        body: {
          'name': 'test',
          'email': 'test@test.com',
          'password': 'test123',
          'org_id': orgId,
        },
      );

      // If it fails with "admin already exists" message, return true
      if (response['success'] == false &&
          response['message']?.toLowerCase().contains('admin') == true) {
        return true;
      }

      return false;
    } catch (e) {
      // Assume has admin if we can't check
      return true;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Result of organization onboarding process
class OnboardingResult {
  final Organization organization;
  final Map<String, dynamic>? admin;
  final bool success;

  OnboardingResult({
    required this.organization,
    required this.admin,
    required this.success,
  });
}
