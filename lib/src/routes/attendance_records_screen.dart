import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/admin_provider.dart';
import '../models/session.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/components/animated_cards.dart' as components;

class AttendanceRecordsScreen extends StatefulWidget {
  static const String routeName = '/attendance-records';
  const AttendanceRecordsScreen({super.key});

  @override
  State<AttendanceRecordsScreen> createState() =>
      _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends State<AttendanceRecordsScreen>
    with TickerProviderStateMixin {
  String? selectedSessionId;
  List<Map<String, dynamic>> attendanceRecords = [];
  bool isLoading = false;
  String? error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSessions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSessions() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.fetchSessions();
  }

  Future<void> _loadSessionAttendance(String sessionId) async {
    setState(() {
      isLoading = true;
      error = null;
      selectedSessionId = sessionId;
    });

    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );
      final records = await attendanceProvider.fetchSessionAttendance(
        sessionId,
        includeStudentDetails: true,
      );

      setState(() {
        attendanceRecords = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load attendance records: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadOrganizationAttendance({String? date}) async {
    setState(() {
      isLoading = true;
      error = null;
      selectedSessionId = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      if (auth.user?.orgId == null) {
        throw Exception('No organization found');
      }

      final records = await attendanceProvider.fetchOrganizationAttendance(
        auth.user!.orgId,
        date: date,
        limit: 200,
      );

      setState(() {
        attendanceRecords = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load organization attendance: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CompactAppLogo(size: 28),
            const SizedBox(width: 12),
            const Text(
              'Attendance Records',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.event), text: 'By Session'),
            Tab(icon: Icon(Icons.calendar_today), text: 'All Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSessionTab(adminProvider), _buildAllRecordsTab()],
      ),
    );
  }

  Widget _buildSessionTab(AdminProvider adminProvider) {
    return RefreshIndicator(
      onRefresh: () async => _loadSessions(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Selection
              _buildSessionSelection(adminProvider),
              const SizedBox(height: 20),

              // Attendance Records
              if (selectedSessionId != null) _buildAttendanceRecords(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllRecordsTab() {
    return RefreshIndicator(
      onRefresh: () async => _loadOrganizationAttendance(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Filter
              _buildDateFilter(),
              const SizedBox(height: 20),

              // All Attendance Records
              _buildAttendanceRecords(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSelection(AdminProvider adminProvider) {
    final allSessions = [...adminProvider.sessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Session', style: AppTheme.headingSmall)
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 16),

        if (adminProvider.loading)
          Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
          )
        else if (allSessions.isEmpty)
          _buildEmptyState(
            'No Sessions Found',
            'Create a session to view attendance records',
            Icons.event_note,
          )
        else
          Column(
            children: List.generate(
              allSessions.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSessionCard(allSessions[index], index),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSessionCard(Session session, int index) {
    final now = DateTime.now();
    final isActive =
        now.isAfter(session.startTime) && now.isBefore(session.endTime);

    return components.SessionCard(
      title: session.sessionName,
      description: session.description.isEmpty
          ? 'No description'
          : session.description,
      timeRange:
          '${_formatDate(session.startTime)} • ${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
      isActive: isActive,
      onTap: () => _loadSessionAttendance(session.sessionId),
      index: index,
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter by Date', style: AppTheme.headingSmall)
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _loadOrganizationAttendance(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('All Records'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _loadOrganizationAttendance(
                  date: _formatDateForApi(DateTime.now()),
                ),
                icon: const Icon(Icons.today, size: 16),
                label: const Text('Today'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _selectDate(),
              icon: const Icon(Icons.calendar_month),
              tooltip: 'Select Date',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      _loadOrganizationAttendance(date: _formatDateForApi(selectedDate));
    }
  }

  Widget _buildAttendanceRecords() {
    if (isLoading) {
      return Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
            const SizedBox(height: 16),
            Text(
              'Loading attendance records...',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildErrorState(error!);
    }

    if (attendanceRecords.isEmpty) {
      return _buildEmptyState(
        'No Attendance Records',
        selectedSessionId != null
            ? 'No students have marked attendance for this session yet'
            : 'No attendance records found for the selected criteria',
        Icons.event_available,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Attendance Records (${attendanceRecords.length})',
              style: AppTheme.headingSmall,
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 16),

        Column(
          children: List.generate(
            attendanceRecords.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildAttendanceCard(attendanceRecords[index], index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record, int index) {
    final studentName =
        record['student_name'] ?? record['user_name'] ?? 'Unknown Student';
    final studentEmail = record['student_email'] ?? record['user_email'] ?? '';
    final sessionName = record['session_name'] ?? 'Unknown Session';
    final status = record['status'] ?? 'unknown';
    final markedAt = record['marked_at'] ?? record['created_at'];
    final distance = record['distance'];
    final accuracy = record['accuracy'];

    // Parse marked_at time
    DateTime? markedTime;
    if (markedAt != null) {
      try {
        markedTime = DateTime.parse(markedAt);
      } catch (e) {
        print('Error parsing time: $e');
      }
    }

    // Status color and icon
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.access_time;
        break;
      case 'absent':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.textLight;
        statusIcon = Icons.help;
    }

    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.borderRadiusMedium,
            boxShadow: AppTheme.cardShadow,
            border: Border(left: BorderSide(width: 4, color: statusColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Text(
                      studentName.isNotEmpty
                          ? studentName.substring(0, 1).toUpperCase()
                          : 'S',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (studentEmail.isNotEmpty)
                          Text(
                            studentEmail,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textLight,
                            ),
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadiusSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Session and Time Info
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: AppTheme.textLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sessionName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ),
                  if (markedTime != null) ...[
                    Icon(Icons.schedule, size: 16, color: AppTheme.textLight),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(markedTime)} ${_formatTime(markedTime)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ],
              ),

              // Location Info (if available)
              if (distance != null || accuracy != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 6),
                    if (distance != null)
                      Text(
                        'Distance: ${distance.toStringAsFixed(1)}m',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    if (distance != null && accuracy != null)
                      Text(
                        ' • ',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    if (accuracy != null)
                      Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}m',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 50).ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 50).ms);
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

  Widget _buildErrorState(String errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error, size: 72, color: AppTheme.errorColor)
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
            'Error Loading Records',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.errorColor),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (selectedSessionId != null) {
                _loadSessionAttendance(selectedSessionId!);
              } else {
                _loadOrganizationAttendance();
              }
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
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

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
