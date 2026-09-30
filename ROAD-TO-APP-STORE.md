# Glow Protocol — from now to the App Store

Updated September 30, 2026. This is the current execution plan. `MVP-SHIP-PLAN.md` retains the technical checklist and `SUPERWALL-INTEGRATION.md` retains the purchase setup details. Onboarding redesign is deferred until the current feature work is verified, as requested.

## Release goal

Ship a polished 75-day habit app for the audience drawn to Her 75: approachable wellness, an attractive daily routine, visible progress, and accountability with real friends.

**Required for v1:** working subscriptions, private Friends, small and medium Home Screen widgets, reliable local tracking/photos, clear onboarding, and the release/support materials. **AR stays in v2.**

Suggested App Store name: **Glow Protocol: 75 Day Habits**. Suggested subtitle: **Habit tracker & friends**. These are recommendations; name availability still needs checking. Home Screen display name: **Glow Protocol**. Bundle ID: `sam.GlowProtocol`.

## What is true today

- [x] Native SwiftUI app with Today, Scrapbook, and Progress tabs exists.
- [x] SuperwallKit is installed and configured with the supplied public iOS key.
- [x] Onboarding and returning-user subscription gates, restore handling, and preview URL scheme are implemented.
- [x] Owner reports subscription configuration completed. Treat this as setup completed, with real purchase validation still pending.
- [x] App, widget and test targets compile; 15 unit tests passed on September 30 after Friends/widget changes. Local PostgreSQL privacy tests passed. UI/physical-device tests remain open; Xcode Friends preview timed out twice.
- [x] Saved store preservation, archived runs, separate photo paths, partial water persistence, and grace-date fixes are implemented.
- [x] Visible development controls are removed.
- [x] Workout Live Activity extension and App Group configuration exist.
- [x] Small and medium daily progress widgets implemented with App Group snapshots, private habit names by default, midnight stale-state handling, and Today navigation. Widget gallery/device QA remains pending.
- [x] Supabase project URL and public publishable key configured; Apple and Google providers enabled; `glowprotocol://auth/callback` allowed. Actual sign-in flows are implemented and require device testing.
- [x] Friends UI, Apple/Google authentication, private requests, opt-in summaries, remove/block/report, logout and deletion integration implemented. Migration and deletion function deployed; app login callback configured. Local SQL privacy tests passed. Real two-account and Apple revocation tests remain pending. See `FRIENDS-SETUP.md` and `FRIENDS-DESIGN-PHILOSOPHY.md`.
- [ ] Full purchase/device/UI QA, public privacy/support pages, and submission materials remain open.

## What the supplied references teach us

Reviewed all **55 Reset75 PNGs** in `Reset75/` and **78 Her 75 PNGs** in `Her75App/`. Several are alternate selections or repeated screens. These are design references; screenshots alone cannot establish conversion rates or why an app succeeds.

| Reference | Observed pattern | Planned adaptation |
|---|---|---|
| Reset75 `IMG_3333.PNG`, `IMG_3338.PNG`–`IMG_3339.PNG` | Product preview followed by goals and a response explaining the value | Start with an attractive preview of the daily experience; visibly connect selected goals to the plan summary |
| Reset75 `IMG_3354.PNG`–`IMG_3357.PNG` | Short plan-building sequence | Keep the existing brief animation and show the real selected habits at its end |
| Reset75 `IMG_3365.PNG`–`IMG_3369.PNG` | Commitment and readiness before purchase | Use one concise “Make it official” moment and a Day 1 preview |
| Reset75 `IMG_3370.PNG`–`IMG_3372.PNG` | Explicit trial timeline and billing date | Explain the actual configured offer, payment timing, renewal, and restore clearly |
| Her 75 `IMG_0927 2.PNG`, `IMG_0929 2.PNG`–`IMG_0939 2.PNG` | Lifestyle collage, serif typography, visual goals, editable challenge tasks | Retain Glow's identity; add original, licensed imagery and make the challenge selection/summary feel personal |
| Her 75 `IMG_0946 2.PNG`, `IMG_2947.PNG` | Invite code and native share sheet with a solo option | Add a real friend invite flow after purchase; make “Start solo” explicit |
| Her 75 `IMG_0947 2.PNG`, `IMG_2950.PNG` | Shareable Day 1 plan card | Add an optional Glow-branded commitment card generated from the user's actual plan |
| Her 75 `IMG_2954.PNG`–`IMG_2958.PNG` | Contextual first-use hints | Add three dismissible hints for daily tasks, progress, and Friends/widget setup |
| Her 75 `IMG_2966.PNG`–`IMG_2967.PNG` | At-a-glance friend accountability | Show accepted friends' day number and opted-in completion percentage |

