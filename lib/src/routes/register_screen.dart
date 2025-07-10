import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/components/animated_cards.dart';
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
  String _orgId = '1'; // Using verified organization ID
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _formKey.currentState!.save();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.register(
      _name,
      _email,
      _password,
      _role,
      _orgId,
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
                    // Header Section
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppTheme.textDark,
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                    ).animate().fadeIn(
                          duration: AppTheme.animDurationFast,
                          delay: 100.ms,
                        ),
                        
                    // Title and Subtitle
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.app_registration_rounded,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ).animate().scale(
                                duration: AppTheme.animDurationMedium,
                                curve: Curves.easeOutBack,
                                delay: 200.ms,
                              ),
                          const SizedBox(height: 16),
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
                    AnimatedCard(
                      padding: const EdgeInsets.all(24),
                      boxShadow: AppTheme.cardShadowLarge,
                      borderRadius: AppTheme.borderRadiusLarge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Name Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your name',
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
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
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
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
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
                            validator: (v) => v != null && v.length >= 6
                                ? null
                                : 'Password must be at least 6 characters',
                            onSaved: (v) => _password = v ?? '',
                          ).animate().custom(
                                duration: AppTheme.animDurationMedium,
                                delay: 700.ms,
                                begin: 0,
                                end: 1,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
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
                            onChanged: (v) => setState(() => _role = v ?? 'student'),
                          ).animate().custom(
                                duration: AppTheme.animDurationMedium,
                                delay: 800.ms,
                                begin: 0,
                                end: 1,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                              
                          const SizedBox(height: 20),
                          
                          // Organization Dropdown
                          DropdownButtonFormField<String>(
                            value: _orgId,
                            decoration: InputDecoration(
                              labelText: 'Organization',
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
                                value: '1',
                                child: Text('Default Organization'),
                              ),
                              DropdownMenuItem(
                                value: '2',
                                child: Text('Test Organization'),
                              ),
                              DropdownMenuItem(
                                value: '3',
                                child: Text('Demo Organization'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _orgId = v ?? '1'),
                          ).animate().custom(
                                duration: AppTheme.animDurationMedium,
                                delay: 900.ms,
                                begin: 0,
                                end: 1,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
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
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
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
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
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
    );
  }
}
