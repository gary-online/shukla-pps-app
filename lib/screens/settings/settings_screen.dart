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
