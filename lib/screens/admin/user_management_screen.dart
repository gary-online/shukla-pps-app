import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/user_profile.dart';
import 'package:shukla_pps/providers/user_management_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/widgets/empty_state.dart';
import 'package:shukla_pps/widgets/error_state.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => context.push('/admin/create-user'),
                icon: const Icon(Icons.person_add),
                tooltip: 'Create User',
              ),
            ],
          ),
        ),
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ErrorState(
              message: 'Could not load users',
              onRetry: () => ref.invalidate(userListProvider(_search)),
            ),
            data: (users) {
              if (users.isEmpty) {
                return const EmptyState(
                  message: 'No users found',
                  icon: Icons.people_outline,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(userListProvider(_search)),
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.isActive ? AppTheme.primaryBlue : Colors.grey,
                        child: Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(user.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.isAdmin ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: user.isAdmin ? AppTheme.primaryBlue : AppTheme.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 4),
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
              );
            },
          ),
        ),
      ],
    );
  }
}
