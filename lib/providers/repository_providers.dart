import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shukla_pps/data/repositories/auth_repository.dart';
import 'package:shukla_pps/data/repositories/submission_repository.dart';
import 'package:shukla_pps/data/repositories/notification_repository.dart';
import 'package:shukla_pps/data/repositories/user_repository.dart';
import 'package:shukla_pps/data/supabase/supabase_auth_repository.dart';
import 'package:shukla_pps/data/supabase/supabase_submission_repository.dart';
import 'package:shukla_pps/data/supabase/supabase_notification_repository.dart';
import 'package:shukla_pps/data/supabase/supabase_user_repository.dart';

/// The Supabase client provider. All repository implementations depend on this.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// --- SWAP POINT ---
/// To migrate from Supabase to C#/.NET REST API:
/// 1. Create HttpAuthRepository, HttpSubmissionRepository, etc.
/// 2. Change the implementations below to the HTTP versions.
/// 3. No other code changes needed.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  return SupabaseSubmissionRepository(ref.watch(supabaseClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return SupabaseNotificationRepository(ref.watch(supabaseClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return SupabaseUserRepository(ref.watch(supabaseClientProvider));
});
