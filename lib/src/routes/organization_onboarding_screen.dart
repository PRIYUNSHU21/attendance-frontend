import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/organization_search_field.dart';
import '../models/organization.dart';

class OrganizationOnboardingScreen extends StatefulWidget {
  static const String routeName = '/organization-onboarding';

  const OrganizationOnboardingScreen({super.key});

  @override
  State<OrganizationOnboardingScreen> createState() =>
      _OrganizationOnboardingScreenState();
}

class _OrganizationOnboardingScreenState
    extends State<OrganizationOnboardingScreen> {
  final PageController _pageController = PageController();

  // Form controllers
  final _orgNameController = TextEditingController();
  final _orgDescriptionController = TextEditingController();
  final _orgContactEmailController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  String? _selectedOrgId;
  Organization? _selectedOrganization;
  bool _isCreatingNewOrg = true;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  void _loadOrganizations() {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    onboardingProvider.fetchOrganizations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Setup'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OnboardingProvider>(
        builder: (context, onboardingProvider, child) {
          if (onboardingProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStepOne(onboardingProvider),
              _buildStepTwo(onboardingProvider),
              _buildStepThree(onboardingProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepOne(OnboardingProvider onboardingProvider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(0),
          const SizedBox(height: 32),

          // Title
          Text('Choose Your Organization', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text(
            'Select an existing organization or create a new one',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),

          // Organization choice tabs
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCreatingNewOrg = false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !_isCreatingNewOrg
                          ? AppTheme.primaryColor
                          : Colors.grey[100],
                      borderRadius: AppTheme.borderRadiusMedium,
                    ),
                    child: Text(
                      'Join Existing',
                      style: TextStyle(
                        color: !_isCreatingNewOrg
                            ? Colors.white
                            : AppTheme.textMedium,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCreatingNewOrg = true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCreatingNewOrg
                          ? AppTheme.primaryColor
                          : Colors.grey[100],
                      borderRadius: AppTheme.borderRadiusMedium,
                    ),
                    child: Text(
                      'Create New',
                      style: TextStyle(
                        color: _isCreatingNewOrg
                            ? Colors.white
                            : AppTheme.textMedium,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Content based on choice
          Expanded(
            child: _isCreatingNewOrg
                ? _buildCreateNewOrgForm()
                : _buildJoinExistingOrgList(onboardingProvider),
          ),

          // Error display
          if (onboardingProvider.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: AppTheme.borderRadiusMedium,
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                onboardingProvider.error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),

          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canProceedToStepTwo() ? _proceedToStepTwo : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewOrgForm() {
    return Column(
      children: [
        TextField(
          controller: _orgNameController,
          decoration: InputDecoration(
            labelText: 'Organization Name',
            hintText: 'e.g., ABC University',
            border: OutlineInputBorder(
              borderRadius: AppTheme.borderRadiusMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _orgDescriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Brief description of your organization',
            border: OutlineInputBorder(
              borderRadius: AppTheme.borderRadiusMedium,
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _orgContactEmailController,
          decoration: InputDecoration(
            labelText: 'Contact Email',
            hintText: 'admin@organization.com',
            border: OutlineInputBorder(
              borderRadius: AppTheme.borderRadiusMedium,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildJoinExistingOrgList(OnboardingProvider onboardingProvider) {
    return OrganizationSearchField(
      organizations: onboardingProvider.organizations,
      selectedOrganization: _selectedOrganization,
      isLoading: onboardingProvider.loading,
      onSelectionChanged: (org) {
        setState(() {
          _selectedOrganization = org;
          _selectedOrgId = org?.orgId;
        });
      },
      hintText: 'Search for your organization...',
      labelText: 'Select Organization',
    );
  }

  Widget _buildStepTwo(OnboardingProvider onboardingProvider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(1),
          const SizedBox(height: 32),

          Text('Create Admin Account', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text(
            'Set up the administrator account for your organization',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _adminNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter admin full name',
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _adminEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'admin@organization.com',
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusMedium,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _adminPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a strong password',
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusMedium,
                    ),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),

          if (onboardingProvider.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: AppTheme.borderRadiusMedium,
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                onboardingProvider.error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBackToStepOne,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceedToStepThree()
                      ? _proceedToStepThree
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Complete Setup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepThree(OnboardingProvider onboardingProvider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildProgressIndicator(2),
          const SizedBox(height: 32),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Setup Complete!',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your organization and admin account have been created successfully.',
                    style: AppTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Continue to Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AppTheme.primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  bool _canProceedToStepTwo() {
    if (_isCreatingNewOrg) {
      return _orgNameController.text.isNotEmpty &&
          _orgDescriptionController.text.isNotEmpty &&
          _orgContactEmailController.text.isNotEmpty;
    } else {
      return _selectedOrgId != null;
    }
  }

  bool _canProceedToStepThree() {
    return _adminNameController.text.isNotEmpty &&
        _adminEmailController.text.isNotEmpty &&
        _adminPasswordController.text.isNotEmpty;
  }

  void _proceedToStepTwo() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBackToStepOne() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _proceedToStepThree() async {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    onboardingProvider.clearError();

    OnboardingResult? result;

    if (_isCreatingNewOrg) {
      // Create new organization + admin
      result = await onboardingProvider.setupNewOrganization(
        orgName: _orgNameController.text,
        orgDescription: _orgDescriptionController.text,
        orgContactEmail: _orgContactEmailController.text,
        adminName: _adminNameController.text,
        adminEmail: _adminEmailController.text,
        adminPassword: _adminPasswordController.text,
      );
    } else {
      // Create admin for existing organization
      final admin = await onboardingProvider.createFirstAdmin(
        name: _adminNameController.text,
        email: _adminEmailController.text,
        password: _adminPasswordController.text,
        orgId: _selectedOrgId!,
      );

      if (admin != null) {
        final org = onboardingProvider.organizations.firstWhere(
          (o) => o.orgId == _selectedOrgId,
        );
        result = OnboardingResult(
          organization: org,
          admin: admin,
          success: true,
        );
      }
    }

    if (result?.success == true) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Navigate to login screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orgNameController.dispose();
    _orgDescriptionController.dispose();
    _orgContactEmailController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }
}
