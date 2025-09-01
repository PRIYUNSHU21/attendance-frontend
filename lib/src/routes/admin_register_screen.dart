import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  static const String routeName = '/admin-register';
  const AdminRegisterScreen({super.key});
  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactEmailController = TextEditingController();
  String _name = '';
  String _email = '';
  String _password = '';
  String _orgName = '';
  String _orgDescription = '';
  String _orgContactEmail = '';
  bool _loading = false;
  String? _error;
  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _formKey.currentState!.save();
    // Ensure the contact email is saved correctly
    _orgContactEmail = _contactEmailController.text;
    // Additional validation checks
    if (_name.isEmpty) {
      setState(() {
        _error = 'Name is required';
        _loading = false;
      });
      return;
    }
    if (_email.isEmpty || !_email.contains('@')) {
      setState(() {
        _error = 'Valid email is required';
        _loading = false;
      });
      return;
    }
    if (_password.length < 8) {
      setState(() {
        _error = 'Password must be at least 8 characters';
        _loading = false;
      });
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(_password)) {
      setState(() {
        _error = 'Password must contain at least one uppercase letter';
        _loading = false;
      });
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(_password)) {
      setState(() {
        _error = 'Password must contain at least one number';
        _loading = false;
      });
      return;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_password)) {
      setState(() {
        _error = 'Password must contain at least one special character';
        _loading = false;
      });
      return;
    }
    if (_orgName.isEmpty) {
      setState(() {
        _error = 'Organization name is required';
        _loading = false;
      });
      return;
    }
    if (_orgDescription.isEmpty) {
      setState(() {
        _error = 'Organization description is required';
        _loading = false;
      });
      return;
    }
    if (_orgContactEmail.isEmpty || !_orgContactEmail.contains('@')) {
      setState(() {
        _error = 'Valid organization contact email is required';
        _loading = false;
      });
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Register admin with new organization
    final result = await authProvider.registerAdmin(
      _name,
      _email,
      _password,
      _orgName,
      _orgDescription,
      _orgContactEmail,
    );
    setState(() {
      _loading = false;
    });
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! You can now log in.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    } else {
      // Show detailed error information
      String errorMessage = result.toString();
      // Check if it's a validation error with details
      if (errorMessage.contains('validation_errors')) {
        try {
          // Try to parse detailed validation errors
          final errorData = result;
          if (errorData is Map && errorData.containsKey('details')) {
            final details = errorData['details'];
            if (details is Map && details.containsKey('validation_errors')) {
              final validationErrors = details['validation_errors'];
              if (validationErrors is Map) {
                String detailedErrors = '';
                validationErrors.forEach((field, errors) {
                  if (errors is List) {
                    detailedErrors += '$field:\n';
                    for (var error in errors) {
                      detailedErrors += '  • $error\n';
                    }
                  }
                });
                if (detailedErrors.isNotEmpty) {
                  errorMessage = 'Validation failed:\n\n$detailedErrors';
                }
              }
            }
          }
        } catch (e) {}
      }
      // Check for specific error types and provide helpful messages
      if (errorMessage.contains('contact_email') ||
          errorMessage.contains('email')) {
        errorMessage =
            'Please check that all email fields are filled correctly.';
      } else if (errorMessage.contains('organization')) {
        errorMessage =
            'There was an issue creating the organization. Please try again.';
      } else if (errorMessage.contains('admin')) {
        errorMessage =
            'There was an issue creating the admin account. Please try again.';
      } else if (errorMessage.contains('validation') ||
          errorMessage.contains('required')) {
        // Keep the detailed validation message if we have it
        if (!errorMessage.contains('validation_errors')) {
          errorMessage = 'Please fill in all required fields correctly.';
        }
      }
      setState(() {
        _error = errorMessage;
      });
      // Also show a snackbar for immediate feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed: ${errorMessage.split('\n').first}',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 8),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.background, AppTheme.surfaceVariant],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo and Title
                    Column(
                      children: [
                        AppLogo(size: 80, showText: false).animate().scale(
                          duration: AppTheme.animDurationMedium,
                          curve: Curves.elasticOut,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ATTENDIFY',
                          style: AppTheme.headingLarge.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ).animate().fadeIn(
                          duration: AppTheme.animDurationMedium,
                          delay: 300.ms,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'CREATE ADMIN ACCOUNT',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ).animate().fadeIn(
                          duration: AppTheme.animDurationMedium,
                          delay: 500.ms,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Welcome Text
                    Column(
                      children: [
                        Text(
                          'Join as Organization Admin',
                          style: AppTheme.headingMedium.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ).animate().fadeIn(
                          duration: AppTheme.animDurationMedium,
                          delay: 600.ms,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your organization and start managing attendance',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textMedium,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(
                          duration: AppTheme.animDurationMedium,
                          delay: 700.ms,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Registration Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.borderRadiusLarge,
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Info box for admin registration
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.info.withOpacity(0.1),
                                    AppTheme.info.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: AppTheme.borderRadiusMedium,
                                border: Border.all(
                                  color: AppTheme.info.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppTheme.info,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Admin Registration',
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.info,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create your organization and become the first admin. You will be able to manage attendance sessions and add team members.',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Admin Information Section
                            Text(
                              'Admin Information',
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Admin Name Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'Enter your full name',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  borderSide: BorderSide(
                                    color: AppTheme.outline,
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
                              validator: (v) => v != null && v.isNotEmpty
                                  ? null
                                  : 'Enter your name',
                              onSaved: (v) => _name = v ?? '',
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email address',
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
                                    color: AppTheme.outline,
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
                                  : 'Enter a valid email',
                              onSaved: (v) => _email = v ?? '',
                              onChanged: (v) {
                                _email = v;
                                // Auto-populate contact email if it's empty
                                if (_contactEmailController.text.isEmpty) {
                                  _contactEmailController.text = v;
                                  _orgContactEmail = v;
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Create a strong password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  borderSide: BorderSide(
                                    color: AppTheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                helperText:
                                    'Min 8 chars, uppercase, number, special char',
                                helperStyle: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              obscureText: true,
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
                              onChanged: (v) => _password = v,
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                hintText: 'Re-enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  borderSide: BorderSide(
                                    color: AppTheme.outline,
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
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (v != _password) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Organization Information Section
                            Text(
                              'Organization Information',
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Organization Name Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Organization Name',
                                hintText: 'Enter your organization name',
                                prefixIcon: Icon(
                                  Icons.business_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  borderSide: BorderSide(
                                    color: AppTheme.outline,
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
                              validator: (v) => v != null && v.isNotEmpty
                                  ? null
                                  : 'Enter organization name',
                              onSaved: (v) => _orgName = v ?? '',
                            ),
                            const SizedBox(height: 16),

                            // Organization Description Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Organization Description',
                                hintText:
                                    'Brief description of your organization',
                                prefixIcon: Icon(
                                  Icons.description_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  borderSide: BorderSide(
                                    color: AppTheme.outline,
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
                              maxLines: 3,
                              validator: (v) => v != null && v.isNotEmpty
                                  ? null
                                  : 'Please enter a description for your organization',
                              onSaved: (v) => _orgDescription = v ?? '',
                            ),
                            const SizedBox(height: 16),

                            // Organization Contact Email Field
                            TextFormField(
                              controller: _contactEmailController,
                              decoration: InputDecoration(
                                labelText: 'Organization Contact Email',
                                hintText: 'Contact email for your organization',
                                prefixIcon: Icon(
                                  Icons.contact_mail_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  borderSide: BorderSide(
                                    color: AppTheme.outline,
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
                                  : 'Enter a valid contact email',
                              onSaved: (v) => _orgContactEmail = v ?? '',
                            ),

                            const SizedBox(height: 24),

                            // Error message display
                            if (_error != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.1),
                                  borderRadius: AppTheme.borderRadiusMedium,
                                  border: Border.all(
                                    color: AppTheme.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppTheme.error,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Registration Error',
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.error,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _error!,
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          setState(() => _error = null),
                                      icon: Icon(
                                        Icons.close,
                                        color: AppTheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Register Button
                            ElevatedButton(
                              onPressed: _loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppTheme.borderRadiusMedium,
                                ),
                                elevation: 2,
                              ),
                              child: _loading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Create Admin Account',
                                      style: AppTheme.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 24),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                        context,
                                        LoginScreen.routeName,
                                      ),
                                  child: Text(
                                    'Sign In',
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(
                      begin: 0.3,
                      duration: AppTheme.animDurationMedium,
                      curve: Curves.easeOut,
                      delay: 800.ms,
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
