import 'package:flutter_test/flutter_test.dart';
import 'package:shukla_pps/services/session_service.dart';

void main() {
  group('SessionService', () {
    late SessionService service;

    setUp(() {
      service = SessionService(timeout: const Duration(seconds: 2));
    });

    tearDown(() {
      service.dispose();
    });

    test('starts unlocked', () {
      expect(service.isLocked, false);
    });

    test('locks after timeout', () async {
      service.startTimer();
      await Future.delayed(const Duration(seconds: 3));
      expect(service.isLocked, true);
    });

    test('resetTimer prevents lock', () async {
      service.startTimer();
      await Future.delayed(const Duration(seconds: 1));
      service.resetTimer();
      await Future.delayed(const Duration(seconds: 1));
      expect(service.isLocked, false);
    });

    test('unlock resets lock state', () {
      service.lock();
      expect(service.isLocked, true);
      service.unlock();
      expect(service.isLocked, false);
    });
  });
}
