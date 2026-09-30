# Glow Protocol: product review and proposed changes

**Review date:** September 17, 2026  
**Status:** Product proposal based on the current working tree, a simulator walkthrough, and the supplied competitor screenshots. Proposed features still need user validation.

## Executive recommendation

Position Glow Protocol as **the private, adaptable 75-day protocol people can actually sustain**. Her75 makes joining a challenge feel exciting through imagery, member counts, invitations, and social activity. Glow already has a stronger set of daily tools: a workout timer, water interaction, progress scrapbook, grace days, habit statistics, and run history. The next step is to make that value obvious before purchase and make the record reliable enough to trust for 75 days.

Prioritize data integrity and purchase readiness first. Then shorten onboarding, improve the first day, and add a small private accountability loop. Do not build a broad public feed or recipe platform before testing whether users want those features.

## Evidence and scope

- Reviewed the current local SwiftUI working tree, including the uncommitted Superwall integration. The public GitHub README describes an earlier paywall state.
- Reviewed all 78 Her75 screenshots in `Her75App`. Screenshots establish visible UI, not actual usage, conversion, privacy controls, or feature reliability.
- The live simulator walkthrough is recorded below. Device-only behavior, real purchases, and long-term retention require separate testing.

## Live app walkthrough

I ran the local app in the **Test iphone, iOS 18.0** simulator. Onboarding was tested through its normal route. The summary's final action did not advance, so I temporarily routed the simulator to the main tabs, inspected them, and restored the source afterward. That route creates a default Hard plan; its eight-habit Today screen is **not** evidence that a completed Medium onboarding would produce the wrong plan. I did not test a real purchase, camera capture, notifications, or a multi-day run.

### What already works

- The serif typography, warm neutral palette, restrained icons, and generous spacing form a coherent identity. The Today view is calmer and easier to scan than Her75's more crowded challenge and community surfaces.
- Onboarding suggests a difficulty based on the selected lifestyle, lets users inspect habits, and shows a final protocol summary. That gives users more control over the rules than a fixed challenge.
- Today has a visible day count and completion ring, clear per-habit rows, a water sheet, and a workout timer with pause and end controls. A workout starts in one tap. Ending it early leaves the task incomplete, which is the honest result.
- Progress brings day count, streak, per-habit completion, and a run heatmap together. Settings exposes difficulty, habit editing, grace days, reminder, theme, and reset in one place.

### Friction observed in the simulator

1. **The first useful screen is late.** The opening uses three editorial slides; the main CTA appears on the third. Name, identity, goal, lifestyle, social proof, difficulty, habit configuration, grace days, loading, and summary follow before any daily interaction. Several screens use large blank areas while key explanatory text is small.
2. **The promise changes mid-flow.** The grace screen says **“Start Day 1”**, then a loading screen and summary appear. The summary says **“Make it official →”**, but tapping it did not navigate or show a paywall in this simulator session. The project contains a placeholder Superwall API key, and the Xcode console reported `notAuthenticated` and `Skipped paywall presentation: no_config`. The simulator also showed an Apple Account sign-in prompt during launch; I dismissed it. A configured key, dashboard, and store account still need a separate purchase test.
3. **Proof and rules need clearer language.** Onboarding displays **“94,000 women have completed their protocol”** and a testimonial without a source in the project. Medium describes all habits as required while the habit setup presents toggles. A first-time user may not know which items are fixed, optional, or self-reported.
4. **The daily flow is clear but offers little guidance.** Today presents the full list at once and does not nominate a first action or show a useful time estimate. The water sheet says “Tap a glass to log it,” but its large vessel graphic does not show discrete glass controls clearly. The visible `DEV CONTROLS` section makes the build look unfinished.
5. **Progress has weak empty states.** On Day 1, Scrapbook is almost entirely blank aside from one small photo tile. “Before & After” says two photos are needed but provides no capture action. Progress starts with a useful summary, then a long list of 0% habit rates; at this stage, a motivating next step would carry more value than historical percentages.

## Competitive assessment

| Dimension | Her75 advantage | Glow response |
| --- | --- | --- |
| First impression | Photography and a clear lifestyle mood make the challenge desirable immediately. | Show the actual personal protocol and its distinctive benefits within the first two screens. Keep the calm editorial style. |
| Social motivation | Challenge groups, partner matching, friend status, and invitations make starting feel communal. | Test one invited accountability partner and a shareable day-one card before building a public network. |
| Adjacent help | Recipes and routine walls help users choose what to do, beyond checking a box. | Add targeted help inside the relevant habit, such as a saved meal idea or reading plan. |
| Daily execution | The screenshots show a simple checklist and photo slots. | Emphasize Glow's timer, progress record, and configurable rules. Make self-reported actions explicit. |
| Progress | A 75-day grid and profile content are visible. | Keep Glow's habit rates, streaks, scrapbook, before/after comparison, and past runs; make the metrics honest and explorable. |
| Trust | Large membership and success claims appear without supporting context in the screenshots. | Use only verifiable social proof. Lead with demonstrated product value and privacy. |

