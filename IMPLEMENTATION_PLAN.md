# Shukla PPS App — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter + Supabase mobile app for Shukla Medical sales reps to submit surgical case reports, replacing the existing phone automation system.

**Architecture:** Repository pattern with Riverpod DI. Supabase handles auth, database, and realtime. go_router with StatefulShellRoute for bottom tab navigation. All Supabase-specific code isolated behind abstract interfaces for future C#/.NET API migration (shuklamedical.com + Epicor ERP).

**Tech Stack:** Flutter, Dart, Supabase (auth, Postgres, realtime, edge functions), Riverpod, go_router, freezed, json_serializable, flutter_secure_storage, flutter_form_builder, connectivity_plus, Firebase Cloud Messaging

**Design Spec:** `DESIGN.md`
**High-Level Plan:** `PLAN.md`

---

## File Structure

```
lib/
  main.dart                              # App entry, Supabase init, ProviderScope
  config/
    app_config.dart                      # Supabase URL + anon key (from env)
    constants.dart                       # Tray catalog, request type metadata
    theme.dart                           # AppTheme — blue/black/white palette
    router.dart                          # GoRouter with auth redirect + StatefulShellRoute
  models/
    request_type.dart                    # RequestType enum with labels + icons + field configs
    priority.dart                        # Priority enum (normal, urgent)
    submission_status.dart               # SubmissionStatus enum with colors
    submission.dart                      # Submission model (@freezed, json_serializable)
    user_profile.dart                    # UserProfile model (@freezed)
    notification_item.dart               # NotificationItem model (@freezed)
    status_history_entry.dart            # StatusHistoryEntry model (@freezed)
  data/
    repositories/
      auth_repository.dart               # Abstract: signIn, signOut, currentUser, onAuthChange
      submission_repository.dart          # Abstract: create, list, getById, updateStatus, stream
      notification_repository.dart        # Abstract: list, markRead, markAllRead, unreadCount
      user_repository.dart                # Abstract: listUsers, createUser, toggleActive
    supabase/
      supabase_auth_repository.dart      # Supabase auth implementation
      supabase_submission_repository.dart # Supabase query implementation
      supabase_notification_repository.dart
      supabase_user_repository.dart
  services/
    session_service.dart                 # Inactivity timer, lock/unlock
    connectivity_service.dart            # Online/offline detection
  providers/
    repository_providers.dart            # Wires abstract repos → Supabase impls (swap point)
    auth_providers.dart                  # Auth state, current user, login/logout
    submission_providers.dart            # Submission list, detail, create
    notification_providers.dart          # Notification list, unread count
    session_providers.dart               # Inactivity timeout, lock state
    user_management_providers.dart       # Admin user CRUD
  screens/
    auth/
      login_screen.dart                  # Email + password, Shukla branding
      lock_screen.dart                   # Inactivity overlay, re-enter password
    home/
      rep_home_screen.dart               # Feed of 10 recent submissions
      admin_dashboard_screen.dart        # Status counts + activity feed
    submission/
      request_type_picker_screen.dart    # 2x3 card grid
      submission_form_screen.dart        # Wizard + single-page toggle
      confirmation_screen.dart           # Read-back before submit
      success_screen.dart                # Success + next actions
    submissions/
      submission_list_screen.dart        # Paginated, filterable list
      submission_detail_screen.dart      # Full detail + status timeline
    notifications/
      notification_center_screen.dart    # Bell icon list with read/unread
    admin/
      user_management_screen.dart        # User list + activate/deactivate
      create_user_screen.dart            # Create new user form
    settings/
      settings_screen.dart               # Profile, prefs, logout
      change_password_screen.dart        # Password change form
  widgets/
    app_shell.dart                       # StatefulShellRoute scaffold + bottom nav + FAB
    submission_card.dart                 # Reusable submission list card
    status_badge.dart                    # Colored pill badge
    tray_type_picker.dart                # Searchable dropdown with fuzzy match
    priority_toggle.dart                 # Normal/Urgent toggle switch
    empty_state.dart                     # Reusable empty state with illustration
    offline_banner.dart                  # "You're offline" persistent banner

test/
  models/
    submission_test.dart
    request_type_test.dart
  data/
    supabase_submission_repository_test.dart
  services/
    session_service_test.dart
  screens/
    login_screen_test.dart
    submission_form_screen_test.dart

supabase/
  migrations/
    001_initial_schema.sql               # Tables, RLS, triggers
  functions/
    on-submission-created/index.ts       # Google Chat + Gmail notification
    on-status-updated/index.ts           # FCM push to rep
    create-user/index.ts                 # Admin user creation (admin SDK)
```

---
