import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance.dart';

class AnalyticsScreen extends StatefulWidget {
  static const String routeName = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
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
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Sessions', icon: Icon(Icons.event)),
            Tab(text: 'Attendance', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSessionsTab(),
          _buildAttendanceTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<AdminProvider, AttendanceProvider>(
      builder: (context, adminProvider, attendanceProvider, child) {
        final totalSessions = adminProvider.sessions.length;
        final activeSessions = adminProvider.sessions
            .where((s) => s.isActive)
            .length;
        final completedSessions = adminProvider.sessions
            .where((s) => !s.isActive)
            .length;
        final totalAttendance = attendanceProvider.history.length;

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewCards(
                  totalSessions,
                  activeSessions,
                  completedSessions,
                  totalAttendance,
                ),
                const SizedBox(height: 24),
                Text(
                  'Session Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildSessionPieChart(activeSessions, completedSessions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(
    int totalSessions,
    int activeSessions,
    int completedSessions,
    int totalAttendance,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildInfoCard(
          'Total Sessions',
          totalSessions.toString(),
          Icons.event,
          Colors.blue,
        ),
        _buildInfoCard(
          'Total Attendance',
          totalAttendance.toString(),
          Icons.people,
          Colors.green,
        ),
        _buildInfoCard(
          'Active Sessions',
          activeSessions.toString(),
          Icons.play_circle_fill,
          Colors.orange,
        ),
        _buildInfoCard(
          'Completed Sessions',
          completedSessions.toString(),
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionPieChart(int active, int completed) {
    final total = active + completed;
    final activePercent = total > 0 ? (active / total * 100).round() : 0;
    final completedPercent = total > 0 ? (completed / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: active / (total > 0 ? total : 1),
                            backgroundColor: Colors.grey[300],
                            color: Colors.orange,
                            strokeWidth: 12,
                          ),
                          Text(
                            '$activePercent%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('$active sessions'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: completed / (total > 0 ? total : 1),
                            backgroundColor: Colors.grey[300],
                            color: Colors.purple,
                            strokeWidth: 12,
                          ),
                          Text(
                            '$completedPercent%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('$completed sessions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.sessions.isEmpty) {
          return const Center(child: Text('No sessions found.'));
        }
        return ListView.builder(
          itemCount: adminProvider.sessions.length,
          itemBuilder: (context, index) {
            final session = adminProvider.sessions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  session.isActive ? Icons.play_arrow : Icons.check,
                  color: session.isActive ? Colors.green : Colors.grey,
                ),
                title: Text(session.sessionName),
                subtitle: Text(
                  '${session.description} - ${session.startTime.toLocal()}',
                ),
                trailing: Text('ID: ${session.sessionId.substring(0, 8)}...'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        if (attendanceProvider.history.isEmpty) {
          return const Center(child: Text('No attendance records found.'));
        }
        return Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Attendance History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 1,
              child: _buildAttendanceBarChart(attendanceProvider.history),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: attendanceProvider.history.length,
                itemBuilder: (context, index) {
                  final record = attendanceProvider.history[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.person_pin_circle),
                      title: Text('Session ID: ${record.sessionId}'),
                      subtitle: Text('User ID: ${record.userId}'),
                      trailing: Text(record.checkInTime.toLocal().toString()),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceBarChart(List<AttendanceRecord> records) {
    // Create a simple attendance summary by date
    final Map<String, int> attendanceByDate = {};
    for (var record in records) {
      final date = record.checkInTime.toLocal().toString().substring(0, 10);
      attendanceByDate[date] = (attendanceByDate[date] ?? 0) + 1;
    }

    // If there's no data, return a placeholder
    if (attendanceByDate.isEmpty) {
      return Center(child: Text('No attendance data available'));
    }

    // Create a simple column chart using Container instead
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Attendance Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: attendanceByDate.length,
              itemBuilder: (context, index) {
                final entry = attendanceByDate.entries.elementAt(index);
                final date = entry.key;
                final count = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value:
                            count /
                            (attendanceByDate.values.reduce(
                              (a, b) => a > b ? a : b,
                            )),
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue,
                        minHeight: 16,
                      ),
                      const SizedBox(height: 4),
                      Text('$count check-ins'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
