# Implementation Plan 8: HIPAA Hardening, Compliance & App Store Prep

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Make the app production-ready, HIPAA-compliant, and ready for app store distribution (unlisted/private).

**Prerequisites:** Implementation Plans 1–7 completed.

**Design Spec:** `DESIGN.md`
**HIPAA Requirements:** `PLAN.md` — Phase 7

---

## Task 1: Supabase HIPAA Compliance

- [ ] **Step 1: Upgrade Supabase plan**
- Supabase HIPAA compliance requires the Pro plan or higher
- Execute Business Associate Agreement (BAA) with Supabase
- Document BAA execution date and parties

- [ ] **Step 2: Verify US data residency**
- Confirm Supabase project is in a US region
- Verify no data replication outside US
- Document region and any cross-region considerations

- [ ] **Step 3: Verify TLS enforcement**
- All Supabase connections use TLS 1.2+
- Verify in Flutter app that all HTTP calls go through HTTPS
- No plaintext HTTP calls anywhere in codebase

- [ ] **Step 4: Verify encryption at rest**
- Supabase: AES-256 encryption at rest (built-in on managed Postgres)
- Device: flutter_secure_storage uses Keychain (iOS) / EncryptedSharedPreferences (Android)
- Document encryption specifications

- [ ] **Step 5: Commit documentation**

---

## Task 2: RLS Policy Audit

- [ ] **Step 1: Audit all RLS policies**

Verify each table has correct policies:

| Table | Rep Access | Admin Access |
|-------|-----------|-------------|
| profiles | Read own | Read all, update all |
| submissions | Read/insert own | Read/update all |
| submission_status_history | Read own submission's history | Read all |
| notifications | Read/update own | Read/update own |
| push_tokens | Manage own | Manage own |
| audit_log | None | Read all |

- [ ] **Step 2: Penetration test RLS**
- Log in as Rep A
- Attempt to read Rep B's submissions via Supabase client → should fail
- Attempt to read all profiles → should only return own
- Attempt to update another rep's submission → should fail
- Attempt to create a user (admin action) → should fail
- Document test results

- [ ] **Step 3: Fix any RLS gaps found**

- [ ] **Step 4: Commit**

---

## Task 3: Audit Logging

- [ ] **Step 1: Create audit_log table (if not exists)**

```sql
CREATE TABLE IF NOT EXISTS public.audit_log (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id),
  action text NOT NULL,          -- 'login', 'logout', 'login_failed', 'submission_created', 'submission_viewed', 'status_updated', 'user_created', 'user_deactivated'
  resource_type text,            -- 'submission', 'user', 'session'
  resource_id text,              -- ID of the affected resource
  metadata jsonb,                -- Additional context (request_type, old_status, new_status, etc.)
  ip_address text,
  created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- Insert-only for authenticated users
CREATE POLICY "Authenticated users insert audit logs"
  ON public.audit_log FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Read for admins only
CREATE POLICY "Admins read audit logs"
  ON public.audit_log FOR SELECT
  USING (public.is_admin());

-- Index for queries
CREATE INDEX idx_audit_log_user_id ON public.audit_log(user_id);
CREATE INDEX idx_audit_log_action ON public.audit_log(action);
CREATE INDEX idx_audit_log_created_at ON public.audit_log(created_at);
```

- [ ] **Step 2: Create audit service in Flutter**

```dart
// lib/services/audit_service.dart
// - logLogin(userId)
// - logLogout(userId)
// - logLoginFailed(email)
// - logSubmissionCreated(submissionId, requestType)
// - logSubmissionViewed(submissionId)
// - logStatusUpdated(submissionId, oldStatus, newStatus)
```

- [ ] **Step 3: Wire audit logging into existing flows**
- Auth providers: log login, logout, login failures
- Submission creation: log on successful create
- Submission detail: log on view
- Status update: log on admin status change

