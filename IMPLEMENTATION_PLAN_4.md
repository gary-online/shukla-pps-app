# Implementation Plan 4: Navigation Shell, Home Screens & Submission Flow

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Build the bottom tab navigation shell, rep home screen, admin dashboard, and the complete submission flow (type picker → form → confirmation → success).

**Prerequisites:** Implementation Plans 1–3 completed.

**Design Spec:** `DESIGN.md` — Screen Inventory, Home Screens, Submission Flow sections

---

## Task 1: Reusable Widgets

**Files:**
- Create: `lib/widgets/status_badge.dart`
- Create: `lib/widgets/priority_toggle.dart`
- Create: `lib/widgets/tray_type_picker.dart`
- Create: `lib/widgets/submission_card.dart`
- Create: `lib/widgets/empty_state.dart`
- Create: `lib/widgets/offline_banner.dart`

- [ ] **Step 1: StatusBadge widget**

```dart
// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:shukla_pps/models/submission_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final SubmissionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: PriorityToggle widget**

```dart
// lib/widgets/priority_toggle.dart
import 'package:flutter/material.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/priority.dart';

class PriorityToggle extends StatelessWidget {
  const PriorityToggle({super.key, required this.value, required this.onChanged});

  final Priority value;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) {
    final isUrgent = value == Priority.urgent;
    return Row(
      children: [
        const Text('Priority:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Text(
          isUrgent ? 'Urgent' : 'Normal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isUrgent ? AppTheme.urgentRed : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isUrgent,
          activeColor: AppTheme.urgentRed,
          onChanged: (val) => onChanged(val ? Priority.urgent : Priority.normal),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: TrayTypePicker widget with fuzzy matching**

```dart
// lib/widgets/tray_type_picker.dart
import 'package:flutter/material.dart';
import 'package:shukla_pps/config/constants.dart';

class TrayTypePicker extends StatefulWidget {
  const TrayTypePicker({super.key, required this.onSelected, this.initialValue});

  final ValueChanged<String> onSelected;
  final String? initialValue;

  @override
  State<TrayTypePicker> createState() => _TrayTypePickerState();
}

class _TrayTypePickerState extends State<TrayTypePicker> {
  late TextEditingController _controller;
  List<String> _filtered = trayCatalog;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = trayCatalog.where((tray) {
        return tray.toLowerCase().contains(q) ||
            _fuzzyMatch(tray.toLowerCase(), q);
      }).toList();
      _showDropdown = query.isNotEmpty;
    });
  }

  bool _fuzzyMatch(String source, String query) {
    // Simple fuzzy: check if all characters appear in order
    int si = 0;
    for (int qi = 0; qi < query.length && si < source.length; si++) {
      if (source[si] == query[qi]) qi++;
    }
    return si <= source.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Tray Type',
            prefixIcon: Icon(Icons.search),
            hintText: 'Search tray types...',
          ),
          onChanged: _filter,
          onTap: () => setState(() => _showDropdown = true),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Tray type is required';
            if (!trayCatalog.contains(value)) return 'Select a valid tray type';
            return null;
          },
        ),
        if (_showDropdown && _filtered.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final tray = _filtered[index];
                return ListTile(
                  title: Text(tray),
                  dense: true,
                  onTap: () {
                    _controller.text = tray;
                    setState(() => _showDropdown = false);
                    widget.onSelected(tray);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: SubmissionCard widget**

```dart
// lib/widgets/submission_card.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/widgets/status_badge.dart';
import 'package:shukla_pps/config/theme.dart';

class SubmissionCard extends StatelessWidget {
  const SubmissionCard({super.key, required this.submission, this.showRepName = false, this.onTap});

  final Submission submission;
  final bool showRepName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(submission.createdAt);
    final timeAgo = createdAt != null ? timeago.format(createdAt) : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(submission.requestType.icon, color: AppTheme.primaryBlue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.requestType.label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    if (showRepName && submission.repName != null)
                      Text(submission.repName!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text(
                      [submission.trayType, submission.facility].whereType<String>().join(' • '),
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(timeAgo, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              StatusBadge(status: submission.status),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: EmptyState widget**

```dart
// lib/widgets/empty_state.dart
import 'package:flutter/material.dart';
import 'package:shukla_pps/config/theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.actionLabel, this.onAction, this.icon});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.inbox_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(fontSize: 16, color: AppTheme.textSecondary), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: OfflineBanner widget**

```dart
// lib/widgets/offline_banner.dart
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Text(
        "You're offline",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/widgets/
git commit -m "Add reusable widgets: StatusBadge, PriorityToggle, TrayTypePicker, SubmissionCard, EmptyState, OfflineBanner"
```

---

## Task 2: Submission Providers

**Files:**
- Create: `lib/providers/submission_providers.dart`

- [ ] **Step 1: Implement submission providers**

```dart
// lib/providers/submission_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/providers/auth_providers.dart';

/// Recent submissions for the home feed (10 most recent).
final recentSubmissionsProvider = StreamProvider<List<Submission>>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();

  return repo.streamSubmissions(
    repId: user.isAdmin ? null : user.id,
    limit: 10,
  );
});

/// Full submission list with filters. Re-fetches when filters change.
final submissionListProvider = FutureProvider.family<List<Submission>, SubmissionFilters>(
  (ref, filters) {
    final repo = ref.watch(submissionRepositoryProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return [];

    return repo.list(
      repId: user.isAdmin ? filters.repId : user.id,
      status: filters.status,
      requestType: filters.requestType,
      fromDate: filters.fromDate,
      toDate: filters.toDate,
      limit: filters.limit,
      offset: filters.offset,
    );
  },
);

/// Single submission detail.
final submissionDetailProvider = FutureProvider.family<Submission, String>(
  (ref, id) => ref.watch(submissionRepositoryProvider).getById(id),
);

/// Status history for a submission.
final statusHistoryProvider = FutureProvider.family(
  (ref, String submissionId) =>
      ref.watch(submissionRepositoryProvider).getStatusHistory(submissionId),
);

/// Status counts for admin dashboard.
final statusCountsProvider = FutureProvider.family(
  (ref, DateRange? range) {
    final repo = ref.watch(submissionRepositoryProvider);
    return repo.getStatusCounts(fromDate: range?.from, toDate: range?.to);
  },
);

/// Filter model for submission list.
class SubmissionFilters {
  final String? repId;
  final SubmissionStatus? status;
  final String? requestType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int limit;
  final int offset;

  const SubmissionFilters({
    this.repId,
    this.status,
    this.requestType,
    this.fromDate,
    this.toDate,
    this.limit = 20,
    this.offset = 0,
  });
}

/// Date range helper for dashboard time toggles.
class DateRange {
  final DateTime from;
  final DateTime to;

  DateRange({required this.from, required this.to});

  factory DateRange.today() {
    final now = DateTime.now();
    return DateRange(from: DateTime(now.year, now.month, now.day), to: now);
  }

  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return DateRange(from: DateTime(start.year, start.month, start.day), to: now);
  }

  factory DateRange.thisMonth() {
    final now = DateTime.now();
    return DateRange(from: DateTime(now.year, now.month, 1), to: now);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/submission_providers.dart
git commit -m "Add submission providers with filters and status counts"
```

---

## Task 3: App Shell (Bottom Navigation + FAB)

**Files:**
- Create: `lib/widgets/app_shell.dart`
- Modify: `lib/config/router.dart`

- [ ] **Step 1: Implement AppShell with role-based tabs**

```dart
// lib/widgets/app_shell.dart
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
            Icon(Icons.medical_services, color: AppTheme.primaryBlue),
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
```

- [ ] **Step 2: Update router.dart with StatefulShellRoute**

Replace the placeholder `'/'` route in `lib/config/router.dart` with:

```dart
// In lib/config/router.dart — replace the placeholder GoRoute at '/' with:

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
          builder: (context, state) {
            // Dynamically show rep home or admin dashboard
            // based on role — handled inside the screen itself
            return const HomeRouter();
          },
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
          builder: (context, state) => const SettingsOrAdminRouter(),
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
```

Note: `HomeRouter` and `SettingsOrAdminRouter` are simple ConsumerWidgets that check `isAdminProvider` and return the appropriate screen. Import all screen files at the top of `router.dart`.

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/app_shell.dart lib/config/router.dart
git commit -m "Add AppShell with role-based bottom navigation and StatefulShellRoute"
```

---

## Task 4: Rep Home Screen

**Files:**
- Create: `lib/screens/home/rep_home_screen.dart`

- [ ] **Step 1: Implement RepHomeScreen**

```dart
// lib/screens/home/rep_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';
import 'package:shukla_pps/widgets/empty_state.dart';

class RepHomeScreen extends ConsumerWidget {
  const RepHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(recentSubmissionsProvider);

    return submissionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (submissions) {
        if (submissions.isEmpty) {
          return EmptyState(
            message: 'No submissions yet',
            actionLabel: 'Create your first submission',
            onAction: () => context.push('/submission/new'),
            icon: Icons.note_add,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(recentSubmissionsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return SubmissionCard(
                submission: sub,
                onTap: () => context.push('/submissions/${sub.id}'),
              );
            },
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/home/rep_home_screen.dart
git commit -m "Add rep home screen with submission feed"
```

---

## Task 5: Admin Dashboard Screen

**Files:**
- Create: `lib/screens/home/admin_dashboard_screen.dart`

- [ ] **Step 1: Implement AdminDashboardScreen**

```dart
// lib/screens/home/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedRange = 0; // 0=Today, 1=This Week, 2=This Month

  DateRange? get _dateRange {
    return switch (_selectedRange) {
      0 => DateRange.today(),
      1 => DateRange.thisWeek(),
      2 => DateRange.thisMonth(),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(statusCountsProvider(_dateRange));
    final recentAsync = ref.watch(recentSubmissionsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(statusCountsProvider(_dateRange));
        ref.invalidate(recentSubmissionsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time range toggle
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Today')),
              ButtonSegment(value: 1, label: Text('This Week')),
              ButtonSegment(value: 2, label: Text('This Month')),
            ],
            selected: {_selectedRange},
            onSelectionChanged: (val) => setState(() => _selectedRange = val.first),
          ),
          const SizedBox(height: 16),

          // Status count cards
          countsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (counts) {
              return Row(
                children: [
                  _CountCard(label: 'Pending', count: counts[SubmissionStatus.pending] ?? 0, color: AppTheme.statusPending),
                  const SizedBox(width: 8),
                  _CountCard(label: 'In Progress', count: counts[SubmissionStatus.inProgress] ?? 0, color: AppTheme.statusInProgress),
                  const SizedBox(width: 8),
                  _CountCard(label: 'Completed', count: counts[SubmissionStatus.completed] ?? 0, color: AppTheme.statusCompleted),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent activity
          Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          recentAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (submissions) {
              if (submissions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No recent submissions', textAlign: TextAlign.center),
                );
              }
              return Column(
                children: submissions.map((sub) => SubmissionCard(
                  submission: sub,
                  showRepName: true,
                  onTap: () => context.push('/submissions/${sub.id}'),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/home/admin_dashboard_screen.dart
git commit -m "Add admin dashboard with status counts and activity feed"
```

---

## Task 6: Submission Flow — Request Type Picker

**Files:**
- Create: `lib/screens/submission/request_type_picker_screen.dart`

- [ ] **Step 1: Implement RequestTypePickerScreen**

```dart
// lib/screens/submission/request_type_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/request_type.dart';

class RequestTypePickerScreen extends StatelessWidget {
  const RequestTypePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Submission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What type of request?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: RequestType.values.map((type) {
                  return Card(
                    child: InkWell(
                      onTap: () => context.push('/submission/form', extra: type),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(type.icon, size: 36, color: AppTheme.primaryBlue),
                            const SizedBox(height: 12),
                            Text(
                              type.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/submission/request_type_picker_screen.dart
git commit -m "Add request type picker screen with 2x3 card grid"
```

---

## Task 7: Submission Flow — Form Screen (Wizard + Single-Page)

**Files:**
- Create: `lib/screens/submission/submission_form_screen.dart`

- [ ] **Step 1: Implement SubmissionFormScreen**

```dart
// lib/screens/submission/submission_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/constants.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/models/priority.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/widgets/tray_type_picker.dart';
import 'package:shukla_pps/widgets/priority_toggle.dart';

/// Remembers whether the user prefers wizard or single-page mode.
final formModeProvider = StateProvider<bool>((ref) => true); // true = wizard

class SubmissionFormScreen extends ConsumerStatefulWidget {
  const SubmissionFormScreen({super.key, required this.requestType});

  final RequestType requestType;

  @override
  ConsumerState<SubmissionFormScreen> createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends ConsumerState<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  Priority _priority = Priority.normal;

  // Field controllers
  final _surgeonController = TextEditingController();
  final _facilityController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedTrayType;
  DateTime? _selectedDate;

  List<String> get _fields => widget.requestType.requiredFields;

  @override
  void dispose() {
    _surgeonController.dispose();
    _facilityController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collectData() {
    final user = ref.read(currentUserProvider).valueOrNull;
    return {
      'rep_id': user?.id,
      'request_type': widget.requestType.toJson(),
      'surgeon': _surgeonController.text.isNotEmpty ? _surgeonController.text : null,
      'facility': _facilityController.text.isNotEmpty ? _facilityController.text : null,
      'tray_type': _selectedTrayType,
      'surgery_date': _selectedDate?.toIso8601String().split('T').first,
      'details': _detailsController.text.isNotEmpty ? _detailsController.text : null,
      'priority': _priority.toJson(),
      'source': 'app',
      // Include display values for confirmation screen
      '_request_type_label': widget.requestType.label,
      '_priority_label': _priority.label,
    };
  }

  Widget _buildField(String field) {
    final rtJson = widget.requestType.jsonValue;
    final hint = fieldHints[rtJson]?[field];

    switch (field) {
      case 'surgeon':
        return TextFormField(
          controller: _surgeonController,
          decoration: InputDecoration(
            labelText: fieldLabels[field],
            hintText: hint,
          ),
          validator: (v) => v == null || v.isEmpty ? '${fieldLabels[field]} is required' : null,
        );
      case 'facility':
        return TextFormField(
          controller: _facilityController,
          decoration: InputDecoration(
            labelText: fieldLabels[field],
            hintText: hint ?? 'Facility / Hospital name',
          ),
          validator: (v) => v == null || v.isEmpty ? '${fieldLabels[field]} is required' : null,
        );
      case 'tray_type':
        return TrayTypePicker(
          initialValue: _selectedTrayType,
          onSelected: (val) => _selectedTrayType = val,
        );
      case 'surgery_date':
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_selectedDate != null
              ? '${fieldLabels[field]}: ${_selectedDate!.toIso8601String().split('T').first}'
              : fieldLabels[field] ?? 'Date'),
          subtitle: hint != null ? Text(hint) : null,
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
        );
      case 'details':
        return TextFormField(
          controller: _detailsController,
          decoration: InputDecoration(
            labelText: fieldLabels[field],
            hintText: hint ?? 'Additional details',
          ),
          maxLines: 3,
          validator: widget.requestType == RequestType.other
              ? (v) => v == null || v.isEmpty ? 'Details are required' : null
              : null,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _goToConfirmation() {
    if (_formKey.currentState!.validate()) {
      context.push('/submission/confirm', extra: _collectData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWizard = ref.watch(formModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requestType.label),
        actions: [
          TextButton(
            onPressed: () => ref.read(formModeProvider.notifier).state = !isWizard,
            child: Text(isWizard ? 'Show all fields' : 'Wizard mode'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: isWizard ? _buildWizard() : _buildSinglePage(),
      ),
    );
  }

  Widget _buildSinglePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._fields.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildField(f),
        )),
        PriorityToggle(value: _priority, onChanged: (p) => setState(() => _priority = p)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _goToConfirmation, child: const Text('Review & Submit')),
      ],
    );
  }

  Widget _buildWizard() {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (_currentStep + 1) / (_fields.length + 1), // +1 for priority
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Step ${_currentStep + 1} of ${_fields.length + 1}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _currentStep < _fields.length
                ? _buildField(_fields[_currentStep])
                : PriorityToggle(value: _priority, onChanged: (p) => setState(() => _priority = p)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _fields.length) {
                      setState(() => _currentStep++);
                    } else {
                      _goToConfirmation();
                    }
                  },
                  child: Text(_currentStep < _fields.length ? 'Next' : 'Review & Submit'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/submission/submission_form_screen.dart
git commit -m "Add submission form screen with wizard and single-page modes"
```

---

## Task 8: Submission Flow — Confirmation & Success Screens

**Files:**
- Create: `lib/screens/submission/confirmation_screen.dart`
- Create: `lib/screens/submission/success_screen.dart`

- [ ] **Step 1: Implement ConfirmationScreen**

```dart
// lib/screens/submission/confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/config/constants.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key, required this.submissionData});

  final Map<String, dynamic> submissionData;

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _isSubmitting = true; _error = null; });

    try {
      // Remove display-only fields before submitting
      final data = Map<String, dynamic>.from(widget.submissionData)
        ..removeWhere((key, _) => key.startsWith('_'));

      final submission = await ref.read(submissionRepositoryProvider).create(data);
      if (mounted) {
        context.go('/submission/success', extra: submission.id);
      }
    } catch (e) {
      setState(() { _error = 'Submission failed. Please try again.'; _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.submissionData;
    final isUrgent = data['priority'] == 'urgent';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Submission')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isUrgent)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.urgentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.urgentRed),
              ),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: AppTheme.urgentRed),
                  const SizedBox(width: 8),
                  Text('URGENT', style: TextStyle(color: AppTheme.urgentRed, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          _ReviewRow(label: 'Request Type', value: data['_request_type_label'] ?? ''),
          if (data['surgeon'] != null) _ReviewRow(label: fieldLabels['surgeon']!, value: data['surgeon']),
          if (data['facility'] != null) _ReviewRow(label: fieldLabels['facility']!, value: data['facility']),
          if (data['tray_type'] != null) _ReviewRow(label: fieldLabels['tray_type']!, value: data['tray_type']),
          if (data['surgery_date'] != null) _ReviewRow(label: fieldLabels['surgery_date']!, value: data['surgery_date']),
          if (data['details'] != null) _ReviewRow(label: fieldLabels['details']!, value: data['details']),
          _ReviewRow(label: 'Priority', value: data['_priority_label'] ?? 'Normal'),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_error!, style: TextStyle(color: AppTheme.urgentRed), textAlign: TextAlign.center),
            ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => context.pop(),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Implement SuccessScreen**

```dart
// lib/screens/submission/success_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.submissionId});

  final String submissionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 80, color: AppTheme.statusCompleted),
                const SizedBox(height: 16),
                Text('Submission Sent!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('ID: ${submissionId.substring(0, 8)}...', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/submissions/$submissionId'),
                    child: const Text('View Submission'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/submission/new'),
                    child: const Text('Submit Another'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/submission/
git commit -m "Add confirmation and success screens for submission flow"
```

---

## End of Plan 4

**What we have after completing Plan 4:**
- Bottom tab navigation with role-based tabs (rep vs admin)
- FAB for "New Submission" on home tab only
- Rep home screen with submission feed
- Admin dashboard with status counts and activity feed
- Complete submission flow: type picker → wizard/single-page form → confirmation → success
- Reusable widgets: StatusBadge, PriorityToggle, TrayTypePicker, SubmissionCard, EmptyState, OfflineBanner
- All submission-related providers

**Next:** Implementation Plan 5 — Submissions List, Detail, Notifications, Admin & Settings
