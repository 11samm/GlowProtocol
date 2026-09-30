# Friends design philosophy

Written September 30, 2026. Read before making any Friends screen, copy, animation, or backend decision. This is the implementation reference; onboarding redesign is deliberately deferred until the rest of the app is ready.

## 1. Product feeling

**A quiet place to show up alongside someone you know.** Opening Friends should feel like checking in with a friend over coffee: personal, encouraging, easy to understand, and comfortable to leave. The user's own routine remains the main activity. Friends provides companionship and accountability without turning the challenge into an audience or a competition.

The requested clean girl aesthetic is expressed through editing and restraint: warm white, generous whitespace, editorial type, soft paper-like cards, pale sage and blush accents, and deliberate pacing. It should feel cared for and usable every day. It should not rely on an ideal body, expensive possessions, or a specific lifestyle to make someone feel included.

## 2. Reference evidence and limits

Reviewed the supplied screenshots in `Her75App` and `Reset75`. These are visual references, not permission to reuse their photographs, copy, statistics, interface assets, or trademarks. Static screenshots establish appearance and visible screen structure; they cannot establish retention, conversion, live backend behavior, or causation. The user separately described Her75's reversible login blur animation.

### Her75 observations

- `IMG_2937.PNG`, `IMG_2940.PNG`, `IMG_2941.PNG`: photographic challenge strips sit in broad white space. The large serif heading gives a sense of lifestyle and identity, while buttons are compact, dark, and obvious.
- `IMG_2944.PNG`: account creation appears after challenge selection. The headline is editorial, providers are familiar, and decorative flowers leave most of the screen uncluttered. Glow's copy must match actual storage behavior rather than imply cloud backups.
- `IMG_2947.PNG` and `IMG_0946 2.PNG`: the invitation becomes a tangible card with a friend code. This makes a backend action feel like giving someone something. A solo choice remains visible.
- `IMG_2949.PNG`–`IMG_2951.PNG`: commitment is represented as a personal artifact. Its small task list makes an abstract challenge concrete.
- `IMG_2966.PNG`, `IMG_2967.PNG`: Friends is person-first: avatar/name/day beside a small task card, plus an add control. The social surface has breathing room, rather than dense metrics.
- `IMG_2968.PNG`–`IMG_2970.PNG`: Discover/community groups are broader than a private friendship. Their appearance does not mean Glow needs those surfaces in v1.
- `IMG_2971.PNG`–`IMG_2981.PNG`: the profile/wall uses a sparse, scrapbook-like layout. Recipes and routine photographs enrich the lifestyle brand, but expanding into public posting would materially change privacy and moderation requirements.
- `IMG_2982.PNG`, `IMG_2985.PNG`: account and legal actions are grouped in settings; logout and deletion are visible.

**What we take:** whitespace, serif/sans hierarchy, human names before numbers, rounded paper cards, calm provider choices, a beautiful share artifact, light tactile motion, and clear account controls.

**What we adapt:** initials instead of uploaded avatars; day and percentage instead of private task text; private accepted friends instead of discovery; original Glow palette/copy/layout. The reference's numerical uplift and matching claims are not evidence for our app.

### Reset75 observations

- `IMG_3333.PNG`, `IMG_3382.PNG`, `IMG_3384.PNG`: warm neutral surfaces, crisp sections, restrained lines, legible large day numbers, and a primary action with little ambiguity.
- `IMG_3336.PNG`–`IMG_3352.PNG`: short questions separate decisions and progressively establish a plan. This is relevant to explaining Friends in small steps, even though onboarding work is postponed.
- `IMG_3354.PNG`–`IMG_3357.PNG`: progress and a named checklist make a process feel understandable. Glow uses honest busy states, without fabricated analysis or arbitrary delays.
- `IMG_3365.PNG`–`IMG_3368.PNG`: a commitment has specific behaviors and a visible signature. A future Glow commitment can become a share artifact, but it is not required to connect two accounts.
- `IMG_3383.PNG`: a task sheet narrows the screen to one action, preserving the context behind it.
- `IMG_3386.PNG`, `IMG_3387.PNG`: a purchase timeline explains what happens next. Friends invitations likewise need explicit request, acceptance, and sharing states.

No private Friends screen is visible in the supplied Reset75 set. We infer useful structure from its task/progress screens, not an undocumented social feature.

**What we take:** clear progress states, practical hierarchy, precise next steps, calm neutral surfaces, and focused sheets.

