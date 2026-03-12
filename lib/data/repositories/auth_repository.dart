import 'package:shukla_pps/models/user_profile.dart';

abstract class AuthRepository {
  /// Sign in with email and password. Returns the user profile.
  /// Throws on invalid credentials or deactivated account.
  Future<UserProfile> signIn({required String email, required String password});

  /// Sign out the current user.
  Future<void> signOut();

  /// Get the currently authenticated user's profile, or null if not signed in.
  Future<UserProfile?> getCurrentUser();

  /// Stream of auth state changes (signed in, signed out, token refreshed).
  Stream<AuthState> onAuthStateChange();

  /// Re-authenticate with password (for lock screen unlock).
  Future<void> reauthenticate({required String password});

  /// Update the current user's password.
  Future<void> updatePassword({required String newPassword});
}

enum AuthState { signedIn, signedOut, tokenRefreshed }
