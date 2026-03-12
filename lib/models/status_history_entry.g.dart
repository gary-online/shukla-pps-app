// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatusHistoryEntryImpl _$$StatusHistoryEntryImplFromJson(
  Map<String, dynamic> json,
) => _$StatusHistoryEntryImpl(
  id: json['id'] as String,
  submissionId: json['submission_id'] as String,
  status: SubmissionStatus.fromJson(json['status'] as String),
  note: json['note'] as String?,
  changedBy: json['changed_by'] as String,
  changedByName: json['changed_by_name'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$$StatusHistoryEntryImplToJson(
  _$StatusHistoryEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'submission_id': instance.submissionId,
  'status': _statusToJson(instance.status),
  'note': instance.note,
  'changed_by': instance.changedBy,
  'changed_by_name': instance.changedByName,
  'created_at': instance.createdAt,
};