## 3. Core principles and implementation consequences

### People first

The screen title is Friends. The introductory line is “A little company for your 75 days.” Connected rows show a display name and a small initials medallion before statistics. No follower counts, popularity scores, ranking, strangers, or inferred match percentages. V1 supports known people through an invitation code.

### One visual priority per region

The upper region establishes the emotional purpose. The invitation region exposes one main action. The friends list answers who is connected and what they chose to share. Account/privacy lives in a sheet accessible from the header. Requests are separate from accepted friends; a pending request must not look like a completed connection.

### Privacy is part of the design

“Only accepted friends can see the daily summary you choose to share” appears at the sharing control. Sharing starts off. Acceptance and sharing are distinct decisions. The interface never exposes email addresses, invite codes belonging to another account, photos, habit names, goals, or workout descriptions in friend rows. “Not sharing” is a valid neutral state. Lack of an update is not described as failure.

### No shame

Use “Today so far,” “Day 12,” “Last shared Sep 29,” and “Sharing is off.” Never use “behind,” “lazy,” “your friend is beating you,” or a red failure badge for someone else's incomplete day. Completion is a factual percentage, not a character judgment. A friend can be at a different challenge day and still belong here.

### Invitations are offers

Share content names Glow Protocol, contains the real authenticated invite code, and explains how to join. Native share sheet completion is not delivery, acceptance, or payment. A copied link cannot grant a subscription. Entering a code creates a request; the owner accepts it. Preview the recipient's display name through the resulting request rather than exposing a searchable user directory.

### Honest absence and uncertainty

An empty screen has one invitation action and one code-entry alternative. A loading state says what is loading. An unavailable backend explains that local progress is safe and offers retry/support. No fake connected friends, fabricated live status, or zero-percent placeholder presented as real data. If refreshing fails, clear remote summary data rather than continuing to present potentially revoked private information.

### Local progress stays resilient

Friends outages never delete or overwrite SwiftData logs/photos. Server writes share only a minimal daily summary after consent. Logout clears account-specific memory and cancels pending work. Account switching must not publish the previous person's local challenge automatically; require a new sharing decision. The app must revalidate access before exposing paid social functionality.

## 4. Visual specification

| Element | Rule |
| --- | --- |
| Canvas | Existing warm `glowBackground`; dark mode adapts to existing surface colors. |
| Main heading | Playfair Display, approximately 34–38 pt, restrained italic emphasis; scales with accessibility type. |
| Functional text | System sans, approximately 15–17 pt; body and important secondary text meet readable contrast. |
| Eyebrow | Small uppercase, modest tracking, one per major section. |
| Card | Rounded continuous corners 24–28 pt; white/light surface; fine neutral border. |
| Spacing | 24 pt screen gutters; 24–32 pt major section gap; 12–16 pt card interior rhythm. |
| Primary action | Dark filled rounded button with high-contrast text, minimum 48 pt height. |
| Secondary action | Quiet outlined or text action, still at least 44 pt tap target. |
| Accent | Sage and blush in small shapes/initial medallions; no full-screen pink wash. |
| Avatar | Initials in a pale circle; no implied real photo or stock person impersonating a friend. |
| Progress | Thin neutral/sage ring and explicit percentage; never color alone. |
| Divider | Hairline neutral separator; avoid boxing every label. |
| Shadow | One subtle elevation layer where useful; not a shadow on every row. |

Do not force fixed heights for paragraphs, truncate names without an accessible full name, or place tiny tap targets beside oversized decoration. Decorative motifs remain abstract and original. No copied floral images or competitor photography.

## 5. Screen map

### Signed out

Hero headline and concise purpose; small original interlocking-circle motif; Apple and Google buttons; text explaining that friends accounts are optional for solo tracking. Support/privacy access remains available. Native Apple button uses platform styling. Google uses a clear text button in the OAuth flow. No passwords or fake email field.

### Signed in, no profile

Ask for a display name, not a full legal name. Explain that accepted friends see it. Validate length and control characters. Create one profile for the authenticated UUID; retry should reuse it, not create duplicates. Do not upload questionnaire answers to fill the profile.

### Empty Friends home

Header Friends plus account control. Hero “Better, together.” Invite card includes the user's code, copy action, share action. Separate “Have a friend's code?” entry. Empty section “Your circle starts here” explains acceptance. Sharing control is understandable and off by default.

### Connected home

