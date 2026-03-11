# Shukla PPS App

## Project Overview
Flutter + Supabase mobile app (iOS + Android) for Shukla Medical sales reps to submit surgical case reports, request shipping labels, check tray availability, etc. Replaces the existing AI phone automation system with a form-based workflow.

Shukla is a government contractor subject to HIPAA regulations.

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Supabase (auth, database, edge functions, realtime)
- **State management:** Riverpod
- **Routing:** go_router
- **Future:** Repository pattern enables migration to self-hosted DB + Epicor ERP

## Architecture
- Repository pattern: nothing outside `lib/data/` imports `supabase_flutter`
- Abstract interfaces in `lib/data/repositories/`
- Supabase implementations behind those interfaces
- Riverpod providers wire implementations — swap happens in one place

## Project Structure
```
lib/
  config/        # app_config, constants, theme
  models/        # request_type, priority, submission, user_profile, submission_status
  data/
    datasources/ # supabase_datasource, local_datasource
    repositories/ # abstract interfaces + supabase implementations
  services/      # notification, session, audit, connectivity
  providers/     # riverpod providers
  screens/       # auth, home, submission, admin, settings
  widgets/       # reusable UI components
```

## Key Reference
- Implementation plan: `PLAN.md`
- UI/UX design spec: `DESIGN.md`
- Phone automation source models: `../shukla-phone-automation/src/types.py`
- Phone automation field requirements: `../shukla-phone-automation/src/system_prompt.py`

## UI/UX Design Decisions
- **Navigation:** Bottom tab bar — Rep: Home, Submissions, Notifications, Settings; Admin: Dashboard, Submissions, Notifications, Admin
- **New Submission:** FAB on Home tab only → request type picker (2x3 grid) → wizard form (toggle to single-page) → confirmation → success
- **Rep Home:** Feed of 10 most recent submissions + FAB
- **Admin Home:** Dashboard with status counts + activity feed
- **Notifications:** In-app notification center (bell icon with badge) + push notifications
- **Status model:** Fixed list (pending, in progress, completed, cancelled) with admin notes
- **Priority:** Toggle switch (normal/urgent)
- **Theme:** Blue, black, white (Shukla brand colors — exact hex TBD)

## Conventions
- HIPAA compliance is non-negotiable — no PHI in logs, encrypted storage, RLS on all tables
- US data residency only
- No self-registration; admin creates all accounts
- Commit messages must NOT contain any references to Claude or AI co-authoring
