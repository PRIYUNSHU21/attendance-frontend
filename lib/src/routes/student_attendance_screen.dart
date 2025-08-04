import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/session.dart';
import '../utils/app_theme.dart';

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
        backgroundColor: AppTheme.primaryColor,
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
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
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
            Row(
              children: [
                Expanded(
                  flex: 2,
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
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () => _showSessionDetails(context, session),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
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

  void _showSessionDetails(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => SessionDetailsDialog(session: session),
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
  double? _altitude;
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

      // Get position with more specific settings
      print('🔍 Attempting to get current position...');
      print('   Desired accuracy: HIGH');
      print('   Timeout: 15 seconds');

      Position position;
      try {
        // First try: High accuracy with longer timeout
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30), // Increased timeout
          forceAndroidLocationManager: false,
        );

        // Check if accuracy is acceptable (within 100m)
        if (position.accuracy > 100) {
          print('⚠️ Low accuracy (${position.accuracy}m), trying again...');
          throw Exception('Accuracy too low: ${position.accuracy}m');
        }
      } catch (timeoutError) {
        print('⏱️ High accuracy failed: $timeoutError');
        print('🔄 Trying best accuracy...');

        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: const Duration(seconds: 20),
          );
        } catch (bestError) {
          print('⏱️ Best accuracy failed: $bestError');
          print('🔄 Trying medium accuracy as last resort...');

          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        }
      }

      print('📍 Raw position received:');
      print('   Latitude: ${position.latitude}');
      print('   Longitude: ${position.longitude}');
      print('   Accuracy: ${position.accuracy}m');
      print('   Altitude: ${position.altitude}');
      print('   Timestamp: ${position.timestamp}');

      // Calculate distance from session location
      double sessionLat = widget.session.locationLat;
      double sessionLon = widget.session.locationLon;

      // Debug: Print session coordinates
      print('🔍 Session coordinates: ($sessionLat, $sessionLon)');
      print(
        '📍 User coordinates: (${position.latitude}, ${position.longitude})',
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        sessionLat,
        sessionLon,
      );

      print('📏 Calculated distance: ${distance}m');

      double radius = widget.session.locationRadius;
      bool withinRange = distance <= radius;

      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
        _altitude = position.altitude;

        // Check if we got approximate/IP-based location (indicating a location accuracy issue)
        bool isApproximateLocation =
            position.accuracy > 100 ||
            ((position.latitude > 22.5 && position.latitude < 22.7) &&
                (position.longitude > 88.3 && position.longitude < 88.4));

        if (isApproximateLocation) {
          print('⚠️ WARNING: Location appears to be approximate/IP-based!');
          print('   Accuracy: ${position.accuracy}m (should be <100m for GPS)');
          print('   Coordinates: ${position.latitude}, ${position.longitude}');
          print(
            '   This indicates browser is using WiFi/IP location instead of GPS',
          );

          _locationStatus =
              '⚠️ Using approximate location (${position.accuracy.round()}m accuracy). '
              'For better accuracy, enable precise location in browser settings.';
        } else {
          _locationStatus = withinRange
              ? '✅ You are within range (${distance.round()}m from session)'
              : '❌ You are ${distance.round()}m away (max ${radius.round()}m)';
        }

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
        _loading = false;
      });
    }
  }

  Future<void> _requestLocationForAttendance() async {
    setState(() {
      _loading = true;
      _locationStatus = 'Requesting location permission for attendance...';
    });

    try {
      // Always check location services first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus =
              'Location services disabled. Please enable location services in your browser.';
          _loading = false;
        });

        // Show user dialog to enable location
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Services Required'),
              content: const Text(
                'Location services are disabled. Please enable location access in your browser to mark attendance.\n\n'
                '1. Click the location icon in your browser\'s address bar\n'
                '2. Select "Always allow" for this site\n'
                '3. Refresh the page if needed',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Always request permission explicitly for attendance marking
      print('🔐 Checking location permissions...');
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('🔐 Requesting location permission...');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus =
                'Location permission denied. Please allow location access to mark attendance.';
            _loading = false;
          });

          // Show permission dialog
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Location Permission Required'),
                content: const Text(
                  'Location access is required to verify your attendance.\n\n'
                  'Please click "Allow" when your browser asks for location permission.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _requestLocationForAttendance(); // Try again
                    },
                    child: const Text('Try Again'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          }
          return;
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _locationStatus =
                'Location permission permanently denied. Please enable in browser settings.';
            _loading = false;
          });

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Location Permission Blocked'),
                content: const Text(
                  'Location permission has been permanently denied. To mark attendance:\n\n'
                  '1. Click the location icon in your browser\'s address bar\n'
                  '2. Change the setting to "Allow"\n'
                  '3. Refresh the page',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      // Get fresh location for attendance
      print('📍 Getting fresh location for attendance...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
        _altitude = position.altitude;
        _locationStatus = 'Location updated for attendance marking';
        _loading = false;
      });

      print('✅ Fresh location obtained for attendance:');
      print('   Latitude: ${position.latitude}');
      print('   Longitude: ${position.longitude}');
      print('   Accuracy: ${position.accuracy}m');
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
        _loading = false;
      });

      print('❌ Location error: $e');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Error'),
            content: Text(
              'Unable to get your location:\n$e\n\n'
              'Please ensure location services are enabled and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _requestLocationForAttendance(); // Try again
                },
                child: const Text('Try Again'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _markAttendance() async {
    // Always request fresh location for attendance marking
    await _requestLocationForAttendance();

    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location access is required to mark attendance. Please allow location permissions.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final attendance = Provider.of<AttendanceProvider>(context, listen: false);

    // Use the new simplified attendance system
    final result = await attendance.markAttendance(
      widget.session.sessionId,
      _lat!,
      _lon!,
      altitude: _altitude, // Include altitude if available
    );

    setState(() => _loading = false);

    if (result != null) {
      Navigator.pop(context);

      // Show detailed success message with status and distance
      final status = result['status'] ?? 'present';
      final distance = result['distance']?.toStringAsFixed(1) ?? 'unknown';
      final organization = result['organization'] ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Attendance marked successfully!\n'
            'Status: ${status.toUpperCase()}\n'
            'Distance: ${distance}m\n'
            '${organization.isNotEmpty ? 'Organization: $organization' : ''}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Refresh the sessions list
      attendance.fetchActiveSessions();
    } else {
      // Show detailed error message
      String errorMessage = attendance.error ?? "Failed to mark attendance";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
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
          const SizedBox(height: 8),

          // Location permission notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location access required to verify attendance',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
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
            const SizedBox(height: 4),
            Text(
              'Session location: ${widget.session.locationLat.toStringAsFixed(6)}, ${widget.session.locationLon.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loading ? null : _getCurrentLocation,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Location'),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
              ),
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
          onPressed: _loading || _lat == null || _lon == null
              ? null
              : _markAttendance,
          child: _loading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _locationStatus?.contains('permission') == true
                          ? 'Requesting Permission...'
                          : 'Getting Location...',
                    ),
                  ],
                )
              : const Text('Mark Attendance'),
        ),
      ],
    );
  }
}

