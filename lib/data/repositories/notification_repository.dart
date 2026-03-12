import 'package:shukla_pps/models/notification_item.dart';

abstract class NotificationRepository {
  /// List notifications for the current user.
  Future<List<NotificationItem>> list({int limit = 50, int offset = 0});

  /// Get the count of unread notifications.
  Future<int> getUnreadCount();

  /// Mark a single notification as read.
  Future<void> markRead(String notificationId);

  /// Mark all notifications as read for the current user.
  Future<void> markAllRead();

  /// Stream real-time notification updates.
  Stream<List<NotificationItem>> streamNotifications();
}
