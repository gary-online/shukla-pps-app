# Implementation Plan 5: Submissions List, Detail, Notifications, Admin & Settings

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Build the remaining screens: submission list with filters, submission detail with status timeline, notification center, admin user management, and settings.

**Prerequisites:** Implementation Plans 1–4 completed.

**Design Spec:** `DESIGN.md`

---

## Task 1: Notification Providers

**Files:**
- Create: `lib/providers/notification_providers.dart`

- [ ] **Step 1: Implement notification providers**

```dart
// lib/providers/notification_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/models/notification_item.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

final notificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.streamNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) {
  // Re-compute when notification list changes
  ref.watch(notificationsProvider);
  return ref.watch(notificationRepositoryProvider).getUnreadCount();
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/notification_providers.dart
git commit -m "Add notification providers with unread count"
```

---

## Task 2: Submission List Screen

**Files:**
- Create: `lib/screens/submissions/submission_list_screen.dart`

- [ ] **Step 1: Implement SubmissionListScreen with filters**

```dart
// lib/screens/submissions/submission_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';
import 'package:shukla_pps/widgets/empty_state.dart';
import 'package:shukla_pps/config/theme.dart';

class SubmissionListScreen extends ConsumerStatefulWidget {
  const SubmissionListScreen({super.key});

  @override
  ConsumerState<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends ConsumerState<SubmissionListScreen> {
  SubmissionStatus? _statusFilter;
  String? _typeFilter;

  SubmissionFilters get _filters => SubmissionFilters(
    status: _statusFilter,
    requestType: _typeFilter,
  );

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final submissionsAsync = ref.watch(submissionListProvider(_filters));

    return Column(
      children: [
        // Filter bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Statuses'),
                selected: _statusFilter == null,
                onSelected: (_) => setState(() => _statusFilter = null),
              ),
              const SizedBox(width: 8),
              ...SubmissionStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s.label),
                  selected: _statusFilter == s,
                  selectedColor: s.color.withValues(alpha: 0.2),
                  onSelected: (_) => setState(() => _statusFilter = _statusFilter == s ? null : s),
                ),
              )),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Types'),
                selected: _typeFilter == null,
                onSelected: (_) => setState(() => _typeFilter = null),
              ),
              const SizedBox(width: 8),
              ...RequestType.values.map((rt) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(rt.label),
                  selected: _typeFilter == rt.jsonValue,
                  onSelected: (_) => setState(() => _typeFilter = _typeFilter == rt.jsonValue ? null : rt.jsonValue),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: submissionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (submissions) {
              if (submissions.isEmpty) {
                return EmptyState(
                  message: 'No results found',
                  icon: Icons.search_off,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(submissionListProvider(_filters)),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    return SubmissionCard(
                      submission: sub,
                      showRepName: isAdmin,
                      onTap: () => context.push('/submissions/${sub.id}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/submissions/submission_list_screen.dart
git commit -m "Add submission list screen with status and type filters"
```

---

## Task 3: Submission Detail Screen with Status Timeline

**Files:**
- Create: `lib/screens/submissions/submission_detail_screen.dart`

- [ ] **Step 1: Implement SubmissionDetailScreen**

