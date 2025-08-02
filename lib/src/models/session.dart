class Session {
  final String sessionId;
  final String sessionName;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final double locationLat;
  final double locationLon;
  final double locationRadius;
  final bool isActive;
  final String? orgId; // Organization ID for filtering
  final String? createdBy; // User ID of the teacher who created this session

  Session({
    required this.sessionId,
    required this.sessionName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.locationLat,
    required this.locationLon,
    required this.locationRadius,
    required this.isActive,
    this.orgId,
    this.createdBy,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] ?? '',
      sessionName: json['session_name'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      locationLat: (json['location_lat'] ?? 0).toDouble(),
      locationLon: (json['location_lon'] ?? 0).toDouble(),
      locationRadius: (json['location_radius'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? false,
      orgId: json['org_id'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'session_name': sessionName,
    'description': description,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'location_lat': locationLat,
    'location_lon': locationLon,
    'location_radius': locationRadius,
    'is_active': isActive,
    'org_id': orgId,
    'created_by': createdBy,
  };
}
