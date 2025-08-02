import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
    _checkAuth();
  }

  void _setupAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Progress animations
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );
  }

  void _startAnimationSequence() async {
    // Start logo animation
    _logoController.forward();

    // Wait and start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Wait and start progress animation
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
  }

  Future<void> _checkAuth() async {
    // Add minimum splash duration for better UX
    await Future.delayed(const Duration(seconds: 3));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserFromStorage();

    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryLight,
              AppTheme.secondaryColor,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // Top spacing
                const Spacer(flex: 2),

                // Logo Section
                Expanded(
                  flex: 4,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _logoController,
                        _textController,
                      ]),
                      builder: (context, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Logo
                            Transform.scale(
                              scale: _logoScale.value,
                              child: FadeTransition(
                                opacity: _logoFade,
                                child: AppLogo(
                                  size: 150,
                                  showText: false,
                                  iconColor: Colors.white.withOpacity(0.95),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // App Name with Slide Animation
                            SlideTransition(
                              position: _textSlide,
                              child: FadeTransition(
                                opacity: _textFade,
                                child: Column(
                                  children: [
                                    Text(
                                      'AttendanceTracker',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            offset: const Offset(0, 2),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Smart • Reliable • Efficient',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Loading Section
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _progressFade,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Custom Loading Indicator
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Text(
                              'Initializing your workspace...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Footer Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _progressFade,
                        child: Column(
                          children: [
                            Container(
                              height: 1,
                              width: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Powered by Modern Flutter Technology',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
