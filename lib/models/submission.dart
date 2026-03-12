import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/models/priority.dart';
import 'package:shukla_pps/models/submission_status.dart';

part 'submission.freezed.dart';
part 'submission.g.dart';

@freezed
class Submission with _$Submission {
  const factory Submission({
    required String id,
    @JsonKey(name: 'rep_id') required String repId,
    @JsonKey(name: 'request_type', fromJson: RequestType.fromJson, toJson: _requestTypeToJson)
    required RequestType requestType,
    @JsonKey(name: 'tray_type') String? trayType,
    String? surgeon,
    String? facility,
    @JsonKey(name: 'surgery_date') String? surgeryDate,
    String? details,
    @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
    required Priority priority,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required SubmissionStatus status,
    @JsonKey(name: 'status_note') String? statusNote,
    required String source,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    // Joined field — only present when fetching with profile join
    @JsonKey(name: 'rep_name') String? repName,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) => _$SubmissionFromJson(json);
}

String _requestTypeToJson(RequestType rt) => rt.toJson();
String _priorityToJson(Priority p) => p.toJson();
String _statusToJson(SubmissionStatus s) => s.toJson();