```dart
// lib/screens/submissions/submission_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/config/constants.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/widgets/status_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class SubmissionDetailScreen extends ConsumerWidget {
  const SubmissionDetailScreen({super.key, required this.submissionId});

  final String submissionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(submissionDetailProvider(submissionId));
    final historyAsync = ref.watch(statusHistoryProvider(submissionId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Submission Detail')),
      body: subAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (submission) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                children: [
                  Icon(submission.requestType.icon, color: AppTheme.primaryBlue, size: 28),
                  const SizedBox(width: 8),
                  Text(submission.requestType.label, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  StatusBadge(status: submission.status),
                ],
              ),
              if (submission.source == 'phone')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Submitted via phone', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ),
              const SizedBox(height: 16),

              // Fields card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (submission.repName != null)
                        _DetailRow(label: 'Rep', value: submission.repName!),
                      if (submission.surgeon != null)
                        _DetailRow(label: fieldLabels['surgeon']!, value: submission.surgeon!),
                      if (submission.facility != null)
                        _DetailRow(label: fieldLabels['facility']!, value: submission.facility!),
                      if (submission.trayType != null)
                        _DetailRow(label: fieldLabels['tray_type']!, value: submission.trayType!),
                      if (submission.surgeryDate != null)
                        _DetailRow(label: fieldLabels['surgery_date']!, value: submission.surgeryDate!),
                      if (submission.details != null)
                        _DetailRow(label: fieldLabels['details']!, value: submission.details!),
                      _DetailRow(label: 'Priority', value: submission.priority.label),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status timeline
              Text('Status Timeline', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading history: $err'),
                data: (history) {
                  if (history.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 12, color: submission.status.color),
                            const SizedBox(width: 12),
                            Text('Created as ${submission.status.label}'),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: history.map((entry) {
                      final ts = DateTime.tryParse(entry.createdAt);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.circle, size: 12, color: entry.status.color),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.status.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (entry.changedByName != null)
                                      Text('by ${entry.changedByName}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                    if (entry.note != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(entry.note!, style: const TextStyle(fontSize: 14)),
                                      ),
                                    if (ts != null)
                                      Text(timeago.format(ts), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),

      // Admin: Update Status button
      bottomNavigationBar: isAdmin
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _showUpdateStatusSheet(context, ref),
                  child: const Text('Update Status'),
                ),
              ),
            )
          : null,
    );
  }

  void _showUpdateStatusSheet(BuildContext context, WidgetRef ref) {
    SubmissionStatus? selected;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update Status', style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ...SubmissionStatus.values.map((s) => RadioListTile<SubmissionStatus>(
                    title: Text(s.label),
                    value: s,
                    groupValue: selected,
                    activeColor: s.color,
                    onChanged: (val) => setSheetState(() => selected = val),
                  )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Note (optional)', hintText: 'Add a note...'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected == null ? null : () async {
                        await ref.read(submissionRepositoryProvider).updateStatus(
                          submissionId: submissionId,
                          newStatus: selected!,
                          note: noteController.text.isNotEmpty ? noteController.text : null,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        ref.invalidate(submissionDetailProvider(submissionId));
                        ref.invalidate(statusHistoryProvider(submissionId));
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/submissions/submission_detail_screen.dart
git commit -m "Add submission detail screen with status timeline and admin status update"
```

---

## Task 4: Notification Center Screen

**Files:**
- Create: `lib/screens/notifications/notification_center_screen.dart`

- [ ] **Step 1: Implement NotificationCenterScreen**

```dart
// lib/screens/notifications/notification_center_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/notification_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/widgets/empty_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Column(
      children: [
        // Mark all as read action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  await ref.read(notificationRepositoryProvider).markAllRead();
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadNotificationCountProvider);
                },
                child: const Text('Mark all as read'),
              ),
            ],
          ),
        ),

        Expanded(
          child: notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const EmptyState(
                  message: 'No notifications yet',
                  icon: Icons.notifications_none,
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  final ts = DateTime.tryParse(n.createdAt);

                  return ListTile(
                    leading: n.isRead
                        ? const Icon(Icons.notifications_none, color: Colors.grey)
                        : Icon(Icons.circle, size: 10, color: AppTheme.primaryBlue),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.body),
                        if (ts != null) Text(timeago.format(ts), style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                    onTap: () async {
                      if (!n.isRead) {
                        await ref.read(notificationRepositoryProvider).markRead(n.id);
                        ref.invalidate(notificationsProvider);
                        ref.invalidate(unreadNotificationCountProvider);
                      }
                      if (context.mounted) {
                        context.push('/submissions/${n.submissionId}');
                      }
                    },
                  );
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

- [ ] **Step 2: Commit**

```bash
git add lib/screens/notifications/notification_center_screen.dart
git commit -m "Add notification center screen with mark-as-read"
```

---

## Task 5: Admin User Management

**Files:**
- Create: `lib/providers/user_management_providers.dart`
- Create: `lib/screens/admin/user_management_screen.dart`
- Create: `lib/screens/admin/create_user_screen.dart`

- [ ] **Step 1: Create user management providers**

```dart
// lib/providers/user_management_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/models/user_profile.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

