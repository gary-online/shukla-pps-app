import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shukla_pps/models/submission_status.dart';

part 'status_history_entry.freezed.dart';
part 'status_history_entry.g.dart';

@freezed
class StatusHistoryEntry with _$StatusHistoryEntry {
  const factory StatusHistoryEntry({
    required String id,
    @JsonKey(name: 'submission_id') required String submissionId,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required SubmissionStatus status,
    String? note,
    @JsonKey(name: 'changed_by') required String changedBy,
    @JsonKey(name: 'changed_by_name') String? changedByName,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _StatusHistoryEntry;

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryEntryFromJson(json);
}

String _statusToJson(SubmissionStatus s) => s.toJson();
