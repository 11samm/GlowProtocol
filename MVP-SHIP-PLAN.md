# Glow Protocol — v1 shipping plan

**Updated:** September 29, 2026  
**Release goal:** Submit a reliable iOS build with a working subscription paywall, a private Friends feature, and small/medium Home Screen widgets. AR belongs in v2. The September 26 target in `RELEASE-PLAN.md` has passed; use the gates below to choose the submission date.

**Current status:** Superwall public SDK key is configured, identity hooks and preview deep links are implemented, and subscription access is enforced on onboarding and relaunch. App/test targets compile, and all 12 unit tests pass on the iPhone 16 Pro iOS 18.2 simulator. Dashboard campaign/product configuration and real sandbox purchase checks remain open. See `SUPERWALL-INTEGRATION.md`. Friends implementation and Supabase setup remain required before shipping.

**Current execution roadmap:** See `ROAD-TO-APP-STORE.md` for the reference-inspired onboarding, widget scope, implementation order, TestFlight, and public release gates. Owner reports subscription configuration completed; device purchase validation remains pending.

## v1 contract

- A new user can finish onboarding, purchase a subscription, and use the daily tracker. An active subscriber and a restored purchase can enter without buying again. Dismissing the paywall does not unlock the app or trap the user.
- A subscriber can use the tracker without a Friends account. Signing in is required only to use Friends.
- A signed-in user can invite by code, accept, remove, and block a friend. Accepted, unblocked friends can see only an opted-in daily completion percentage and day number. Habit names and photos remain local.
- A user can turn sharing off, sign out, and delete the Friends account and server data in the app.
- Existing local progress and photos survive upgrades, reset, and reconfiguration.
- Small and medium Home Screen widgets show saved daily progress and open Today. The existing workout Live Activity is separate.
- No AR experience is required for v1. Plan and scope AR after submission as v2.

## Work already completed in this pass

- [x] Preserve the SwiftData store when it cannot be opened; show a recovery screen instead of deleting it.
- [x] Archive active logs and photos on reconfiguration instead of deleting all logs.
- [x] Store photos by run ID and date; continue resolving legacy relative photo paths.
- [x] Remove the on-screen development controls and the persisted day offset from app date logic.
- [x] Add unit and UI test targets to the shared Xcode scheme.
- [x] Preserve the current onboarding claims at the owner's request.
- [x] Confirm a normal Xcode build succeeds after these changes.
- [x] Add regression tests for reconfiguration, separate photo files, partial water persistence, and grace dates; correct the outdated immediate-reset assertion.
- [x] Persist partial water progress using the existing metadata column.
- [x] Schedule the background check after midnight, evaluate yesterday, and apply grace to the failed date.
- [x] Confirm app and test targets build using `build-for-testing` after the Superwall integration and latest local-data fixes.
- [x] Confirm all 12 unit tests pass on the booted iPhone 16 Pro simulator (September 29). UI and purchase-flow runtime checks remain open.

## Gate 1 — account and release configuration

- [ ] Confirm Apple Developer Program and App Store Connect access, app record, bundle ID `sam.GlowProtocol`, signing, App Group, and device provisioning.
- [ ] Create and verify the weekly, monthly, and yearly subscription products in App Store Connect. Set product availability and localizations.
- [ ] Finish Superwall app setup with bundle ID `sam.GlowProtocol`. Put its public **iOS SDK key** in `GlowProtocol/Info.plist` → `SuperwallPublicAPIKey`. Configure the `onboarding_complete` placement, paywall, products, and entitlement mapping in Superwall.
- [x] Create a Supabase project and configure its project URL/public publishable key in Info.plist. Verified the Auth endpoint accepts the key. Apple and Google provider switches were verified enabled September 30; actual sign-in remains untested; never embed a service-role key in the app.
- [ ] Configure and test both **Sign in with Apple and Google** for v1 with Supabase Auth. Complete the required Apple and Google provider/client setup.
- [ ] Verify a working support email plus public support and privacy-policy URLs. Update the in-app privacy text to describe subscriptions and Friends accurately.

## Gate 2 — paywall end to end

