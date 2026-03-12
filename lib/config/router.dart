import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/session_providers.dart';
import 'package:shukla_pps/screens/auth/login_screen.dart';
import 'package:shukla_pps/screens/auth/lock_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final isLocked = ref.watch(isLockedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      if (isLocked) {
        return state.matchedLocation == '/lock' ? null : '/lock';
      }

      if (loggingIn || state.matchedLocation == '/lock') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      // App shell with bottom tabs — defined in Plan 4
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home — Coming in Plan 4')),
        ),
      ),
    ],
  );
});
