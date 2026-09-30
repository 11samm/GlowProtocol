# Working baseline — September 30, 2026

## Order of work

1. Build/test the existing app, add support contact, and push this baseline to GitHub.
2. Study Her75 and Reset75 references and write the Friends design philosophy.
3. Implement private Friends, Apple/Google authentication, backend migrations, deletion, and privacy boundaries.
4. Complete Home Screen widgets, subscription verification, release materials and QA.
5. Revamp onboarding last. Preserve the current difficulty screens and onboarding claims until that phase.

## Baseline scope

The app builds with the existing onboarding, local tracking, photos and workout Live Activity. Superwall integration enforces verified active access and exposes purchase restoration. The runnable unit test suite covers streak/grace rules, archived runs, water persistence, and separate photo files across runs.

Apple and Google provider switches are enabled in Supabase; this does not verify credentials or implement sign-in. Friends tables and account deletion have not been deployed. Actual sandbox purchase/device verification and public privacy/support pages remain launch requirements. This checkpoint is a development baseline, not App Store release approval.

Support: glowprotocol.info@gmail.com. Linked in Settings and the subscription recovery screen.

## Reference implementation order

Friends work starts only after the baseline is pushed. Onboarding design changes are deferred; authentication will initially be reachable through Friends and subscription recovery so account deletion and sign-out remain accessible without paid access.
