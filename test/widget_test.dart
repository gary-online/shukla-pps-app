import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shukla_pps/screens/auth/login_screen.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/models/user_profile.dart';

void main() {
  testWidgets('LoginScreen renders email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(() => _FakeCurrentUserNotifier()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shukla PPS'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}

class _FakeCurrentUserNotifier extends AsyncNotifier<UserProfile?> implements CurrentUserNotifier {
  @override
  Future<UserProfile?> build() async => null;

  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> refresh() async {}
}
