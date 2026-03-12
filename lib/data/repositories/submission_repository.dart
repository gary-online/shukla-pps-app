import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/models/status_history_entry.dart';

abstract class SubmissionRepository {
  /// Create a new submission. Returns the created submission with ID.
  Future<Submission> create(Map<String, dynamic> data);

  /// Get a single submission by ID.
  Future<Submission> getById(String id);

  /// List submissions with optional filters and pagination.
  /// If [repId] is null, returns all submissions (admin view).
  Future<List<Submission>> list({
    String? repId,
    SubmissionStatus? status,
    String? requestType,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  });

  /// Update the status of a submission (admin action).
  Future<void> updateStatus({
    required String submissionId,
    required SubmissionStatus newStatus,
    String? note,
  });

  /// Get status history for a submission.
  Future<List<StatusHistoryEntry>> getStatusHistory(String submissionId);

  /// Stream real-time updates for a specific submission.
  Stream<Submission> streamSubmission(String submissionId);

  /// Stream real-time updates for the submission list.
  Stream<List<Submission>> streamSubmissions({String? repId, int limit = 10});

  /// Get submission counts grouped by status.
  /// Optional [repId] filters to one rep; null returns all (admin).
  Future<Map<SubmissionStatus, int>> getStatusCounts({
    String? repId,
    DateTime? fromDate,
    DateTime? toDate,
  });
}
