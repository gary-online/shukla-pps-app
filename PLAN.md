# Shukla PPS Mobile App — Implementation Plan

## Context

Shukla Medical currently has an AI phone automation system (`shukla-phone-automation`) where sales reps call in to report surgical cases, request shipping labels, check tray availability, etc. The company wants a mobile app (iOS + Android) that lets reps submit the same information via a form instead of a phone call. Shukla is a government contractor subject to HIPAA regulations.

**Tech stack:** Flutter + Supabase (with repository pattern for future migration to self-hosted DB + Epicor ERP).

**Design spec:** See `DESIGN.md` for the complete UI/UX design spec covering navigation, screen layouts, submission flow, and visual theming.

---

## Progress Overview

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Project Foundation | COMPLETE |
| 2 | Authentication | COMPLETE |
| 3 | Submission Form | COMPLETE |
| 4 | Dashboard & History | COMPLETE |
| 5 | Notifications (partial) | IN PROGRESS — UI built, edge functions not deployed, no FCM |
| 6 | Admin User Management (partial) | IN PROGRESS — screens built, edge function not deployed |
| 6.5 | UI/UX Polish | NOT STARTED |
| 7 | Hardening & Compliance | NOT STARTED |
| 8 | Epicor Integration (future) | NOT STARTED |

### Known Issues Fixed
- Infinite submission list loop — `SubmissionFilters` needed `==`/`hashCode` for Riverpod `.family`
- Dashboard spinner — `DateRange` recreated on every build; now stored in state
- RLS recursive policy — `is_admin()` SECURITY DEFINER function created
- Various layout issues — Material ancestor missing, infinite width, overflow

### Supabase Setup
- Project URL: `https://oiyrejablirpqxphgxli.supabase.co`
- Migration `001_initial_schema.sql` applied manually (4 parts)
- `is_admin()` SECURITY DEFINER function added to fix recursive RLS
- Test user: `admin@shukla.test` (admin role)

---

## Phase 1: Project Foundation

**Goal:** Flutter project scaffolded, Supabase project created, data models defined.

### 1.1 Initialize Flutter project
- Create Flutter project in `/home/arch/Projects/shukla-pps-app`
- Set up folder structure:
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
- Add dependencies: `supabase_flutter`, `flutter_riverpod`, `go_router`, `flutter_secure_storage`, `freezed`, `json_serializable`, `flutter_form_builder`, `form_builder_validators`, `intl`, `connectivity_plus`

### 1.2 Define Dart models
Mirror the existing Python models from `/home/arch/Projects/shukla-phone-automation/src/types.py`:
- **6 request types:** PPS Case Report, FedEx Label Request, Bill Only Request, Tray Availability, Delivery Status, Other
- **22 tray types:** Mini, Maxi, Blade, Shoulder-Blade, Modular Hip, Copter, Broken Nail, Lag, Screw-Flex, Anterior Hip, Vise, Screw, Hip, Knee, Nail, Spine-Cervical, Spine-Thoracic & Lumbar, Spine-Instruments, Shoulder, Trephine, Cup, Cement
- **Priorities:** normal, urgent
- **Submission statuses:** pending, in_progress, completed, cancelled
- **Submission model fields:** rep_id, request_type, tray_type, surgeon, facility, surgery_date, details, priority, status, status_note, source

### 1.3 Set up Supabase project
- Create Supabase project in **US region** (data residency requirement)
- Create tables: `profiles`, `submissions`, `submission_status_history`, `audit_log`, `push_tokens`
- Enable Row Level Security (RLS) on all tables:
  - Reps: read/insert own submissions, read own profile
  - Admins: read/update all submissions, manage profiles
  - Audit log: insert-only for all, read for admins
- Create triggers: auto-update `updated_at`, auto-log status changes to `submission_status_history`

### 1.4 Repository pattern (DB abstraction layer)
- Abstract interfaces: `AuthRepository`, `SubmissionRepository`, `NotificationRepository`
- Supabase implementations: `AuthRepositoryImpl`, `SubmissionRepositoryImpl`
- **Rule:** Nothing outside `data/` imports `supabase_flutter` — enables future swap to self-hosted API for Epicor integration
- Riverpod providers wire implementations; swap happens in one place

---

## Phase 2: Authentication

**Goal:** Login screen, session management, HIPAA-compliant security.

### 2.1 Login screen
- Email + password fields, login button, Shukla branding
- No self-registration (admin creates accounts only)
- Calls `supabase.auth.signInWithPassword()`
- Stores tokens in `flutter_secure_storage` (Keychain/Keystore — encrypted at rest)

### 2.2 Session management (HIPAA)
- Access token TTL: 15 minutes
- Refresh token TTL: 8 hours (one work day)
- App-level inactivity timeout: 5 minutes → lock screen overlay, re-enter password
- Full logout on refresh token expiry
- Password minimum: 12 characters

### 2.3 Account management
- Admin creates accounts via Supabase Edge Function (`supabase.auth.admin.createUser()`)
- Admin can deactivate accounts (sets `is_active = false`)
- App checks `is_active` on auth state change; forces logout if deactivated

### 2.4 Audit logging
- Log every login, logout, failed login attempt to `audit_log` table

---

## Phase 3: Submission Form

**Goal:** Reps can submit reports with the same data the phone system collects.

### 3.1 Request type selector
- Card-based picker for the 6 request types (2-column grid — see `DESIGN.md`)

### 3.2 Dynamic form per request type
Wizard mode by default (one section at a time with progress indicator). Toggle to single-page form mode; preference remembered locally. Match field requirements from `/home/arch/Projects/shukla-phone-automation/src/system_prompt.py` (lines 39-76):

