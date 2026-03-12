import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/notification_providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text('Shukla PPS'),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: isAdmin ? _adminDestinations(unreadCount) : _repDestinations(unreadCount),
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/submission/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Submission'),
            )
          : null,
    );
  }

  List<NavigationDestination> _repDestinations(int unreadCount) => [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.list), label: 'Submissions'),
    NavigationDestination(
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text('$unreadCount'),
        child: const Icon(Icons.notifications),
      ),
      label: 'Notifications',
    ),
    const NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  List<NavigationDestination> _adminDestinations(int unreadCount) => [
    const NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    const NavigationDestination(icon: Icon(Icons.list), label: 'Submissions'),
    NavigationDestination(
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text('$unreadCount'),
        child: const Icon(Icons.notifications),
      ),
      label: 'Notifications',
    ),
    const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
  ];
}
