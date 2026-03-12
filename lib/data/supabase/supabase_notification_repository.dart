import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:shukla_pps/data/repositories/notification_repository.dart';
import 'package:shukla_pps/models/notification_item.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  final sb.SupabaseClient _client;

  SupabaseNotificationRepository(this._client);

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('No authenticated user');
    return user.id;
  }

  @override
  Future<List<NotificationItem>> list({int limit = 50, int offset = 0}) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return data.map((row) => NotificationItem.fromJson(row)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', _userId)
        .eq('is_read', false);
    return data.length;
  }

  @override
  Future<void> markRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _userId)
        .eq('is_read', false);
  }

  @override
  Stream<List<NotificationItem>> streamNotifications() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows.map((r) => NotificationItem.fromJson(r)).toList());
  }
}
