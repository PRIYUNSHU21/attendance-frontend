import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/session.dart';
import '../utils/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  static const String routeName = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'Last 7 Days';
  final List<String> _timeframes = [
    'Last 7 Days',
    'Last 30 Days',
    'This Month',
    'All Time',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Use post frame callback to avoid build-time setState calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    adminProvider.fetchSessions();
    attendanceProvider.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTimeframe,
                dropdownColor: AppTheme.primaryColor.withOpacity(0.95),
                style: TextStyle(color: Colors.white, fontSize: 14),
                icon: Icon(Icons.access_time, color: Colors.white, size: 20),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTimeframe = newValue;
                    });
                  }
                },
                items: _timeframes.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.school), text: 'Sessions'),
            Tab(icon: Icon(Icons.people), text: 'Attendance'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildSessionsTab(),
            _buildAttendanceTab(),
            _buildTrendsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<AdminProvider, AttendanceProvider>(
      builder: (context, adminProvider, attendanceProvider, child) {
        final totalSessions = adminProvider.sessions.length;
        final now = DateTime.now();

        // Properly classify sessions based on current time and isActive flag
        final activeSessions = adminProvider.sessions
            .where((s) => s.isActive && s.endTime.isAfter(now))
            .length;
        final completedSessions = adminProvider.sessions
            .where((s) => !s.isActive || s.endTime.isBefore(now))
            .length;
        final totalAttendance = attendanceProvider.history.length;

        // Calculate attendance rate based on actual data
        final attendanceRate = totalSessions > 0 && totalAttendance > 0
            ? (totalAttendance / totalSessions) *
                  10 // More realistic calculation
            : 0.0;

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Header
                Text(
                  'Quick Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(),
                Text(
                  'Real-time insights into your attendance system',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ).animate().fadeIn(duration: 800.ms).slideX(delay: 200.ms),

                const SizedBox(height: 24),

                // Enhanced Overview Cards
                _buildEnhancedOverviewCards(
                  totalSessions,
                  activeSessions,
                  completedSessions,
                  totalAttendance,
                  attendanceRate,
                ),

                const SizedBox(height: 32),

                // Charts Section
                Text(
                  'Visual Analytics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(delay: 400.ms),

                const SizedBox(height: 16),

                // Session Status Chart
                _buildSessionStatusChart(activeSessions, completedSessions),

                const SizedBox(height: 24),

                // Attendance Rate Chart
                _buildAttendanceRateChart(attendanceRate),

                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivity(adminProvider, attendanceProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedOverviewCards(
    int totalSessions,
    int activeSessions,
    int completedSessions,
    int totalAttendance,
    double attendanceRate,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 2.2,
      children: [
        _buildEnhancedInfoCard(
          'Total Sessions',
          totalSessions.toString(),
          Icons.school,
          AppTheme.primaryColor,
          '${activeSessions} active',
          Icons.circle,
          Colors.green,
        ).animate().fadeIn(duration: 600.ms).scale(delay: 100.ms),

        _buildEnhancedInfoCard(
          'Total Attendance',
          totalAttendance.toString(),
          Icons.people,
          Colors.orange,
          'Across all sessions',
          Icons.trending_up,
          Colors.blue,
        ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),

        _buildEnhancedInfoCard(
          'Attendance Rate',
          '${attendanceRate.toStringAsFixed(1)}%',
          Icons.analytics,
          Colors.green,
          _getAttendanceStatus(attendanceRate),
          _getAttendanceIcon(attendanceRate),
          _getAttendanceColor(attendanceRate),
        ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),

        _buildEnhancedInfoCard(
          'Completed Sessions',
          completedSessions.toString(),
          Icons.check_circle,
          Colors.purple,
          'Out of $totalSessions total',
          Icons.history,
          Colors.grey,
        ).animate().fadeIn(duration: 600.ms).scale(delay: 400.ms),
      ],
    );
  }

  Widget _buildSessionsTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sessions found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first session to see analytics',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final activeSessions = adminProvider.sessions
            .where((s) => s.isActive)
            .toList();
        final completedSessions = adminProvider.sessions
            .where((s) => !s.isActive)
            .toList();

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Summary Cards
                Text(
                  'Session Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(),

                SizedBox(height: 16),

                _buildSessionSummaryCards(
                  activeSessions.length,
                  completedSessions.length,
                ),

                SizedBox(height: 32),

                // Active Sessions
                if (activeSessions.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.play_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Active Sessions (${activeSessions.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideX(delay: 200.ms),

                  SizedBox(height: 16),

                  ...activeSessions.asMap().entries.map((entry) {
                    final session = entry.value;
                    final index = entry.key;
                    return _buildEnhancedSessionCard(session, true, index);
                  }).toList(),

                  SizedBox(height: 24),
                ],

                // Completed Sessions
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Recent Completed Sessions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideX(delay: 400.ms),

                SizedBox(height: 16),

                ...completedSessions.take(5).toList().asMap().entries.map((
                  entry,
                ) {
                  final session = entry.value;
                  final index = entry.key;
                  return _buildEnhancedSessionCard(session, false, index);
                }).toList(),

                if (completedSessions.length > 5) ...[
                  SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // Show all sessions dialog or navigate to full list
                      },
                      icon: Icon(Icons.visibility),
                      label: Text(
                        'View All ${completedSessions.length} Sessions',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionSummaryCards(int activeCount, int completedCount) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.green.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.play_circle, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  '$activeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Active Sessions',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.orange.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  '$completedCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Completed',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).scale(delay: 400.ms),
        ),
      ],
    );
  }

  Widget _buildEnhancedSessionCard(Session session, bool isActive, int index) {
    final duration = session.endTime.difference(session.startTime);
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isActive ? Icons.play_circle : Icons.check_circle,
                    color: isActive ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.sessionName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        session.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'LIVE' : 'DONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildSessionInfoChip(
                  Icons.access_time,
                  durationText,
                  Colors.blue,
                ),
                SizedBox(width: 8),
                _buildSessionInfoChip(
                  Icons.calendar_today,
                  _formatDate(session.startTime),
                  Colors.purple,
                ),
                SizedBox(width: 8),
                if (session.hasValidLocation)
                  _buildSessionInfoChip(
                    Icons.location_on,
                    'Location Set',
                    Colors.green,
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Session ID: ${session.sessionId.substring(0, 8)}...',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(delay: (500 + index * 100).ms);
  }

  Widget _buildSessionInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildAttendanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Attendance Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text(
            'This section is under development.\nWe\'re working to bring you comprehensive attendance analytics.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Enhanced Info Card Widget
  Widget _buildEnhancedInfoCard(
    String title,
    String value,
    IconData icon,
    Color primaryColor,
    String subtitle,
    IconData subtitleIcon,
    Color subtitleColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: primaryColor, size: 14),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 12),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(subtitleIcon, size: 10, color: subtitleColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 8, color: subtitleColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Attendance Helper Methods
  String _getAttendanceStatus(double rate) {
    if (rate >= 80) return 'Excellent';
    if (rate >= 70) return 'Good';
    if (rate >= 60) return 'Average';
    return 'Needs attention';
  }

  IconData _getAttendanceIcon(double rate) {
    if (rate >= 80) return Icons.star;
    if (rate >= 70) return Icons.thumb_up;
    if (rate >= 60) return Icons.trending_flat;
    return Icons.warning;
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 70) return Colors.blue;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  // Enhanced Session Status Chart
  Widget _buildSessionStatusChart(int activeSessions, int completedSessions) {
    if (activeSessions == 0 && completedSessions == 0) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No session data available'),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Session Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: activeSessions.toDouble(),
                          title: '${activeSessions}',
                          radius: 40,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: completedSessions.toDouble(),
                          title: '${completedSessions}',
                          radius: 40,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Active', Colors.green, activeSessions),
                      SizedBox(height: 8),
                      _buildLegendItem(
                        'Completed',
                        Colors.orange,
                        completedSessions,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 600.ms);
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Attendance Rate Chart
  Widget _buildAttendanceRateChart(double attendanceRate) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Attendance Rate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '${attendanceRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getAttendanceColor(attendanceRate),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: attendanceRate / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getAttendanceColor(attendanceRate),
                            _getAttendanceColor(
                              attendanceRate,
                            ).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _getAttendanceStatus(attendanceRate),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: TextStyle(color: Colors.grey)),
              Text('50%', style: TextStyle(color: Colors.grey)),
              Text('100%', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(delay: 800.ms);
  }

  // Recent Activity Widget
  Widget _buildRecentActivity(
    AdminProvider adminProvider,
    AttendanceProvider attendanceProvider,
  ) {
    final recentSessions = adminProvider.sessions.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (recentSessions.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No recent sessions',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentSessions.asMap().entries.map((entry) {
              final session = entry.value;
              final index = entry.key;
              return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          width: 4,
                          color: session.isActive
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          session.isActive
                              ? Icons.play_circle
                              : Icons.check_circle,
                          color: session.isActive
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.sessionName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                session.isActive
                                    ? 'Currently Active'
                                    : 'Completed',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          session.isActive ? 'LIVE' : 'DONE',
                          style: TextStyle(
                            color: session.isActive
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(delay: (1000 + index * 200).ms);
            }).toList(),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(delay: 1000.ms);
  }

  // New Trends Tab
  Widget _buildTrendsTab() {
    return Consumer2<AdminProvider, AttendanceProvider>(
      builder: (context, adminProvider, attendanceProvider, child) {
        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Trends',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(),

                Text(
                  'Track attendance patterns over time',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ).animate().fadeIn(duration: 800.ms).slideX(delay: 200.ms),

                const SizedBox(height: 24),

                _buildTrendChart(attendanceProvider),

                const SizedBox(height: 24),

                _buildTrendInsights(adminProvider, attendanceProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendChart(AttendanceProvider attendanceProvider) {
    // Create sample trend data (you can replace this with real data)
    final trendData = _generateTrendData(attendanceProvider);

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Weekly Attendance Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        if (value.toInt() < days.length) {
                          return Text(days[value.toInt()]);
                        }
                        return Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: trendData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, Colors.blue],
                    ),
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.3),
                          Colors.blue.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 600.ms);
  }

  List<FlSpot> _generateTrendData(AttendanceProvider attendanceProvider) {
    // Generate sample data - replace with real data processing
    return [
      FlSpot(0, 85),
      FlSpot(1, 78),
      FlSpot(2, 92),
      FlSpot(3, 88),
      FlSpot(4, 95),
      FlSpot(5, 73),
      FlSpot(6, 81),
    ];
  }

  Widget _buildTrendInsights(
    AdminProvider adminProvider,
    AttendanceProvider attendanceProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildInsightItem(
            Icons.trending_up,
            'Peak Day',
            'Friday shows highest attendance',
            Colors.green,
          ),
          _buildInsightItem(
            Icons.trending_down,
            'Low Day',
            'Saturday needs attention',
            Colors.orange,
          ),
          _buildInsightItem(
            Icons.insights,
            'Recommendation',
            'Focus on weekend engagement strategies',
            Colors.blue,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(delay: 1000.ms);
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Attendance Helper Methods
}
