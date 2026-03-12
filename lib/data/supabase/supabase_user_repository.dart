import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:shukla_pps/data/repositories/user_repository.dart';
import 'package:shukla_pps/models/user_profile.dart';

class SupabaseUserRepository implements UserRepository {
  final sb.SupabaseClient _client;

  SupabaseUserRepository(this._client);

  @override
  Future<List<UserProfile>> listUsers({String? search}) async {
    var query = _client.from('profiles').select();
    if (search != null && search.isNotEmpty) {
      query = query.or('full_name.ilike.%$search%,email.ilike.%$search%');
    }
    final data = await query.order('full_name');
    return data.map((row) => UserProfile.fromJson(row)).toList();
  }

  @override
  Future<UserProfile> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    // Calls the create-user Edge Function which uses the admin SDK
    final response = await _client.functions.invoke(
      'create-user',
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to create user: ${response.data}');
    }

    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> setUserActive({required String userId, required bool isActive}) async {
    await _client
        .from('profiles')
        .update({'is_active': isActive})
        .eq('id', userId);
  }
}
