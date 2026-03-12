# Implementation Plan 6: Edge Functions, Notifications Backend & FCM Push

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Deploy Supabase Edge Functions, set up the notifications table, wire FCM push notifications, and make the create-user edge function work so admins can create users from the app.

**Prerequisites:** Implementation Plans 1–5 completed. Supabase project active.

**Design Spec:** `DESIGN.md` — Notifications section

---

## Task 1: Notifications Table Migration

**Context:** The `notifications` table was defined in the original migration but needs to be verified/created. The in-app notification UI already exists but has no data source.

- [ ] **Step 1: Create notifications migration**

```sql
-- supabase/migrations/002_notifications.sql

-- Notifications table for in-app notification center
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  submission_id uuid REFERENCES public.submissions(id) ON DELETE SET NULL,
  is_read boolean DEFAULT false NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can only read their own notifications
CREATE POLICY "Users read own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update (mark read) their own notifications
CREATE POLICY "Users update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Service role (edge functions) can insert notifications
CREATE POLICY "Service role inserts notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (true);

-- Index for fast queries
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_user_unread ON public.notifications(user_id, is_read) WHERE NOT is_read;
```

- [ ] **Step 2: Run migration in Supabase SQL editor**

- [ ] **Step 3: Commit migration file**

---

## Task 2: Deploy Edge Functions

**Context:** Edge function code exists in `supabase/functions/` but has never been deployed. These functions handle:
- `on-submission-created`: Creates in-app notifications for admins, sends Google Chat webhook
- `on-status-updated`: Creates in-app notification for the rep, sends FCM push
- `create-user`: Server-side user creation using admin SDK (required because client can't call `auth.admin`)

- [ ] **Step 1: Review and update edge function code**

Review each function in `supabase/functions/` and ensure:
- `on-submission-created/index.ts` inserts into `notifications` table for all admin users
- `on-status-updated/index.ts` inserts into `notifications` table for the submitting rep
- `create-user/index.ts` creates auth user + profile row in a transaction
- All functions use `SUPABASE_SERVICE_ROLE_KEY` (not anon key) for admin operations

- [ ] **Step 2: Set up Supabase database webhooks**

In Supabase dashboard > Database > Webhooks:
- Create webhook on `submissions` table INSERT → calls `on-submission-created`
- Create webhook on `submissions` table UPDATE (when `status` column changes) → calls `on-status-updated`

- [ ] **Step 3: Deploy functions via Supabase CLI or dashboard**

```bash
# If using Supabase CLI:
supabase functions deploy on-submission-created
supabase functions deploy on-status-updated
supabase functions deploy create-user
```

- [ ] **Step 4: Update create_user_screen.dart to call edge function**

The create user screen currently may call Supabase auth directly (which won't work from client). Update to call the `create-user` edge function instead.

- [ ] **Step 5: Test notification flow end-to-end**
- Create a submission → verify notification appears for admin
- Update submission status as admin → verify notification appears for rep
- Create a user as admin → verify user appears in auth + profiles

- [ ] **Step 6: Commit**

---

## Task 3: Firebase Cloud Messaging (FCM) Setup

**Context:** Push notifications require FCM for both iOS and Android. This is a significant setup task.

- [ ] **Step 1: Create Firebase project**
- Go to Firebase Console → Add project
- Add Android app (package name from `android/app/build.gradle`)
- Add iOS app (bundle ID from Xcode)
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

- [ ] **Step 2: Add Flutter dependencies**

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^latest
  firebase_messaging: ^latest
```

- [ ] **Step 3: Initialize Firebase in main.dart**

```dart
await Firebase.initializeApp();
```

- [ ] **Step 4: Create push notification service**

```dart
// lib/services/push_notification_service.dart
// - Request notification permissions
// - Get FCM token
// - Save token to push_tokens table in Supabase
// - Handle foreground/background/terminated notification taps
// - Deep link to submission detail screen
```

- [ ] **Step 5: Create push_tokens table migration**

```sql
-- supabase/migrations/003_push_tokens.sql
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  token text NOT NULL,
  platform text NOT NULL, -- 'android' or 'ios'
  created_at timestamptz DEFAULT now() NOT NULL,
  UNIQUE(user_id, token)
);

ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own tokens"
  ON public.push_tokens FOR ALL
  USING (auth.uid() = user_id);
```

- [ ] **Step 6: Update on-status-updated edge function to send FCM**

```typescript
// Look up rep's FCM token from push_tokens table
// Send FCM message via Firebase Admin SDK
// Include submission_id in data payload for deep linking
```

- [ ] **Step 7: Wire FCM token registration on login**

In auth_providers.dart, after successful sign-in:
- Get FCM token
- Upsert into push_tokens table
- Listen for token refresh and update

- [ ] **Step 8: Test push notification flow**
- Login on a real device (not Linux desktop — FCM doesn't work on desktop)
- Have admin update a submission status
- Verify push notification received
- Tap notification → verify deep link to submission detail

- [ ] **Step 9: Commit**

---

## Task 4: Google Chat & Gmail Notifications (Backend-Only)

**Context:** The phone automation system sends Google Chat webhook and Gmail notifications. The edge functions should replicate this.

- [ ] **Step 1: Set up Google Chat webhook URL**
- Get webhook URL from Google Chat space settings
- Store as Supabase Edge Function secret: `GOOGLE_CHAT_WEBHOOK_URL`

- [ ] **Step 2: Set up Gmail OAuth2 (if needed)**
- Reference: `../shukla-phone-automation/src/email_service.py`
- Store credentials as edge function secrets
- Or: Use Supabase's built-in email (simpler but less control)

- [ ] **Step 3: Update on-submission-created to send Google Chat + email**
- Format message card matching phone automation format
- Reference: `../shukla-phone-automation/src/google_chat_service.py`

- [ ] **Step 4: Test end-to-end**
- Create a submission
- Verify Google Chat message appears
- Verify email notification sent

- [ ] **Step 5: Commit**
