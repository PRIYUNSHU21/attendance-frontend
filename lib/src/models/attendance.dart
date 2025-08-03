class AttendanceRecord {
  final String recordId;
  final String userId;
  final String sessionId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final double lat;
  final double lon;

  AttendanceRecord({
    required this.recordId,
    required this.userId,
    required this.sessionId,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.lat,
    required this.lon,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      recordId: json['record_id'] ?? '',
      userId: json['user_id'] ?? '',
      sessionId: json['session_id'] ?? '', // May be null in new format
      checkInTime: DateTime.parse(json['check_in_time'] ?? json['timestamp'] ?? DateTime.now().toIso8601String()),
      checkOutTime: json['check_out_time'] != null ? DateTime.tryParse(json['check_out_time']) : null,
      status: json['status'] ?? '',
      // Handle both old and new location formats
      lat: _parseCoordinate(json, 'lat', 'latitude'),
      lon: _parseCoordinate(json, 'lon', 'longitude'),
    );
  }

  // Helper method to parse coordinates from different formats
  static double _parseCoordinate(Map<String, dynamic> json, String oldKey, String newKey) {
    // Try new format first (direct latitude/longitude fields)
    if (json[newKey] != null) {
      return (json[newKey] is String) 
        ? double.tryParse(json[newKey]) ?? 0.0 
        : (json[newKey] as num).toDouble();
    }
    
    // Try nested location object format
    if (json['location'] != null && json['location'][oldKey] != null) {
      final locationValue = json['location'][oldKey];
      return (locationValue is String) 
        ? double.tryParse(locationValue) ?? 0.0 
        : (locationValue as num).toDouble();
    }
    
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'record_id': recordId,
    'user_id': userId,
    'session_id': sessionId,
    'check_in_time': checkInTime.toIso8601String(),
    'check_out_time': checkOutTime?.toIso8601String(),
    'status': status,
    'location': {
      'lat': lat,
      'lon': lon,
    },
  };
} 