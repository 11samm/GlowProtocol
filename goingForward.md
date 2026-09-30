# Glow Protocol — Going Forward

> Written Jun 17, 2026. Based on BLUEPRINT.md, Sprint2.md, the ship plan, and the current state of the codebase.

---

## What's done

| Item | Status |
|---|---|
| 13-step onboarding with personalization | ✅ |
| Daily Glow checklist — all validators (workout timer, water, photo, steps, reading, diet, no alcohol) | ✅ |
| Custom habits with icon + color picker (Sprint 2) | ✅ |
| Scrapbook grid + before/after slider + watermarked export | ✅ |
| Progress dashboard + streak stats + calendar heatmap | ✅ |
| Fail-state + grace-day flow | ✅ |
| Settings (appearance, notifications, edit protocol, reset) | ✅ |
| StreakService with unit tests | ✅ |
| Widget extension — Live Activity (workout timer) | ✅ |
| App Groups entitlement + background modes — wired | ✅ |
| App icon — standard / dark / tinted 1024×1024 PNGs in asset catalog | ✅ |
| Prices — lowered 1¢ each ($12.99 / $44.99 / $5.99) | ✅ |
| Superwall SDK — added, configured in code, onboarding gate wired | ✅ |

---

## Part 1 — Do right now (no Apple Developer Program needed)

These can be completed today while your ADP enrollment processes.

---

### 1. Download and add the bold Playfair fonts

Every `.glowSerif(weight: .bold)` call — the launch logotype, paywall headline, hero screen titles — is silently falling back to the system serif because only `PlayfairDisplay-Regular.ttf` and `PlayfairDisplay-Italic.ttf` are bundled. This is the most visible gap in the app right now.

