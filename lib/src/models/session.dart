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
      // Backend returns latitude/longitude/radius (not location_lat/location_lon/location_radius)
      // Use -999.0 as placeholder for missing location data
      locationLat: (json['latitude'] ?? json['location_lat'] ?? -999.0)
          .toDouble(),
      locationLon: (json['longitude'] ?? json['location_lon'] ?? -999.0)
          .toDouble(),
      locationRadius: (json['radius'] ?? json['location_radius'] ?? 100)
          .toDouble(),
      isActive: json['is_active'] ?? false,
      orgId: json['org_id'],
      createdBy: json['created_by'],
    );
  }

  /// Check if session has valid location coordinates
  bool get hasValidLocation => locationLat != -999.0 && locationLon != -999.0;

  /// Get a copy of session with organization location if session location is missing
  Session withOrganizationLocation({
    required double orgLat,
    required double orgLon,
    required double orgRadius,
  }) {
    if (hasValidLocation) {
      return this; // Return unchanged if session already has location
    }

    return Session(
      sessionId: sessionId,
      sessionName: sessionName,
      description: description,
      startTime: startTime,
      endTime: endTime,
      locationLat: orgLat,
      locationLon: orgLon,
      locationRadius: orgRadius,
      isActive: isActive,
      orgId: orgId,
      createdBy: createdBy,
    );
  }

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'session_name': sessionName,
    'description': description,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'latitude': locationLat,
    'longitude': locationLon,
    'radius': locationRadius,
    'is_active': isActive,
    'org_id': orgId,
    'created_by': createdBy,
  };
}
