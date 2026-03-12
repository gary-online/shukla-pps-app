import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/models/user_profile.dart';
import 'package:shukla_pps/providers/auth_providers.dart';

/// Recent submissions for the home feed (10 most recent).
final recentSubmissionsProvider = StreamProvider<List<Submission>>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();

  return repo.streamSubmissions(
    repId: user.isAdmin ? null : user.id,
    limit: 10,
  );
});

/// Full submission list with filters. Re-fetches when filters change.
final submissionListProvider = FutureProvider.family<List<Submission>, SubmissionFilters>(
  (ref, filters) {
    final repo = ref.watch(submissionRepositoryProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return [];

    return repo.list(
      repId: user.isAdmin ? filters.repId : user.id,
      status: filters.status,
      requestType: filters.requestType,
      fromDate: filters.fromDate,
      toDate: filters.toDate,
      limit: filters.limit,
      offset: filters.offset,
    );
  },
);

/// Single submission detail.
final submissionDetailProvider = FutureProvider.family<Submission, String>(
  (ref, id) => ref.watch(submissionRepositoryProvider).getById(id),
);

/// Status history for a submission.
final statusHistoryProvider = FutureProvider.family(
  (ref, String submissionId) =>
      ref.watch(submissionRepositoryProvider).getStatusHistory(submissionId),
);

/// Status counts for admin dashboard.
final statusCountsProvider = FutureProvider.family(
  (ref, DateRange? range) {
    final repo = ref.read(submissionRepositoryProvider);
    return repo.getStatusCounts(fromDate: range?.from, toDate: range?.to);
  },
);

/// Filter model for submission list.
class SubmissionFilters {
  final String? repId;
  final SubmissionStatus? status;
  final String? requestType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int limit;
  final int offset;

  const SubmissionFilters({
    this.repId,
    this.status,
    this.requestType,
    this.fromDate,
    this.toDate,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionFilters &&
          runtimeType == other.runtimeType &&
          repId == other.repId &&
          status == other.status &&
          requestType == other.requestType &&
          fromDate == other.fromDate &&
          toDate == other.toDate &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode =>
      Object.hash(repId, status, requestType, fromDate, toDate, limit, offset);
}

/// Date range helper for dashboard time toggles.
class DateRange {
  final DateTime from;
  final DateTime to;

  DateRange({required this.from, required this.to});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(from, to);

  factory DateRange.today() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(from: DateTime(now.year, now.month, now.day), to: endOfDay);
  }

  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(from: DateTime(start.year, start.month, start.day), to: endOfDay);
  }

  factory DateRange.thisMonth() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(from: DateTime(now.year, now.month, 1), to: endOfDay);
  }
}