- [x] Replace the placeholder Superwall key with configuration lookup and a visible unavailable message when the key is absent. The public iOS key supplied by the owner is now configured.
- [ ] Verify onboarding purchase, paywall dismissal, an already active entitlement, restore purchases, expired entitlement, and offline state. Use StoreKit sandbox and a physical iPhone.
- [ ] Ensure the rendered paywall clearly displays actual pricing, billing period, renewal, restore, terms, and privacy links. Match App Store listing copy to the product actually sold.
- [x] Prevent the user from entering subscription-gated screens when entitlement is absent, including on relaunch after expiration. Runtime sandbox expiry verification remains required.

## Gate 3 — private Friends end to end

- [ ] Add Apple and Google sign-in through Supabase Auth and profile creation with a unique random invite code tied to the authenticated user UUID.
- [ ] Place optional account creation after challenge setup and before the first friend invite. Require successful sign-in before creating/sharing an invite; preserve the plan on cancellation or failure.
- [ ] Add welcome **Already have an account?** with a dismissible Apple/Google login overlay and coordinated blur/unblur animation. Respect Reduce Motion and accessibility focus. Keep login and purchase restoration separate; preserve saved local progress and recheck subscription access.
- [ ] Build `profiles`, `friendships`, and `day_summaries` tables with migrations, constraints, and row-level security. Test policy behavior using two separate accounts before enabling the UI.
- [ ] Add Friends entry, sign-in, profile and invite code, request/accept, accepted list, remove/block, and useful loading/offline/error states.
- [ ] Add an explicit daily-summary sharing setting, off by default. Sync only day number and completion percentage for opted-in users. Turning sharing off must remove or hide previously shared summaries as the privacy text promises.
- [ ] Add sign out and in-app account deletion; delete server profile, relationships, and summaries. Local habit tracking must continue if Friends or Supabase is unavailable.
- [ ] Test no access before acceptance or after removal/block; no cross-account writes; no photo or habit-name upload; two-account flows on two devices when possible.
- [ ] Review App Store social-feature requirements, including blocking, reporting/contact, moderation scope, and review access. Keep the v1 social surface private and limited.

## Gate 4 — release QA and submission

- [ ] Add regression tests for reset/reconfiguration keeping archived logs; same-date photos in two runs; old photo path loading; paywall routing; and privacy boundaries where feasible.
- [ ] Run unit and UI tests, then device-test clean install and upgrade, full onboarding, purchase/restore, Day 1 persistence, workout Live Activity, camera, notification denial, dark mode, large text, and iPad layout.
- [ ] Archive a Release build and verify signing, icon, launch, and the absence of development UI. Record the version/build number.
- [ ] Publish support and privacy pages. In App Store Connect, enter the privacy-policy URL under **App Privacy** and the support URL on the iOS version information page. Complete App Privacy answers for the app, Superwall, and Supabase.
- [ ] Finish screenshots, description, age rating, pricing, review notes, and persistent demo access for Friends. Upload the archive, choose the processed build, resolve validation, and submit for review.

## v2

- [ ] Define the AR experience after v1 submission: user job, supported devices, permission needs, privacy impact, and one testable prototype. AR is not a substitute for any v1 gate above.

## Attach privacy and support pages

1. Publish two public HTTPS pages on your website or GitHub Pages. A local Markdown file or a private document will not work as an App Store URL.
2. The privacy page must describe the shipped data flows: local logs/photos, Superwall, and Supabase account/profile/friendship/summary data, sharing controls, retention, account deletion, and contact information.
3. The support page should give a working contact method and help with subscriptions, restoring purchases, Friends, and account deletion.
4. In App Store Connect → My Apps → Glow Protocol → App Privacy → Privacy Policy, enter the privacy URL. Complete and publish the App Privacy answers as well.
5. Open the iOS version being submitted and enter the support page in its **Support URL** field. Add the privacy and terms URLs to the rendered Superwall paywall and link the public policy from app Settings.

References: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy and https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information

## Submission gate

Submit only after a real subscription flow and the two-account Friends flow pass on the Release candidate, the local record survives an upgrade and reset, database access tests pass, and App Store Connect accepts the build and required metadata. If a gate fails, fix it and move the submission date; keep paywall and Friends in scope.