Same layout with a lighter intro. “Your circle” contains person rows: initials, display name, day number/percentage if permitted, date of shared summary. Hidden/stale/no-summary states say so plainly. Requests section groups incoming and outgoing with distinct accept/decline/cancel actions. Pull to refresh and foreground refresh keep the data recent.

### Account sheet

Edit display name, explain sharing, sign out, delete account, and contact support. Deletion confirmation explains server records removed, local logs/photos kept, and that deleting an account does not cancel an Apple subscription. Apple revocation needs fresh authorization and server handling. Errors preserve a signed-in session for retry and never falsely report deletion complete.

### Remove/block/report

Friend menu uses plain language. Remove disconnects. Block removes relationships and prevents new requests/access; blocked accounts are manageable in the account sheet. Report offers a few reasons and optional short description, sent privately for moderation. A working support inbox and server report queue are required; “reported” means the server saved it.

### Invite opened before purchase

Store the code locally as a pending invitation. Sign in and create a profile before sending a request. Minimal account/invite actions can be available without paid access, while reading friends' daily summaries and tracking remain gated. Account recovery/deletion is reachable after expiry. Onboarding insertion and reversible welcome login overlay are postponed to the final onboarding phase.

## 6. Motion and interaction

Sheets rise over the current scene; dismissing restores the same context. A gentle 0.2–0.35 second fade/slide is sufficient. Avoid bouncy celebrations for relationship actions. Disable duplicate requests while busy and announce success/error to assistive technology. Reduce Motion removes large movement; VoiceOver reads name, relationship state and progress as a coherent element. Share uses the native sheet. Copy gives a small confirmation. Logout/deletion requires deliberate confirmation.

The future welcome login overlay coordinates blur and fade in both directions and dismisses via outside tap/close. It is recorded here to keep auth styling consistent, but belongs to the postponed onboarding phase.

## 7. Backend contract

All access derives from authenticated `auth.uid()`, never a UUID sent as proof by the client. Random invite code belongs to one profile. Request sender/recipient and status are validated on the server. Only recipient can accept, only participants can remove, and blocks in either direction suppress access. RLS is enabled for every table. Direct anonymous queries are denied. Privileged functions have fixed search paths and explicit grants.

Daily summaries contain user ID, local date, day number and integer completion percent. Writes require the owner and current explicit sharing permission. Accepted friends can read only with active relationship and no block. Turning sharing off removes old summaries and disables reads immediately. Profile reads reveal only accepted/request-related public display data through controlled RPCs, not email or another person's code. The owner can read their own profile/code.

Requests, reports and mutations require rate/size limits. Profile names are short plain text; a report queue has a human support process. Account deletion cascades relationships, blocks and summaries and anonymizes retained moderation records where necessary. Private service credentials and Apple signing keys remain only in server secrets.

## 8. Verification and review checklist

- [ ] Two real accounts connect via code; sender cannot accept their own request.
- [ ] Pending, rejected, canceled, removed and blocked states grant no summary access.
- [ ] Sharing starts off; disabling it revokes old summary reads.
- [ ] Summary contains no habit names, photos or questionnaire answers.
- [ ] Identity switching clears all remote UI and requires new sharing consent for local progress.
- [ ] Offline mutation reports failure and preserves local habit/photo data.
- [ ] Google cancellation, Apple cancellation, token expiry and relaunch are handled.
- [ ] Deletion is server confirmed; Apple revocation is handled where required.
- [ ] Small phone, large text, dark mode, VoiceOver and Reduce Motion remain usable.
- [ ] A screenshot of each state reads as one calm hierarchy, with one obvious next action.
- [ ] Privacy/support links and moderation workflow are live before submission.

## 9. Definition of a finished Friends feature

A user can authenticate with either provider, create a display profile, share a real invitation, request/accept a known friend, optionally share daily completion, remove/block/report, manage blocked accounts, sign out and delete their account. The interface is consistent with this document and the backend enforces the privacy boundaries even if the client is modified. Two-account device testing and deployment confirmation are required; compiling the app does not prove the social system works.

## 10. Implementation sources

- Supabase Swift OAuth: https://supabase.com/docs/reference/swift/auth-signinwithoauth
- Supabase native token login: https://supabase.com/docs/reference/swift/auth-signinwithidtoken
- Supabase Apple configuration: https://supabase.com/docs/guides/auth/social-login/auth-apple
- Row-level security: https://supabase.com/docs/guides/database/postgres/row-level-security
- Apple review requirements: https://developer.apple.com/app-store/review/guidelines/
