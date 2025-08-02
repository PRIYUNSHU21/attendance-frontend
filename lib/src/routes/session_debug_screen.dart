import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/session.dart';

class SessionDebugScreen extends StatefulWidget {
  static const String routeName = '/session-debug';
  const SessionDebugScreen({super.key});

  @override
  State<SessionDebugScreen> createState() => _SessionDebugScreenState();
}

class _SessionDebugScreenState extends State<SessionDebugScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);

    // Load both admin sessions and student active sessions
    if (auth.user?.role == 'admin' || auth.user?.role == 'teacher') {
      admin.fetchSessions();
    }
    attendance.fetchActiveSessions();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final admin = Provider.of<AdminProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Debug Info'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current User Info',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Name', auth.user?.name ?? 'Unknown'),
                    _buildInfoRow('Email', auth.user?.email ?? 'Unknown'),
                    _buildInfoRow('Role', auth.user?.role ?? 'Unknown'),
                    _buildInfoRow(
                      'Organization ID',
                      auth.user?.orgId ?? 'Unknown',
                    ),
                    _buildInfoRow('User ID', auth.user?.userId ?? 'Unknown'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Admin/Teacher Sessions Section
            if (auth.user?.role == 'admin' || auth.user?.role == 'teacher') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin/Teacher Sessions (${admin.sessions.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (admin.loading)
                        const Center(child: CircularProgressIndicator())
                      else if (admin.error != null)
                        Text(
                          'Error: ${admin.error}',
                          style: const TextStyle(color: Colors.red),
                        )
                      else if (admin.sessions.isEmpty)
                        const Text(
                          'No sessions found',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...admin.sessions.map(
                          (session) =>
                              _buildSessionCard(session, 'Admin/Teacher'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Student Active Sessions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Active Sessions (${attendance.activeSessions.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (attendance.loading)
                      const Center(child: CircularProgressIndicator())
                    else if (attendance.error != null)
                      Text(
                        'Error: ${attendance.error}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (attendance.activeSessions.isEmpty)
                      const Text(
                        'No active sessions found',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ...attendance.activeSessions.map(
                        (session) => _buildSessionCard(session, 'Student'),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loadData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Refresh All Data'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _testCreateSession(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create Test Session'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Session session, String source) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.sessionName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: source == 'Student' ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  source,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Session ID', session.sessionId),
          _buildInfoRow(
            'Description',
            session.description.isEmpty
                ? 'No description'
                : session.description,
          ),
          _buildInfoRow('Start Time', session.startTime.toString()),
          _buildInfoRow('End Time', session.endTime.toString()),
          _buildInfoRow('Is Active', session.isActive ? 'Yes' : 'No'),
          _buildInfoRow('Organization ID', session.orgId ?? 'Not specified'),
          _buildInfoRow('Created By', session.createdBy ?? 'Not specified'),
          _buildInfoRow(
            'Location',
            '${session.locationLat}, ${session.locationLon} (${session.locationRadius}m)',
          ),
        ],
      ),
    );
  }

  void _testCreateSession(BuildContext context) async {
    final admin = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Test Session'),
        content: const Text(
          'This will create a test session that should be visible to students in your organization.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final now = DateTime.now();
              final success = await admin.createSession(
                sessionName: 'Test Session ${now.millisecondsSinceEpoch}',
                description: 'Auto-generated test session for debugging',
                startTime: now,
                endTime: now.add(const Duration(hours: 2)),
                locationLat: 0.0,
                locationLon: 0.0,
                locationRadius: 100.0,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test session created! Refreshing data...'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create session: ${admin.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