| Request Type | Fields |
|---|---|
| PPS Case Report | surgeon, facility, tray_type, surgery_date, details |
| FedEx Label Request | facility (destination), tray_type, details (PO number) |
| Bill Only Request | surgeon, facility, tray_type, surgery_date, details |
| Tray Availability | tray_type, surgery_date (date needed), facility |
| Delivery Status | tray_type, facility (destination), details (tracking #) |
| Other | details (freeform) |

All forms also include: priority toggle (normal/urgent)

### 3.3 Tray type picker
- Searchable dropdown over the 22-item catalog
- Fuzzy matching (like the phone system does with similar names)

### 3.4 Submission flow
- Request type picker → dynamic form → confirmation screen (read-back, like phone system step 4) → submit → success screen
- Success screen offers "View Submission" or "Submit Another"
- Audit log entry on submission creation

---

## Phase 4: Dashboard & History

**Goal:** Reps see their submissions; admins see everything.

### 4.1 Navigation structure
- Bottom tab navigation (see `DESIGN.md` for full spec)
- Rep tabs: Home (feed + FAB), Submissions, Notifications, Settings
- Admin tabs: Dashboard, Submissions, Notifications, Admin
- FAB ("New Submission") visible on Home tab only

### 4.2 Rep home screen
- Feed of 10 most recent submissions with status badges
- Pull-to-refresh + Supabase Realtime for live updates

### 4.3 Submission list
- Paginated list with filters: by status, request type, date range
- Pull-to-refresh + Supabase Realtime for live updates
- Submission card shows: request type, tray, facility, status badge, timestamp

### 4.4 Submission detail
- Full submission data + status timeline (from `submission_status_history`)
- Real-time status updates via Supabase stream

### 4.5 Admin dashboard
- Status summary cards (Pending, In Progress, Completed counts) with time range toggle (Today/Week/Month)
- View all submissions across all reps
- Filter by rep, status, request type
- Update submission status via bottom sheet (fixed status list + optional notes)

---

## Phase 5: Notifications

**Goal:** Team notifications on new submissions, push notifications on status changes.

### 5.1 Supabase Edge Functions
- `on-submission-created`: sends Google Chat webhook + Gmail notification (same format as phone system, ref: `google_chat_service.py`, `email_service.py`)
- `on-status-updated`: sends FCM push notification to the submitting rep

### 5.2 Push notifications in Flutter
- Firebase Cloud Messaging setup (iOS + Android)
- Register FCM token on login → `push_tokens` table
- Deep link from notification → submission detail screen
- Reps: notified on status changes to their submissions
- Admins: notified on new submissions

### 5.3 In-app notification center
- Bell icon with unread badge count in app bar
- Notification list with blue dot for unread items
- "Mark all as read" action
- Tapping a notification opens submission detail
- Rep format: "Your [Request Type] was marked [Status]"
- Admin format: "[Rep Name] submitted a [Request Type]"

### 5.4 In-app real-time
- Supabase Realtime subscriptions on submissions table
- Dashboard updates live without polling

---

## Phase 6: Admin User Management

**Goal:** Admins can create and manage rep accounts.

- Create user screen: email, password, full name, role
- User list with activate/deactivate toggle
- Edge Function for server-side user creation (admin SDK)

---

## Phase 7: Hardening & Compliance

**Goal:** Production-ready, HIPAA-compliant, app store ready.

### HIPAA checklist
- [ ] Supabase BAA executed (HIPAA-compliant plan)
- [ ] US data residency verified (no replication outside US)
- [ ] TLS 1.2+ enforced on all connections
- [ ] Certificate pinning in Flutter app
- [ ] Encryption at rest: Supabase (AES-256), device (Keychain/Keystore)
- [ ] RLS policies verified (pentest: reps cannot access other reps' data)
- [ ] Audit log covers all actions (login, logout, create, view, update)
- [ ] Session timeouts working (5min inactivity, 15min token, 8hr max)
- [ ] No PHI stored — details field guidance warns reps not to enter patient identifiers
- [ ] Audit log retention: minimum 6 years
- [ ] Code obfuscation: `--obfuscate --split-debug-info` on release builds

### App store prep
- Apple Developer account ($99/year)
- Google Play Developer account ($25 one-time)
- App signing, provisioning profiles
- Unlisted on App Store (not in search results, distributed via direct link)

---

## Phase 8 (Future): Epicor Integration

- Build custom REST API on self-hosted infrastructure (potentially FedRAMP-authorized cloud if required)
- Create `SubmissionRepositoryHttpImpl` and `AuthRepositoryHttpImpl`
- Migrate data from Supabase to self-hosted PostgreSQL
- Swap provider bindings (one-line change per repository)
- Connect to Epicor for quote generation

---

## Key Reference Files

| File | What to reuse |
|---|---|
| `shukla-phone-automation/src/types.py` | Request types, tray catalog, priorities, data model |
| `shukla-phone-automation/src/system_prompt.py` | Per-request-type field requirements (lines 39-76) |
| `shukla-phone-automation/src/google_chat_service.py` | Chat notification card format |
| `shukla-phone-automation/src/email_service.py` | Email notification format + OAuth2 flow |
| `shukla-phone-automation/src/call_processor.py` | Parallel dispatch pattern for notifications |

## Verification

- **Auth:** Login with test account, verify session timeout, verify deactivated account gets locked out
- **Submissions:** Create one of each request type, verify data in Supabase dashboard, verify Google Chat + Gmail notifications fire
- **RLS:** Log in as rep A, confirm cannot see rep B's submissions
- **Push:** Update submission status as admin, verify rep receives push notification
- **Audit:** Review `audit_log` table — every action should be logged
- **Compliance:** Run through HIPAA checklist above, all items checked
