import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/session.dart';

class StudentAttendanceScreen extends StatefulWidget {
  static const String routeName = '/student-attendance';
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AttendanceProvider>(
      context,
      listen: false,
    ).fetchActiveSessions();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = Provider.of<AttendanceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header card with user info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${auth.user?.name ?? 'Student'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a session to mark your attendance',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Active sessions list
          Expanded(
            child: attendance.loading
                ? const Center(child: CircularProgressIndicator())
                : attendance.error != null
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
                          'Error: ${attendance.error}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => attendance.fetchActiveSessions(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : attendance.activeSessions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No Active Sessions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'There are no active sessions available for attendance.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => attendance.fetchActiveSessions(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: attendance.activeSessions.length,
                      itemBuilder: (context, index) {
                        final session = attendance.activeSessions[index];
                        return SessionCard(session: session);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final Session session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final startTime = session.startTime;
    final endTime = session.endTime;
    final now = DateTime.now();
    final isLate = now.isAfter(
      startTime.add(const Duration(minutes: 15)),
    ); // 15 min grace period

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
                if (isLate)
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
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
                onPressed: () => _showCheckInDialog(context, session),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLate ? Colors.orange : Colors.green,
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showCheckInDialog(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => CheckInDialog(session: session),
    );
  }
}

class CheckInDialog extends StatefulWidget {
  final Session session;

  const CheckInDialog({super.key, required this.session});

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  bool _loading = false;
  double? _lat;
  double? _lon;
  String? _locationStatus;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
      _locationStatus = 'Getting your location...';
    });

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus =
              'Location services disabled. Please enable location.';
          _loading = false;
        });
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus =
                'Location permission denied. Please allow location access.';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus =
              'Location permission permanently denied. Please enable in settings.';
          _loading = false;
        });
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Calculate distance from session location
      double sessionLat = widget.session.locationLat;
      double sessionLon = widget.session.locationLon;
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        sessionLat,
        sessionLon,
      );

      double radius = widget.session.locationRadius;
      bool withinRange = distance <= radius;

      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
        _locationStatus = withinRange
            ? '✅ You are within range (${distance.round()}m from session)'
            : '❌ You are ${distance.round()}m away (max ${radius.round()}m)';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
        _loading = false;
      });
    }
  }

  Future<void> _checkIn() async {
    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available. Please try again.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final attendance = Provider.of<AttendanceProvider>(context, listen: false);
    final success = await attendance.checkIn(
      widget.session.sessionId,
      _lat!,
      _lon!,
    );

    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Attendance marked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh the sessions list
      attendance.fetchActiveSessions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${attendance.error ?? "Failed to mark attendance"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark Attendance'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.session.sessionName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Location status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (_loading)
                  const CircularProgressIndicator()
                else
                  Icon(
                    _locationStatus?.contains('✅') == true
                        ? Icons.check_circle
                        : Icons.location_on,
                    color: _locationStatus?.contains('✅') == true
                        ? Colors.green
                        : Colors.blue,
                    size: 32,
                  ),
                const SizedBox(height: 8),
                Text(
                  _locationStatus ?? 'Checking location...',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          if (_lat != null && _lon != null) ...[
            const SizedBox(height: 12),
            Text(
              'Your location: ${_lat!.toStringAsFixed(6)}, ${_lon!.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading || _lat == null || _lon == null ? null : _checkIn,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Check In'),
        ),
      ],
    );
  }
}
