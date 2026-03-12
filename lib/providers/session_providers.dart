import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/services/session_service.dart';

final sessionServiceProvider = ChangeNotifierProvider<SessionService>((ref) {
  final service = SessionService(timeout: AppConfig.inactivityTimeout);
  ref.onDispose(() => service.dispose());
  return service;
});

final isLockedProvider = Provider<bool>((ref) {
  return ref.watch(sessionServiceProvider).isLocked;
});
