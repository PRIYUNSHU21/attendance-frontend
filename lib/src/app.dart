import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'routes/splash_screen.dart';
import 'routes/login_screen.dart';
import 'routes/register_screen.dart';
import 'routes/dashboard_screen.dart';
import 'routes/attendance_screen.dart';
import 'routes/session_management_screen.dart';
import 'routes/student_attendance_screen.dart';
import 'routes/student_dashboard_screen.dart';
import 'routes/teacher_dashboard_screen.dart';
import 'routes/analytics_screen.dart';
import 'routes/admin_register_screen.dart';
import 'routes/organization_onboarding_screen.dart';
import 'routes/students_list_screen.dart';
import 'routes/session_debug_screen.dart';
import 'routes/browse_sessions_screen.dart';
import 'routes/admin_dashboard_screen.dart';
import 'routes/organization_location_setup_screen.dart';
import 'routes/organization_attendance_screen.dart';
import 'routes/user_management_screen.dart';
import 'routes/attendance_records_screen.dart';
import 'utils/app_theme.dart';

// Configure global animation defaults
void _configureAnimations() {
  Animate.restartOnHotReload = true;
  Animate.defaultDuration = AppTheme.animDurationMedium;
  Animate.defaultCurve = Curves.easeOutCubic;
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    _configureAnimations();

    return MaterialApp(
      title: 'Attendance System',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        AdminRegisterScreen.routeName: (context) => const AdminRegisterScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        AttendanceScreen.routeName: (context) => const AttendanceScreen(),
        SessionManagementScreen.routeName: (context) =>
            const SessionManagementScreen(),
        StudentAttendanceScreen.routeName: (context) =>
            const StudentAttendanceScreen(),
        StudentDashboardScreen.routeName: (context) =>
            const StudentDashboardScreen(),
        TeacherDashboardScreen.routeName: (context) =>
            const TeacherDashboardScreen(),
        AnalyticsScreen.routeName: (context) => const AnalyticsScreen(),
        OrganizationOnboardingScreen.routeName: (context) =>
            const OrganizationOnboardingScreen(),
        StudentsListScreen.routeName: (context) => const StudentsListScreen(),
        SessionDebugScreen.routeName: (context) => const SessionDebugScreen(),
        BrowseSessionsScreen.routeName: (context) =>
            const BrowseSessionsScreen(),
        AdminDashboardScreen.routeName: (context) =>
            const AdminDashboardScreen(),
        OrganizationLocationSetupScreen.routeName: (context) =>
            const OrganizationLocationSetupScreen(),
        OrganizationAttendanceScreen.routeName: (context) =>
            const OrganizationAttendanceScreen(),
        UserManagementScreen.routeName: (context) =>
            const UserManagementScreen(),
        AttendanceRecordsScreen.routeName: (context) =>
            const AttendanceRecordsScreen(),
      },
    );
  }
}
