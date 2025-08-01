import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/session.dart';
import '../models/attendance.dart';
import '../utils/app_theme.dart';
import '../widgets/components/animated_cards.dart' as components;
import 'student_attendance_screen.dart';
import 'attendance_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  static const String routeName = '/student-dashboard';
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    attendanceProvider.fetchActiveSessions();
    attendanceProvider.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Dashboard',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
                            Navigator.pop(context);
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

                // Attendance Stats
                _buildAttendanceStats(attendanceProvider),
                const SizedBox(height: 20),

                // Active Sessions
                _buildActiveSessionsSection(attendanceProvider),
                const SizedBox(height: 20),

                // Recent Attendance
                _buildRecentAttendance(attendanceProvider),
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
                          : 'S',
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
                          'Hello,',
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
                          auth.user?.name ?? 'Student',
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
                'Track your attendance and stay updated',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats(AttendanceProvider attendanceProvider) {
    final totalAttendance = attendanceProvider.history.length;
    final presentCount = attendanceProvider.history
        .where((a) => a.status == 'present')
        .length;
    final lateCount = attendanceProvider.history
        .where((a) => a.status == 'late')
        .length;
    final absentCount = attendanceProvider.history
        .where((a) => a.status == 'absent')
        .length;

    final attendanceRate = totalAttendance > 0
        ? (presentCount + lateCount) / totalAttendance
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Overview', style: AppTheme.headingSmall)
            .animate()
            .fadeIn(duration: 400.ms, delay: 250.ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 250.ms),

        const SizedBox(height: 16),

        // Attendance Rate Card
        components.GradientCard(
          gradient: LinearGradient(
            colors: [
              attendanceRate >= 0.8
                  ? AppTheme.successColor.withOpacity(0.8)
                  : attendanceRate >= 0.6
                  ? AppTheme.warningColor.withOpacity(0.8)
                  : AppTheme.errorColor.withOpacity(0.8),
              attendanceRate >= 0.8
                  ? AppTheme.successColor
                  : attendanceRate >= 0.6
                  ? AppTheme.warningColor
                  : AppTheme.errorColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            children: [
              Text(
                'Attendance Rate',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                    '${(attendanceRate * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    duration: 3.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: AppTheme.borderRadiusFull,
                child: LinearProgressIndicator(
                  value: attendanceRate,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stats Row
        Row(
          children: [
            Expanded(
              child: components.StatsCard(
                title: 'Present',
                value: presentCount.toString(),
                icon: Icons.check_circle,
                color: AppTheme.successColor,
                index: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: components.StatsCard(
                title: 'Late',
                value: lateCount.toString(),
                icon: Icons.access_time,
                color: AppTheme.warningColor,
                index: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: components.StatsCard(
                title: 'Absent',
                value: absentCount.toString(),
                icon: Icons.cancel,
                color: AppTheme.errorColor,
                index: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveSessionsSection(AttendanceProvider attendanceProvider) {
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

            if (attendanceProvider.activeSessions.isNotEmpty)
              ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      StudentAttendanceScreen.routeName,
                    ),
                    icon: const Icon(Icons.assignment_turned_in, size: 18),
                    label: const Text('Mark Attendance'),
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
            'Check back later for new sessions',
            Icons.event_busy,
          )
        else
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attendanceProvider.activeSessions.length,
              itemBuilder: (context, index) {
                final session = attendanceProvider.activeSessions[index];
                return _buildActiveSessionCard(session, index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActiveSessionCard(Session session, [int index = 0]) {
    final now = DateTime.now();
    final isLate = now.isAfter(
      session.startTime.add(const Duration(minutes: 15)),
    );

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: components.AnimatedCard(
        borderRadius: AppTheme.borderRadiusLarge,
        index: index,
        boxShadow: AppTheme.cardShadowLarge,
        gradient: LinearGradient(
          colors: isLate
              ? [AppTheme.warningColor.withOpacity(0.7), AppTheme.warningColor]
              : [AppTheme.primaryColor.withOpacity(0.7), AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: AppTheme.borderRadiusMedium,
                      ),
                      child: Icon(Icons.event, color: Colors.white, size: 24),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: 2.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session.sessionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLate)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppTheme.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
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
                        const SizedBox(width: 4),
                        const Text(
                          'LATE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.description.isNotEmpty
                  ? session.description
                  : 'No description',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusSmall,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  StudentAttendanceScreen.routeName,
                ),
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('Mark Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isLate
                      ? AppTheme.warningColor
                      : AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAttendance(AttendanceProvider attendanceProvider) {
    final recentAttendance = attendanceProvider.history.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Attendance', style: AppTheme.headingSmall)
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 250.ms),

            TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AttendanceScreen.routeName),
                  icon: const Icon(Icons.history),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 300.ms),
          ],
        ),
        const SizedBox(height: 16),
        if (attendanceProvider.loading)
          Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
          )
        else if (recentAttendance.isEmpty)
          _buildEmptyState(
            'No attendance records',
            'Mark your first attendance to see history',
            Icons.history,
          )
        else
          Column(
            children: List.generate(
              recentAttendance.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRecentAttendanceCard(
                  recentAttendance[index],
                  index,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentAttendanceCard(AttendanceRecord record, [int index = 0]) {
    final isPresent = record.status == 'present';
    final isLate = record.status == 'late';
    final color = isPresent
        ? AppTheme.successColor
        : isLate
        ? AppTheme.warningColor
        : AppTheme.errorColor;
    final icon = isPresent
        ? Icons.check_circle
        : isLate
        ? Icons.access_time
        : Icons.cancel;

    return components.AnimatedCard(
      index: index,
      borderRadius: AppTheme.borderRadiusMedium,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppTheme.borderRadiusMedium,
          ),
          child: Icon(icon, color: color, size: 24)
              .animate(onPlay: (controller) => controller.loop(count: 1))
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
        ),
        title: Text('Session: ${record.sessionId}', style: AppTheme.labelLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Check-in: ${_formatDateTime(record.checkInTime)}',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusFull,
              ),
              child: Text(
                record.status.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textLight,
          size: 16,
        ),
      ),
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
        Row(
          children: [
            Expanded(
              child: components.ActionCard(
                title: 'Mark Attendance',
                subtitle: 'Check-in to active sessions',
                icon: Icons.assignment_turned_in,
                color: AppTheme.primaryColor,
                onTap: () => Navigator.pushNamed(
                  context,
                  StudentAttendanceScreen.routeName,
                ),
                index: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: components.ActionCard(
                title: 'View History',
                subtitle: 'Check attendance records',
                icon: Icons.history,
                color: AppTheme.secondaryColor,
                onTap: () =>
                    Navigator.pushNamed(context, AttendanceScreen.routeName),
                index: 1,
              ),
            ),
          ],
        ),
      ],
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

  String _formatDateTime(DateTime time) {
    return '${_formatDate(time)} ${_formatTime(time)}';
  }
}
