import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/user_provider.dart';
import 'src/providers/attendance_provider.dart';
import 'src/providers/admin_provider.dart';
import 'src/providers/onboarding_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Base providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),

        // Providers with dependencies
        // AdminProvider depends on AuthProvider for session invalidation
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (_) => AdminProvider(),
          update: (_, authProvider, previousAdminProvider) =>
              AdminProvider(authProvider: authProvider),
        ),
      ],
      child: const AttendanceApp(),
    ),
  );
}