**Steps:**
1. Go to [fonts.google.com/specimen/Playfair+Display](https://fonts.google.com/specimen/Playfair+Display), click **Download family**.
2. From the zip, take `PlayfairDisplay-Bold.ttf` and `PlayfairDisplay-BoldItalic.ttf`.
3. Drag both into `GlowProtocol/Resources/Fonts/` in Xcode — make sure **Add to targets: GlowProtocol** is checked (not the widget target).
4. In Xcode → GlowProtocol target → Build Settings → search `UIAppFonts`. Update both the Debug and Release values to:
   ```
   PlayfairDisplay-Regular.ttf,PlayfairDisplay-Italic.ttf,PlayfairDisplay-Bold.ttf,PlayfairDisplay-BoldItalic.ttf
   ```
5. Build and run. The launch logotype, paywall headline, and onboarding hero titles should now render in proper Playfair Bold.

**Verify:** In a debug build, temporarily add `print(UIFont.familyNames)` to `GlowProtocolApp.init()` — `"Playfair Display"` must appear. Remove the print before archiving.

---

### 2. Host the privacy policy

App Store Connect will not let you submit without a publicly accessible privacy policy URL. The copy already exists in the app (`SettingsView.swift` → `PrivacyPolicyView`). You just need to put it online.

**Quickest path — GitHub Pages:**
1. In the `GlowProtocol` repo, create a `/docs/` folder.
2. Create `/docs/privacy.html` with the content below (adapt as needed):

```html
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Glow Protocol — Privacy Policy</title>
<style>body{font-family:-apple-system,sans-serif;max-width:680px;margin:48px auto;padding:0 24px;color:#141414;line-height:1.6}h1{font-size:28px}h2{font-size:18px;margin-top:32px}</style>
</head>
<body>
<h1>Privacy Policy</h1>
<p><strong>Last updated: June 2026</strong></p>

<h2>Your data stays on your device</h2>
<p>Glow Protocol stores all habit data, photos, and progress locally on your device using Apple's SwiftData framework. We do not operate a backend server or upload your personal data.</p>

<h2>Photos</h2>
<p>Progress photos are written to your app's private sandbox and are never uploaded to any server.</p>

<h2>Notifications</h2>
<p>We use local notifications scheduled on your device for daily reminders and the nightly streak evaluation. No notification content is transmitted over the network.</p>

<h2>Subscriptions & Payments</h2>
<p>Subscriptions are processed entirely by Apple through the App Store. We use Superwall to present subscription options; Superwall may collect anonymized analytics about paywall interactions. We do not receive or store your payment information. See <a href="https://superwall.com/privacy">Superwall's Privacy Policy</a> for their data practices.</p>

<h2>Analytics</h2>
<p>We do not use any third-party analytics SDK beyond Superwall's paywall analytics described above.</p>

<h2>Contact</h2>
<p>Questions? Email <a href="mailto:support@glowprotocol.app">support@glowprotocol.app</a>.</p>
</body>
</html>
```

3. Push to GitHub. In the repo Settings → Pages → Source: `main` branch, `/docs` folder. Save.
4. Your URL will be: `https://yourusername.github.io/GlowProtocol/privacy.html`
5. Keep this URL — you'll paste it into App Store Connect later.

---

### 3. Draft your App Store Connect metadata

Write this now so you're not staring at a blank text box during submission. Character counts matter.

| Field | Limit | Suggested content |
|---|---|---|
| **Name** | 30 | `Glow Protocol` |
| **Subtitle** | 30 | `Your 75-Day Discipline Protocol` |
| **Promotional text** | 170 | Editable after launch without review. Use as a hook: `"The discipline challenge that adapts to your life. 75 days. Your habits. Your transformation."` |
| **Keywords** | 100 | `75 hard,discipline,habit tracker,glow up,fitness,challenge,streak,routine,self improvement` |
| **Age Rating** | — | 4+ |
| **Category** | — | Health & Fitness (already in build settings) |
| **What's New** | — | `Version 1.0 — Initial release.` |

**Description (≤4000 chars) — draft:**

```
Glow Protocol is a 75-day discipline challenge built around your life.

Not a rigid fitness app. A personal protocol. You choose your habits, your intensity, and your pace. Glow Protocol holds you accountable without punishing you.

— WHAT YOU BUILD —
Choose from three protocols: Hard (all habits, no grace days), Medium (all habits, 2 grace days/month), or Soft (your choice of habits, 3 grace days/month). Customize your workout duration, reading goal, and water target. Add up to 3 personal habits with custom icons and colors.

— HOW IT WORKS —
Each day you check off your habits. Glow Protocol validates them — your workout runs a real 45-minute timer, your water tracks glass by glass, your daily photo saves privately to your scrapbook. No honor system shortcuts.

— YOUR VISUAL PROOF —
Every day you take a progress photo. After 75 days, your scrapbook is a private visual diary of your transformation. Use the Before & After slider to see how far you've come — and share the comparison with a single tap.

— GRACE DAYS —
Life happens. Grace days let you miss a day without resetting your streak. Use them intentionally.

— YOUR PROGRESS —
The Progress dashboard shows your streak, per-habit completion rates, and a full calendar heatmap of your 75 days. Past runs are preserved — you can always look back at what you built.

SUBSCRIPTION INFORMATION
Glow Protocol is free to download. Access requires a subscription:
• Weekly: $5.99 per week
• Monthly: $12.99 per month
• Yearly: $44.99 per year

Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage or cancel your subscription anytime in iPhone Settings → Apple ID → Subscriptions. Payment is charged to your Apple ID account at confirmation of purchase.

Privacy Policy: [your URL here]
Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

---

### 4. Take and frame your screenshots

Apple requires screenshots for at least the **6.7" display** (1290×2796). Do this now in the simulator.

**Step 1 — clean up the status bar:**
```bash
xcrun simctl status_bar booted override --time "9:41" --batteryLevel 100 --cellularBars 4 --wifiBars 3
```

**Step 2 — capture the 4 hero screens:**
```bash
xcrun simctl io booted screenshot ~/Desktop/shot1.png
```

Run this after navigating to each of:
1. **Daily Glow** — with 3–4 habits checked, progress ring at ~60%, so it looks lived-in
2. **Scrapbook** — grid filled with placeholder/test photos
3. **Progress dashboard** — "Day 47" or similar, with the heatmap populated
4. **Paywall / onboarding summary** — the protocol summary screen looks great as a store screenshot

**Step 3 — frame and caption them:**
Raw simulator screenshots look amateur. Use one of:
- **Figma** — most control; use an App Store screenshot template, paste your shots in, add a `#F7F5F2` background and a Playfair Bold caption line above each frame. Caption ideas:
  - "Check in. Every day."
  - "Watch yourself transform."
  - "Your 75 days, your rules."
  - "Discipline, made beautiful."
- **Shotbot** (shotbot.io) — fast template-based framing, no Figma needed
- **Fastlane frameit** — scriptable if you'll redo them often

For **5.5"** (1242×2208): run iPhone 8 Plus simulator and repeat. Optional but recommended.

---

### 5. Design the Superwall paywall layout

You can log into the Superwall dashboard and design the paywall before your App Store Connect products exist. The visual editor works independently.

Build a paywall that matches the app brand:
- Background: `#F7F5F2`
- Headline: Playfair-style serif, bold italic, `#141414`
- 3-tier plan cards (Monthly = Most Popular, Yearly = Save 86%, Weekly)
- "PROTOCOL" in tracked small caps below the logo
- Subscription legal text block (required by Apple): "Subscriptions auto-renew. Cancel anytime in Settings."

You'll connect the real product IDs once your ADP account is active.

---

## Part 2 — Once you're in the Apple Developer Program

Do these in order. Steps 1–3 unlock everything else.

---

### 1. Create your App Store Connect app record

1. Sign in at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. My Apps → **+** → New App
3. Platform: iOS · Name: `Glow Protocol` · Bundle ID: `sam.GlowProtocol` · SKU: `glowprotocol-1`

---

### 2. Create the 3 subscription products

App Store Connect → your app → **Monetization → Subscriptions**

1. Create a Subscription Group: **"Glow Protocol"**
2. Add 3 Auto-Renewable Subscriptions:

| Reference name | Product ID | Price tier | Duration |
|---|---|---|---|
| Glow Weekly | `glow.weekly` | $5.99 | 1 week |
| Glow Monthly | `glow.monthly` | $12.99 | 1 month |
| Glow Yearly | `glow.yearly` | $44.99 | 1 year |

3. For each product, add a **localization** (English): display name + short description.
4. Add a **Subscription Group Localization**: name = "Glow Protocol", description = your subscription pitch.

---

### 3. Finish Superwall dashboard setup

1. **Settings → Keys** → copy your Public API Key → paste into `GlowProtocolApp.swift` replacing `"SUPERWALL_API_KEY"`
2. **Products** → Add the 3 product IDs (`glow.weekly`, `glow.monthly`, `glow.yearly`)
3. **Paywalls** → finish building the paywall you designed in Part 1 Step 5
4. **Campaigns → New Campaign** → name "Onboarding" → add placement `onboarding_complete` (must match the code exactly) → attach the paywall → Audience: All Users → **Publish**

---

### 4. Verify entitlements and signing on device

The entitlements files already exist and are wired in code. You just need to confirm:

1. Xcode → GlowProtocol target → **Signing & Capabilities**
2. Confirm **App Groups** shows `group.sam.GlowProtocol`
3. Confirm **Background Modes** has `fetch` and `audio` checked
4. In Apple Developer portal → Identifiers → `sam.GlowProtocol` → confirm App Groups and Live Activities are enabled
5. Automatic signing will regenerate the provisioning profile; just build once to a connected device to trigger it

---

### 5. Device QA pass

Do this on a physical iPhone running iOS 18+.

- [ ] All habit validators: workout timer (45 min, runs on lock screen), water tracker (8 glasses), progress photo (camera), reading, diet, no alcohol, steps, custom habits
- [ ] Workout Live Activity appears on lock screen and Dynamic Island
- [ ] Superwall purchase flow — use a **StoreKit sandbox account** (ASC → Users and Access → Sandbox Testers → create one; sign out of App Store on device and sign in with sandbox account):
  - [ ] Buy each of the 3 tiers
  - [ ] Restore purchases
  - [ ] Dismiss without buying — stays on summary, can re-trigger
  - [ ] Already subscribed → closure fires immediately, no paywall shown
- [ ] Midnight fail-state: set device clock to 23:59, confirm `StreakService.evaluateDay()` fires and fail/grace sheet appears
- [ ] Grace day flow end-to-end
- [ ] Cold launch after streak reset → Day 1 shows correctly
- [ ] Dark mode: every screen, no hardcoded colors bleeding through
- [ ] iPad layout: no broken layouts (target family includes iPad)
- [ ] All haptics fire correctly on completions

---

### 6. Fill in App Store Connect

1. Paste in all metadata from Part 1 Step 3
2. Upload your framed screenshots (from Part 1 Step 4)
3. Privacy Policy URL: the GitHub Pages URL from Part 1 Step 2
4. **App Privacy** nutrition label: declare the data Superwall collects (see [superwall.com/privacy](https://superwall.com/privacy) for their manifest). Your app itself collects nothing off-device, but you must declare Superwall's paywall analytics.
5. Set app price to **Free** (the subscriptions are the paid layer)
6. Age rating: 4+

---

### 7. Archive and submit

1. In Xcode: scheme → **Release** → destination → **Any iOS Device (arm64)**
2. **Product → Archive**
3. Xcode Organizer → **Distribute App → App Store Connect → Upload**
4. In App Store Connect: select the uploaded build, confirm all metadata is complete, submit the **3 subscriptions for review alongside the build** (they get reviewed together)
5. Add a note to the reviewer under "Review Notes": explain the Superwall paywall and provide a sandbox test account

**Expected review:** 24–48 hours for Health & Fitness.

---

## Part 3 — Future features (post-launch)

Everything below is from BLUEPRINT.md §8 and is explicitly scoped to Phase 2+. None of this should block the v1.0 launch.

---

### Near-term (v1.1 — first update after launch)

**HealthKit steps integration**
The current steps habit is a manual honor-system tap. Phase 1 intentionally skipped HealthKit to avoid the extra entitlement complexity for first submission. After launch:
- Add HealthKit capability (read access only)
- `NSHealthShareUsageDescription` in Info.plist
- Use `CMPedometer` or `HKStatisticsQuery` to auto-pull daily step count
- Auto-complete the steps habit when the device reports ≥ 10,000 steps

**Home screen widget — habit summary**
The `GlowProtocolWidgets` target exists and the Live Activity (workout timer) works. The home screen medium widget and lock screen accessory widget from BLUEPRINT §7 are not yet implemented:
- `GlowWidgetProvider.swift` reads today's `DayLog` from the shared App Group store
- Medium widget: progress ring + day number + top 3 habits
- Lock screen accessory: single progress ring with day number

**Past Runs in Progress tab**
BLUEPRINT §11.15 spec'd a "Past Runs" section in the Progress dashboard. When the user resets and starts again, their archived `DayLog` records (where `isCurrentRun == false`) are preserved but not currently surfaced in the UI. Add the read-only past-run cards with mini heatmaps.

---

### Medium-term (v1.2–v1.3)

**Apple Watch companion**
A watchOS target with a simple complication showing today's completion ring and a glanceable habit list. Shares the same App Group store.

**Widgets on iPad / Mac Catalyst**
The app targets iPhone + iPad (family 1,2). A Mac Catalyst build + Mac-optimized layout would open the app to MacBook users doing desk-based protocols.

**Streak sharing card**
A one-tap "I'm on Day X" share card using `ImageRenderer` — the Glow Protocol logotype, day number in large serif, and a minimal heatmap of the current streak. Sized for Instagram Stories (9:16). Drives organic word-of-mouth.

**Notification customization**
The current reminder is a single daily time. Let users set per-habit reminders ("remind me at 7am to work out, 9pm to read").

---

### Phase 2 — Social / Backend (major update)

All of this requires Supabase (PostgreSQL + Realtime + Auth + Storage) as specified in BLUEPRINT §8.

**Glow Circle — friends tab (Tab 4)**
- Add Friend by username search
- Friend list: avatar, username, current day number, today's completion ring
- Data from `day_summaries` table via Supabase Realtime (live updates)

**Passive social feed**
- Vertical scrollable feed, one card per friend per day
- Shows: avatar, name, "Day X" badge, habit rows with completion checkmarks and timestamps
- Privacy toggle: each user controls which habits are visible
- No comments, no likes — read-only, intentionally minimal

**Nudge notifications**
- Lightning bolt button on each friend's card
- Sends a push notification via Supabase Edge Function + APNs: "Sam nudged you — time to glow! 💪"
- Rate-limited: 3 nudges sent per user per day

**Verification photo sharing**
- After capturing a progress photo, an opt-in toggle: "Share to Glow Circle?"
- Shared photos upload to Supabase Storage, visible to accepted friends only
- Never a global public feed — privacy first

**Auth**
- Sign in with Apple (BLUEPRINT §9, capability #7)
- Supabase Auth wrapping Apple's identity token

**Push Notifications (server-side)**
- Currently all local. Phase 2 adds server-sent push for nudges, friend milestones ("your friend just hit Day 75!"), and streak encouragement

---

## Priority cheat sheet

```
RIGHT NOW (no ADP)
  1. Bold Playfair fonts → biggest visible gap
  2. Privacy policy HTML → host on GitHub Pages
  3. Draft App Store metadata + description
  4. Take simulator screenshots, frame them
  5. Design Superwall paywall layout in dashboard

ONCE ADP IS ACTIVE
  1. Create ASC app record
  2. Create 3 subscriptions (glow.weekly / glow.monthly / glow.yearly)
  3. Finish Superwall dashboard — API key + products + campaign + placement
  4. Verify signing / entitlements on device
  5. Full device QA (esp. purchase flow + Live Activity)
  6. Fill ASC metadata + screenshots + privacy labels
  7. Archive → Upload → Submit

AFTER LAUNCH (v1.1)
  1. HealthKit steps auto-completion
  2. Home screen + lock screen widgets
  3. Past Runs UI in Progress tab

PHASE 2 (major)
  Supabase backend → Glow Circle → nudges → photo sharing
```
