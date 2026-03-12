import 'package:flutter_test/flutter_test.dart';
import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/models/priority.dart';
import 'package:shukla_pps/models/submission_status.dart';

void main() {
  group('Submission', () {
    test('fromJson / toJson round-trips', () {
      final json = {
        'id': 'abc-123',
        'rep_id': 'user-456',
        'request_type': 'pps_case_report',
        'tray_type': 'Mini',
        'surgeon': 'Dr. Smith',
        'facility': 'General Hospital',
        'surgery_date': '2026-03-15',
        'details': 'Left knee replacement',
        'priority': 'normal',
        'status': 'pending',
        'status_note': null,
        'source': 'app',
        'created_at': '2026-03-11T10:00:00Z',
        'updated_at': '2026-03-11T10:00:00Z',
      };

      final submission = Submission.fromJson(json);
      expect(submission.id, 'abc-123');
      expect(submission.requestType, RequestType.ppsCaseReport);
      expect(submission.trayType, 'Mini');
      expect(submission.priority, Priority.normal);
      expect(submission.status, SubmissionStatus.pending);
      expect(submission.source, 'app');

      final backToJson = submission.toJson();
      expect(backToJson['request_type'], 'pps_case_report');
      expect(backToJson['priority'], 'normal');
    });

    test('fromJson handles nullable fields', () {
      final json = {
        'id': 'abc-123',
        'rep_id': 'user-456',
        'request_type': 'other',
        'tray_type': null,
        'surgeon': null,
        'facility': null,
        'surgery_date': null,
        'details': 'General question',
        'priority': 'normal',
        'status': 'pending',
        'status_note': null,
        'source': 'app',
        'created_at': '2026-03-11T10:00:00Z',
        'updated_at': '2026-03-11T10:00:00Z',
      };

      final submission = Submission.fromJson(json);
      expect(submission.trayType, isNull);
      expect(submission.surgeon, isNull);
    });
  });
}
