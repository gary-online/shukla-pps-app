import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/data/repositories/auth_repository.dart';
import 'package:shukla_pps/data/repositories/submission_repository.dart';
import 'package:shukla_pps/data/repositories/notification_repository.dart';
import 'package:shukla_pps/data/repositories/user_repository.dart';

// TODO: Replace with Supabase implementations in Implementation Plan 2
// When migrating to C#/.NET, swap these to HttpAuthRepository, etc.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Wire up SupabaseAuthRepository in Plan 2');
});

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  throw UnimplementedError('Wire up SupabaseSubmissionRepository in Plan 2');
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  throw UnimplementedError('Wire up SupabaseNotificationRepository in Plan 2');
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('Wire up SupabaseUserRepository in Plan 2');
});
