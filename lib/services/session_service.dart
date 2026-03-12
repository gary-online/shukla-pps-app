import 'dart:async';
import 'package:flutter/foundation.dart';

class SessionService extends ChangeNotifier {
  SessionService({required this.timeout});

  final Duration timeout;
  Timer? _timer;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, lock);
  }

  void resetTimer() {
    if (!_isLocked) {
      startTimer();
    }
  }

  void lock() {
    _isLocked = true;
    _timer?.cancel();
    notifyListeners();
  }

  void unlock() {
    _isLocked = false;
    startTimer();
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
