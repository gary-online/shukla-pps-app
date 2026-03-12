# Shukla PPS App — Implementation Plan Index

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter + Supabase mobile app for Shukla Medical sales reps to submit surgical case reports, replacing the existing phone automation system.

**Architecture:** Repository pattern with Riverpod DI. Supabase handles auth, database, and realtime. go_router with StatefulShellRoute for bottom tab navigation. All Supabase-specific code isolated behind abstract interfaces for future C#/.NET API migration (shuklamedical.com + Epicor ERP).

**Tech Stack:** Flutter, Dart, Supabase (auth, Postgres, realtime, edge functions), Riverpod, go_router, flutter_secure_storage, connectivity_plus, Firebase Cloud Messaging

**Design Spec:** `DESIGN.md`
**High-Level Plan:** `PLAN.md`

---

## Implementation Plans

| Plan | Description | Status |
|------|-------------|--------|
| [Plan 1](IMPLEMENTATION_PLAN_1.md) | Project scaffold, models, theme, config | COMPLETE |
| [Plan 2](IMPLEMENTATION_PLAN_2.md) | Supabase setup, repositories, auth | COMPLETE |
| [Plan 3](IMPLEMENTATION_PLAN_3.md) | Submission flow (picker, form, confirmation, success) | COMPLETE |
| [Plan 4](IMPLEMENTATION_PLAN_4.md) | Navigation shell, home screens, providers | COMPLETE |
| [Plan 5](IMPLEMENTATION_PLAN_5.md) | Submission list, detail, notifications UI, admin, settings | COMPLETE |
| [Plan 6](IMPLEMENTATION_PLAN_6.md) | Edge function deployment, notifications backend, FCM push | NOT STARTED |
| [Plan 7](IMPLEMENTATION_PLAN_7.md) | UI/UX polish, bug fixes, mobile-first improvements | NOT STARTED |
| [Plan 8](IMPLEMENTATION_PLAN_8.md) | HIPAA hardening, compliance, app store prep | NOT STARTED |

Phase 8 (Epicor Integration) from PLAN.md is deferred — no implementation plan needed yet.

---

## File Structure

```
lib/
  main.dart                              # App entry, Supabase init, ProviderScope, 430px max width
  config/
    app_config.dart                      # Supabase URL + anon key (from --dart-define)
    constants.dart                       # Tray catalog, field labels, field hints
    theme.dart                           # AppTheme — Material 3, blue/black/white palette
    router.dart                          # GoRouter with auth redirect + StatefulShellRoute tabs
  models/
    request_type.dart                    # RequestType enum with labels + icons + field configs
    priority.dart                        # Priority enum (normal, urgent)
    submission_status.dart               # SubmissionStatus enum with colors
    submission.dart                      # Submission model
    user_profile.dart                    # UserProfile model
    notification_item.dart               # NotificationItem model
    status_history_entry.dart            # StatusHistoryEntry model
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
    submission_providers.dart            # Submission list, detail, filters, status counts
    notification_providers.dart          # Notification list, unread count
    session_providers.dart               # Inactivity timeout, lock state
    user_management_providers.dart       # Admin user list
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
      submission_list_screen.dart        # Filterable list with bottom sheet filters
      submission_detail_screen.dart      # Full detail + status timeline + admin status update
    notifications/
      notification_center_screen.dart    # Notification list with read/unread
    admin/
      user_management_screen.dart        # User list + search + activate/deactivate
      create_user_screen.dart            # Create new user form
    settings/
      settings_screen.dart               # Profile card, prefs, logout with confirmation
      change_password_screen.dart        # Password change form
  widgets/
    app_shell.dart                       # StatefulShellRoute scaffold + bottom nav + FAB
    submission_card.dart                 # Submission list card with icon box
    status_badge.dart                    # Soft tinted pill badge
    tray_type_picker.dart                # Searchable dropdown with fuzzy match
    priority_toggle.dart                 # Normal/Urgent toggle switch
    empty_state.dart                     # Empty state with icon box
    offline_banner.dart                  # "You're offline" persistent banner

supabase/
  migrations/
    001_initial_schema.sql               # Tables, RLS, triggers, is_admin() function
  functions/
    on-submission-created/index.ts       # Google Chat + Gmail + in-app notification
    on-status-updated/index.ts           # FCM push + in-app notification
    create-user/index.ts                 # Admin user creation (admin SDK)
```
