import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:shukla_pps/data/repositories/auth_repository.dart';
import 'package:shukla_pps/models/user_profile.dart';

class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Future<UserProfile> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed');
    }

    final profile = await _fetchProfile(response.user!.id);

    if (!profile.isActive) {
      await _client.auth.signOut();
      throw Exception('Your account has been deactivated. Contact your administrator.');
    }

    return profile;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  @override
  Stream<AuthState> onAuthStateChange() {
    return _client.auth.onAuthStateChange.map((data) {
      return switch (data.event) {
        sb.AuthChangeEvent.signedIn => AuthState.signedIn,
        sb.AuthChangeEvent.signedOut => AuthState.signedOut,
        sb.AuthChangeEvent.tokenRefreshed => AuthState.tokenRefreshed,
        _ => AuthState.signedOut,
      };
    });
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    final user = _client.auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user');
    }

    await _client.auth.signInWithPassword(
      email: user.email!,
      password: password,
    );
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(
      sb.UserAttributes(password: newPassword),
    );
  }

  Future<UserProfile> _fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(data);
  }
}