final userListProvider = FutureProvider.family<List<UserProfile>, String?>(
  (ref, search) => ref.watch(userRepositoryProvider).listUsers(search: search),
);
```

- [ ] **Step 2: Implement UserManagementScreen**

```dart
// lib/screens/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/user_management_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String? _search;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListProvider(_search));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => _search = val.isEmpty ? null : val),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.push('/admin/create-user'),
                icon: const Icon(Icons.person_add),
                label: const Text('Create'),
              ),
            ],
          ),
        ),
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (users) => ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isActive ? AppTheme.primaryBlue : Colors.grey,
                    child: Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.isAdmin ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(user.role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: user.isAdmin ? AppTheme.primaryBlue : AppTheme.textSecondary)),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: user.isActive,
                        onChanged: (val) async {
                          await ref.read(userRepositoryProvider).setUserActive(userId: user.id, isActive: val);
                          ref.invalidate(userListProvider(_search));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Implement CreateUserScreen**

```dart
// lib/screens/admin/create_user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/providers/user_management_providers.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _role = 'rep';
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isSubmitting = true; _error = null; });

    try {
      await ref.read(userRepositoryProvider).createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        role: _role,
      );
      if (mounted) {
        ref.invalidate(userListProvider(null));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                helperText: 'Minimum ${AppConfig.minPasswordLength} characters',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < AppConfig.minPasswordLength) {
                  return 'Password must be at least ${AppConfig.minPasswordLength} characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge)),
              items: const [
                DropdownMenuItem(value: 'rep', child: Text('Sales Rep')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (val) => setState(() => _role = val!),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: TextStyle(color: AppTheme.urgentRed), textAlign: TextAlign.center),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/providers/user_management_providers.dart lib/screens/admin/
git commit -m "Add admin user management and create user screens"
```

---

## Task 6: Settings Screen

**Files:**
- Create: `lib/screens/settings/settings_screen.dart`
- Create: `lib/screens/settings/change_password_screen.dart`

- [ ] **Step 1: Implement SettingsScreen**

```dart
// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/screens/submission/submission_form_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isWizard = ref.watch(formModeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _InfoRow(label: 'Name', value: user?.fullName ?? ''),
                _InfoRow(label: 'Email', value: user?.email ?? ''),
                _InfoRow(label: 'Role', value: (user?.role ?? '').toUpperCase()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Preferences
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Wizard form mode'),
                subtitle: const Text('Step-by-step submission form'),
                value: isWizard,
                onChanged: (val) => ref.read(formModeProvider.notifier).state = val,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Actions
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/change-password'),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: AppTheme.urgentRed),
          title: Text('Log Out', style: TextStyle(color: AppTheme.urgentRed)),
          onTap: () async {
            await ref.read(currentUserProvider.notifier).signOut();
          },
        ),
        const SizedBox(height: 32),

        // App version
        Center(
          child: Text('Shukla PPS v1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: TextStyle(color: AppTheme.textSecondary))),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Implement ChangePasswordScreen**

```dart
// lib/screens/settings/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isSubmitting = true; _error = null; });

    try {
      await ref.read(authRepositoryProvider).updatePassword(
        newPassword: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() { _error = 'Failed to update password. Try again.'; _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                helperText: 'Minimum ${AppConfig.minPasswordLength} characters',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < AppConfig.minPasswordLength) {
                  return 'Must be at least ${AppConfig.minPasswordLength} characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              validator: (v) {
                if (v != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: TextStyle(color: AppTheme.urgentRed)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings/
git commit -m "Add settings screen with profile info, preferences, and password change"
```

---

## Task 7: Connectivity Service

**Files:**
- Create: `lib/services/connectivity_service.dart`

- [ ] **Step 1: Implement ConnectivityService**

```dart
// lib/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/connectivity_service.dart
git commit -m "Add connectivity provider for offline detection"
```

---

## Task 8: Wire All Routes in Router

**Files:**
- Modify: `lib/config/router.dart`

- [ ] **Step 1: Add all remaining imports and routes**

Update `lib/config/router.dart` to import all screen files created in Plans 3-5 and ensure all routes are properly connected:

- `/settings` route
- `/settings/change-password` route
- `/admin/create-user` route
- `HomeRouter` widget that checks `isAdminProvider` and returns `RepHomeScreen` or `AdminDashboardScreen`
- `SettingsOrAdminRouter` widget that checks `isAdminProvider` and returns `SettingsScreen` or `UserManagementScreen`

- [ ] **Step 2: Verify full app builds**

```bash
flutter analyze
```

Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/config/router.dart
git commit -m "Wire all screen routes into GoRouter"
```

---

## Task 9: Edge Functions for Notifications (Backend)

**Files:**
- Create: `supabase/functions/on-submission-created/index.ts`
- Create: `supabase/functions/on-status-updated/index.ts`

- [ ] **Step 1: Create on-submission-created Edge Function**

This function is triggered by a database webhook when a new submission is inserted. It sends Google Chat and Gmail notifications matching the phone automation format, and creates in-app notifications for admins.

```typescript
// supabase/functions/on-submission-created/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  const { record } = await req.json() // Database webhook payload

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // Get the rep's name
  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name')
    .eq('id', record.rep_id)
    .single()

  const repName = profile?.full_name ?? 'Unknown'

  // 1. Send Google Chat notification
  const webhookUrl = Deno.env.get('GOOGLE_CHAT_WEBHOOK_URL')
  if (webhookUrl) {
    const widgets = []
    if (record.tray_type) widgets.push({ keyValue: { topLabel: 'Tray Type', content: record.tray_type } })
    if (record.surgeon) widgets.push({ keyValue: { topLabel: 'Surgeon', content: record.surgeon } })
    if (record.facility) widgets.push({ keyValue: { topLabel: 'Facility', content: record.facility } })
    if (record.surgery_date) widgets.push({ keyValue: { topLabel: 'Surgery Date', content: record.surgery_date } })
    widgets.push({ keyValue: { topLabel: 'Priority', content: record.priority.toUpperCase() } })
    if (record.details) widgets.push({ textParagraph: { text: `<b>Details:</b> ${record.details}` } })

    await fetch(webhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cards: [{
          header: { title: `New ${record.request_type}`, subtitle: `From: ${repName}` },
          sections: [{ widgets }],
        }],
      }),
    })
  }

  // 2. Send Gmail notification (via Gmail API — requires OAuth credentials in env)
  // TODO: Implement Gmail notification matching email_service.py format

  // 3. Create in-app notifications for all admins
  const { data: admins } = await supabase
    .from('profiles')
    .select('id')
    .eq('role', 'admin')
    .eq('is_active', true)

  if (admins && admins.length > 0) {
    const notifications = admins.map((admin: { id: string }) => ({
      user_id: admin.id,
      submission_id: record.id,
      title: 'New Submission',
      body: `${repName} submitted a ${record.request_type.replace(/_/g, ' ')}`,
    }))

    await supabase.from('notifications').insert(notifications)
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

- [ ] **Step 2: Create on-status-updated Edge Function**

```typescript
// supabase/functions/on-status-updated/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  const { record, old_record } = await req.json()

  // Only trigger if status actually changed
  if (record.status === old_record.status) {
    return new Response(JSON.stringify({ skipped: true }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const statusLabel = record.status.replace(/_/g, ' ')
  const requestTypeLabel = record.request_type.replace(/_/g, ' ')

  // Create in-app notification for the rep
  await supabase.from('notifications').insert({
    user_id: record.rep_id,
    submission_id: record.id,
    title: 'Status Updated',
    body: `Your ${requestTypeLabel} was marked ${statusLabel}`,
  })

  // TODO: Send FCM push notification to rep's device
  // Requires: fetch push_tokens for record.rep_id, send via FCM HTTP v1 API

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

- [ ] **Step 3: Set up database webhooks in Supabase dashboard**

In the Supabase dashboard, create two database webhooks:
1. **on-submission-created:** Trigger on INSERT on `submissions` table → calls `on-submission-created` Edge Function
2. **on-status-updated:** Trigger on UPDATE on `submissions` table → calls `on-status-updated` Edge Function

- [ ] **Step 4: Deploy Edge Functions**

```bash
supabase functions deploy on-submission-created
supabase functions deploy on-status-updated
```

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/
git commit -m "Add Edge Functions for submission and status change notifications"
```

---

## End of Plan 5

**What we have after completing all 5 plans:**
- Full Flutter app with bottom tab navigation (role-based)
- Login + lock screen with HIPAA session management
- Complete submission flow: type picker → wizard/single-page form → confirmation → success
- Submission list with filters and submission detail with status timeline
- Admin dashboard with status counts and activity feed
- Admin status update via bottom sheet
- Notification center with read/unread tracking
- Admin user management (create, search, activate/deactivate)
- Settings with profile info, form preference, password change, logout
- Supabase database with RLS, triggers, and realtime
- Edge Functions for Google Chat, Gmail, and in-app notifications
- Repository pattern with clear swap point for C#/.NET migration
- Connectivity detection for offline awareness

**Remaining work not covered in these plans (see PLAN.md Phase 5 & 7):**
- Firebase Cloud Messaging setup (iOS + Android push notifications)
- Gmail notification implementation in Edge Function
- Certificate pinning for HIPAA
- Code obfuscation for release builds
- App store provisioning and signing
- Supabase BAA execution
