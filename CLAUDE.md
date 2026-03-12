# Shukla PPS App

## Project Overview
Flutter + Supabase mobile app (iOS + Android) for Shukla Medical sales reps to submit surgical case reports, request shipping labels, check tray availability, etc. Replaces the existing AI phone automation system with a form-based workflow.

Shukla is a government contractor subject to HIPAA regulations.

## Tech Stack
- **Frontend:** Flutter 3.x (Dart)
- **Backend:** Supabase (auth, database, edge functions, realtime)
- **State management:** Riverpod
- **Routing:** go_router with StatefulShellRoute
- **Future:** Repository pattern enables migration to self-hosted DB + Epicor ERP (C#/.NET)

## Architecture
- Repository pattern: nothing outside `lib/data/` imports `supabase_flutter`
- Abstract interfaces in `lib/data/repositories/`
- Supabase implementations in `lib/data/supabase/`
- Riverpod providers wire implementations — swap happens in `lib/providers/repository_providers.dart`

## Project Structure
```
lib/
  main.dart              # App entry, Supabase init, ProviderScope, 430px max width
  config/
    app_config.dart      # Supabase URL + anon key (from --dart-define)
    constants.dart       # Tray catalog, field labels, field hints
    theme.dart           # AppTheme — Material 3, blue/black/white palette
    router.dart          # GoRouter with auth redirect + StatefulShellRoute tabs
  models/                # request_type, priority, submission, user_profile, submission_status, notification_item, status_history_entry
  data/
    repositories/        # Abstract interfaces (auth, submission, notification, user)
    supabase/            # Supabase implementations
  services/              # session_service, connectivity_service
  providers/             # Riverpod providers (auth, submission, notification, session, user_management, repository)
  screens/
    auth/                # login_screen, lock_screen
    home/                # rep_home_screen, admin_dashboard_screen
    submission/          # request_type_picker, submission_form, confirmation, success
    submissions/         # submission_list_screen, submission_detail_screen
    notifications/       # notification_center_screen
    admin/               # user_management_screen, create_user_screen
    settings/            # settings_screen, change_password_screen
  widgets/               # app_shell, submission_card, status_badge, tray_type_picker, priority_toggle, empty_state, offline_banner

supabase/
  migrations/
    001_initial_schema.sql        # Tables, RLS, triggers, is_admin() function
  functions/
    on-submission-created/        # Google Chat + Gmail + in-app notification
    on-status-updated/            # FCM push + in-app notification
    create-user/                  # Admin user creation via admin SDK
```

## Key Reference
- Master implementation plan: `PLAN.md`
- UI/UX design spec: `DESIGN.md`
- Implementation plan index: `IMPLEMENTATION_PLAN.md`
- Detailed plans: `IMPLEMENTATION_PLAN_1.md` through `IMPLEMENTATION_PLAN_5.md` (completed)
- Remaining plans: `IMPLEMENTATION_PLAN_6.md` through `IMPLEMENTATION_PLAN_8.md`
- Phone automation source: `../shukla-phone-automation/src/types.py`, `system_prompt.py`

## Current Status (as of 2026-03-12)
- **Plans 1-5: COMPLETE** — All screens built, navigation wired, Supabase connected
- **Supabase project:** Active at `https://oiyrejablirpqxphgxli.supabase.co`
- **Known issues fixed:** Infinite submission list loop (SubmissionFilters equality), dashboard spinner (DateRange recreated on each build), RLS recursive policy (is_admin() SECURITY DEFINER)
- **Remaining work:** Edge function deployment, FCM push notifications, HIPAA hardening, UI polish, app store prep

## Running the App
```bash
flutter run -d linux \
  --dart-define=SUPABASE_URL=https://oiyrejablirpqxphgxli.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```
Anon key rotates when Supabase project is paused/restored — get current key from Supabase dashboard > Settings > API.

## UI/UX Design Decisions
- **Navigation:** Bottom tab bar — Rep: Home, Submissions, Notifications, Settings; Admin: Dashboard, Submissions, Notifications, Admin
- **New Submission:** FAB on Home tab only → request type picker (2x3 grid) → wizard form (toggle to single-page) → confirmation → success
- **Rep Home:** Feed of 10 most recent submissions + FAB
- **Admin Home:** Dashboard with status counts + activity feed
- **Notifications:** In-app notification center (bell icon with badge) + push notifications
- **Status model:** Fixed list (pending, in progress, completed, cancelled) with admin notes
- **Priority:** Toggle switch (normal/urgent)
- **Theme:** Material 3, blue (#1565C0), black (#1A1A1A), white — cards with subtle borders (no shadows), soft tinted status badges, 430px max width for mobile-first desktop testing

## Conventions
- HIPAA compliance is non-negotiable — no PHI in logs, encrypted storage, RLS on all tables
- US data residency only
- No self-registration; admin creates all accounts
- Commit messages must NOT contain any references to Claude or AI co-authoring
- Mobile-first development — all layouts designed for ~430px width
- Riverpod `.family` providers: parameter classes MUST implement `==` and `hashCode`
- `DateRange` / filter objects: store in state, don't recreate in getters (causes infinite rebuilds)
