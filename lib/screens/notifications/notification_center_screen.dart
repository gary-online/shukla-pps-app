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
