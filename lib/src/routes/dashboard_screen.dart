import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import 'attendance_screen.dart';
import 'admin_screen.dart';
import 'session_management_screen.dart';
import 'student_attendance_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user?.role == 'admin' || auth.user?.role == 'teacher') {
      Provider.of<AdminProvider>(context, listen: false).fetchDashboardStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final admin = Provider.of<AdminProvider>(context);
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('Role: ${user.role}'),
                  const SizedBox(height: 24),
                  if (user.role == 'admin' || user.role == 'teacher') ...[
                    Text(
                      'Dashboard Stats:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    admin.loading
                        ? const CircularProgressIndicator()
                        : admin.dashboardStats != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Users: ${admin.dashboardStats!['total_users'] ?? '-'}',
                              ),
                              Text(
                                'Total Students: ${admin.dashboardStats!['total_students'] ?? '-'}',
                              ),
                              Text(
                                'Total Teachers: ${admin.dashboardStats!['total_teachers'] ?? '-'}',
                              ),
                              Text(
                                'Active Sessions: ${admin.dashboardStats!['active_sessions'] ?? '-'}',
                              ),
                            ],
                          )
                        : Text(admin.error ?? 'No stats available'),
                    const SizedBox(height: 24),
                  ],
                  // Navigation buttons based on user role
                  if (user.role == 'student') ...[
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/student-dashboard'),
                      icon: const Icon(Icons.dashboard),
                      label: const Text('Student Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        StudentAttendanceScreen.routeName,
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark Attendance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AttendanceScreen.routeName,
                      ),
                      icon: const Icon(Icons.history),
                      label: const Text('View Attendance History'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/teacher-dashboard'),
                      icon: const Icon(Icons.dashboard),
                      label: const Text('Teacher Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        SessionManagementScreen.routeName,
                      ),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Manage Sessions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/analytics'),
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analytics Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AttendanceScreen.routeName,
                      ),
                      icon: const Icon(Icons.list),
                      label: const Text('View Attendance Reports'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AdminScreen.routeName),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Admin Panel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
