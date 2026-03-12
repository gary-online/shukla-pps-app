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
        // Profile card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    (user?.fullName ?? '?')[0].toUpperCase(),
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (user?.role ?? '').toUpperCase(),
                          style: TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Preferences
        Card(
          child: SwitchListTile(
            title: const Text('Wizard form mode'),
            subtitle: const Text('Step-by-step submission form'),
            value: isWizard,
            onChanged: (val) => ref.read(formModeProvider.notifier).state = val,
          ),
        ),
        const SizedBox(height: 12),

        // Actions
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline, size: 22),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => context.push('/settings/change-password'),
              ),
              const Divider(height: 1, indent: 52),
              ListTile(
                leading: Icon(Icons.logout, color: AppTheme.urgentRed, size: 22),
                title: Text('Log Out', style: TextStyle(color: AppTheme.urgentRed)),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Log Out', style: TextStyle(color: AppTheme.urgentRed)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(currentUserProvider.notifier).signOut();
                  }
                },
              ),
            ],
          ),
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