### Where Her75 is ahead

The supplied screenshots show a clearer emotional payoff before the user starts: photography, challenge options with member counts, partner matching, an invitation/story card, friends, recipes, and a profile wall. Those elements make the program feel like an event with other people involved. Glow's current first impression is polished but mostly text, and its private daily tools do not become tangible until after setup. Her75 also helps with the *decisions around a habit*, such as what to eat, whereas Glow currently records mostly whether a habit was done.

### Where Her75 is vulnerable

Its first-use path is also long. The Friends screen and profile wall are sparse in the provided examples, so the promised community can feel empty at the point of entry. The many content types can dilute the core daily action. Member counts and success language in screenshots do not tell us how active or successful those members are, and the screenshots do not establish whether its social features improve retention. A public-facing wall also creates more privacy and moderation work than a private progress record. These are observations and product risks, not claims about Her75's actual conversion or retention.

### Open territory for both products

Build a protocol that learns from the user's week without rewriting history: reflect on what worked, suggest one prospective adjustment, and show the effect on adherence over time. Make completion sources explicit (self-report, timer, device import, photo) so progress is credible. Give users a private export and a planned transition after day 75. Those moves make the product useful as an ongoing practice, rather than only a countdown or social challenge.

## Priority 0: protect the record and make the build shippable

### P0.1 Preserve past runs through reset and reconfiguration

**Problem:** `SettingsViewModel.resetProtocol()` archives current logs, but `OnboardingViewModel.finalize()` later deletes every `DayLog`. This can erase the history the Progress dashboard promises to retain.

**Change:** Give each run a permanent ID. On reconfiguration, archive the current run and create a new one without deleting old logs. If the user edits only a habit, apply the change prospectively and keep historical entries as they were.

**Acceptance:** Complete a run for several days, reset, reconfigure, and verify both the archived run and its photos remain visible after relaunch.

**Code:** `GlowProtocol/Features/Settings/SettingsViewModel.swift`, `GlowProtocol/Features/Onboarding/OnboardingViewModel.swift`, `GlowProtocol/Services/StreakService.swift`.

### P0.2 Make photo storage run-specific

**Problem:** `PhotoService` names JPEGs by calendar date and finds an existing photo by date alone. A new run on the same date can overwrite an archived photo or repurpose its metadata.

**Change:** Store under a run-specific path, such as `Scrapbook/<run-id>/<day-id>.jpg`, and query by run ID plus date. Add a migration for existing filenames.

**Acceptance:** Two runs containing the same calendar date retain distinct original photos and thumbnails.

**Code:** `GlowProtocol/Services/PhotoService.swift`.

### P0.3 Replace destructive migration recovery

**Problem:** `GlowProtocolApp` deletes the SwiftData store when initialization fails, then may fall back to an in-memory store. A schema issue can cost someone months of progress.

**Change:** Introduce versioned schema migration. On an unexpected failure, preserve the original store, report a recoverable error, and offer export or support rather than silently erasing it. Add a user-facing export of logs and photos; decide explicitly whether iCloud backup or cross-device sync is part of the promise.

**Acceptance:** An incompatible test store is never deleted automatically, and the user can recover or export it.

**Code:** `GlowProtocol/GlowProtocolApp.swift`.

### P0.4 Finish paywall and release configuration

**Problem:** The live onboarding path calls Superwall, but the current local app configures it with `SUPERWALL_API_KEY`. The older native `PaywallView` is bypassed. In my simulator walkthrough, tapping **“Make it official →”** produced no visible transition; the console reported `notAuthenticated` and `no_config`. Actual displayed offers depend on external dashboard and StoreKit setup that is not established by this repository.

**Change:** Provide the real public key through build configuration, configure the placement and products, and verify purchase, restore, dismissal, and already-subscribed paths in StoreKit sandbox. Review the actual rendered paywall for clear total billing, renewal, restore, and terms. Keep a useful route back to the protocol summary after dismissal.

**Acceptance:** A new user can purchase and enter Day 1; a returning subscriber bypasses purchase; restore works; a dismissed paywall does not trap or incorrectly unlock the app.

