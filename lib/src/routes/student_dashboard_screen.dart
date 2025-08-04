import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import 'student_attendance_screen.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  static const String routeName = '/student-dashboard';
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    attendanceProvider.fetchActiveSessions();
    attendanceProvider.fetchHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CompactAppLogo(size: 28),
            const SizedBox(width: 12),
            const Text('Student Dashboard'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.schedule), text: 'Sessions'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(user, attendance),
          // Sessions Tab
          _buildSessionsTab(attendance),
          // History Tab
          _buildHistoryTab(attendance),
          // Profile Tab
          _buildProfileTab(user, auth),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(user, AttendanceProvider attendance) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? 'Student',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Stats
          Text(
            'Quick Stats',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Sessions',
                  '${attendance.activeSessions.length}',
                  Icons.schedule,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Attended',
                  '${attendance.history.length}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  '${_getThisWeekAttendance(attendance.history)}',
                  Icons.calendar_today,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Attendance Rate',
                  '${_calculateAttendanceRate(attendance.history)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildQuickActionCard(
            'Mark Attendance',
            'Check in to active sessions',
            Icons.check_circle_outline,
            Colors.green,
            () =>
                Navigator.pushNamed(context, StudentAttendanceScreen.routeName),
          ),

          const SizedBox(height: 12),

          _buildQuickActionCard(
            'View History',
            'See your attendance records',
            Icons.history,
            Colors.blue,
            () => Navigator.pushNamed(context, AttendanceScreen.routeName),
          ),

          const SizedBox(height: 24),

          // Recent Sessions
          if (attendance.activeSessions.isNotEmpty) ...[
            Text(
              'Current Active Sessions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...attendance.activeSessions
                .take(3)
                .map((session) => _buildSessionPreviewCard(session)),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsTab(AttendanceProvider attendance) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.indigo.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Sessions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Active and recent sessions',
                style: TextStyle(color: Colors.indigo.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: attendance.loading
              ? const Center(child: CircularProgressIndicator())
              : (attendance.activeSessions.isEmpty &&
                    attendance.pastSessions.isEmpty)
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Sessions Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for new sessions',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => attendance.fetchActiveSessions(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        attendance.activeSessions.length +
                        attendance.pastSessions.length,
                    itemBuilder: (context, index) {
                      if (index < attendance.activeSessions.length) {
                        // Show active sessions first
                        final session = attendance.activeSessions[index];
                        return _buildDetailedSessionCard(session);
                      } else {
                        // Show past sessions after active ones
                        final pastIndex =
                            index - attendance.activeSessions.length;
                        final session = attendance.pastSessions[pastIndex];
                        return _buildDetailedSessionCard(session, isPast: true);
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(AttendanceProvider attendance) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your past attendance records',
                style: TextStyle(color: Colors.blue.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: attendance.loading
              ? const Center(child: CircularProgressIndicator())
              : attendance.history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No History Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your attendance records will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => attendance.fetchHistory(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: attendance.history.length,
                    itemBuilder: (context, index) {
                      final record = attendance.history[index];
                      return _buildHistoryCard(record);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(user, AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Profile Details
          _buildProfileSection('Personal Information', [
            _buildProfileItem('Name', user?.name ?? 'N/A'),
            _buildProfileItem('Email', user?.email ?? 'N/A'),
            _buildProfileItem('Role', user?.role ?? 'N/A'),
            _buildProfileItem('User ID', user?.userId ?? 'N/A'),
            _buildProfileItem('Organization', user?.orgId ?? 'N/A'),
          ]),

          const SizedBox(height: 24),

          // Settings
          _buildProfileSection('Settings', [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification settings
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location Services'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement location settings
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement theme settings
                },
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Actions
          _buildProfileSection('Actions', [
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Refresh Data'),
              onTap: () {
                final attendance = Provider.of<AttendanceProvider>(
                  context,
                  listen: false,
                );
                attendance.fetchActiveSessions();
                attendance.fetchHistory();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Data refreshed')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.green),
              title: const Text('Help & Support'),
              onTap: () {
                // TODO: Navigate to help screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                await auth.logout();
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSessionPreviewCard(session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.schedule, color: Colors.blue),
        ),
        title: Text(session.sessionName),
        subtitle: Text(
          '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () =>
            Navigator.pushNamed(context, StudentAttendanceScreen.routeName),
      ),
    );
  }

  Widget _buildDetailedSessionCard(session, {bool isPast = false}) {
    final now = DateTime.now();
    final isLate = now.isAfter(
      session.startTime.add(const Duration(minutes: 15)),
    );
    final isExpired = isPast || now.isAfter(session.endTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.sessionName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.description.isNotEmpty
                            ? session.description
                            : 'No description',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLate && !isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LATE',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ENDED',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Within ${session.locationRadius}m radius',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isExpired
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        StudentAttendanceScreen.routeName,
                      ),
                icon: Icon(
                  isExpired ? Icons.history : Icons.check_circle_outline,
                ),
                label: Text(isExpired ? 'Session Ended' : 'Mark Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpired
                      ? Colors.grey
                      : (isLate ? Colors.orange : Colors.green),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(AttendanceRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.check_circle, color: Colors.green),
        ),
        title: Text('Session: ${record.sessionId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Checked in: ${_formatDateTime(record.checkInTime)}'),
            Text('Status: ${record.status}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return ListTile(title: Text(label), subtitle: Text(value), dense: true);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  int _getThisWeekAttendance(List<AttendanceRecord> history) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return history
        .where((record) => record.checkInTime.isAfter(weekStart))
        .length;
  }

  int _calculateAttendanceRate(List<AttendanceRecord> history) {
    if (history.isEmpty) return 0;
    // Simple calculation - in real app you'd compare with total possible sessions
    return ((history.length / (history.length + 2)) * 100).round();
  }
}
