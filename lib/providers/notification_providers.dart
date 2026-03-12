import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/models/notification_item.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

final notificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.streamNotifications();
});

/// Derived from the stream data — no separate network call, no race condition.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});