**Code:** `GlowProtocol/GlowProtocolApp.swift`, `GlowProtocol/Features/Onboarding/OnboardingView.swift`.

### P0.5 Remove release-only defects and unverifiable proof

**Problem:** The Today view renders `DEV CONTROLS` with no debug-only guard. Onboarding hardcodes “94,000 women” and a testimonial. The bold Playfair files referenced in the product notes are absent from the current resource folder.

**Change:** Compile debug controls only in debug builds; review all time-travel flags before release. Replace numerical and testimonial claims with documented, permissioned evidence or remove them. Bundle the intended font weights and verify the actual rendered typography.

**Acceptance:** Release builds have no simulation controls; every public proof claim has a source; hero typography uses the intended font.

**Code:** `GlowProtocol/Features/DailyGlow/DailyGlowView.swift`, `GlowProtocol/Features/Onboarding/WelcomeSlideView.swift`, `GlowProtocol/Features/Onboarding/SocialProofView.swift`, `GlowProtocol/Resources/Fonts/`.

## Priority 1: make the first week compelling

### P1.1 Shorten onboarding and show a real plan before payment

**Problem:** Glow collects a name, identity, goals, lifestyle, difficulty, habits, and grace preferences before a user sees Day 1. It also inserts social proof and a loading step. Identity and goal selections are not currently persisted into the final config, so parts of the sequence feel more personal than the resulting app is. “Start Day 1” on the grace screen does not match the next screen.

**Change:** Test a shorter sequence: goal → suggested daily plan → adjust intensity and habits → plan preview → purchase → Day 1. Let the user see the expected time commitment, a sample daily screen, the grace rule, and the private scrapbook before purchase. Move optional name, notification, and partner steps to moments when they are useful. Persist an answer only if it changes later content or review prompts. Rename the grace CTA to describe the actual next step, and state whether each suggested habit is required or optional for the chosen mode.

**Acceptance:** A first-time user can explain what the app will ask of them tomorrow, what happens on a missed day, and why they would pay for it.

**Code:** `GlowProtocol/Features/Onboarding/`.

### P1.2 Make the first day useful immediately

**Problem:** The observed Today screen is clean, but it opens with the complete list and a 0% ring. It offers no suggested starting task, time estimate, or first-day guidance. The Day 1 Progress screen leads with historical percentages that have not yet had time to mean anything.

**Change:** Put the next meaningful action at the top. Show a concise day summary and estimated time for timed tasks, with a clear way to start a workout, log water, or capture a photo. Keep completed items accessible without letting them dominate. Add a small explanation of each habit's completion method. For the first few days, let Progress show one actionable insight before detailed rates.

**Acceptance:** In a usability session, a new user can start their first task without instruction and can find how to undo it.

**Code:** `GlowProtocol/Features/DailyGlow/DailyGlowView.swift`, `GlowProtocol/DesignSystem/Components/HabitRow.swift`.

### P1.3 Persist partial progress and describe proof honestly

**Problem:** Water taps live only in view-model state, and touching a high bottle segment can jump to eight glasses. Steps are a manual check. These are useful logging actions, but do not verify consumption or movement.

**Change:** Persist partial water quantity in the day log, support units and a configurable target, and make each increment explicit. Add optional HealthKit step import with a manual fallback. Label completion sources as self-reported, timer-recorded, device-imported, or photo-attached; never call a self-report “verified.”

**Acceptance:** Partial water progress survives force quit and relaunch; completion reflects the chosen target; imported and manual steps are visibly distinguishable.

**Code:** `GlowProtocol/Features/DailyGlow/WaterTrackerView.swift`, `GlowProtocol/Features/DailyGlow/DailyGlowViewModel.swift`, `GlowProtocol/Models/DayLog.swift`.

### P1.4 Separate continuity, adherence, and grace

**Problem:** Soft mode marks incomplete days as `streakHeld`, and the heatmap renders held days in the same dark color as completed days. This makes a supportive mode look more complete than it is.

**Change:** Track and display three concepts separately: days continued, percent of planned habits completed, and grace/rest days. Let users inspect a past day from the heatmap. On a missed day, offer a recovery choice and a brief reason prompt rather than only a reset decision.

**Acceptance:** A user can tell which days were fully complete, partially complete, excused, or missed in every mode.

**Code:** `GlowProtocol/Services/StreakService.swift`, `GlowProtocol/Features/Progress/ProgressDashboardView.swift`, `GlowProtocol/Features/FailState/`.

### P1.5 Make reminder promises match actual behavior

