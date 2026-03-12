import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/user_management_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/models/user_profile.dart';

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
