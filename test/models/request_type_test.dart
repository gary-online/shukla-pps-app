import 'package:flutter_test/flutter_test.dart';
import 'package:shukla_pps/models/request_type.dart';

void main() {
  group('RequestType', () {
    test('has 6 values', () {
      expect(RequestType.values.length, 6);
    });

    test('label returns display name', () {
      expect(RequestType.ppsCaseReport.label, 'PPS Case Report');
      expect(RequestType.fedexLabelRequest.label, 'FedEx Label Request');
      expect(RequestType.other.label, 'Other');
    });

    test('fromJson round-trips correctly', () {
      for (final rt in RequestType.values) {
        expect(RequestType.fromJson(rt.toJson()), rt);
      }
    });

    test('requiredFields returns correct fields per type', () {
      final ppsFields = RequestType.ppsCaseReport.requiredFields;
      expect(ppsFields, contains('surgeon'));
      expect(ppsFields, contains('facility'));
      expect(ppsFields, contains('tray_type'));
      expect(ppsFields, contains('surgery_date'));

      final otherFields = RequestType.other.requiredFields;
      expect(otherFields, contains('details'));
      expect(otherFields.length, 1);
    });
  });
}
