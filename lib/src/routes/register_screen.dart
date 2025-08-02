import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/organization_search_field.dart';
import '../models/organization.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _role = 'student';
  Organization? _selectedOrganization;
  bool _loading = false;
  bool _loadingOrgs = false;
  String? _error;
  bool _obscurePassword = true;
  List<Organization> _organizations = [];
  @override
  void initState() {
    super.initState();
    // Delay organization fetching to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrganizations();
    });
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      _loadingOrgs = true;
    });

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchPublicOrganizations();

    setState(() {
      _organizations = adminProvider.publicOrganizations;
      _loadingOrgs = false;
    });
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _loading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.register(
      _name,
      _email,
      _password,
      _role,
      _selectedOrganization!.orgId,
    );
    setState(() {
      _loading = false;
    });
    if (result == true) {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    } else {
      setState(() {
        _error = result.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section with Logo
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: AppTheme.textDark),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                    ).animate().fadeIn(
                      duration: AppTheme.animDurationFast,
                      delay: 100.ms,
                    ),

                    const SizedBox(height: 16),

                    // Logo Section
                    Center(
                      child: Column(
                        children: [
                          AppLogo(size: 80, showText: false).animate().scale(
                            duration: AppTheme.animDurationMedium,
                            curve: Curves.easeOutBack,
                            delay: 200.ms,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Create Account',
                            style: AppTheme.headingMedium.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ).animate().fadeIn(
                            duration: AppTheme.animDurationMedium,
                            curve: Curves.easeOut,
                            delay: 300.ms,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join our attendance platform',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textMedium,
                            ),
                          ).animate().fadeIn(
                            duration: AppTheme.animDurationMedium,
                            curve: Curves.easeOut,
                            delay: 400.ms,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Registration Form Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome Text
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join AttendEase today',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Name Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your name',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (v) => v != null && v.isNotEmpty
                                ? null
                                : 'Please enter your name',
                            onSaved: (v) => _name = v ?? '',
                          ).animate().custom(
                            duration: AppTheme.animDurationMedium,
                            delay: 500.ms,
                            begin: 0,
                            end: 1,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          // Email Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                                borderSide: BorderSide(
                                  color: AppTheme.dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v != null && v.contains('@')
                                ? null
                                : 'Please enter a valid email address',
                            onSaved: (v) => _email = v ?? '',
                          ).animate().custom(
                            duration: AppTheme.animDurationMedium,
                            delay: 600.ms,
                            begin: 0,
                            end: 1,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppTheme.primaryColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.textMedium,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                                borderSide: BorderSide(
                                  color: AppTheme.dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                                return 'Password must contain at least one uppercase letter';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(v)) {
                                return 'Password must contain at least one number';
                              }
                              if (!RegExp(
                                r'[!@#$%^&*(),.?":{}|<>]',
                              ).hasMatch(v)) {
                                return 'Password must contain at least one special character';
                              }
                              return null;
                            },
                            onSaved: (v) => _password = v ?? '',
                          ).animate().custom(
                            duration: AppTheme.animDurationMedium,
                            delay: 700.ms,
                            begin: 0,
                            end: 1,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                          ),

                          // Password requirements
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 12.0,
                            ),
                            child: Text(
                              'Password must contain:\n• At least 8 characters\n• One uppercase letter (A-Z)\n• One number (0-9)\n• One special character (!@#\$%^&*)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Role Dropdown
                          DropdownButtonFormField<String>(
                            value: _role,
                            decoration: InputDecoration(
                              labelText: 'Role',
                              prefixIcon: Icon(
                                Icons.badge_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                                borderSide: BorderSide(
                                  color: AppTheme.dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'student',
                                child: Text('Student'),
                              ),
                              DropdownMenuItem(
                                value: 'teacher',
                                child: Text('Teacher'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _role = v ?? 'student'),
                          ).animate().custom(
                            duration: AppTheme.animDurationMedium,
                            delay: 800.ms,
                            begin: 0,
                            end: 1,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Organization Search Field
                          OrganizationSearchField(
                            organizations: _organizations,
                            selectedOrganization: _selectedOrganization,
                            isLoading: _loadingOrgs,
                            onSelectionChanged: (org) {
                              setState(() {
                                _selectedOrganization = org;
                              });
                            },
                          ).animate().custom(
                            duration: AppTheme.animDurationMedium,
                            delay: 900.ms,
                            begin: 0,
                            end: 1,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Message
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: AppTheme.borderRadiusMedium,
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake(
                        duration: 300.ms,
                        curve: Curves.easeInOut,
                      ),

                    const SizedBox(height: 24),

                    // Register Button
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ).animate().custom(
                            duration: AppTheme.animDurationMedium,
                            delay: 1000.ms,
                            begin: 0,
                            end: 1,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                          ),

                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.routeName,
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(
                      duration: AppTheme.animDurationMedium,
                      delay: 1100.ms,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
