import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/admin_provider.dart';
import '../models/session.dart';
class SessionManagementScreen extends StatefulWidget {
  static const String routeName = '/session-management';
  const SessionManagementScreen({super.key});
  @override
  State<SessionManagementScreen> createState() =>
      _SessionManagementScreenState();
}
class _SessionManagementScreenState extends State<SessionManagementScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AdminProvider>(context, listen: false).fetchSessions();
  }
  void _showCreateSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateSessionDialog(),
    );
  }
  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _showCreateSessionDialog,
            tooltip: 'Create New Session',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSessionDialog,
        tooltip: 'Create New Session',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCreateSessionDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create New Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: admin.loading
                ? const Center(child: CircularProgressIndicator())
                : admin.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${admin.error}'),
                        ElevatedButton(
                          onPressed: () => admin.fetchSessions(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : admin.sessions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No sessions found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Create your first session to get started!'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: admin.sessions.length,
                    itemBuilder: (context, index) {
                      final session = admin.sessions[index];
                      return SessionCard(session: session);
                    },
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
    final isActive = session.isActive;
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          session.sessionName.isNotEmpty
              ? session.sessionName
              : 'Unknown Session',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.description),
            Text('Start: ${startTime.toString()}'),
            Text('End: ${endTime.toString()}'),
            Text('Status: ${isActive ? 'Active' : 'Inactive'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isActive ? Icons.pause : Icons.play_arrow),
              onPressed: () => _toggleSession(context, session),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editSession(context, session),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSession(context, session),
            ),
          ],
        ),
      ),
    );
  }
  void _toggleSession(BuildContext context, Session session) {
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final isActive = session.isActive;
    admin.updateSession(session.sessionId, isActive: !isActive);
  }
  void _editSession(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => CreateSessionDialog(session: session),
    );
  }
  void _deleteSession(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to delete "${session.sessionName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AdminProvider>(
                context,
                listen: false,
              ).deleteSession(session.sessionId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
class CreateSessionDialog extends StatefulWidget {
  final Session? session;
  const CreateSessionDialog({super.key, this.session});
  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}
class _CreateSessionDialogState extends State<CreateSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _radiusController;
  DateTime? _startTime;
  DateTime? _endTime;
  double? _lat;
  double? _lon;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.session?.sessionName ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.session?.description ?? '',
    );
    _radiusController = TextEditingController(
      text: widget.session?.locationRadius.toString() ?? '100',
    );
    if (widget.session != null) {
      _startTime = widget.session!.startTime;
      _endTime = widget.session!.endTime;
      _lat = widget.session!.locationLat;
      _lon = widget.session!.locationLon;
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _radiusController.dispose();
    super.dispose();
  }
  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location services are disabled. Please enable location in your browser settings.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        _showLocationFallbackDialog();
        return;
      }
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission denied. Please allow location access when prompted by your browser.',
                ),
                duration: Duration(seconds: 5),
              ),
            );
          }
          _showLocationFallbackDialog();
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permissions are permanently denied. Please enable them in browser settings (click the lock icon in the address bar).',
              ),
              duration: Duration(seconds: 7),
            ),
          );
        }
        _showLocationFallbackDialog();
        return;
      }
      // Try to get current position with multiple accuracy levels
      Position position;
      // First try high accuracy with shorter timeout
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        // Fallback to medium accuracy
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e) {
          // Final fallback to low accuracy
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5),
            );
          } catch (e) {
            rethrow; // Re-throw to be caught by outer catch
          }
        }
      }
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lon = position.longitude;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location captured: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Could not get location: ';
      if (e.toString().contains('timeout') ||
          e.toString().contains('TIMEOUT')) {
        errorMessage +=
            'Request timed out. Please try again or check your internet connection.';
      } else if (e.toString().contains('permission') ||
          e.toString().contains('PERMISSION')) {
        errorMessage +=
            'Permission denied. Please allow location access in your browser.';
      } else if (e.toString().contains('POSITION_UNAVAILABLE')) {
        errorMessage +=
            'Position unavailable. Please check your GPS/location settings.';
      } else {
        errorMessage += e.toString();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // Show fallback dialog
      _showLocationFallbackDialog();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
  void _showLocationFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Could not get your current location automatically.'),
            SizedBox(height: 8),
            Text('To fix this:'),
            SizedBox(height: 4),
            Text('• Click the location icon in your browser\'s address bar'),
            Text('• Select "Allow" for location access'),
            Text('• Try again'),
            SizedBox(height: 12),
            Text('Or use one of the options below:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showManualLocationDialog();
            },
            child: const Text('Enter Manual'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _lat = 40.7128; // New York coordinates for testing
                _lon = -74.0060;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Using default location (New York) for testing',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Use Default'),
          ),
        ],
      ),
    );
  }
  void _showManualLocationDialog() {
    final latController = TextEditingController(text: _lat?.toString() ?? '');
    final lonController = TextEditingController(text: _lon?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Location Manually'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter latitude and longitude coordinates:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 40.7128',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: lonController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., -74.0060',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular locations:\n• New York: 40.7128, -74.0060\n• London: 51.5074, -0.1278\n• Tokyo: 35.6762, 139.6503',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lon = double.tryParse(lonController.text);
              if (lat != null &&
                  lon != null &&
                  lat >= -90 &&
                  lat <= 90 &&
                  lon >= -180 &&
                  lon <= 180) {
                setState(() {
                  _lat = lat;
                  _lon = lon;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Location set to: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid coordinates'),
                  ),
                );
              }
            },
            child: const Text('Set Location'),
          ),
        ],
      ),
    );
  }
  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          final selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            _startTime = selectedDateTime;
          } else {
            _endTime = selectedDateTime;
          }
        });
      }
    }
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }
    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get current location')),
      );
      return;
    }
    setState(() => _loading = true);
    final admin = Provider.of<AdminProvider>(context, listen: false);
    bool success;
    if (widget.session != null) {
      // Update existing session
      success = await admin.updateSession(
        widget.session!.sessionId,
        sessionName: _nameController.text,
        description: _descriptionController.text,
        startTime: _startTime!,
        endTime: _endTime!,
        locationLat: _lat!,
        locationLon: _lon!,
        locationRadius: double.parse(_radiusController.text),
      );
    } else {
      // Create new session
      success = await admin.createSession(
        sessionName: _nameController.text,
        description: _descriptionController.text,
        startTime: _startTime!,
        endTime: _endTime!,
        locationLat: _lat!,
        locationLon: _lon!,
        locationRadius: double.parse(_radiusController.text),
      );
    }
    setState(() => _loading = false);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Session ${widget.session != null ? 'updated' : 'created'} successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            admin.error ??
                'Failed to ${widget.session != null ? 'update' : 'create'} session',
          ),
        ),
      );
    }
  }
  // Debug method to test geolocation step by step
  Future<void> _debugGeolocation() async {
    try {
      // Test 1: Check if geolocation is supported
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // Test 2: Check permissions
      final permission = await Geolocator.checkPermission();
      // Test 3: Try to get position with very basic settings
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 30),
      );
      print(
        '   Success! Position: ${position.latitude}, ${position.longitude}',
      );
      // Update UI
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lon = position.longitude;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debug: Location retrieved successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Debug Error: $e')));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.session != null ? 'Edit Session' : 'Create Session'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Session Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a session name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDateTime(true),
                      child: Text(
                        _startTime != null
                            ? 'Start: ${_startTime.toString()}'
                            : 'Select Start Time',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDateTime(false),
                      child: Text(
                        _endTime != null
                            ? 'End: ${_endTime.toString()}'
                            : 'Select End Time',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Location:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _lat != null && _lon != null
                          ? 'Lat: ${_lat!.toStringAsFixed(6)}, Lon: ${_lon!.toStringAsFixed(6)}'
                          : 'No location selected',
                      style: TextStyle(
                        color: _lat != null && _lon != null
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _getCurrentLocation,
                            icon: _loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _loading
                                  ? 'Getting Location...'
                                  : 'Get Current Location',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _lat != null && _lon != null
                                  ? Colors.green
                                  : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showManualLocationDialog,
                          icon: const Icon(Icons.edit_location),
                          label: const Text('Manual'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Debug button for troubleshooting
                    ElevatedButton.icon(
                      onPressed: _debugGeolocation,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Debug Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 36),
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(
                  labelText: 'Location Radius (meters)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a radius';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.session != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
