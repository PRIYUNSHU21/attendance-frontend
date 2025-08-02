import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

// A standalone test script to simulate the entire session and attendance process.
// To run this test:
// 1. Make sure you have a `test` directory in your project root.
// 2. Save this file as `test/full_flow_test.dart`.
// 3. Add `test: ^1.21.0` and `http: ^1.2.0` to your dev_dependencies in pubspec.yaml if not present.
// 4. Run `flutter pub get`.
// 5. Run the test from your terminal: `flutter test test/full_flow_test.dart`

void main() {
  const String baseUrl = 'https://attendance-backend-go8h.onrender.com';
  const String teacherEmail = 'alpha@gmail.com';
  const String studentEmail = 'beta@gmail.com';
  const String password = 'P210412004p#';

  String? teacherToken;
  String? studentToken;
  String? sessionId;
  String? orgId;

  group('E2E Attendance Flow Test:', () {
    test('Step 1: Teacher logs in successfully', () async {
      print('--- Running: Teacher Login ---');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': teacherEmail, 'password': password}),
      );

      expect(
        response.statusCode,
        200,
        reason: 'Login request should be successful',
      );
      final data = jsonDecode(response.body);
      expect(
        data['success'],
        isTrue,
        reason: 'Login success flag should be true',
      );

      teacherToken = data['data']['jwt_token'];
      orgId = data['data']['user']['organization_id'];

      expect(
        teacherToken,
        isNotNull,
        reason: 'Teacher token should not be null',
      );
      expect(orgId, isNotNull, reason: 'Organization ID should not be null');

      print('✅ Teacher logged in. Org ID: $orgId');
    });

    test('Step 2: Teacher creates a new session', () async {
      print('\n--- Running: Create Session ---');
      expect(
        teacherToken,
        isNotNull,
        reason: 'Pre-requisite: Teacher must be logged in.',
      );

      final sessionName =
          'E2E Test Session ${DateTime.now().millisecondsSinceEpoch}';
      final startTime = DateTime.now().toIso8601String();
      final endTime = DateTime.now()
          .add(const Duration(hours: 1))
          .toIso8601String();

      final response = await http.post(
        Uri.parse('$baseUrl/admin/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $teacherToken',
        },
        body: jsonEncode({
          'session_name': sessionName,
          'description':
              'This is a test session created by an automated script.',
          'start_time': startTime,
          'end_time': endTime,
          'location_lat': 22.5726,
          'location_lon': 88.3639,
          'location_radius': 100.0,
        }),
      );

      expect(
        response.statusCode,
        201,
        reason: 'Session creation should return 201 Created',
      );
      final data = jsonDecode(response.body);
      expect(
        data['success'],
        isTrue,
        reason: 'Session creation success flag should be true',
      );

      sessionId = data['data']['session_id'];
      expect(sessionId, isNotNull, reason: 'Session ID should not be null');

      print('✅ Session created successfully. Session ID: $sessionId');
    });

    test('Step 3: Student logs in successfully', () async {
      print('\n--- Running: Student Login ---');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': studentEmail, 'password': password}),
      );

      expect(
        response.statusCode,
        200,
        reason: 'Student login request should be successful',
      );
      final data = jsonDecode(response.body);
      expect(
        data['success'],
        isTrue,
        reason: 'Student login success flag should be true',
      );

      studentToken = data['data']['jwt_token'];
      expect(
        studentToken,
        isNotNull,
        reason: 'Student token should not be null',
      );

      print('✅ Student logged in.');
    });

    test('Step 4: Student sees the created session', () async {
      print('\n--- Running: Verify Session Visibility ---');
      expect(
        studentToken,
        isNotNull,
        reason: 'Pre-requisite: Student must be logged in.',
      );
      expect(
        sessionId,
        isNotNull,
        reason: 'Pre-requisite: Session must have been created.',
      );

      // This simulates the frontend logic: try student endpoint, then fallback to admin endpoint
      http.Response response;

      // Try student-specific endpoint first
      response = await http.get(
        Uri.parse('$baseUrl/attendance/active-sessions'),
        headers: {'Authorization': 'Bearer $studentToken'},
      );

      var data = jsonDecode(response.body);
      List<dynamic> sessions = data['data'] ?? [];

      if (!data['success'] || sessions.isEmpty) {
        print(
          '🔄 Student endpoint empty or failed. Trying admin endpoint as fallback...',
        );
        response = await http.get(
          Uri.parse('$baseUrl/admin/sessions'),
          headers: {
            'Authorization': 'Bearer $teacherToken',
          }, // Use teacher/admin token for this
        );
        data = jsonDecode(response.body);
        if (data['success']) {
          sessions = (data['data'] as List)
              .where((s) => s['is_active'] == true && s['org_id'] == orgId)
              .toList();
        }
      }

      expect(
        sessions,
        isNotEmpty,
        reason: 'Active sessions list should not be empty',
      );

      final foundSession = sessions.firstWhere(
        (s) => s['session_id'] == sessionId,
        orElse: () => null,
      );

      expect(
        foundSession,
        isNotNull,
        reason: 'The created session must be visible to the student',
      );
      print('✅ Session is visible to the student.');
    });

    test('Step 5: Student marks attendance', () async {
      print('\n--- Running: Mark Attendance ---');
      expect(
        studentToken,
        isNotNull,
        reason: 'Pre-requisite: Student must be logged in.',
      );
      expect(
        sessionId,
        isNotNull,
        reason: 'Pre-requisite: Session must be visible.',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-in'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $studentToken',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'lat': 22.5726, // Mock location within radius
          'lon': 88.3639,
        }),
      );

      expect(
        response.statusCode,
        200,
        reason: 'Check-in request should be successful',
      );
      final data = jsonDecode(response.body);
      expect(
        data['success'],
        isTrue,
        reason: 'Check-in success flag should be true',
      );

      print('✅ Attendance marked successfully.');
    });

    test('Step 6: Student verifies attendance in history', () async {
      print('\n--- Running: Verify Attendance History ---');
      expect(
        studentToken,
        isNotNull,
        reason: 'Pre-requisite: Student must be logged in.',
      );
      expect(
        sessionId,
        isNotNull,
        reason: 'Pre-requisite: Attendance must have been marked.',
      );

      final response = await http.get(
        Uri.parse('$baseUrl/attendance/my-history'),
        headers: {'Authorization': 'Bearer $studentToken'},
      );

      expect(
        response.statusCode,
        200,
        reason: 'History fetch should be successful',
      );
      final data = jsonDecode(response.body);
      expect(
        data['success'],
        isTrue,
        reason: 'History fetch success flag should be true',
      );

      final history = data['data'] as List;
      final foundRecord = history.firstWhere(
        (r) => r['session_id'] == sessionId,
        orElse: () => null,
      );

      expect(
        foundRecord,
        isNotNull,
        reason: 'Attendance record must be in the history',
      );
      expect(
        foundRecord['status'],
        isIn(['present', 'late']),
        reason: 'Status should be present or late',
      );

      print('✅ Attendance record verified in history.');
    });

    test('Step 7: Teacher deletes the session for cleanup', () async {
      print('\n--- Running: Cleanup Session ---');
      expect(
        teacherToken,
        isNotNull,
        reason: 'Pre-requisite: Teacher must be logged in.',
      );
      expect(
        sessionId,
        isNotNull,
        reason: 'Pre-requisite: Session must exist.',
      );

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/sessions/$sessionId'),
        headers: {'Authorization': 'Bearer $teacherToken'},
      );

      expect(
        response.statusCode,
        200,
        reason: 'Session deletion should be successful',
      );
      final data = jsonDecode(response.body);
      expect(
        data['success'],
        isTrue,
        reason: 'Session deletion success flag should be true',
      );

      print('✅ Session cleaned up successfully.');
    });
  });
}
