import 'package:shukla_pps/models/user_profile.dart';

abstract class UserRepository {
  /// List all user profiles (admin only).
  Future<List<UserProfile>> listUsers({String? search});

  /// Create a new user account (admin only).
  /// This calls a server-side function (Edge Function) since
  /// creating users requires the Supabase admin SDK.
  Future<UserProfile> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  /// Activate or deactivate a user account (admin only).
  Future<void> setUserActive({required String userId, required bool isActive});
}
