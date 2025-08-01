// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:attendance_frontend/src/app.dart';
import 'package:attendance_frontend/src/providers/auth_provider.dart';
import 'package:attendance_frontend/src/providers/user_provider.dart';
import 'package:attendance_frontend/src/providers/attendance_provider.dart';
import 'package:attendance_frontend/src/providers/admin_provider.dart';

void main() {
  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => AttendanceProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: const AttendanceApp(),
      ),
    );

    // Verify that the splash screen loads
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
