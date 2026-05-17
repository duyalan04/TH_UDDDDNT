import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontendapp/providers/auth_provider.dart';
import 'package:frontendapp/screens/login_screen.dart';
import 'package:frontendapp/services/auth_service.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(AuthService()),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('User Management'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
