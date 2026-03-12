import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/session_providers.dart';
import 'package:shukla_pps/screens/auth/login_screen.dart';
import 'package:shukla_pps/screens/auth/lock_screen.dart';
import 'package:shukla_pps/screens/home/rep_home_screen.dart';
import 'package:shukla_pps/screens/home/admin_dashboard_screen.dart';
import 'package:shukla_pps/screens/submission/request_type_picker_screen.dart';
import 'package:shukla_pps/screens/submission/submission_form_screen.dart';
import 'package:shukla_pps/screens/submission/confirmation_screen.dart';
import 'package:shukla_pps/screens/submission/success_screen.dart';
import 'package:shukla_pps/screens/submissions/submission_list_screen.dart';
import 'package:shukla_pps/screens/submissions/submission_detail_screen.dart';
import 'package:shukla_pps/screens/notifications/notification_center_screen.dart';
import 'package:shukla_pps/screens/settings/settings_screen.dart';
import 'package:shukla_pps/screens/settings/change_password_screen.dart';
import 'package:shukla_pps/screens/admin/user_management_screen.dart';
import 'package:shukla_pps/screens/admin/create_user_screen.dart';
import 'package:shukla_pps/widgets/app_shell.dart';

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

      // App shell with bottom tab navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home (rep) / Dashboard (admin)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const _HomeRouter(),
              ),
            ],
          ),
          // Branch 1: Submissions
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/submissions',
                builder: (context, state) => const SubmissionListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => SubmissionDetailScreen(
                      submissionId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Notifications
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationCenterScreen(),
              ),
            ],
          ),
          // Branch 3: Settings (rep) / Admin (admin)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings-or-admin',
                builder: (context, state) => const _SettingsOrAdminRouter(),
              ),
            ],
          ),
        ],
      ),

      // Submission flow (outside tabs, no bottom nav)
      GoRoute(
        path: '/submission/new',
        builder: (context, state) => const RequestTypePickerScreen(),
      ),
      GoRoute(
        path: '/submission/form',
        builder: (context, state) {
          final requestType = state.extra as RequestType;
          return SubmissionFormScreen(requestType: requestType);
        },
      ),
      GoRoute(
        path: '/submission/confirm',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ConfirmationScreen(submissionData: data);
        },
      ),
      GoRoute(
        path: '/submission/success',
        builder: (context, state) {
          final submissionId = state.extra as String;
          return SuccessScreen(submissionId: submissionId);
        },
      ),

      // Settings (accessible via app bar gear icon for admins)
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
        ],
      ),

      // Admin create user
      GoRoute(
        path: '/admin/create-user',
        builder: (context, state) => const CreateUserScreen(),
      ),
    ],
  );
});

/// Routes to rep home or admin dashboard based on role.
class _HomeRouter extends ConsumerWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    return isAdmin ? const AdminDashboardScreen() : const RepHomeScreen();
  }
}

/// Routes to settings or admin panel based on role.
class _SettingsOrAdminRouter extends ConsumerWidget {
  const _SettingsOrAdminRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    return isAdmin ? const UserManagementScreen() : const SettingsScreen();
  }
}
