# GlowProtocol: one-day App Store submission plan

**Target:** Submit a tested iOS build to App Store review by September 26, 2026. Submission is the deadline; review approval and public availability are controlled by Apple.

## Release definition

Ship the existing habit tracker plus a small, working Friends feature backed by Supabase. A user can keep using the core app without an account. After opting in, they can create an account, share an invite code, accept a friend, and see that friend's daily completion percentage. Progress photos and individual habit details remain local and private.

**Release scope:** sign in, profile and invite code, friend invitation and acceptance, accepted-friend list, opt-in daily summary sync, remove/block friend, sign out, delete account. Use manual refresh when opening Friends. Defer messages, photo sharing, public profiles, push notifications, and real-time sync.

## Gate 0: release access (first 30 minutes)

- [ ] Confirm access to a Mac with a current Xcode installation and a physical iPhone.
- [ ] Confirm active Apple Developer Program membership and App Store Connect access.
- [ ] Confirm the bundle ID, signing team, App Group capability, and app record in App Store Connect.
- [ ] Confirm a public support URL, working support email, and public privacy-policy URL can be published today.
- [ ] Create the app record and start its required metadata now; do not leave this until after coding.

**Stop condition:** If signing or App Store Connect access cannot be resolved today, prioritize a device-tested build and resolve account access immediately. Code alone cannot meet the submission target.

## Phase 1: make the existing app release-ready (2–3 hours)

- [ ] Replace the development paywall with a free onboarding step. Remove plan prices, purchase language, and the fake Restore action. `GlowProtocol/Features/Onboarding/PaywallView.swift` currently advances without StoreKit payment.
- [ ] Verify a clean install and an upgrade from an existing development build. `GlowProtocol/GlowProtocolApp.swift` currently destroys an incompatible SwiftData store on migration failure; do not ship a schema change that silently loses user data.
- [ ] Make scrapbook filenames unique per challenge run and photo, and preserve existing-file lookup for older photos. `GlowProtocol/Services/PhotoService.swift` currently uses only the calendar date as a filename.
- [ ] Check the app icon, launch, onboarding copy, camera permission, notifications, timer Live Activity, scrapbook, progress view, and settings on a physical device.
- [ ] Remove or correct any feature claims in the app and listing that the build does not fulfill.

## Phase 2: minimal Friends database (3–5 hours)

Use Supabase Auth and Postgres. Keep SwiftData as the source of truth for private habit records; send only the user's chosen daily summary to Supabase.

### Database contract

| Table | Minimum fields | Access rule |
| --- | --- | --- |
| `profiles` | `id` (Auth user ID), `display_name`, unique random `invite_code`, `created_at` | Owner can update their profile; invite-code lookup exposes only the minimum needed to request a connection. |
| `friendships` | two user IDs, status (`pending`, `accepted`, `blocked`), requester ID, timestamps | Only the two participants can see the row; only the recipient accepts; either can remove or block. Prevent self-invites and duplicate pairs. |
| `day_summaries` | `user_id`, local calendar date, day number, completion percentage, `updated_at` | Owner can write/delete; only owner and accepted, unblocked friends can read. Unique on `(user_id, date)`. |

- [ ] Create the Supabase project and save its URL and publishable/anon key in the app configuration. Never put the service-role key in the iOS app.
- [ ] Enable and test row-level security on **every** public table before connecting the app UI.
- [ ] Add optional authentication from the Friends screen; keep tracking usable while signed out. Choose one sign-in method that can be tested reliably before submission.
- [ ] Generate a random invite code and implement request, accept, remove, and block. Avoid global user search for this release.
- [ ] Add an explicit **Share my daily progress with friends** setting, off until the user opts in. Sync only day number and completion percentage; never upload scrapbook images or custom habit names.
- [ ] Show clear empty, loading, error, offline, and revoked-access states. A failed sync must never block local habit tracking.
- [ ] Add sign out and in-app account deletion that removes server-side profile, friendships, and summaries. Make the deletion flow accessible in Settings.
- [ ] Include a support/contact route for account and safety concerns.

### Database checks before shipping

- [ ] Account A cannot read Account B's summary before friendship acceptance.
- [ ] Pending, removed, and blocked relationships do not grant summary access.
- [ ] Account A cannot update Account B's profile or summary.
- [ ] A user can turn sharing off and previously shared summaries are removed or hidden according to the privacy copy.
- [ ] Deleting an account removes its server data and leaves the other user's app in a valid state.

## Phase 3: two-account test and release QA (2–3 hours)

Use two real test accounts and, if possible, two devices.

- [ ] Fresh install → onboarding → Day 1 habit completion → app restart: progress persists.
- [ ] Capture and reopen a photo; reset/start a new challenge; confirm an earlier run's photo is intact.
- [ ] Start, pause, finish, and dismiss a workout timer; verify Live Activity behavior on device.
- [ ] Account A requests Account B → B accepts → both see the right shared completion value.
- [ ] Test remove/block, sign out/in, sharing off, and account deletion.
- [ ] Test airplane mode and backend failure: core tracking still works and Friends gives a useful error.
- [ ] Test permission denial for camera and notifications; app remains usable.
- [ ] Run the streak unit tests and a full device smoke test. Record the build number and any known limitations.

## Phase 4: App Store Connect and submission (reserve 2–3 hours)

- [ ] Archive a Release build and upload it through Xcode. Allow time for build processing.
- [ ] Complete app name, description, keywords, category, age rating, pricing/availability, screenshots, support URL, and privacy-policy URL.
- [ ] Complete App Privacy answers to match the shipped build and Supabase data collection.
- [ ] Provide App Review with a persistent demo account, a second connected test account, and concise instructions for opening Friends. Include any needed access details in review notes.
- [ ] Select the processed build, resolve all App Store Connect validation errors, and submit for review.
- [ ] Confirm the status becomes **Waiting for Review** and monitor review messages.

## Cutoff and release decision

By **tomorrow morning**, Friends must work end to end with two accounts and pass the database access checks. If it does not, hide Friends entirely and submit the stable free core app. Do not leave a broken social screen or an unprotected database in the release build. Friends can follow in a subsequent version.

## Submission requirements to keep in mind

- Apple requires in-app account deletion when an app offers account creation: https://developer.apple.com/support/offering-account-deletion-in-your-app
- Apps with user-generated content or social networking features may need filtering, reporting, blocking, and published contact information: https://developer.apple.com/app-store/review/guidelines/
- iOS apps need a privacy-policy URL and accurate App Privacy answers: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- App Review needs usable demo access when login is needed: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Supabase Swift setup and row-level security: https://supabase.com/docs/guides/getting-started/tutorials/with-swift

**Success criterion:** A reviewer can install the build, complete a daily habit without signing in, create or use a test account, connect with a friend, view an opted-in daily summary, and delete the account without a crash or data leak.
