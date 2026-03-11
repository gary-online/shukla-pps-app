# Implementation Plan 1: Project Foundation

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the Flutter project, define all data models, set up theming, and create the repository pattern abstraction layer.

**Architecture:** Repository pattern with Riverpod DI. All Supabase-specific code isolated in `lib/data/supabase/` behind abstract interfaces in `lib/data/repositories/`. Models use freezed + json_serializable for JSON compatibility with any backend (Supabase now, C#/.NET later).

**Tech Stack:** Flutter, Dart, freezed, json_serializable, flutter_riverpod, supabase_flutter, go_router, flutter_secure_storage, flutter_form_builder, form_builder_validators, intl, connectivity_plus

**Design Spec:** `DESIGN.md`

---

## Task 1: Scaffold Flutter Project

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `analysis_options.yaml`

- [ ] **Step 1: Create Flutter project**

```bash
cd /home/arch/Projects/shukla-pps-app
flutter create --org com.shuklamedical --project-name shukla_pps . --platforms ios,android
```

- [ ] **Step 2: Update pubspec.yaml dependencies**

Replace the `dependencies` and `dev_dependencies` sections in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0
  go_router: ^15.1.0
  flutter_secure_storage: ^9.2.0
  flutter_form_builder: ^9.5.0
  form_builder_validators: ^11.1.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  intl: ^0.19.0
  connectivity_plus: ^6.1.0
  timeago: ^3.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.9.0
  riverpod_generator: ^2.6.0
  custom_lint: ^0.7.0
  riverpod_lint: ^2.6.0
```

- [ ] **Step 3: Install dependencies**

```bash
flutter pub get
```

Expected: No errors, all packages resolve.

- [ ] **Step 4: Create folder structure**

```bash
mkdir -p lib/{config,models,data/repositories,data/supabase,services,providers}
mkdir -p lib/screens/{auth,home,submission,submissions,notifications,admin,settings}
mkdir -p lib/widgets
mkdir -p test/{models,data,services,screens}
```

- [ ] **Step 5: Verify project builds**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Scaffold Flutter project with dependencies and folder structure"
```

---

## Task 2: Define Enums — RequestType, Priority, SubmissionStatus

**Files:**
- Create: `lib/models/request_type.dart`
- Create: `lib/models/priority.dart`
- Create: `lib/models/submission_status.dart`
- Create: `test/models/request_type_test.dart`

- [ ] **Step 1: Write tests for RequestType**

```dart
// test/models/request_type_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/models/request_type_test.dart
```

Expected: FAIL — `package:shukla_pps/models/request_type.dart` not found.

- [ ] **Step 3: Implement RequestType**

```dart
// lib/models/request_type.dart
import 'package:flutter/material.dart';

enum RequestType {
  ppsCaseReport(
    label: 'PPS Case Report',
    icon: Icons.medical_services,
    jsonValue: 'pps_case_report',
    requiredFields: ['surgeon', 'facility', 'tray_type', 'surgery_date', 'details'],
  ),
  fedexLabelRequest(
    label: 'FedEx Label Request',
    icon: Icons.local_shipping,
    jsonValue: 'fedex_label_request',
    requiredFields: ['facility', 'tray_type', 'details'],
  ),
  billOnlyRequest(
    label: 'Bill Only Request',
    icon: Icons.receipt_long,
    jsonValue: 'bill_only_request',
    requiredFields: ['surgeon', 'facility', 'tray_type', 'surgery_date', 'details'],
  ),
  trayAvailability(
    label: 'Tray Availability',
    icon: Icons.inventory_2,
    jsonValue: 'tray_availability',
    requiredFields: ['tray_type', 'surgery_date', 'facility'],
  ),
  deliveryStatus(
    label: 'Delivery Status',
    icon: Icons.track_changes,
    jsonValue: 'delivery_status',
    requiredFields: ['tray_type', 'facility', 'details'],
  ),
  other(
    label: 'Other',
    icon: Icons.more_horiz,
    jsonValue: 'other',
    requiredFields: ['details'],
  );

  const RequestType({
    required this.label,
    required this.icon,
    required this.jsonValue,
    required this.requiredFields,
  });

  final String label;
  final IconData icon;
  final String jsonValue;
  final List<String> requiredFields;

  String toJson() => jsonValue;

  static RequestType fromJson(String value) {
    return RequestType.values.firstWhere((e) => e.jsonValue == value);
  }
}
```

- [ ] **Step 4: Implement Priority**

```dart
// lib/models/priority.dart
enum Priority {
  normal(label: 'Normal', jsonValue: 'normal'),
  urgent(label: 'Urgent', jsonValue: 'urgent');

  const Priority({required this.label, required this.jsonValue});

  final String label;
  final String jsonValue;

  String toJson() => jsonValue;

  static Priority fromJson(String value) {
    return Priority.values.firstWhere((e) => e.jsonValue == value);
  }
}
```

- [ ] **Step 5: Implement SubmissionStatus**

```dart
// lib/models/submission_status.dart
import 'package:flutter/material.dart';

enum SubmissionStatus {
  pending(label: 'Pending', color: Colors.grey, jsonValue: 'pending'),
  inProgress(label: 'In Progress', color: Colors.blue, jsonValue: 'in_progress'),
  completed(label: 'Completed', color: Colors.green, jsonValue: 'completed'),
  cancelled(label: 'Cancelled', color: Colors.red, jsonValue: 'cancelled');

  const SubmissionStatus({
    required this.label,
    required this.color,
    required this.jsonValue,
  });

  final String label;
  final Color color;
  final String jsonValue;

  String toJson() => jsonValue;

  static SubmissionStatus fromJson(String value) {
    return SubmissionStatus.values.firstWhere((e) => e.jsonValue == value);
  }
}
```

- [ ] **Step 6: Run tests**

```bash
flutter test test/models/request_type_test.dart
```

Expected: All tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/models/request_type.dart lib/models/priority.dart lib/models/submission_status.dart test/models/request_type_test.dart
git commit -m "Add RequestType, Priority, and SubmissionStatus enums"
```

---

## Task 3: Define Constants — Tray Catalog

**Files:**
- Create: `lib/config/constants.dart`

- [ ] **Step 1: Create constants file with tray catalog**

```dart
// lib/config/constants.dart

/// The 22 surgical implant extraction tray types manufactured by Shukla Medical.
/// Source: shukla-phone-automation/src/types.py
const List<String> trayCatalog = [
  'Mini',
  'Maxi',
  'Blade',
  'Shoulder-Blade',
  'Modular Hip',
  'Copter',
  'Broken Nail',
  'Lag',
  'Screw-Flex',
  'Anterior Hip',
  'Vise',
  'Screw',
  'Hip',
  'Knee',
  'Nail',
  'Spine-Cervical',
  'Spine-Thoracic & Lumbar',
  'Spine-Instruments',
  'Shoulder',
  'Trephine',
  'Cup',
  'Cement',
];

/// Field labels for the submission form.
const Map<String, String> fieldLabels = {
  'surgeon': 'Surgeon / Doctor',
  'facility': 'Facility / Hospital',
  'tray_type': 'Tray Type',
  'surgery_date': 'Surgery Date',
  'details': 'Details',
};

/// Placeholder hints per field, per request type where they differ from default.
const Map<String, Map<String, String>> fieldHints = {
  'fedex_label_request': {
    'facility': 'Destination facility name and city/state',
    'details': 'PO number or Shukla account number',
  },
  'tray_availability': {
    'surgery_date': 'Date needed',
  },
  'delivery_status': {
    'facility': 'Destination facility',
    'details': 'Tracking number (if available)',
  },
  'other': {
    'details': 'Describe your request',
  },
};
```

- [ ] **Step 2: Commit**

```bash
git add lib/config/constants.dart
git commit -m "Add tray catalog and field configuration constants"
```

---

## Task 4: Define Freezed Models — Submission, UserProfile, NotificationItem, StatusHistoryEntry

**Files:**
- Create: `lib/models/submission.dart`
- Create: `lib/models/user_profile.dart`
- Create: `lib/models/notification_item.dart`
- Create: `lib/models/status_history_entry.dart`
- Create: `test/models/submission_test.dart`

- [ ] **Step 1: Write test for Submission JSON serialization**

```dart
// test/models/submission_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/models/submission_test.dart
```

Expected: FAIL — `package:shukla_pps/models/submission.dart` not found.

- [ ] **Step 3: Implement Submission model**

```dart
// lib/models/submission.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/models/priority.dart';
import 'package:shukla_pps/models/submission_status.dart';

part 'submission.freezed.dart';
part 'submission.g.dart';

@freezed
class Submission with _$Submission {
  const factory Submission({
    required String id,
    @JsonKey(name: 'rep_id') required String repId,
    @JsonKey(name: 'request_type', fromJson: RequestType.fromJson, toJson: _requestTypeToJson)
    required RequestType requestType,
    @JsonKey(name: 'tray_type') String? trayType,
    String? surgeon,
    String? facility,
    @JsonKey(name: 'surgery_date') String? surgeryDate,
    String? details,
    @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
    required Priority priority,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required SubmissionStatus status,
    @JsonKey(name: 'status_note') String? statusNote,
    required String source,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    // Joined field — only present when fetching with profile join
    @JsonKey(name: 'rep_name') String? repName,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) => _$SubmissionFromJson(json);
}

String _requestTypeToJson(RequestType rt) => rt.toJson();
String _priorityToJson(Priority p) => p.toJson();
String _statusToJson(SubmissionStatus s) => s.toJson();
```

- [ ] **Step 4: Implement UserProfile model**

```dart
// lib/models/user_profile.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    required String role, // 'rep' or 'admin'
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

extension UserProfileX on UserProfile {
  bool get isAdmin => role == 'admin';
  bool get isRep => role == 'rep';
}
```

- [ ] **Step 5: Implement StatusHistoryEntry model**

```dart
// lib/models/status_history_entry.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shukla_pps/models/submission_status.dart';

part 'status_history_entry.freezed.dart';
part 'status_history_entry.g.dart';

@freezed
class StatusHistoryEntry with _$StatusHistoryEntry {
  const factory StatusHistoryEntry({
    required String id,
    @JsonKey(name: 'submission_id') required String submissionId,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required SubmissionStatus status,
    String? note,
    @JsonKey(name: 'changed_by') required String changedBy,
    @JsonKey(name: 'changed_by_name') String? changedByName,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _StatusHistoryEntry;

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryEntryFromJson(json);
}

String _statusToJson(SubmissionStatus s) => s.toJson();
```

- [ ] **Step 6: Implement NotificationItem model**

```dart
// lib/models/notification_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'submission_id') required String submissionId,
    required String title,
    required String body,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}
```

- [ ] **Step 7: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Generated `.freezed.dart` and `.g.dart` files for all models.

- [ ] **Step 8: Run tests**

```bash
flutter test test/models/submission_test.dart
```

Expected: All tests PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/models/ test/models/
git commit -m "Add Submission, UserProfile, StatusHistoryEntry, and NotificationItem models"
```

---

## Task 5: App Theme

**Files:**
- Create: `lib/config/theme.dart`

- [ ] **Step 1: Create theme**

```dart
// lib/config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors — placeholders, update with exact hex from shuklamedical.com
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color black = Color(0xFF1A1A1A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF757575);

  // Status colors
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF1565C0);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFC62828);
  static const Color urgentRed = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        onPrimary: white,
        surface: white,
        onSurface: black,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/config/theme.dart
git commit -m "Add app theme with Shukla brand colors"
```

---

## Task 6: App Config

**Files:**
- Create: `lib/config/app_config.dart`

- [ ] **Step 1: Create app config**

```dart
// lib/config/app_config.dart

class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Session timeouts (HIPAA)
  static const Duration inactivityTimeout = Duration(minutes: 5);
  static const Duration accessTokenTtl = Duration(minutes: 15);
  static const Duration refreshTokenTtl = Duration(hours: 8);

  // Password requirements
  static const int minPasswordLength = 12;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/config/app_config.dart
git commit -m "Add app config with Supabase and HIPAA session settings"
```

---

## Task 7: Repository Interfaces (Abstraction Layer)

**Files:**
- Create: `lib/data/repositories/auth_repository.dart`
- Create: `lib/data/repositories/submission_repository.dart`
- Create: `lib/data/repositories/notification_repository.dart`
- Create: `lib/data/repositories/user_repository.dart`

These are abstract interfaces only — no Supabase imports. Designed to be compatible with any backend (Supabase now, C#/.NET REST API later).

- [ ] **Step 1: Create AuthRepository interface**

```dart
// lib/data/repositories/auth_repository.dart
import 'package:shukla_pps/models/user_profile.dart';

abstract class AuthRepository {
  /// Sign in with email and password. Returns the user profile.
  /// Throws on invalid credentials or deactivated account.
  Future<UserProfile> signIn({required String email, required String password});

  /// Sign out the current user.
  Future<void> signOut();

  /// Get the currently authenticated user's profile, or null if not signed in.
  Future<UserProfile?> getCurrentUser();

  /// Stream of auth state changes (signed in, signed out, token refreshed).
  Stream<AuthState> onAuthStateChange();

  /// Re-authenticate with password (for lock screen unlock).
  Future<void> reauthenticate({required String password});

  /// Update the current user's password.
  Future<void> updatePassword({required String newPassword});
}

enum AuthState { signedIn, signedOut, tokenRefreshed }
```

- [ ] **Step 2: Create SubmissionRepository interface**

```dart
// lib/data/repositories/submission_repository.dart
import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/models/status_history_entry.dart';

abstract class SubmissionRepository {
  /// Create a new submission. Returns the created submission with ID.
  Future<Submission> create(Map<String, dynamic> data);

  /// Get a single submission by ID.
  Future<Submission> getById(String id);

  /// List submissions with optional filters and pagination.
  /// If [repId] is null, returns all submissions (admin view).
  Future<List<Submission>> list({
    String? repId,
    SubmissionStatus? status,
    String? requestType,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  });

  /// Update the status of a submission (admin action).
  Future<void> updateStatus({
    required String submissionId,
    required SubmissionStatus newStatus,
    String? note,
  });

  /// Get status history for a submission.
  Future<List<StatusHistoryEntry>> getStatusHistory(String submissionId);

  /// Stream real-time updates for a specific submission.
  Stream<Submission> streamSubmission(String submissionId);

  /// Stream real-time updates for the submission list.
  Stream<List<Submission>> streamSubmissions({String? repId, int limit = 10});

  /// Get submission counts grouped by status.
  /// Optional [repId] filters to one rep; null returns all (admin).
  Future<Map<SubmissionStatus, int>> getStatusCounts({
    String? repId,
    DateTime? fromDate,
    DateTime? toDate,
  });
}
```

- [ ] **Step 3: Create NotificationRepository interface**

```dart
// lib/data/repositories/notification_repository.dart
import 'package:shukla_pps/models/notification_item.dart';

abstract class NotificationRepository {
  /// List notifications for the current user.
  Future<List<NotificationItem>> list({int limit = 50, int offset = 0});

  /// Get the count of unread notifications.
  Future<int> getUnreadCount();

  /// Mark a single notification as read.
  Future<void> markRead(String notificationId);

  /// Mark all notifications as read for the current user.
  Future<void> markAllRead();

  /// Stream real-time notification updates.
  Stream<List<NotificationItem>> streamNotifications();
}
```

- [ ] **Step 4: Create UserRepository interface**

```dart
// lib/data/repositories/user_repository.dart
import 'package:shukla_pps/models/user_profile.dart';

abstract class UserRepository {
  /// List all user profiles (admin only).
  Future<List<UserProfile>> listUsers({String? search});

  /// Create a new user account (admin only).
  /// This calls a server-side function (Edge Function) since
  /// creating users requires the Supabase admin SDK.
  Future<UserProfile> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  /// Activate or deactivate a user account (admin only).
  Future<void> setUserActive({required String userId, required bool isActive});
}
```

- [ ] **Step 5: Verify project analyzes cleanly**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/
git commit -m "Add abstract repository interfaces for auth, submissions, notifications, users"
```

---

## Task 8: Repository Providers (Riverpod Wiring)

**Files:**
- Create: `lib/providers/repository_providers.dart`

This is the **single swap point** for migrating from Supabase to C#/.NET. When migrating, you only change the implementations referenced here.

- [ ] **Step 1: Create provider wiring file**

```dart
// lib/providers/repository_providers.dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/repository_providers.dart
git commit -m "Add repository provider wiring (swap point for backend migration)"
```

---

## Task 9: Minimal main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Write minimal main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/theme.dart';

void main() {
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

- [ ] **Step 2: Verify app builds and runs**

```bash
flutter analyze
flutter build apk --debug 2>&1 | tail -5
```

Expected: Build successful.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "Add minimal main.dart with theme and ProviderScope"
```

---

## End of Plan 1

**What we have after completing Plan 1:**
- Flutter project scaffolded with all dependencies
- All data models defined (Submission, UserProfile, StatusHistoryEntry, NotificationItem)
- All enums defined (RequestType, Priority, SubmissionStatus) with JSON serialization
- Tray catalog and field configuration constants
- App theme with Shukla brand colors
- App config with HIPAA session settings
- Abstract repository interfaces (AuthRepository, SubmissionRepository, NotificationRepository, UserRepository)
- Repository provider wiring (single swap point for C#/.NET migration)
- Minimal running app

**Next:** Implementation Plan 2 — Supabase Backend & Data Layer
