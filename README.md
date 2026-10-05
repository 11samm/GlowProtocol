# Glow Protocol

**Build a daily routine. Track your consistency. See your progress.**

Glow Protocol is a native iOS habit tracker built around a customizable 75-day challenge. It combines daily check-ins, workout timers, hydration tracking, progress photos, streaks, and private friend accountability in a SwiftUI app, with Hard, Medium, and Soft modes.

## Current state

As of October 5, 2026, the repository includes the core tracker, Superwall subscription integration, private Friends with Supabase authentication, and small/medium Home Screen widgets. This is a development build; release validation remains in progress.

The latest recorded verification in [the roadmap](ROAD-TO-APP-STORE.md) is September 30: app, widget, and test targets compiled, 15 unit tests passed, and local PostgreSQL privacy tests passed. Real purchase/restore/expiration checks, two-account Friends testing, Apple account deletion/revocation, and widget/UI testing on physical devices remain pending. Public privacy/support pages and App Store submission materials also remain open. The planned onboarding redesign has not been implemented.

## Implemented features

- **Personalized challenge setup** — goals, difficulty, enabled habits, and grace-day settings.
- **Daily tracking** — workouts, water, reading, diet, steps, alcohol-free days, progress photos, and up to three custom habits. Partial water progress persists between sessions.
- **Workout timer** — Live Activity support for the Lock Screen and Dynamic Island on supported devices.
- **Progress and streaks** — daily completion, mode-specific reset/grace rules, and foreground catch-up for missed days. Resetting or reconfiguring archives earlier runs instead of deleting their records.
- **Photo scrapbook** — local photo capture and before/after comparison, with separate photo files for each challenge run.
- **Private Friends** — optional Apple or Google sign-in, profiles, invite codes and links, requests, acceptance, removal, blocking, reporting, sign-out, and account deletion integration. Daily summary sharing starts off; accepted friends can see opted-in day/date/completion percentage. Habit text and photos stay local.
- **Home Screen widgets** — small and medium daily progress widgets with day, streak, and completion. Habit names are hidden by default and can be enabled in Settings. Tapping opens Today; stale snapshots prompt the user to open the app for updated progress.
- **Subscription access** — Superwall paywalls for onboarding and returning users, purchase restoration, and active-access checks. Expiration preserves local data. Account recovery, sign-out, and deletion remain available without paid access.
- **Reminders and appearance** — local notifications, light/dark appearance, and support contact in the app.

## Architecture and data

**Swift · SwiftUI · SwiftData · WidgetKit · ActivityKit · App Intents · SuperwallKit · Supabase Swift**

Habit logs and challenge configuration are stored locally with SwiftData; scrapbook images are stored on the filesystem. Friends accounts do not provide cloud backup for these records. The app and widget extension share a small progress snapshot through the `group.sam.GlowProtocol` App Group; the widget does not open the SwiftData store.

Supabase handles authentication, profiles, private relationships, and opted-in daily summaries through checked RPC functions and row-level security. The repository includes the Friends SQL migration, account-deletion Edge Function, and database privacy tests. [Friends setup notes](FRIENDS-SETUP.md) record the migration/function deployment on September 30 and the remaining authentication and deletion checks.

Superwall handles App Store subscriptions. Friends sign-in identifies the stable account UUID with Superwall; sign-out/deletion resets that identity. Subscribers can use local tracking without a Friends account. Deleting a Friends account does not cancel an App Store subscription.

## Getting started

You need a Mac with Xcode and an iOS 18 SDK. The app and widget deployment targets are iOS 18.0; use an iOS 18.2 or newer simulator to run the test targets.

1. Clone and open the project:

   ```sh
   git clone https://github.com/11samm/GlowProtocol.git
   cd GlowProtocol
   open GlowProtocol.xcodeproj
   ```

2. Select the **GlowProtocol** scheme and an iPhone simulator or connected device. Xcode resolves the SuperwallKit and Supabase Swift packages through Swift Package Manager.
3. For device builds, select your development team under **Signing & Capabilities**. Provision Sign in with Apple for the app and the shared App Group for both app and widget targets. If you change bundle/App Group identifiers, update the entitlements, source identifiers, and service configuration together.
4. Build and run with **⌘R**.

Public service settings live in [GlowProtocol/Info.plist](GlowProtocol/Info.plist): `SuperwallPublicAPIKey`, `SupabaseProjectURL`, and `SupabasePublishableKey`. These point to the configured services; use your own settings for an independent deployment. Service-role keys, OAuth client secrets, and Apple private keys belong only in server/provider configuration.

A complete subscription flow requires configured App Store products and Superwall campaigns for `onboarding_complete` and `subscription_access`; building the app alone does not grant access. Friends requires the Supabase migration, authentication providers, and deletion function. Follow [subscription setup](SUPERWALL-INTEGRATION.md) and [Friends setup](FRIENDS-SETUP.md) for details; some older checklist items describe earlier checkpoints, so use the current-state section above and the source for implemented scope.

The `glowprotocol` URL scheme supports authentication callbacks, invite codes, Today navigation, and Superwall previews. Public HTTPS invitation landing pages/universal links are not implemented.

## Verification

Use **Product → Test** (**⌘U**) with the shared GlowProtocol scheme to run the unit and UI test targets. Unit tests cover local persistence, streak/grace behavior, archived runs, per-run photo files, invite validation, and summary payload boundaries.

Database privacy tests live in [supabase/tests/friends-policy-tests.mjs](supabase/tests/friends-policy-tests.mjs). With Node.js and `@electric-sql/pglite` installed in a separate validation directory, run:

```sh
PGLITE_MODULE=/absolute/path/to/pglite/dist/index.js node supabase/tests/friends-policy-tests.mjs
```

The SQL tests exercise denied direct/anonymous access, friendship acceptance, sharing revocation, blocking, reporting, validation, and deletion cascades. Their local random-byte replacement is test-only; production uses the migration's pgcrypto implementation.

Use physical iPhones for camera, notifications, workout Live Activities, widget gallery/refresh behavior, sandbox purchases, and two-account authentication/sharing/deletion checks. Passing local tests does not verify those service/device flows.

## Project structure

```text
GlowProtocol/
├── DesignSystem/     # Colors, typography, animations, and reusable controls
├── Features/         # Onboarding, daily tracking, progress, scrapbook, Friends, settings
├── Models/           # SwiftData records and challenge configuration
├── Services/         # Subscriptions, Friends, widgets, timers, streaks, photos, notifications
└── Shared/           # Extensions and configuration utilities
GlowProtocolWidgets/  # Daily progress widgets, timer intents, and Live Activity views
GlowProtocolTests/    # Local tracking and Friends unit tests
GlowProtocolUITests/  # UI test target
supabase/
├── migrations/       # Friends schema, RPC functions, and access rules
├── functions/        # Authenticated account deletion and Apple revocation
└── tests/            # Local PostgreSQL privacy tests
```

## Project notes

- [Road to the App Store](ROAD-TO-APP-STORE.md) — implementation status, planned onboarding, device QA, and release gates.
- [Friends setup](FRIENDS-SETUP.md) — backend/auth configuration, deletion, and two-account verification.
- [Friends design philosophy](FRIENDS-DESIGN-PHILOSOPHY.md) — private accountability and data-sharing boundaries.
- [Superwall integration](SUPERWALL-INTEGRATION.md) — paywall configuration and purchase validation checklist.

Support: [glowprotocol.info@gmail.com](mailto:glowprotocol.info@gmail.com).
