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
      sessionId: json['session_id'] ?? '',
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null ? DateTime.tryParse(json['check_out_time']) : null,
      status: json['status'] ?? '',
      lat: (json['location']?['lat'] ?? 0).toDouble(),
      lon: (json['location']?['lon'] ?? 0).toDouble(),
    );
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