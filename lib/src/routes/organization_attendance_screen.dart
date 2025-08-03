import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class OrganizationAttendanceScreen extends StatefulWidget {
  static const String routeName = '/organization-attendance';

  const OrganizationAttendanceScreen({super.key});

  @override
  State<OrganizationAttendanceScreen> createState() =>
      _OrganizationAttendanceScreenState();
}

class _OrganizationAttendanceScreenState
    extends State<OrganizationAttendanceScreen> {
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _selectedDate;
  int _limit = 100;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    // Check if user has admin access (ADMIN ONLY for organization-wide data)
    if (auth.user?.role != 'admin') {
      setState(() {
        _error =
            'Access denied. Administrator role required to view organization-wide attendance.';
      });
      return;
    }

    // Get organization ID
    final orgId = auth.user?.orgId;
    if (orgId == null) {
      setState(() {
        _error = 'Organization ID not found. Please contact support.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await attendanceProvider.fetchOrganizationAttendance(
        orgId,
        limit: _limit,
        date: _selectedDate?.toIso8601String().split(
          'T',
        )[0], // Format: YYYY-MM-DD
      );

      setState(() {
        _attendanceRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load attendance data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendanceData();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _loadAttendanceData();
  }

  String _formatDateTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Attendance'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendanceData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header and filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Organization info
                Row(
                  children: [
                    Icon(Icons.business, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organization: ${auth.user?.name ?? 'Unknown'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Role: ${auth.user?.role != null ? auth.user!.role.toUpperCase() : 'Unknown'}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date filter
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate != null
                              ? 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select Date (All)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _clearDateFilter,
                        icon: const Icon(Icons.clear),
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAttendanceData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _attendanceRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedDate != null
                              ? 'No attendance records found for selected date'
                              : 'No attendance records found',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Attendance records will appear here when users mark attendance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceRecords[index];
                      return _buildAttendanceCard(record);
                    },
                  ),
          ),

          // Summary footer
          if (_attendanceRecords.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Records',
                    _attendanceRecords.length.toString(),
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Present',
                    _attendanceRecords
                        .where((r) => r['status'] == 'present')
                        .length
                        .toString(),
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Late',
                    _attendanceRecords
                        .where((r) => r['status'] == 'late')
                        .length
                        .toString(),
                    Colors.orange,
                  ),
                  _buildSummaryItem(
                    'Absent',
                    _attendanceRecords
                        .where((r) => r['status'] == 'absent')
                        .length
                        .toString(),
                    Colors.red,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final status = record['status'] ?? 'unknown';
    final userName = record['user_name'] ?? 'Unknown User';
    final timestamp = record['timestamp'];
    final lastUpdated = record['last_updated'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, color: _getStatusColor(status), size: 12),
                const SizedBox(width: 4),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (timestamp != null)
              Text(
                'Recorded: ${_formatDateTime(timestamp)}',
                style: const TextStyle(fontSize: 12),
              ),
            if (lastUpdated != null && lastUpdated != timestamp)
              Text(
                'Updated: ${_formatDateTime(lastUpdated)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'present'
                  ? Icons.check_circle
                  : status == 'late'
                  ? Icons.schedule
                  : Icons.cancel,
              color: _getStatusColor(status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
