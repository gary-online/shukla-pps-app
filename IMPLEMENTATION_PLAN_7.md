# Implementation Plan 7: UI/UX Polish & Bug Fixes

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Make the app look and feel like a polished, professional mobile app. Fix remaining bugs, improve visual hierarchy, responsiveness, and user experience.

**Prerequisites:** Implementation Plans 1–6 completed (or in progress — this plan can run in parallel with Plan 6).

**Design Spec:** `DESIGN.md`

---

## Task 1: UX/UI Design Audit & Fixes

**Context:** A UX/UI design advisor audit is being run. Apply the findings here. Common areas needing work:

- [ ] **Step 1: Typography & visual hierarchy**
- Ensure consistent heading sizes across all screens
- Section headers should use `titleSmall` or `titleMedium` with `FontWeight.w600`
- Body text 14-15sp, secondary text 12-13sp
- Ensure proper contrast ratios (4.5:1 minimum per WCAG AA)

- [ ] **Step 2: Consistent card styling**
- All cards: white background, 1px `#E5E7EB` border, 12dp radius, no shadows
- Cards should have consistent internal padding (14-16px)
- Section headers outside cards, not inside

- [ ] **Step 3: Touch targets & spacing**
- All tappable elements minimum 48x48dp
- Buttons minimum 52dp height
- Consistent spacing between elements (8, 12, 16, 20, 24dp scale)
- Bottom padding on all scrollable lists (80dp to clear FAB)

- [ ] **Step 4: Loading & error states**
- Consistent loading indicator pattern across all screens
- Error states: cloud-off icon + message + outlined retry button
- Empty states: icon in tinted rounded box + message + optional action button
- No raw error messages shown to users

- [ ] **Step 5: Commit**

---

## Task 2: Screen-Specific Polish

- [ ] **Step 1: Login screen**
- Logo in blue rounded square
- Subtitle text under app name
- Error messages in tinted red container with icon
- Keyboard-aware (scroll when keyboard opens)
- "Done" action on password field submits form

- [ ] **Step 2: Admin dashboard**
- Status count cards with icon in tinted circle
- Proper error/empty states for both counts and activity sections
- Segmented button styling

- [ ] **Step 3: Submission list**
- Filter bottom sheet: scrollable, safe area aware, no overflow
- Consistent card margins
- Pull-to-refresh on all list views

- [ ] **Step 4: Submission detail**
- Header card with icon box + status badge
- Details card with labeled rows (label column + value column)
- Timeline entries grouped in a single card with dividers
- Admin update button properly styled

- [ ] **Step 5: Settings screen**
- Profile card with avatar circle (first letter)
- Role displayed as badge
- Logout with confirmation dialog

- [ ] **Step 6: Request type picker**
- Cards should be visually distinct and tappable
- Good spacing between cards
- Icon + label centered in each card

- [ ] **Step 7: Submission form (wizard + single page)**
- Progress indicator visually clear
- Step counter text
- Field spacing consistent
- Back/Next buttons properly sized

- [ ] **Step 8: Notification center**
- Proper empty state when no notifications
- Unread indicator (blue dot)
- Pull-to-refresh
- "Mark all as read" in app bar

- [ ] **Step 9: Admin user management**
- Search field + create user button (stacked, not side by side)
- User list items with role badge and active/inactive indicator
- Empty state and error handling

- [ ] **Step 10: Commit**

---

## Task 3: Navigation & Transitions

- [ ] **Step 1: Bottom navigation polish**
- Outlined/filled icon variants for unselected/selected
- Proper indicator color
- Divider line above nav bar

- [ ] **Step 2: App bar polish**
- Logo in blue rounded square
- Settings gear icon for admin
- Divider line below app bar

- [ ] **Step 3: Page transitions**
- Verify go_router transitions are smooth
- Bottom sheets should have proper animations
- Ensure back navigation works correctly on all screens

- [ ] **Step 4: Commit**

---

## Task 4: Mobile-First Responsive Design

- [ ] **Step 1: Max width constraint**
- Verify 430px max width constraint works correctly
- Content should be centered on wider screens
- No horizontal overflow on any screen

- [ ] **Step 2: Keyboard handling**
- Forms scroll when keyboard opens
- Bottom sheets account for keyboard insets
- No content hidden behind keyboard

- [ ] **Step 3: Safe area handling**
- All screens respect safe area insets
- Bottom sheets respect bottom safe area
- No content hidden behind system UI

- [ ] **Step 4: Text overflow**
- All text fields handle long text (ellipsis or wrap as appropriate)
- Request type labels, facility names, surgeon names truncate properly
- No text overflow warnings in debug mode

- [ ] **Step 5: Commit**

---

## Task 5: Cleanup & Code Quality

- [ ] **Step 1: Remove all debug logging**
- Remove any remaining `debugPrint` statements added during development
- No sensitive data in logs (HIPAA requirement)

- [ ] **Step 2: Remove unused imports**
- Run `flutter analyze` and fix all warnings
- Remove unused variables and imports

- [ ] **Step 3: Verify all screens**
- Walk through every screen in the app
- Verify no layout issues, overflow, or crashes
- Test both admin and rep flows

- [ ] **Step 4: Final commit**
