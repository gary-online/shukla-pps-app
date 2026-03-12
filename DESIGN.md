# Shukla PPS App — UI/UX Design Spec

## Overview

Mobile app (iOS + Android) for Shukla Medical sales reps to submit surgical case reports, request shipping labels, check tray availability, and more. Replaces the existing AI phone automation system with a form-based workflow. Built with Flutter + Supabase.

**Primary users:** Sales reps in the field (not very tech-savvy, but comfortable with mobile apps)
**Secondary users:** Admins managing submissions and user accounts

**Design principles:**
- Rep-first — optimized for quick submissions on the go
- Standard mobile app patterns with generous touch targets
- Better than the current non-mobile-friendly website experience
- Don't sacrifice functionality for simplicity

---

## Navigation Approaches Evaluated

### Approach A: Bottom Tab Navigation (Selected)

- Bottom tabs: Home, Submissions, Notifications, Settings (rep) / Admin (admin)
- "New Submission" is a Floating Action Button (FAB)
- Admin users get an "Admin" tab replacing Settings (settings moves to gear icon in app bar)
- Familiar pattern — feels like most apps reps already use

**Pros:** Dead simple mental model, one tap to any section, very mobile-native
**Cons:** Limited to ~5 tabs, admin features need to fit within that

### Approach B: Drawer Navigation

- Hamburger menu slides out with all sections
- Home screen is the feed + action button
- Admin sections appear in the drawer for admin users

**Pros:** Unlimited menu items, scales well if features grow
**Cons:** Hidden navigation — reps have to remember what's in the menu, extra tap to get anywhere

### Approach C: Hub-and-Spoke

- Home screen is a grid of large cards/buttons: "New Submission", "My Submissions", "Notifications", etc.
- Each card opens its own flow, back button returns to the hub
- Very simple, almost kiosk-like

**Pros:** Very discoverable, great for non-tech-savvy users
**Cons:** Extra tap to do anything, wastes the home screen on navigation instead of useful info

**Decision:** Approach A — Bottom Tab Navigation. Most natural mobile pattern, one-tap access to everything, center FAB for the primary action.

---

## Screen Inventory & Navigation

### Rep Tabs

| Tab | Icon | Screen |
|-----|------|--------|
| Home | house | Feed of recent submissions + FAB for "New Submission" |
| Submissions | list | Full paginated list with filters (status, type, date) |
| Notifications | bell (with badge) | Notification center — status change history |
| Settings | gear | Profile, password change, app preferences |

### Admin Tabs

| Tab | Icon | Screen |
|-----|------|--------|
| Dashboard | grid | Submission counts by status, recent activity across all reps |
| Submissions | list | All submissions, filterable by rep, status, type |
| Notifications | bell (with badge) | Notification center |
| Admin | shield | User management (create, activate/deactivate accounts) |

Settings for admins is accessible via a gear icon in the app bar.

Admins have exactly 4 bottom tabs: Dashboard, Submissions, Notifications, Admin. The Settings screen is accessed via a gear icon in the top app bar, not as a tab.

### Additional Screens (navigated to, not in tabs)

- Login
- Lock screen (inactivity timeout)
- New Submission wizard (multi-step)
- New Submission single-page (togglable)
- Confirmation/review screen
- Submission detail + status timeline
- Success screen

---

## Login & Lock Screen

### Login Screen

- Shukla logo centered at top
- Email field + password field
- "Log In" button (primary blue, full width)
- Password minimum: 12 characters (show hint below field)
- No "Sign Up" or "Forgot Password" link — admin manages all accounts
- Error states:
  - Wrong credentials: "Invalid email or password"
  - Deactivated account: "Your account has been deactivated. Contact your administrator."
  - Network error: "Unable to connect. Check your internet connection."

### Lock Screen (Inactivity Timeout)

- Triggered after 5 minutes of inactivity
- Full-screen overlay on top of the current screen (preserves navigation state)
- Shows Shukla logo + "Session locked" message
- Password field to re-authenticate
- If refresh token has expired (8 hours), redirect to full login screen instead

