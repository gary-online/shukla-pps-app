import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/models/user_profile.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

final userListProvider = FutureProvider.family<List<UserProfile>, String?>(
  (ref, search) => ref.watch(userRepositoryProvider).listUsers(search: search),
);
