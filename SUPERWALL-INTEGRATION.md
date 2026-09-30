# Superwall integration checklist

## App implementation

- [x] Detect platform: native iOS / SwiftUI.
- [x] Determine purchase controller path: default Superwall StoreKit handling. No RevenueCat or custom billing SDK detected.
- [x] Install SDK dependency: existing Swift Package Manager dependency, resolved SuperwallKit 4.15.3.
- [x] Configure Superwall at app launch with the supplied public iOS key in Info.plist.
- [x] User management: retain SDK anonymous identity; provide UUID identify/reset hooks in SubscriptionService.
- [ ] Wire identify/reset to Friends sign-in/sign-out once authentication exists. Protocol reset must not reset purchase identity.
- [x] Feature gating: `onboarding_complete` and `subscription_access`; require active subscription even if the dashboard skips the paywall or uses non-gated dismissal.
- [x] Track subscription state with the SDK publisher; completed onboarding does not bypass expired subscriptions on relaunch.
- [x] Set user properties: app cohort, difficulty preset, enabled habit count, and challenge duration. No names, photos, or custom habit text are sent.
- [x] In-app paywall previews: `glowprotocol` URL scheme and SwiftUI `onOpenURL` forwarding to Superwall.
- [x] Restore: require an active subscription after restoration. A successful restore operation alone does not unlock access.
- [x] Audit analytics: no third-party analytics SDK detected; no event-forwarding integration required.
- [x] Audit feature gating: the main tabs, including tracking, scrapbook, and future Friends, sit behind one subscription gate. Local data is preserved on expiration. The extension currently provides only a workout Live Activity; Home Screen widgets are planned in `ROAD-TO-APP-STORE.md`.
- [x] Remove the unused static-price paywall; actual prices and purchase terms belong on the Superwall paywall backed by StoreKit.
- [x] App and unit/UI test targets compile (`build-for-testing`, September 29, 2026).
- [ ] Complete runtime purchase/restore/expiration checks against the configured dashboard and Apple sandbox.

## Dashboard and Apple setup still required

1. Use bundle ID `sam.GlowProtocol` for the Superwall iOS app and App Store Connect record.
2. Create the intended subscription products in App Store Connect, then map their exact product IDs and a subscription entitlement in Superwall. This app currently treats any active Superwall entitlement as access; keep the entitlement model to one access tier.
3. Publish a campaign for **both** `onboarding_complete` and `subscription_access`. Attach the paywall and select **Gated** feature behavior. Use an audience covering every non-subscriber and no unpaid holdout for these placements.
4. Include actual localized prices, billing periods, renewal/trial wording, Restore Purchases, and working privacy/terms links on the rendered paywall.
5. Set Settings → General → Apple Custom URL Scheme to `glowprotocol`. Build/install the app and scan the paywall Preview QR code from your phone. A preview is not proof that a production campaign or purchase works.
6. Finish Apple API/IAP credentials using the correct key type for each Superwall section. Private `.p8` keys stay in Apple/Superwall configuration, never in app source.
7. Test purchase, cancellation, restoration with and without an active purchase, expiry/relaunch, network failure, and a missing/unpublished campaign. Unpaid users must remain locked while their local progress stays intact.

Web checkout is not part of this App Store subscription integration. Custom preview links are implemented; universal links and associated domains require a configured web-checkout domain before they can be enabled and verified.

## Identity lifecycle for Friends

The app has no account login yet. Use Superwall's persistent anonymous identity until then. On authenticated sign-in, call `SubscriptionService.shared.identify(accountID:)` with the stable server account UUID. On sign-out/account deletion, call `resetIdentity()`. Never identify with an email, device ID, protocol run ID, or a shared hardcoded string.

## Verification

Build log: `/private/tmp/glow-superwall-build.log` — **TEST BUILD SUCCEEDED**.
Unit test log: `/private/tmp/glow-superwall-tests.log` — **TEST EXECUTE SUCCEEDED**, all 12 existing regression tests passed on iPhone 16 Pro / iOS 18.2. These cover local persistence and streak behavior, not sandbox purchases.

Purchase, preview QR, and expiration runtime validation remain pending dashboard setup. Compilation is not a successful purchase test.

Official documentation: https://superwall.com/docs/ios/quickstart/configure, https://superwall.com/docs/ios/quickstart/user-management, https://superwall.com/docs/ios/quickstart/feature-gating, https://superwall.com/docs/ios/quickstart/tracking-subscription-state, https://superwall.com/docs/ios/quickstart/setting-user-properties, https://superwall.com/docs/ios/quickstart/in-app-paywall-previews, https://superwall.com/docs/ios/guides/handling-deep-links
