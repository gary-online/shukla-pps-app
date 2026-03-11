# Implementation Plan 2: Supabase Backend & Data Layer

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Set up the Supabase database schema (tables, RLS, triggers), implement all Supabase repository classes, and wire them into the Riverpod providers.

**Prerequisites:** Implementation Plan 1 completed.

**Design Spec:** `DESIGN.md` | **High-Level Plan:** `PLAN.md`

---

## Task 1: Supabase Database Schema

**Files:**
- Create: `supabase/migrations/001_initial_schema.sql`

**Important:** Before running this, you must have a Supabase project created in the **US region** (HIPAA data residency requirement). Get the project URL and anon key from the Supabase dashboard.

- [ ] **Step 1: Create migration file**

```sql
-- supabase/migrations/001_initial_schema.sql

-- ============================================================
-- PROFILES
-- ============================================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text not null,
  role text not null default 'rep' check (role in ('rep', 'admin')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Reps can read their own profile
create policy "Users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

-- Admins can read all profiles
create policy "Admins can read all profiles"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admins can update profiles (activate/deactivate)
create policy "Admins can update profiles"
  on public.profiles for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Service role can insert profiles (used by create-user Edge Function)
create policy "Service role can insert profiles"
  on public.profiles for insert
  with check (true);

-- ============================================================
-- SUBMISSIONS
-- ============================================================
create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  rep_id uuid not null references public.profiles(id),
  request_type text not null check (request_type in (
    'pps_case_report', 'fedex_label_request', 'bill_only_request',
    'tray_availability', 'delivery_status', 'other'
  )),
  tray_type text,
  surgeon text,
  facility text,
  surgery_date text,
  details text,
  priority text not null default 'normal' check (priority in ('normal', 'urgent')),
  status text not null default 'pending' check (status in (
    'pending', 'in_progress', 'completed', 'cancelled'
  )),
  status_note text,
  source text not null default 'app',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.submissions enable row level security;

-- Reps can read their own submissions
create policy "Reps can read own submissions"
  on public.submissions for select
  using (auth.uid() = rep_id);

-- Reps can insert their own submissions
create policy "Reps can insert own submissions"
  on public.submissions for insert
  with check (auth.uid() = rep_id);

-- Admins can read all submissions
create policy "Admins can read all submissions"
  on public.submissions for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admins can update all submissions (status changes)
create policy "Admins can update all submissions"
  on public.submissions for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- SUBMISSION STATUS HISTORY
-- ============================================================
create table public.submission_status_history (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.submissions(id) on delete cascade,
  status text not null,
  note text,
  changed_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

alter table public.submission_status_history enable row level security;

-- Reps can read status history for their own submissions
create policy "Reps can read own submission history"
  on public.submission_status_history for select
  using (
    exists (
      select 1 from public.submissions s
      where s.id = submission_id and s.rep_id = auth.uid()
    )
  );

-- Admins can read all status history
create policy "Admins can read all status history"
  on public.submission_status_history for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admins can insert status history
create policy "Admins can insert status history"
  on public.submission_status_history for insert
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  submission_id uuid not null references public.submissions(id) on delete cascade,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

-- Users can read their own notifications
create policy "Users can read own notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
create policy "Users can update own notifications"
  on public.notifications for update
  using (auth.uid() = user_id);

-- Service role can insert notifications (used by Edge Functions)
create policy "Service role can insert notifications"
  on public.notifications for insert
  with check (true);

-- ============================================================
-- AUDIT LOG
-- ============================================================
create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id),
  action text not null,
  details jsonb,
  created_at timestamptz not null default now()
);

alter table public.audit_log enable row level security;

-- Anyone can insert audit entries
create policy "All users can insert audit log"
  on public.audit_log for insert
  with check (true);

-- Only admins can read audit log
create policy "Admins can read audit log"
  on public.audit_log for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- PUSH TOKENS
-- ============================================================
create table public.push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('ios', 'android')),
  created_at timestamptz not null default now(),
  unique(user_id, token)
);

alter table public.push_tokens enable row level security;

-- Users can manage their own push tokens
create policy "Users can manage own push tokens"
  on public.push_tokens for all
  using (auth.uid() = user_id);

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Auto-update updated_at on profiles
create or replace function public.update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at();

create trigger submissions_updated_at
  before update on public.submissions
  for each row execute function public.update_updated_at();

-- Auto-log status changes to submission_status_history
create or replace function public.log_status_change()
returns trigger as $$
begin
  if old.status is distinct from new.status then
    insert into public.submission_status_history (submission_id, status, note, changed_by)
    values (new.id, new.status, new.status_note, auth.uid());
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger submissions_status_change
  after update on public.submissions
  for each row execute function public.log_status_change();

-- Enable Realtime on submissions and notifications tables
alter publication supabase_realtime add table public.submissions;
alter publication supabase_realtime add table public.notifications;
```

- [ ] **Step 2: Apply migration via Supabase dashboard or CLI**

```bash
# If using Supabase CLI:
supabase db push
# Or paste the SQL into the Supabase dashboard SQL editor
```

- [ ] **Step 3: Verify tables exist in Supabase dashboard**

Check that all 6 tables are created: `profiles`, `submissions`, `submission_status_history`, `notifications`, `audit_log`, `push_tokens`.

- [ ] **Step 4: Commit**

```bash
git add supabase/
git commit -m "Add initial database schema with RLS policies and triggers"
```

---

## Task 2: Supabase Auth Repository Implementation

**Files:**
- Create: `lib/data/supabase/supabase_auth_repository.dart`

- [ ] **Step 1: Implement SupabaseAuthRepository**