Design decisions: original visual assets and copy; spacious layouts; readable serif headings; a consistent palette; one clear action per screen. Preserve the current onboarding claims as previously requested. Use a longer personal onboarding to build investment and explain the value before purchase. Each question should either shape the routine or be reflected in a useful personalized summary. Use existing hard/medium/soft presets for launch. Public discovery, recipe libraries, partner matchmaking, and expanded profile walls are future candidates. The reference's trial reminder becomes a promise only if we implement and validate that reminder for our configured offer.

## Proposed launch onboarding — personal commitment before purchase

The owner wants the longer, personal journey used by these references. The hypothesis is that investment in creating a plan, plus seeing the app respond to personal goals, increases confidence and willingness to subscribe. Length by itself does not demonstrate effectiveness; assess completion, purchase conversion, and first-day use together.

Target **19–23 short screens**, mostly single-tap choices, with clear back navigation and preserved answers. Introduce the next section with progress cues. Keep optional name entry skippable. The exact count should follow the final screen map, not a requirement to pad the flow.

### Act 1 — recognize the user's aspiration (screens 1–5)

1. **Welcome/product preview:** the attractive daily experience and 75-day premise.
2. **Optional name:** personalize the summary locally.
3. **Your intention:** become consistent, feel confident, build a routine, or make time for yourself.
4. **Your current obstacle:** losing momentum, an unrealistic plan, forgetting daily tasks, or doing it alone.
5. **Reflect it back:** connect the selected obstacle to an actual feature, such as a visible checklist, manageable preset, reminder, or Friends accountability.

### Act 2 — understand the starting point (screens 6–10)

6. **Previous challenge experience:** first attempt / restarting / completed one before; adapt explanation and tone.
7. **Current consistency:** how many days per week the user follows their routine; use it for suggested intensity, not a diagnostic score.
8. **Routine preference:** structured mornings, flexible days, or a gentle reset.
9. **Realistic daily time:** use the answer to recommend workout requirements/preset; show conflicts before committing.
10. **Your desired Day 75:** choose the outcome they care about; bring that wording back in the plan and milestone messages.

### Act 3 — build a believable personal plan (screens 11–16)

11. **Relevant reassurance/social-proof screen:** keep the existing onboarding claims as instructed.
12. **Recommended protocol:** Hard / Medium / Soft, with the reason for the suggestion and an option to change it.
13. **Choose/edit habits:** actual enabled tasks and requirements.
14. **Missed-day rules/grace:** a concise confirmation for the selected mode; explain what happens rather than burying it.
15. **Build the plan:** short animation that assembles the selected routine.
16. **Personal summary:** their goals, starting point, recommended mode, habit checklist, start/end dates, and the features addressing their obstacle. Allow editing.

### Act 4 — connect, invite, commit, and understand the purchase (screens 17–23)

17. **A visible path:** explain Day 1, the first week, and milestones using concrete app actions.
18. **Connect your account:** offer **Continue with Apple** and **Continue with Google** after challenge setup and immediately before the first invitation. Explain that the account creates their Friends profile and connects invitations to them. Offer **Continue solo**; signed-in users skip this screen. Preserve the local plan through authentication, cancellation, and retry. Do not promise cloud backup of habit logs or photos.
19. **First Friends invitation:** introduce accountability with “Someone to show up with” and explain that accepted friends can see opted-in daily completion. Offer **Invite a friend** and **Continue solo** before the commitment. Show the invitation preview and disclose that the app requires a subscription to start tracking. A benefit statement can use “Keep each other accountable”; any numerical completion-rate uplift needs verified evidence applicable to this product.
20. **Make it official:** sign/confirm a personal commitment tied to the user's chosen goal. Save it locally.
21. **Conditional second invitation:** show only if the first prompt was skipped or the share sheet was canceled. Frame it as “Want someone in your corner?” using the finished commitment card. Offer **Share my invitation** and **Keep going solo** with equal clarity. Show this second prompt at most once; do not repeat it when the user returns from a dismissed paywall.
22. **What the subscription includes:** demonstrate tracking/progress, private Friends, and Home Screen widgets.
23. **Hard Superwall paywall:** localized prices, configured offer, renewal/trial timing, restore, terms, and privacy. Verified active access advances. Dismissal returns to the saved plan/purchase entry without repeating the invite sequence.