---

## Submission Flow

### Step 1 — Request Type Picker

- 6 cards in a 2-column grid, each with an icon and label
- PPS Case Report, FedEx Label Request, Bill Only Request, Tray Availability, Delivery Status, Other
- Tapping a card advances to step 2

### Step 2 — Form (wizard mode by default)

- Fields appear one section at a time based on request type
- Progress indicator at the top (e.g., step 2 of 4) — hidden in single-page mode
- Toggle/link at the top: "Show all fields" switches to single-page form mode immediately (re-renders current form)
- User preference for form mode is remembered locally
- **Priority widget:** Toggle switch defaulting to "Normal". When set to "Urgent", the toggle turns red.
- **FAB is hidden** during the entire submission flow

#### Field mapping per request type

| Request Type | Fields |
|---|---|
| PPS Case Report | Surgeon, Facility, Tray Type, Surgery Date, Details, Priority |
| FedEx Label Request | Facility (destination), Tray Type, Details (PO number), Priority |
| Bill Only Request | Surgeon, Facility, Tray Type, Surgery Date, Details, Priority |
| Tray Availability | Tray Type, Surgery Date (date needed), Facility, Priority |
| Delivery Status | Tray Type, Facility (destination), Details (tracking #), Priority |
| Other | Details (freeform), Priority |

#### Tray Type Picker

Searchable dropdown with fuzzy matching across the 22-item tray catalog:
Mini, Maxi, Blade, Shoulder-Blade, Modular Hip, Copter, Broken Nail, Lag, Screw-Flex, Anterior Hip, Vise, Screw, Hip, Knee, Nail, Spine-Cervical, Spine-Thoracic & Lumbar, Spine-Instruments, Shoulder, Trephine, Cup, Cement

### Step 3 — Confirmation Screen

- Full read-back of all entered data (mirrors the phone system's confirmation step)
- "Edit" button to go back, "Submit" button to finalize
- Priority shown prominently if set to urgent

### Step 4 — Success

- Brief success message with submission ID
- Options: "View Submission" or "Submit Another"

---

## Home Screens

### Rep Home

- Top: Shukla logo + app bar with bell icon (notification badge count)
- FAB: "New Submission" — visible on Home tab only, bottom-right
- Feed: chronological list of the 10 most recent submissions (full list on Submissions tab), each card showing:
  - Request type icon + label
  - Tray type & facility
  - Status badge (color-coded)
  - Relative timestamp ("2 hours ago")
- Pull-to-refresh + realtime updates via Supabase
- Tapping a card opens submission detail

### Admin Dashboard

- Top: Same app bar with bell icon
- Status summary cards in a row: Pending (count), In Progress (count), Completed (count)
- Time range toggle: "Today" / "This Week" / "This Month"
- Below: Recent activity feed across all reps — shows rep name on each card
- Tapping a submission opens detail where admin can update status + add notes

---

## Submission Detail & Admin Actions

### Submission Detail (shared by reps and admins)

- Header: Request type + status badge
- Card with all submission fields (surgeon, facility, tray, date, details, priority)
- Status timeline below — vertical timeline showing each status change with:
  - Status label
  - Who changed it
  - Timestamp
  - Note (if admin added one)
- Realtime updates via Supabase stream

### Admin-Only Actions

Visible when an admin views a submission:
- "Update Status" button at the bottom
- Tapping opens a bottom sheet with:
  - Status picker (fixed list: pending, in progress, completed, cancelled)
  - Notes text field (optional)
  - "Update" button
- Status change immediately appears in the timeline and triggers push notification to the rep

---

## Notifications

### Notification Center (bell icon / Notifications tab)

- List of notifications, newest first
- Each item shows: submission type, status change description, timestamp
- Unread items have a blue dot indicator
- Tapping a notification opens the submission detail
- "Mark all as read" option in the app bar

### Push Notifications

- Reps receive push when their submission status changes
- Tapping the push deep-links to the submission detail screen
- Admins receive push when a new submission is created

### Server-Side Notifications (no in-app UI)

- On submission creation, server-side Edge Functions also send Google Chat webhook and Gmail notifications to the team
- These mirror the existing phone automation notification format
- No in-app UI for these — they are backend-only

### Notification Item Format

- **Rep notifications:** "Your [Request Type] was marked [Status]" — e.g., "Your PPS Case Report was marked In Progress"
- **Admin notifications:** "[Rep Name] submitted a [Request Type]" — e.g., "John Doe submitted a PPS Case Report"

---

## Settings & Admin Panel

### Settings (Rep)

- Profile info (name, email — read-only, admin manages these)
- Change password
- Form preference toggle (wizard vs single-page)
- Notification preferences (push on/off)
- App version info
- Logout

### Admin Panel (Admin tab)

- User list with search
- Each user shows: name, email, role badge, active/inactive status
- Toggle to activate/deactivate a user
- "Create User" button — opens full-screen form: email, password (12-char minimum with hint), full name, role picker (rep/admin). Success state returns to user list with a confirmation snackbar.

---

## Visual Design & Theming

### Color Palette

- **Primary Blue:** `#1565C0` (buttons, active tabs, FAB, links, icon tints)
- **Dark Blue:** `#0D47A1` (pressed states)
- **On Primary:** `#FFFFFF` (text/icons on blue backgrounds)
- **Background/Surface:** `#F7F8FA` (scaffold, input fills)
- **Card Color:** `#FFFFFF` (cards on top of surface)
- **Text Primary:** `#1A1A1A` (body text, headings)
- **Text Secondary:** `#6B7280` (timestamps, labels, hints)
- **Divider:** `#E5E7EB` (card borders, separators)
- **Status colors:**
  - Pending: `#9E9E9E` (gray)
  - In Progress: `#1565C0` (blue)
  - Completed: `#2E7D32` (green)
  - Cancelled: `#C62828` (red)
- **Urgent priority:** `#D32F2F` (red)

### Typography

- Clean sans-serif (system default — San Francisco on iOS, Roboto on Android)
- Large, readable body text (16sp minimum)
- Bold headers for section titles

### Visual Style

- Material 3 design system
- Rounded corners on cards and buttons (12dp radius)
- Cards: white background with subtle 1px border (`#E5E7EB`), no shadows
- Status badges: soft tinted background (12% opacity of status color) with colored text (not solid pills)
- Icons in tinted rounded square containers (8% opacity background)
- Bottom sheet with drag handle
- Generous padding and touch targets (minimum 48dp, buttons 52dp height)
- Navigation bar: outlined/filled icon variants for unselected/selected states
- App bar logo: blue rounded square with white medical icon
- 430px max width constraint for mobile-first desktop testing

### Accessibility

- Minimum contrast ratio 4.5:1 for all text
- Touch targets minimum 48x48dp
- Semantic labels for screen readers

---

## Status Model

Fixed status list with admin notes:

| Status | Badge Color | Description |
|--------|-------------|-------------|
| Pending | Gray | Newly submitted, not yet reviewed |
| In Progress | Blue | Being worked on by the team |
| Completed | Green | Request fulfilled |
| Cancelled | Red | Request cancelled |

Admins can add free-text notes when changing status. All status changes are logged to `submission_status_history` with timestamp and who made the change.

---

## Error & Empty States

- **Empty submission feed (new rep):** Illustration + "No submissions yet" + "Create your first submission" button
- **Empty search/filter results:** "No results found" with suggestion to adjust filters
- **Form submission failure:** Inline error banner at top of form: "Submission failed. Please try again."
- **Network unavailable:** Persistent banner at top of screen: "You're offline" — submit button is disabled, feed shows cached data if available
- **Login failure:** Inline error below password field (see Login Screen section)

---

## Data Notes

- **`source` field:** Auto-set to `"app"` on every submission. Displayed in submission detail view as a subtle label (distinguishes app submissions from phone submissions).
- **Audit log:** All actions (login, logout, create, view, update) are logged server-side. Audit log review is done via the Supabase dashboard — there is no in-app audit log screen.
