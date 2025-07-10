import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/components/animated_cards.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'admin_register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _formKey.currentState!.save();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.login(_email, _password);
    setState(() {
      _loading = false;
    });
    if (result == true) {
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
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
                    // Logo and Welcome Text
                    Column(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ).animate().scale(
                          duration: AppTheme.animDurationMedium,
                          curve: Curves.easeOutBack,
                          delay: 200.ms,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
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
                          'Sign in to continue',
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
                    const SizedBox(height: 40),

                    // Login Card
                    AnimatedCard(
                      padding: const EdgeInsets.all(24),
                      boxShadow: AppTheme.cardShadowLarge,
                      borderRadius: AppTheme.borderRadiusLarge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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

                    // Login Button
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
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
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                    const SizedBox(height: 16),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RegisterScreen.routeName,
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(
                      duration: AppTheme.animDurationMedium,
                      delay: 800.ms,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Admin Card
                    GradientCard(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.secondaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppTheme.borderRadiusLarge,
                      padding: const EdgeInsets.all(20),
                      index: 3,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Administrator Portal',
                                      style: AppTheme.labelLarge.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage organizations, users, and sessions',
                                      style: AppTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AdminRegisterScreen.routeName,
                            ),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Register as Admin'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.borderRadiusMedium,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                      duration: AppTheme.animDurationMedium,
                      delay: 900.ms,
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
