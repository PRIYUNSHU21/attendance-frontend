import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../models/session.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceRecord> _history = [];
  List<Session> _activeSessions = [];
  bool _loading = false;
  String? _error;

  List<AttendanceRecord> get history => _history;
  List<Session> get activeSessions => _activeSessions;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _loading = true;
    notifyListeners();
    final response = await ApiService.get('/attendance/my-history');
    _loading = false;
    if (response['success'] == true) {
      _history = (response['data'] as List)
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();
      _error = null;
    } else {
      _error = response['message'];
    }
    notifyListeners();
  }

  Future<void> fetchActiveSessions() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/attendance/active-sessions');
      _loading = false;

      if (response['success'] == true) {
        _activeSessions = (response['data'] as List)
            .map((e) => Session.fromJson(e))
            .toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to fetch active sessions';
      }
    } catch (e) {
      _loading = false;
      _error = 'Error fetching active sessions: $e';
    }
    notifyListeners();
  }

  Future<bool> checkIn(String sessionId, double lat, double lon) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/attendance/check-in',
        body: {'session_id': sessionId, 'lat': lat, 'lon': lon},
      );
      _loading = false;

      if (response['success'] == true) {
        await fetchHistory();
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Failed to check in';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loading = false;
      _error = 'Error checking in: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut(String recordId, double lat, double lon) async {
    _loading = true;
    notifyListeners();
    final response = await ApiService.post(
      '/attendance/check-out',
      body: {'record_id': recordId, 'lat': lat, 'lon': lon},
    );
    _loading = false;
    if (response['success'] == true) {
      await fetchHistory();
      _error = null;
      return true;
    } else {
      _error = response['message'];
      notifyListeners();
      return false;
    }
  }
}
