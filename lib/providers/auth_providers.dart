import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/data/repositories/auth_repository.dart';
import 'package:shukla_pps/models/user_profile.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/providers/session_providers.dart';

/// The current authenticated user profile. Null if not signed in.
final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, UserProfile?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final authRepo = ref.watch(authRepositoryProvider);

    // Listen to auth state changes
    final sub = authRepo.onAuthStateChange().listen((event) {
      if (event == AuthState.signedOut) {
        ref.read(sessionServiceProvider).stop();
        state = const AsyncData(null);
      } else if (event == AuthState.signedIn) {
        ref.read(sessionServiceProvider).startTimer();
      }
    });
    ref.onDispose(() => sub.cancel());

    try {
      return await authRepo.getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final authRepo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authRepo.signIn(email: email, password: password),
    );
    if (state.hasValue && state.value != null) {
      ref.read(sessionServiceProvider).startTimer();
    }
  }

  Future<void> signOut() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
    state = const AsyncData(null);
  }

  Future<void> refresh() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => authRepo.getCurrentUser());
  }
}

/// Whether the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull != null;
});

/// Whether the current user is an admin.
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.isAdmin ?? false;
});
