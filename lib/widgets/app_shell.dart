import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/notification_providers.dart';
import 'package:shukla_pps/services/connectivity_service.dart';
import 'package:shukla_pps/widgets/offline_banner.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medical_services, color: AppTheme.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Shukla PPS'),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => context.push('/settings'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.divider, height: 1),
        ),
      ),
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(color: AppTheme.divider, height: 1),
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            destinations: isAdmin ? _adminDestinations(unreadCount) : _repDestinations(unreadCount),
          ),
        ],
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

  NavigationDestination _notificationDestination(int unreadCount) {
    return NavigationDestination(
      icon: Semantics(
        label: unreadCount > 0 ? '$unreadCount unread notifications' : 'Notifications',
        child: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text('$unreadCount'),
          child: const Icon(Icons.notifications_outlined),
        ),
      ),
      selectedIcon: Semantics(
        label: unreadCount > 0 ? '$unreadCount unread notifications' : 'Notifications',
        child: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text('$unreadCount'),
          child: const Icon(Icons.notifications),
        ),
      ),
      label: 'Notifications',
    );
  }

  List<NavigationDestination> _repDestinations(int unreadCount) => [
    const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Submissions'),
    _notificationDestination(unreadCount),
    const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
  ];

  List<NavigationDestination> _adminDestinations(int unreadCount) => [
    const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
    const NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Submissions'),
    _notificationDestination(unreadCount),
    const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
  ];
}
