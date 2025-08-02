import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_frontend/src/services/api_service.dart';

void main() {
  group('Public Sessions API Test', () {
    test('Test public sessions endpoint', () async {
      print('🧪 Testing public sessions endpoint integration...');

      // Test the public endpoint directly
      final response = await ApiService.getPublic(
        '/attendance/public-sessions',
      );

      print('Response: $response');

      expect(response['success'], true);
      expect(response['data'], isA<List>());

      final sessions = response['data'] as List;
      print('Found ${sessions.length} sessions');

      if (sessions.isNotEmpty) {
        final firstSession = sessions.first;
        expect(firstSession['session_id'], isNotNull);
        expect(firstSession['session_name'], isNotNull);
        expect(firstSession['org_id'], isNotNull);
        expect(firstSession['is_active'], isNotNull);

        print(
          '✅ First session: ${firstSession['session_name']} (${firstSession['session_id']})',
        );
      }
    });
  });
}