```dart
// lib/data/supabase/supabase_auth_repository.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:shukla_pps/data/repositories/auth_repository.dart';
import 'package:shukla_pps/models/user_profile.dart';

class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Future<UserProfile> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed');
    }

    final profile = await _fetchProfile(response.user!.id);

    if (!profile.isActive) {
      await _client.auth.signOut();
      throw Exception('Your account has been deactivated. Contact your administrator.');
    }

    return profile;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  @override
  Stream<AuthState> onAuthStateChange() {
    return _client.auth.onAuthStateChange.map((data) {
      return switch (data.event) {
        sb.AuthChangeEvent.signedIn => AuthState.signedIn,
        sb.AuthChangeEvent.signedOut => AuthState.signedOut,
        sb.AuthChangeEvent.tokenRefreshed => AuthState.tokenRefreshed,
        _ => AuthState.signedOut,
      };
    });
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    final user = _client.auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user');
    }

    await _client.auth.signInWithPassword(
      email: user.email!,
      password: password,
    );
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(
      sb.UserAttributes(password: newPassword),
    );
  }

  Future<UserProfile> _fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(data);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/supabase/supabase_auth_repository.dart
git commit -m "Add SupabaseAuthRepository implementation"
```

---

## Task 3: Supabase Submission Repository Implementation

**Files:**
- Create: `lib/data/supabase/supabase_submission_repository.dart`

- [ ] **Step 1: Implement SupabaseSubmissionRepository**

```dart
// lib/data/supabase/supabase_submission_repository.dart
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
        .map((rows) => Submission.fromJson(rows.first));
  }

  @override
  Stream<List<Submission>> streamSubmissions({String? repId, int limit = 10}) {
    var stream = _client.from('submissions').stream(primaryKey: ['id']);
    if (repId != null) {
      stream = stream.eq('rep_id', repId);
    }
    return stream
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/supabase/supabase_submission_repository.dart
git commit -m "Add SupabaseSubmissionRepository implementation"
```

---

## Task 4: Supabase Notification & User Repository Implementations

**Files:**
- Create: `lib/data/supabase/supabase_notification_repository.dart`
- Create: `lib/data/supabase/supabase_user_repository.dart`

- [ ] **Step 1: Implement SupabaseNotificationRepository**

```dart
// lib/data/supabase/supabase_notification_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:shukla_pps/data/repositories/notification_repository.dart';
import 'package:shukla_pps/models/notification_item.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  final sb.SupabaseClient _client;

  SupabaseNotificationRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<NotificationItem>> list({int limit = 50, int offset = 0}) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return data.map((row) => NotificationItem.fromJson(row)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', _userId)
        .eq('is_read', false);
    return data.length;
  }

  @override
  Future<void> markRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _userId)
        .eq('is_read', false);
  }

  @override
  Stream<List<NotificationItem>> streamNotifications() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows.map((r) => NotificationItem.fromJson(r)).toList());
  }
}
```

- [ ] **Step 2: Implement SupabaseUserRepository**

```dart
// lib/data/supabase/supabase_user_repository.dart
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
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/supabase/
git commit -m "Add SupabaseNotificationRepository and SupabaseUserRepository"
```

---

## Task 5: Wire Supabase Implementations into Providers

**Files:**
- Modify: `lib/providers/repository_providers.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Update repository_providers.dart**

```dart
// lib/providers/repository_providers.dart
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
```

- [ ] **Step 2: Update main.dart with Supabase init**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/config/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: ShuklaPpsApp()));
}

class ShuklaPpsApp extends StatelessWidget {
  const ShuklaPpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shukla PPS',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('Shukla PPS — App Shell Coming Soon'),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify analysis passes**

```bash
flutter analyze
```

Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/providers/repository_providers.dart lib/main.dart
git commit -m "Wire Supabase repository implementations and initialize Supabase client"
```

---

## Task 6: Create-User Edge Function

**Files:**
- Create: `supabase/functions/create-user/index.ts`

This Edge Function uses the Supabase admin SDK to create user accounts, since client-side auth cannot create users for other people.

- [ ] **Step 1: Create the Edge Function**

```typescript
// supabase/functions/create-user/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  try {
    // Verify the request is from an authenticated admin
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'No authorization header' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Create a client with the user's JWT to check their role
    const userClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user } } = await userClient.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Invalid token' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Check if caller is an admin
    const { data: callerProfile } = await userClient
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (callerProfile?.role !== 'admin') {
      return new Response(JSON.stringify({ error: 'Admin access required' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Use the service role client for admin operations
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { email, password, full_name, role } = await req.json()

    // Validate inputs
    if (!email || !password || !full_name || !role) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    if (password.length < 12) {
      return new Response(JSON.stringify({ error: 'Password must be at least 12 characters' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    if (!['rep', 'admin'].includes(role)) {
      return new Response(JSON.stringify({ error: 'Role must be rep or admin' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Create the auth user
    const { data: newUser, error: createError } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    })

    if (createError) {
      return new Response(JSON.stringify({ error: createError.message }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Create the profile
    const { data: profile, error: profileError } = await adminClient
      .from('profiles')
      .insert({
        id: newUser.user.id,
        email,
        full_name,
        role,
      })
      .select()
      .single()

    if (profileError) {
      return new Response(JSON.stringify({ error: profileError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    return new Response(JSON.stringify(profile), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
```

- [ ] **Step 2: Deploy the Edge Function**

```bash
supabase functions deploy create-user
```

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/
git commit -m "Add create-user Edge Function for admin user management"
```

---

## End of Plan 2

**What we have after completing Plan 2:**
- Supabase database with all tables, RLS policies, and triggers
- Supabase realtime enabled on submissions and notifications
- All 4 repository implementations (auth, submission, notification, user)
- Repository providers wired up with clear migration swap point
- Supabase initialized in main.dart
- Create-user Edge Function deployed

**Next:** Implementation Plan 3 — Authentication & Session Management