- [ ] **Step 4: Verify audit log retention**
- Supabase retains data as long as the table exists
- HIPAA requires minimum 6 years retention
- Document retention policy

- [ ] **Step 5: Commit**

---

## Task 4: Session Security

- [ ] **Step 1: Verify session timeouts**
- Access token TTL: 15 minutes (configured in Supabase dashboard > Auth > Settings)
- Refresh token TTL: 8 hours (one work day)
- Verify in Supabase dashboard that these are set correctly

- [ ] **Step 2: Verify inactivity lock**
- App-level inactivity timeout: 5 minutes
- Lock screen overlay (already built in `lock_screen.dart`)
- Test: leave app idle for 5 minutes → lock screen should appear
- Re-enter password to unlock

- [ ] **Step 3: Certificate pinning**

```dart
// lib/config/certificate_pinning.dart
// Pin Supabase's TLS certificate
// Use http_certificate_pinning package or custom SecurityContext
// Prevents MITM attacks on network traffic
```

- [ ] **Step 4: PHI warning**
- Add guidance text on the "Details" field in submission form:
  "Do not include patient names, dates of birth, or other identifying information"
- This is a HIPAA safeguard — the system should not store PHI

- [ ] **Step 5: Commit**

---

## Task 5: Release Build Configuration

- [ ] **Step 1: Code obfuscation**

```bash
flutter build apk --obfuscate --split-debug-info=build/debug-info
flutter build ipa --obfuscate --split-debug-info=build/debug-info
```

- [ ] **Step 2: App signing**
- Android: Generate upload keystore, configure `key.properties`
- iOS: Configure provisioning profiles in Xcode

- [ ] **Step 3: App icons & splash screen**
- Create app icon from Shukla branding (blue rounded square with medical icon)
- Configure splash screen (white background, Shukla logo centered)
- Use `flutter_launcher_icons` and `flutter_native_splash` packages

- [ ] **Step 4: App metadata**
- Bundle ID: `com.shuklamedical.shukla_pps`
- App name: "Shukla PPS"
- Version: 1.0.0+1
- Min SDK: Android 21 (5.0), iOS 13.0

- [ ] **Step 5: Commit**

---

## Task 6: App Store Submission

- [ ] **Step 1: Apple App Store (TestFlight → Unlisted)**
- Apple Developer account ($99/year)
- Create app in App Store Connect
- Upload build via Xcode or `flutter build ipa`
- Set distribution to "Unlisted" (not searchable, distributed via direct link)
- Submit for review

- [ ] **Step 2: Google Play Store (Internal Testing → Private)**
- Google Play Developer account ($25 one-time)
- Create app in Google Play Console
- Upload AAB via `flutter build appbundle`
- Set up internal testing track or private distribution
- Submit for review

- [ ] **Step 3: Distribution**
- Share direct download links with Shukla Medical team
- Document installation instructions for reps

- [ ] **Step 4: Commit final release configuration**

---

## HIPAA Compliance Checklist

| Requirement | Status | Notes |
|------------|--------|-------|
| Supabase BAA executed | [ ] | Requires Pro plan |
| US data residency | [ ] | Verify project region |
| TLS 1.2+ enforced | [ ] | All HTTPS |
| Certificate pinning | [ ] | Custom SecurityContext |
| Encryption at rest (server) | [ ] | Supabase AES-256 |
| Encryption at rest (device) | [ ] | Keychain/EncryptedSharedPrefs |
| RLS policies verified | [ ] | Pentest documented |
| Audit log — all actions | [ ] | login, logout, CRUD |
| Session timeouts | [ ] | 5min inactivity, 15min token, 8hr max |
| No PHI stored | [ ] | Warning text on details field |
| Audit log retention 6yr | [ ] | Supabase retention policy |
| Code obfuscation | [ ] | --obfuscate flag |
| Minimum password 12 chars | [ ] | Enforced in auth |
| No self-registration | [ ] | Admin-only account creation |
