// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubmissionImpl _$$SubmissionImplFromJson(Map<String, dynamic> json) =>
    _$SubmissionImpl(
      id: json['id'] as String,
      repId: json['rep_id'] as String,
      requestType: RequestType.fromJson(json['request_type'] as String),
      trayType: json['tray_type'] as String?,
      surgeon: json['surgeon'] as String?,
      facility: json['facility'] as String?,
      surgeryDate: json['surgery_date'] as String?,
      details: json['details'] as String?,
      priority: Priority.fromJson(json['priority'] as String),
      status: SubmissionStatus.fromJson(json['status'] as String),
      statusNote: json['status_note'] as String?,
      source: json['source'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      repName: json['rep_name'] as String?,
    );

Map<String, dynamic> _$$SubmissionImplToJson(_$SubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rep_id': instance.repId,
      'request_type': _requestTypeToJson(instance.requestType),
      'tray_type': instance.trayType,
      'surgeon': instance.surgeon,
      'facility': instance.facility,
      'surgery_date': instance.surgeryDate,
      'details': instance.details,
      'priority': _priorityToJson(instance.priority),
      'status': _statusToJson(instance.status),
      'status_note': instance.statusNote,
      'source': instance.source,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'rep_name': instance.repName,
    };
