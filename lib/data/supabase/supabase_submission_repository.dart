import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:shukla_pps/data/repositories/submission_repository.dart';
import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/models/status_history_entry.dart';

class SupabaseSubmissionRepository implements SubmissionRepository {
  final sb.SupabaseClient _client;

  SupabaseSubmissionRepository(this._client);

  @override
  Future<Submission> create(Map<String, dynamic> data) async {
    final result = await _client
        .from('submissions')
        .insert(data)
        .select()
        .single();
    return Submission.fromJson(result);
  }

  @override
  Future<Submission> getById(String id) async {
    final data = await _client
        .from('submissions')
        .select('*, profiles!submissions_rep_id_fkey(full_name)')
        .eq('id', id)
        .single();

    // Flatten the join
    if (data['profiles'] != null) {
      data['rep_name'] = data['profiles']['full_name'];
    }
    data.remove('profiles');

    return Submission.fromJson(data);
  }

  @override
  Future<List<Submission>> list({
    String? repId,
    SubmissionStatus? status,
    String? requestType,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('submissions')
        .select('*, profiles!submissions_rep_id_fkey(full_name)');

    if (repId != null) query = query.eq('rep_id', repId);
    if (status != null) query = query.eq('status', status.jsonValue);
    if (requestType != null) query = query.eq('request_type', requestType);
    if (fromDate != null) query = query.gte('created_at', fromDate.toIso8601String());
    if (toDate != null) query = query.lte('created_at', toDate.toIso8601String());

    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map<Submission>((row) {
      if (row['profiles'] != null) {
        row['rep_name'] = row['profiles']['full_name'];
      }
      row.remove('profiles');
      return Submission.fromJson(row);
    }).toList();
  }

  @override
  Future<void> updateStatus({
    required String submissionId,
    required SubmissionStatus newStatus,
    String? note,
  }) async {
    await _client
        .from('submissions')
        .update({
          'status': newStatus.jsonValue,
          'status_note': note,
        })
        .eq('id', submissionId);
  }

  @override
  Future<List<StatusHistoryEntry>> getStatusHistory(String submissionId) async {
    final data = await _client
        .from('submission_status_history')
        .select('*, profiles!submission_status_history_changed_by_fkey(full_name)')
        .eq('submission_id', submissionId)
        .order('created_at', ascending: true);

    return data.map<StatusHistoryEntry>((row) {
      if (row['profiles'] != null) {
        row['changed_by_name'] = row['profiles']['full_name'];
      }
      row.remove('profiles');
      return StatusHistoryEntry.fromJson(row);
    }).toList();
  }

  @override
  Stream<Submission> streamSubmission(String submissionId) {
    return _client
        .from('submissions')
        .stream(primaryKey: ['id'])
        .eq('id', submissionId)
        .where((rows) => rows.isNotEmpty)
        .map((rows) => Submission.fromJson(rows.first));
  }

  @override
  Stream<List<Submission>> streamSubmissions({String? repId, int limit = 10}) {
    final baseStream = _client.from('submissions').stream(primaryKey: ['id']);
    final filteredStream = repId != null ? baseStream.eq('rep_id', repId) : baseStream;
    return filteredStream
        .order('created_at', ascending: false)
        .limit(limit)
        .map((rows) => rows.map((r) => Submission.fromJson(r)).toList());
  }

  @override
  Future<Map<SubmissionStatus, int>> getStatusCounts({
    String? repId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _client.from('submissions').select('status');
    if (repId != null) query = query.eq('rep_id', repId);
    if (fromDate != null) query = query.gte('created_at', fromDate.toIso8601String());
    if (toDate != null) query = query.lte('created_at', toDate.toIso8601String());

    final data = await query;
    final counts = <SubmissionStatus, int>{};
    for (final status in SubmissionStatus.values) {
      counts[status] = 0;
    }
    for (final row in data) {
      final status = SubmissionStatus.fromJson(row['status'] as String);
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }
}