Pre-purchase invitation implementation:

- Account creation and invitation prompts remain skippable for solo subscribers. Complete authentication and profile creation before minting a real invitation; tie the invite to the authenticated Supabase user UUID. If they skipped the account step and later choose either invitation, reopen authentication first. Provide account deletion and sign-out from this pre-purchase route as well.
- Permit minimal account/invite creation before payment; subscription access still gates daily tracking and the full Friends experience. No daily summary is shared before explicit opt-in.
- Use the backend's real invite code plus the native share sheet; accepted requests must explicitly identify the participants. An invite does not automatically grant subscription access to either person.
- Persist `firstInviteSkipped`, `inviteShareCompleted`, and `secondInviteShown` in the draft. Share-sheet completion means a share action finished, not proof that a message was delivered or that the friend accepted. Use actual backend acceptance for the connected state.
- Suppress the second ask after a completed share action or an accepted invitation; do not wait for a friend to accept before letting the sender reach the paywall.
- If invite/auth setup fails, show a retry/continue-solo path and preserve the draft. Keep support/account deletion available even if the user never purchases.

### Returning-user login from welcome

- Add **Already have an account?** on the welcome screen. It opens a lightweight overlay with Apple and Google buttons over the existing welcome scene.
- Animate the background blur and overlay appearance together; tapping outside or a visible close control reverses the same transition smoothly. Keep the underlying screen mounted so dismissal returns to exactly the same state.
- Support VoiceOver focus, sufficient button contrast, and Reduce Motion. Prevent duplicate sign-in requests and handle cancellation without losing the onboarding draft.
- After sign-in, load the authenticated profile/invite state and recheck subscription access. A returning user with a saved local plan should not repeat onboarding. A fresh device without a local plan needs a concise setup route; account login alone does not restore local logs/photos.
- Keep **Restore purchases** available independently of account login. Signing in must not bypass the hard paywall.

### Act 5 — turn commitment into action (after purchase)

- Save the plan once and show Day 1 with a useful first task.
- Offer notification permission with a skip option.
- Show the actual invite/request state and an optional Friends entry; do not add a third automatic invite prompt after purchase.
- Offer the Glow-branded commitment card and Home Screen widget setup instructions. The app cannot silently add a widget.
- Show three brief dismissible first-use hints; ask for a store rating later after earned progress.

### Implementation requirements

- [ ] Write a screen-by-screen map: question, choices, stored field, personalization effect, next screen, and back behavior.
- [ ] Persist the onboarding draft across app termination/paywall cancellation; do not finalize or overwrite the active run until the user completes the flow.
- [ ] Make answers visible in the personalized recommendation/summary. If the app promises a tailored routine, implement the rule that tailors it.
- [ ] Keep personal answers local unless a shipped feature requires explicit sharing. Never send the questionnaire to Superwall as targeting attributes.
- [ ] Measure step drop-off and time to complete alongside purchase/restore and Day 1 completion. Superwall covers purchase metrics; additional funnel measurement needs a defined implementation/data scope.
- [ ] Test the complete flow with target-audience users before shortening or extending individual sections. Optimize for informed commitment and actual use after purchase.

## Execution order and acceptance gates

### Phase 1 — prove the configured subscription works

**Owner dependency:** configured product IDs, active Superwall campaign/paywall, Apple account agreements and sandbox access.

- [ ] Check both placements: `onboarding_complete` and `subscription_access`. Confirm campaign publication, Gated behavior, audience coverage, and product/entitlement mapping.
- [ ] Preview the real paywall on a phone; verify localized price, billing period, any trial eligibility, restore, privacy, and terms.
- [ ] Test a fresh purchase, canceled purchase, active subscriber, restore with/without purchases, expiry and relaunch, offline launch, and missing campaign.
- [ ] Add/manage subscription access from Settings and keep recovery/support reachable when access is locked.
- [ ] Record the tested product IDs, device/build, and results in the integration checklist.

