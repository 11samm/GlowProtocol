# Friends deployment and verification

## Status

The Swift app has Friends UI, Apple native sign-in, Google OAuth, profiles/invites, requests, summary sharing, block/report, logout and deletion integration. The Friends migration and **delete-account** Edge Function were deployed to project `sjmmwypumyaioxudstir` on September 30, 2026. The dashboard confirmed SQL success and the deployed function endpoint. The owner entered Apple deletion secrets; all four required secret names were verified present without revealing values. Real two-account testing and Apple token exchange/revocation remain required. Saved secret names do not validate credentials or the complete login path.

## 1. Supabase SQL

Open the existing project → SQL Editor → New query. Paste and run the entire file `supabase/migrations/202609300001_friends.sql` once. It creates tables, enables RLS, denies direct app-table access, and grants authenticated callers the checked RPC functions. Because automatic table exposure was disabled, these explicit RPC grants are intentional.

Tables: profiles, friendships, blocks, day_summaries, friend_reports, friend_action_limits. The last two are server-only. Do not add broad select/write policies or anonymous grants to fix errors. Initial sharing is off; profiles and invite codes are owned by the actual authenticated UUID.

The local SQL validation test uses PostgreSQL through PGlite with a UUID-based test replacement for pgcrypto random bytes. Production must use real pgcrypto as written in the migration. No production account is created by the test.

## 2. Auth redirects and Apple signing

Configured September 30 in Supabase → Authentication → URL Configuration → Redirect URLs:

`glowprotocol://auth/callback`

Keep Google's authorized redirect URI as `https://sjmmwypumyaioxudstir.supabase.co/auth/v1/callback`. These are two different legs of the same login: Google → Supabase → app.

In Apple Developer → Identifiers → `sam.GlowProtocol`, enable Sign in with Apple. The app entitlement has been added. Xcode must refresh the development/distribution provisioning profiles. Supabase Apple Client IDs must include `sam.GlowProtocol`. Native Apple login uses a hashed nonce and the ID-token flow; it does not require a web OAuth secret.

In Google Auth Platform → Audience, add test accounts while the app is in testing. Before launch, move the Google OAuth app to production and resolve any required brand verification. Google login is an ASWebAuthenticationSession with PKCE; the client secret remains in Supabase.

## 3. Account deletion Edge Function

`supabase/functions/delete-account/index.ts` is deployed as **delete-account**. The legacy-secret gateway is disabled with user approval because it does not accept current asymmetric signing keys. The function independently verifies every bearer session with `Auth.getUser` and deletes only that caller; it never accepts a user ID as authority. An unauthenticated POST returned HTTP 401, `Sign in required`, after deployment.

The hosted Supabase runtime supplies `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY`. Never put either a service-role key or Apple private key in the app, repo, screenshots, or chat.

For Apple-linked users, add these **server secrets**:

- `APPLE_CLIENT_ID`: `sam.GlowProtocol`
- `APPLE_TEAM_ID`: your 10-character Apple developer Team ID
- `APPLE_KEY_ID`: a key configured for Sign in with Apple (not the subscription key)
- `APPLE_PRIVATE_KEY`: its `.p8` contents, entered directly in Supabase secrets

The app requests fresh Apple authorization for deletion. The server exchanges the code, verifies the Apple token's subject matches the caller's linked Apple identity, revokes Apple access, then deletes the Supabase user. If Apple revocation fails, deletion is not falsely reported complete. Google-only accounts use authenticated deletion without Apple secrets. Apple-linked account deletion is a release blocker until this configuration passes real testing.

Account deletion does not cancel an App Store subscription. The confirmation and account settings expose that distinction and a subscriptions-management link.

## 4. Invite links

Current share text includes the real 12-character code and a `glowprotocol://invite?code=…` link. Installed apps can capture the link; the recipient can enter the code manually after installing. A public HTTPS invitation landing page/universal link requires a domain and associated-domain hosting and is not claimed as implemented. Do not publish a non-working App Store download URL before the listing is live.

## 5. Two-account release check

1. Apple user and Google user authenticate on separate devices; save names.
2. Send an invite. Recipient sends a request, owner accepts. Pending requests reveal no daily summaries.
3. Sharing defaults off. Enable sharing and complete a habit; the other account sees only day/date/percentage.
4. Disable sharing; existing summary disappears. Photos and habit text never appear in network payloads.
5. Remove, block, unblock and retry. Block prevents new requests/access; unblock does not silently reconnect.
6. Report a connection and verify the row appears in the private report table.
7. Sign out/switch accounts; no cached remote summary or sharing permission leaks. Confirm sharing again before uploading this device's routine under a different account.
8. Delete Google account; delete Apple account with fresh authorization; verify cascade removal and Apple revocation.
9. Expire subscription; account/invite recovery and deletion remain accessible, paid daily summary UI stays gated.
10. Test offline retry, expired sessions, provider cancellation, cold launch and large text/dark mode.

## 6. Moderation and support

Support inbox: glowprotocol.info@gmail.com. Check `friend_reports` in the Supabase dashboard regularly during launch. Reports are visible only to server/admin access. Remove inappropriate profiles via server administration and respond to support requests; filtering/validation alone is not a moderation process. Public posting, bio, messaging and photo upload are outside v1.

## 7. Local test commands

App/unit regression tests use the shared GlowProtocol scheme. SQL tests: install `@electric-sql/pglite` in a temporary validation directory, then run `supabase/tests/friends-policy-tests.mjs` with `PGLITE_MODULE` pointing to that package's `dist/index.js`. The validation dependencies are not shipping app dependencies.
