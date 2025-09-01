import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/session.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/components/animated_cards.dart' as components;
import 'admin_dashboard_screen.dart';
import 'organization_location_setup_screen.dart';
import 'session_management_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  static const String routeName = '/teacher-dashboard';
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Use post frame callback to avoid build-time setState calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    // Load data progressively to avoid blocking the UI
    Future.microtask(() => attendanceProvider.fetchActiveSessions());
    Future.microtask(() => adminProvider.fetchSessions());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CompactAppLogo(size: 28),
            const SizedBox(width: 12),
            const Text(
              'Teacher Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Admin panel shortcut if user is admin
          if (auth.user?.role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () =>
                  Navigator.pushNamed(context, AdminDashboardScreen.routeName),
            ),

          // Logout button
          IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadiusMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            auth.logout();
                            Navigator.pop(context); // Close dialog
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: -0.2, end: 0, duration: 400.ms, delay: 300.ms),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                _buildWelcomeHeader(auth),
                const SizedBox(height: 20),

                // Quick Stats
                _buildQuickStats(adminProvider, attendanceProvider),
                const SizedBox(height: 20),

                // Active Sessions Section
                _buildActiveSessions(attendanceProvider),
                const SizedBox(height: 20),

                // Recent Sessions
                _buildRecentSessions(adminProvider),
                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: AppTheme.cardShadowLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      auth.user?.name != null
                          ? auth.user!.name.substring(0, 1).toUpperCase()
                          : 'T',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          'Welcome back,',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideX(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                          delay: 200.ms,
                        ),
                    const SizedBox(height: 4),
                    Text(
                          auth.user?.name ?? 'Teacher',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideX(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                          delay: 300.ms,
                        ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: AppTheme.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.today, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Today: ${_formatDate(DateTime.now())}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 400.ms),
          const SizedBox(height: 16),
          Text(
                'Manage your sessions and track student attendance',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    AdminProvider adminProvider,
    AttendanceProvider attendanceProvider,
  ) {
    final totalSessions = adminProvider.sessions.length;
    final activeSessions = attendanceProvider.activeSessions.length;
    final completedSessions = adminProvider.sessions
        .where((s) => !s.isActive)
        .length;

    return Row(
      children: [
        Expanded(
          child: components.StatsCard(
            title: 'Total Sessions',
            value: totalSessions.toString(),
            icon: Icons.event,
            color: AppTheme.primaryColor,
            index: 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: components.StatsCard(
            title: 'Active Now',
            value: activeSessions.toString(),
            icon: Icons.play_circle_fill,
            color: AppTheme.successColor,
            index: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: components.StatsCard(
            title: 'Completed',
            value: completedSessions.toString(),
            icon: Icons.check_circle,
            color: AppTheme.warningColor,
            index: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessions(AttendanceProvider attendanceProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Sessions', style: AppTheme.headingSmall)
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms),

            ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    SessionManagementScreen.routeName,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Session'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: -0.2, end: 0, duration: 400.ms, delay: 300.ms),
          ],
        ),
        const SizedBox(height: 16),
        if (attendanceProvider.loading)
          Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
          )
        else if (attendanceProvider.activeSessions.isEmpty)
          _buildEmptyState(
            'No active sessions',
            'Create a new session to get started',
            Icons.event_busy,
          )
        else
          Column(
            children: List.generate(
              attendanceProvider.activeSessions.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActiveSessionCard(
                  attendanceProvider.activeSessions[index],
                  index,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveSessionCard(Session session, [int index = 0]) {
    return components.AnimatedCard(
      padding: EdgeInsets.zero,
      index: index,
      boxShadow: AppTheme.cardShadow,
      borderRadius: AppTheme.borderRadiusMedium,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: AppTheme.borderRadiusMedium,
                      ),
                      child: Icon(
                        Icons.play_circle_fill,
                        color: AppTheme.successColor,
                        size: 24,
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: 2.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                    ),

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.sessionName, style: AppTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        session.description.isNotEmpty
                            ? session.description
                            : 'No description',
                        style: AppTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .fadeOut(
                            duration: 1.seconds,
                            curve: Curves.easeInOut,
                          ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: AppTheme.borderRadiusSmall,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${session.locationRadius.round()}m radius',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(AdminProvider adminProvider) {
    // Filter for expired/past sessions only
    final expiredSessions = adminProvider.sessions.where((session) {
      // Session is expired if:
      // 1. It's marked as inactive, OR
      // 2. Current time is past the end time
      final now = DateTime.now();
      final isExpired = !session.isActive || now.isAfter(session.endTime);
      return isExpired;
    }).toList();

    // Sort expired sessions by end time (most recently ended first)
    expiredSessions.sort((a, b) => b.endTime.compareTo(a.endTime));

    // Take only the 3 most recent expired sessions
    final recentExpiredSessions = expiredSessions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Sessions', style: AppTheme.headingSmall)
            .animate()
            .fadeIn(duration: 400.ms, delay: 250.ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 250.ms),

        const SizedBox(height: 16),
        if (adminProvider.loading)
          Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
          )
        else if (recentExpiredSessions.isEmpty)
          _buildEmptyState(
            'No past sessions yet',
            'Past sessions will appear here once they expire',
            Icons.history,
          )
        else
          Column(
            children: List.generate(
              recentExpiredSessions.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRecentSessionCard(
                  recentExpiredSessions[index],
                  index,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentSessionCard(Session session, [int index = 0]) {
    return components.SessionCard(
      title: session.sessionName,
      description: session.description.isEmpty
          ? 'No description'
          : session.description,
      timeRange:
          '${_formatDate(session.startTime)} • ${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
      isActive:
          false, // Always show as inactive since these are expired sessions
      onTap: () {
        // Navigate to session details or show read-only view for expired sessions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${session.sessionName} ended on ${_formatDate(session.endTime)}',
            ),
            backgroundColor: Colors.grey[600],
          ),
        );
      },
      index: index,
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTheme.headingSmall)
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 300.ms),
        const SizedBox(height: 16),
        // Primary actions - most important
        Row(
          children: [
            Expanded(
              child: components.ActionCard(
                title: 'New Session',
                subtitle: 'Create attendance session',
                icon: Icons.add_circle,
                color: AppTheme.primaryColor,
                onTap: () => Navigator.pushNamed(
                  context,
                  SessionManagementScreen.routeName,
                ),
                index: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: components.ActionCard(
                title: 'View Students',
                subtitle: 'Manage students',
                icon: Icons.people,
                color: AppTheme.successColor,
                onTap: () => Navigator.pushNamed(context, '/students-list'),
                index: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Secondary actions
        Row(
          children: [
            Expanded(
              child: components.ActionCard(
                title: 'Attendance Records',
                subtitle: 'View attendance history',
                icon: Icons.fact_check,
                color: AppTheme.accentColor,
                onTap: () =>
                    Navigator.pushNamed(context, '/attendance-records'),
                index: 2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: components.ActionCard(
                title: 'Settings',
                subtitle: 'Configure location & users',
                icon: Icons.settings,
                color: Colors.blue,
                onTap: () => _showSettingsMenu(context),
                index: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Settings & Configuration', style: AppTheme.headingSmall),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Location Setup'),
              subtitle: const Text('Configure attendance boundaries'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  OrganizationLocationSetupScreen.routeName,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.orange),
              title: const Text('User Management'),
              subtitle: const Text('Manage organization users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user-management');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.green),
              title: const Text('Analytics & Reports'),
              subtitle: const Text('View detailed reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 72, color: AppTheme.textLight)
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(color: AppTheme.textMedium),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
          const SizedBox(height: 24),
          ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  SessionManagementScreen.routeName,
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 700.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 700.ms),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
