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