**Done when:** only verified active access unlocks the app; purchase or restore reaches Day 1; cancellation/errors preserve setup and allow retry. Dashboard setup alone does not close this gate.

### Phase 2 — implement private Friends

**Owner dependency:** Supabase project URL and publishable/anon key, plus Apple and Google provider configuration. Both providers are now enabled; validate real device login. Private service-role credentials belong only on the server.

- [ ] Add a fourth Friends tab with welcome, sign-in, list, pending requests, and empty/error/offline states.
- [ ] Create Auth-backed profiles, random invite codes, friendships/requests, blocks/reports, and opted-in daily summaries. Add migrations and row-level security.
- [ ] Implement **Sign in with Apple and Google** for v1, using the same account flow on the onboarding account screen and returning-login overlay. Wire the stable Supabase account UUID into Superwall identify; reset identity on sign-out/deletion. Subscribers can continue local tracking without signing in. Test both providers, cancellation, relaunch, and account switching; prevent one account from seeing another account’s cached Friends data.
- [ ] Support code entry, native share invite, accept/reject/cancel, remove, block, and report. Allow the minimal pre-purchase invite flow described above and confirm successful linking explicitly.
- [ ] Start sharing off. Display only day number and completion percentage after acceptance and opt-in. Photos and habit text stay local.
- [ ] Make sharing revocation hide/remove prior summaries; make blocking/removal revoke access immediately.
- [ ] Provide sign-out and in-app account deletion through an authenticated server operation. Remove profile/relationships/summaries and revoke Apple credentials where required.
- [ ] Validate profiles/display names and provide report handling plus working support contact for the private social feature.
- [ ] Test using two real accounts: acceptance, unauthorized reads/writes, blocking, deletion, offline changes, and recovery. Recheck access after relationships change.

**Done when:** two accounts can connect and see only permitted summaries; sharing off/removal/block prevents access; account deletion works; Friends outages preserve local progress.

### Phase 3 — Home Screen widgets

Reuse the existing WidgetKit extension and `group.sam.GlowProtocol` App Group.

- [ ] **Small widget:** Day X of 75, current streak, and today's completion ring/count.
- [ ] **Medium widget:** day/progress plus a compact list of remaining habits. Provide a privacy option to hide habit titles.
- [ ] Publish a small versioned snapshot to the App Group after saved changes. Keep the widget reader independent of SwiftData migrations and backend availability.
- [ ] Update the snapshot after completion/undo, partial water changes, reset/reconfiguration, foreground catch-up, and relevant subscription changes.
- [ ] Use WidgetKit timelines for the next day boundary and reload requests for app edits; handle stale data without promising exact refresh timing.
- [ ] Tapping opens Today through app routing. Keep Superwall preview links working and preserve the subscription gate. For v1, task completion happens inside the app.
- [ ] Handle not-onboarded, no current plan, locked subscription, missing snapshot, and Day 75/completed states.
- [ ] Verify small/medium sizes on a physical device, dark mode, large text, midnight/time-zone changes, and after upgrading/resetting the app.
- [ ] Add a short “Add your widget” guide after Day 1 and in Settings. Continue verifying the existing workout Live Activity independently.

**Done when:** both widgets can be added from the widget gallery, display the correct saved progress, refresh after app changes, and open the right gated app screen.

### Phase 4 — apply onboarding and retention polish

Complete after purchase and Friends behavior are known, so screens demonstrate real features.

- [ ] Add the original welcome/product imagery and visual challenge cards.
- [ ] Implement the longer five-act onboarding above; connect every personal answer to its summary/recommendation effect and retain back navigation.
- [ ] Add the first pre-purchase friend invitation, signed commitment, conditional second invitation, and one shareable commitment card.
- [ ] Add the short tutorial and widget setup guide; keep each optional step skippable.
- [ ] Celebrate full-day completion and milestones at days 7, 30, and 75 using accurate earned progress.
- [ ] Verify permission-denied states, keyboard behavior, smaller phones, contrast, VoiceOver, and large text.
- [ ] Define minimal funnel measurement: onboarding completion, paywall presentation, purchase/restore, first day completed, invite accepted, and return use. Use Superwall for purchase metrics; choose any additional analytics only after deciding its privacy/data scope. Exclude questionnaire answers, names, photos, and habit text from events.

