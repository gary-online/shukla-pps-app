// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationItemImpl _$$NotificationItemImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationItemImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  submissionId: json['submission_id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  isRead: json['is_read'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$$NotificationItemImplToJson(
  _$NotificationItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'submission_id': instance.submissionId,
  'title': instance.title,
  'body': instance.body,
  'is_read': instance.isRead,
  'created_at': instance.createdAt,
};