**Problem:** Settings says streaks evaluate at 11:59 PM; the background task is scheduled with an earliest start at 23:59:50, which is not a guaranteed execution time. Evaluating before midnight can also mark a day failed while the user still has seconds to finish it.

**Change:** Evaluate only a closed calendar day. Use foreground catch-up as the reliable path, and describe background notifications as best-effort reminders. Offer a user-set evening reminder and, later, per-habit timing only if users ask for it.

**Acceptance:** No day is failed before local midnight; app reopening after multiple days produces a consistent run state.

**Code:** `GlowProtocol/Services/BackgroundTaskService.swift`, `GlowProtocol/Services/NotificationService.swift`, `GlowProtocol/RootView.swift`.

### P1.6 Turn empty states into entry points

**Problem:** The observed Scrapbook has a tiny Day 1 placeholder in a mostly blank page. Its “Before & After” sheet explains why it is empty but cannot take the first photo from there. Her75's story card and wall make progress feel shareable earlier, even when a member has little history.

**Change:** On an empty Scrapbook, show a clear **Take your first photo** action, the privacy default, and an example of how a 75-day record will grow. In comparison, link directly to capture when fewer than two photos exist. Keep any social sharing an explicit export, never the default for private photos.

**Acceptance:** A new user can reach photo capture from both empty states and knows who can see the image.

**Code:** `GlowProtocol/Features/Scrapbook/`.

## Priority 2: create a growth loop without losing privacy

### P2.1 Add a day-one sharing card and private invitation

Generate a polished card containing the user's chosen protocol, start and end dates, and optionally a few habit names. Allow sharing through the system share sheet. Offer an invitation for one partner with explicit controls over which completion details they can see. Test whether this produces invitations and useful accountability before building discovery, a feed, or photo sharing.

**Success measure:** Invites sent per activated user, invite acceptance, and day-7 retention for users with and without a partner. Do not interpret correlation as proof that the partner caused retention.

### P2.2 Add a weekly reflection that changes the plan

Ask three short questions: What worked? What got in the way? What should change next week? Show habit completion beside the user's notes. Recommend one small adjustment, subject to user approval, so the app feels adaptive rather than merely customizable on day one.

**Success measure:** Weekly review completion, accepted adjustments, and subsequent adherence.

### P2.3 Support the habit where decisions happen

Offer a lightweight saved idea within a habit: a meal idea for diet, a reading list for reading, or a workout plan link for exercise. Start with personal saved items rather than a full recipe catalog or content feed. This addresses Her75's useful adjacent content while keeping Glow focused.

### P2.4 Design the day-75 handoff

At completion, show an exportable account of consistency, selected reflections, and private photos. Offer a maintenance protocol with fewer habits and flexible scheduling. Let users choose to start another 75-day run without erasing the one they finished.

## Proposed sequence

1. **Reliability gate:** Preserve archived logs and photos; replace destructive store recovery; hide developer controls; verify the live paywall and truthful proof.
2. **First-week redesign:** Shorten onboarding, show the actual protocol before purchase, improve the first daily action, persist partial tracking, and clarify missed-day behavior.
3. **Retention experiment:** Weekly reflection and one private accountability partner.
4. **Expansion:** Add small pieces of supporting content and a post-75-day experience based on observed user needs.

## Validation plan

- Conduct five first-use sessions on an installed build. Record where users hesitate, whether they understand Hard/Medium/Soft, and whether they can complete one habit without help.
- Test reset, reconfiguration, and photo retention with real multi-run data before any public release.
- Run device QA for timer backgrounding, Live Activity, camera, notifications, dark mode, large Dynamic Type, and purchase restoration.
- Instrument only the funnel needed to decide next steps: onboarding step completion, first habit completion, day-2/day-7 return, paywall view and purchase, grace usage, and weekly review. Document privacy implications before adding analytics.
- A/B test the shorter onboarding and day-one card after reliability issues are resolved. Use activation and day-7 retention as primary signals, not just paywall conversion.

## Source references

- Glow code: `GlowProtocol/Features/Onboarding/`, `GlowProtocol/Features/DailyGlow/`, `GlowProtocol/Features/Progress/`, `GlowProtocol/Services/`, and `GlowProtocol/GlowProtocolApp.swift`.
- Her75 screenshots: `IMG_0927 2.PNG` (opening), `IMG_0933 2.PNG` (challenge selection), `IMG_2945.PNG` (partner), `IMG_2950.PNG` (day-one card), `IMG_2963.PNG` (recipes), `IMG_2967.PNG` (friends), `IMG_2977.PNG` (wall), `IMG_2983.PNG` (daily tasks).
