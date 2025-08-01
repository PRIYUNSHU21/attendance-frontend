import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
      appBar: AppBar(
        title: const Text('Admin Registration'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'Create Admin Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info box for admin registration
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Important Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'To register as an admin, you must already have a valid organization ID '
                          'or be the first user in the system. If you have issues registering, '
                          'please contact the system administrator.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'For testing purposes: Log in with test@example.com / Password123!',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Admin Information Section
                  const Text(
                    'Admin Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Enter your name',
                    onSaved: (v) => _name = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
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
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      helperText:
                          'At least 8 characters with uppercase, number, and special character',
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
                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) {
                        return 'Password must contain at least one special character';
                      }
                      return null;
                    },
                    onSaved: (v) => _password = v ?? '',
                    onChanged: (v) => _password = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  // Password requirements info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Password Requirements',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your password must contain:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '  • At least 8 characters\n'
                          '  • At least one uppercase letter (A-Z)\n'
                          '  • At least one number (0-9)\n'
                          '  • At least one special character (!@#\$%^&*)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Organization Information Section
                  const Text(
                    'Organization Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Organization Name',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v != null && v.isNotEmpty
                        ? null
                        : 'Enter organization name',
                    onSaved: (v) => _orgName = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Organization Description *',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                      helperText: 'Brief description of your organization',
                    ),
                    maxLines: 3,
                    validator: (v) => v != null && v.isNotEmpty
                        ? null
                        : 'Please enter a description for your organization',
                    onSaved: (v) => _orgDescription = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Organization Contact Email',
                      prefixIcon: Icon(Icons.contact_mail),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Enter a valid contact email',
                    onSaved: (v) => _orgContactEmail = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  // Error message display
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registration Error',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _error!,
                                  style: TextStyle(color: Colors.red.shade800),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _error = null),
                            icon: Icon(Icons.close, color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Register as Admin',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          LoginScreen.routeName,
                        ),
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
