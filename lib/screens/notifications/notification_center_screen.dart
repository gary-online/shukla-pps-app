import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/notification_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/widgets/empty_state.dart';
import 'package:shukla_pps/widgets/error_state.dart';
import 'package:shukla_pps/widgets/skeleton_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  await ref.read(notificationRepositoryProvider).markAllRead();
                  ref.invalidate(notificationsProvider);
                },
                child: const Text('Mark all as read'),
              ),
            ],
          ),
        ),

        Expanded(
          child: notificationsAsync.when(
            loading: () => const SkeletonList(),
            error: (err, _) => ErrorState(
              message: 'Could not load notifications',
              onRetry: () => ref.invalidate(notificationsProvider),
            ),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const EmptyState(
                  message: 'No notifications yet',
                  icon: Icons.notifications_none,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(notificationsProvider);
                },
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final ts = DateTime.tryParse(n.createdAt);

                    return Container(
                      color: n.isRead ? null : AppTheme.primaryBlue.withValues(alpha: 0.04),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: n.isRead ? AppTheme.textSecondary : AppTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            if (!n.isRead)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                n.title,
                                style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                            if (ts != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(timeago.format(ts), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ),
                          ],
                        ),
                        onTap: () async {
                          if (!n.isRead) {
                            await ref.read(notificationRepositoryProvider).markRead(n.id);
                            ref.invalidate(notificationsProvider);
                          }
                          if (context.mounted) {
                            context.push('/submissions/${n.submissionId}');
                          }
                        },
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