**Done when:** a new user understands the plan, purchase, first task, and optional Friends/widgets without assistance; reconfiguration preserves archived progress.

### Phase 5 — TestFlight release candidate

- [ ] Run all unit and UI tests after final feature changes. Add meaningful tests for subscription routing, widget snapshot/day rollover, and Friends access/deletion boundaries.
- [ ] Test on a physical phone: install/upgrade, onboarding, purchase/restore, midnight/grace, Day 75, camera denial, notifications denial, water persistence, workout timer/Live Activity, widget, and Friends.
- [ ] Verify supported iPad layouts or make an explicit supported-device decision before screenshots/submission.
- [ ] Archive/upload a Release build. Confirm signing, App Group, production backend/auth redirects, product environment, version/build, icon, and no dev controls.
- [ ] Distribute through TestFlight to a small target-audience group; give concrete tasks and collect friction/bug reports.
- [ ] Require successful purchase/restore, widget, and two-account Friends runs on the release candidate. Fix data-loss, crash, billing, or access-control failures before submission.

**Done when:** every critical journey has a recorded pass on the candidate build. Existing 12 passing tests do not substitute for these new-feature checks.

### Phase 6 — finish the store listing and review package

- [ ] Publish public HTTPS privacy and support pages and a working support inbox. Replace the current local-only privacy wording to accurately describe Superwall and Supabase. Link privacy, terms, and support in-app and from the paywall.
- [ ] Complete App Privacy answers based on the shipped SDKs/backend, age rating, content rights, export compliance, and any required account information.
- [ ] Enter support URL on the version page and privacy-policy URL under App Privacy. Complete subscription localizations and review screenshots; include the first subscriptions with the app submission as required.
- [ ] Confirm store title availability. Set Home Screen display name separately; the current project display-name setting needs checking because it is empty.
- [ ] Produce actual-build screenshots: 75-day promise → daily routine → Friends → Home Screen widget → progress/photos → challenge choices. Keep screenshot claims aligned with shipped features.
- [ ] Write concise description/keywords and explain subscriptions clearly. Do not use competitor names in metadata.
- [ ] Provide a working Friends review account/access route and invite code, live backend, exact paywall navigation, restore instructions, widget instructions, and purchase-product notes.
- [ ] Submit the final build with **manual release** selected. Resolve any review questions/rejections, update notes/build if necessary, and recheck the corrected journey.

**Done when:** Apple approves the app and required subscriptions, with the version ready for developer release.

### Phase 7 — release and verify it is live

- [ ] Verify production backend, auth, paywall campaigns, products, support/privacy pages, and review access remain live.
- [ ] Release the approved version from App Store Connect when ready. Apple says availability can take up to 24 hours after manual release.
- [ ] Check the public listing, name, screenshots, pricing, privacy/support links, and supported regions.
- [ ] Install the public App Store build; verify onboarding, purchase access/restore, friend connection, and widget gallery availability.
- [ ] Monitor crashes, purchase issues, invite failures, and support during the first 48 hours. Prepare a focused hotfix if needed.

**Done when:** the public listing is available and the downloaded store build passes the launch journeys.

## Timing and immediate next work

Working estimate: **10–15 focused development/QA days**, assuming service/account configuration is ready. This is a planning range, not a release commitment. TestFlight feedback and Apple's review time are additional and can change the schedule.

1. Prove the configured paywall on-device.
2. Set up Supabase/Auth and complete the private Friends flow.
3. Build the two Home Screen widgets.
4. Apply the reference-inspired onboarding and first-day polish.
5. TestFlight, listing/review package, approval, manual release, public-build verification.

The owner supplies service configuration and confirms final branding/contact details; implementation, testing, and reviewable artifacts can proceed locally. AR remains v2. Save estimates and test evidence as work completes; move the launch date if a required acceptance gate fails.

## Source links

- Her 75 listing: https://apps.apple.com/us/app/her-75/id6746784659 — audience/positioning reference; local screenshots supply the detailed flow analysis above.
- Apple review guidelines: https://developer.apple.com/app-store/review/guidelines/ — accurate metadata, review access, social-feature handling, privacy, and in-app account deletion.
- Manual release: https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/ — manual release after approval and availability timing.
