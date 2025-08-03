import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/admin_provider.dart';
import '../models/session.dart';
import '../utils/location_utils.dart';
import '../utils/app_theme.dart';

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
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
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
  DateTime? _startTime;
  DateTime? _endTime;
  bool _loading = false;
  
  // Location capture state
  bool _useCustomLocation = false;
  bool _fetchingLocation = false;
  double? _sessionLat;
  double? _sessionLon;
  String? _locationStatus;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.session?.sessionName ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.session?.description ?? '',
    );
    if (widget.session != null) {
      _startTime = widget.session!.startTime;
      _endTime = widget.session!.endTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Capture current location for the session
  Future<void> _captureCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Validate coordinates
      if (!LocationUtils.areValidCoordinates(position.latitude, position.longitude)) {
        throw Exception('Invalid coordinates received');
      }

      setState(() {
        _sessionLat = position.latitude;
        _sessionLon = position.longitude;
        _locationStatus = '📍 Location captured: '
            '${LocationUtils.formatCoordinate(position.latitude)}, '
            '${LocationUtils.formatCoordinate(position.longitude)}';
        _fetchingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = '❌ Failed to get location: $e';
        _fetchingLocation = false;
        _sessionLat = null;
        _sessionLon = null;
      });
    }
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
    
    // Validate custom location if enabled
    if (_useCustomLocation && (_sessionLat == null || _sessionLon == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture location or disable custom location')),
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
        // Removed location parameters as per backend schema changes
        // locationLat: _lat!,
        // locationLon: _lon!,
        // locationRadius: double.parse(_radiusController.text),
      );
    } else {
      // Create new session with optional custom location
      success = await admin.createSession(
        sessionName: _nameController.text,
        description: _descriptionController.text,
        startTime: _startTime!,
        endTime: _endTime!,
        customLat: _useCustomLocation ? _sessionLat : null,
        customLon: _useCustomLocation ? _sessionLon : null,
        customRadius: _useCustomLocation ? 100.0 : null, // Default 100m radius
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
              
              // Custom Location Section
              CheckboxListTile(
                title: const Text('Set Custom Location for This Session'),
                subtitle: const Text('Capture current location instead of using organization default'),
                value: _useCustomLocation,
                onChanged: widget.session != null ? null : (value) {
                  setState(() => _useCustomLocation = value ?? false);
                  if (_useCustomLocation) {
                    _captureCurrentLocation();
                  } else {
                    _sessionLat = null;
                    _sessionLon = null;
                    _locationStatus = null;
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),

              if (_useCustomLocation && widget.session == null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _fetchingLocation ? null : _captureCurrentLocation,
                        icon: _fetchingLocation 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          : const Icon(Icons.my_location),
                        label: Text(_fetchingLocation ? 'Getting Location...' : 'Update Location'),
                      ),
                    ),
                  ],
                ),
                if (_locationStatus != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _locationStatus!.startsWith('📍') 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _locationStatus!.startsWith('📍') 
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _locationStatus!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _locationStatus!.startsWith('📍') 
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
                if (_sessionLat != null && _sessionLon != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Location Preview:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Latitude: ${LocationUtils.formatCoordinate(_sessionLat!)}'),
                          Text('Longitude: ${LocationUtils.formatCoordinate(_sessionLon!)}'),
                          const Text('Radius: 100m'),
                          const SizedBox(height: 8),
                          Text(
                            '📍 Students must be within 100 meters of this location to mark attendance',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
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