class SessionDetailsDialog extends StatefulWidget {
  final Session session;

  const SessionDetailsDialog({super.key, required this.session});

  @override
  State<SessionDetailsDialog> createState() => _SessionDetailsDialogState();
}

class _SessionDetailsDialogState extends State<SessionDetailsDialog> {
  Session? _detailedSession;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );
      final session = await attendanceProvider.fetchSessionDetails(
        widget.session.sessionId,
      );

      setState(() {
        _detailedSession = session;
        _loading = false;
        _error = session == null ? 'Failed to fetch session details' : null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text('Session Details'),
        ],
      ),
      content: _loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _error != null
          ? SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : _detailedSession != null
          ? SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Session Name',
                    _detailedSession!.sessionName,
                  ),
                  _buildDetailRow(
                    'Description',
                    _detailedSession!.description.isNotEmpty
                        ? _detailedSession!.description
                        : 'No description',
                  ),
                  _buildDetailRow(
                    'Organization ID',
                    _detailedSession!.orgId ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Created By',
                    _detailedSession!.createdBy ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Start Time',
                    _formatDateTime(_detailedSession!.startTime),
                  ),
                  _buildDetailRow(
                    'End Time',
                    _formatDateTime(_detailedSession!.endTime),
                  ),
                  _buildDetailRow(
                    'Location',
                    'Lat: ${_detailedSession!.locationLat.toStringAsFixed(6)}\n'
                        'Lon: ${_detailedSession!.locationLon.toStringAsFixed(6)}\n'
                        'Radius: ${_detailedSession!.locationRadius.toStringAsFixed(0)}m',
                  ),
                  _buildDetailRow(
                    'Status',
                    _detailedSession!.isActive ? 'Active' : 'Inactive',
                  ),
                ],
              ),
            )
          : const Center(child: Text('No data available')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (!_loading && _error != null)
          TextButton(
            onPressed: _fetchSessionDetails,
            child: const Text('Retry'),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
