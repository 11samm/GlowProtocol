# Glow Protocol — App Product Blueprint

> **Bundle ID:** `sam.GlowProtocol` · **Deployment target:** iOS 18.0 · **Xcode:** 16.2 · **Language:** Swift 5.10 / SwiftUI

---

## Table of Contents

1. [Executive Summary & Aesthetic System](#1-executive-summary--aesthetic-system)
2. [Tech Stack](#2-tech-stack)
3. [MVVM Architecture & Folder Layout](#3-mvvm-architecture--folder-layout)
4. [SwiftData Models](#4-swiftdata-models)
5. [Screen Inventory & Navigation Map](#5-screen-inventory--navigation-map)
6. [Phase 1 Feature Specs](#6-phase-1-feature-specs)
7. [Widget Specs](#7-widget-specs)
8. [Phase 2 Social Feature Specs](#8-phase-2-social-feature-specs)
9. [Xcode Capability Checklist](#9-xcode-capability-checklist)
10. [May 25–31 Development Schedule](#10-may-2531-development-schedule)
11. [Screen-by-Screen UI Design Specification](#11-screen-by-screen-ui-design-specification)

---

## 1. Executive Summary & Aesthetic System

### Mission

Empower women to structure personal transformation through a fully customizable, high-aesthetic 75-day discipline challenge. Glow Protocol is not a rigid fitness tracker — it is a personal protocol that adapts to the user's lifestyle, aesthetic preferences, and discipline level.

---

### The Visual Identity

The reference image ("Do it with friends") defines the entire aesthetic direction. Key observations to carry through every screen:

- **Typography does the heavy lifting.** The hero title is a large, high-contrast serif (bold + italic), not a hero image. Let words be the visual.
- **The UI is almost colorless.** Backgrounds are white or off-white. Text is near-black. Color only appears as small indicators.
- **Checkmarks are bold black circles** when complete — no colored fills, no gradients. The contrast is the signal.
- **Cards are borderless white panels** on an off-white background. Depth comes from subtle shadows, not borders or colors.
- **Avatars are circular, full-bleed photos** with a thin ring indicator for completion state.
- **Everything is generous and unhurried.** Whitespace is not wasted — it communicates calm and premium quality.

**The rule:** if a design choice requires a bright or saturated color, it's wrong. The only color in the app comes from the pastel habit indicators (see below) and the fail-state red.

---

### Primary Palette

The app is built on three neutral base colors. These are used for 95% of all UI surfaces.

| Token | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| `background` | `#F7F5F2` (warm off-white) | `#0C0C0C` (near-black) | Root screen backgrounds |
| `surface` | `#FFFFFF` (pure white) | `#161616` (soft black) | Cards, sheets, modals |
| `surfaceSecondary` | `#EFECE7` (warm beige) | `#1F1F1F` (dark gray) | Input fields, secondary row fills |
| `divider` | `#E5E0D8` | `#2C2C2C` | Separators, hairlines |
| `textPrimary` | `#141414` (near-black) | `#F0EDE8` (warm white) | Headlines, habit names, body |
| `textSecondary` | `#9A9188` (warm gray) | `#6B6560` | Captions, day labels, timestamps |
| `textDisabled` | `#C5BFB7` | `#3A3A3A` | Placeholder text, unchecked habit label |

> The background is `#F7F5F2`, not pure white — this warm off-white is what gives the "clean girl" feel. Pure white (`#FFFFFF`) is reserved for elevated surfaces (cards) so they float visually.

---

### Pastel Habit Indicator Palette

Each habit type has its own assigned pastel. These pastels are used **only** for:
- The progress ring or dot on a habit row (incomplete state border / fill)
- The habit icon background tint
- The widget habit dot indicators

They are **never** used for backgrounds, text, or full-surface fills. Kept to small 16–24pt elements.

| Habit | Token | Light Pastel | Dark Pastel (muted) | Meaning |
|---|---|---|---|---|
| Workout | `habitWorkout` | `#D4E8C2` (sage green) | `#2A3D22` | Movement / vitality |
| Water | `habitWater` | `#C2DCF0` (sky blue) | `#1A2E3D` | Hydration |
| Diet | `habitDiet` | `#F5E6C8` (peach cream) | `#3D2E1A` | Nourishment |
| Reading | `habitReading` | `#E8D4F0` (lavender) | `#2E1A3D` | Mind |
| Steps | `habitSteps` | `#C8EAE0` (mint) | `#1A3330` | Movement |
| No Alcohol | `habitNoAlcohol` | `#FAE0E0` (blush) | `#3D1F1F` | Discipline |
| Progress Photo | `habitPhoto` | `#FFF0C2` (soft yellow) | `#3D3010` | Reflection |
| Custom 1/2/3 | `habitCustom` | `#E0E0E0` (cool silver) | `#282828` | General |

**Completed state for all habits:** the pastel ring fills to a solid **black** (`textPrimary`) checkmark on a white background — matching the reference image exactly. The pastel disappears on completion; the bold black check is the reward signal.

---

### Semantic Colors

These are used sparingly for system-level states only.

| Token | Hex | Usage |
|---|---|---|
| `checkComplete` | `#141414` / `#F0EDE8` | Filled checkmark circle (adapts to mode) |
| `checkIncomplete` | pastel per habit | Unfilled ring border |
| `destructive` | `#D94040` | Fail-state screen, reset confirmation |
| `destructiveSoft` | `#FAE8E8` | Fail-state background tint (light mode) |
| `gracePulse` | `#F5DFA0` (warm amber) | Grace day button pulse animation |

---

### Typography

The type system pairs a **high-contrast editorial serif** (Playfair Display) for hero moments with **SF Pro** for all functional UI text. This pairing is directly derived from the reference image.

| Style token | Font | Weight | Size | Line height | Usage |
|---|---|---|---|---|---|
| `displayHero` | Playfair Display | Bold Italic | 44pt | 1.1× | Onboarding hero ("Do it with friends"), fail-state "Day 1" |
| `displayTitle` | Playfair Display | Regular Italic | 32pt | 1.15× | Screen titles, section heroes |
| `displaySubtitle` | Playfair Display | Regular | 24pt | 1.2× | Secondary display moments |
| `headline` | SF Pro Display | Semibold | 17pt | 1.3× | Card titles, habit names, nav titles |
| `subheadline` | SF Pro Text | Medium | 15pt | 1.35× | Row sublabels, secondary headings |
| `body` | SF Pro Text | Regular | 15pt | 1.5× | Description copy, settings rows |
| `caption` | SF Pro Text | Regular | 12pt | 1.4× | Timestamps ("11:45am"), day labels |
| `mono` | SF Mono | Regular | 14pt | 1.0× | Timer countdown (45:00), step count |
| `badge` | SF Pro Rounded | Bold | 11pt | 1.0× | "Day 47" pill, completion count chip |

**Typography rules:**
- Serif (`displayHero`, `displayTitle`) is used on at most **one element per screen**. Never two serifs stacked.
- Never use a font size smaller than 11pt.
- `textSecondary` color is the only permitted color for body text — no colored text outside of error states.
- Letter-spacing: `-0.3pt` on `displayHero` and `displayTitle` for a tighter editorial feel; `+0.4pt` on `badge` for legibility.

Playfair Display is bundled as a custom font resource (`GlowProtocol/Resources/Fonts/`). Defined in `DesignSystem/Typography.swift` as `Font` extensions and `.glowText(_ style:)` `ViewModifier`.

---

### Spacing & Radius Scale

| Token | Value | Usage |
|---|---|---|
| `spacing2` | 2pt | Micro gaps (icon to label) |
| `spacing4` | 4pt | Inline element gaps |
| `spacing8` | 8pt | Component internal padding |
| `spacing12` | 12pt | Row vertical padding |
| `spacing16` | 16pt | Standard horizontal screen margin |
| `spacing24` | 24pt | Card internal padding, between list groups |
| `spacing32` | 32pt | Between major screen sections |
| `spacing48` | 48pt | Onboarding vertical rhythm |
| `spacing64` | 64pt | Hero section breathing room |
| `radiusSmall` | 8pt | Pill buttons, tag chips |
| `radiusMedium` | 14pt | Habit rows, input fields |
| `radiusLarge` | 22pt | Cards, bottom sheets |
| `radiusFull` | 999pt | Avatars, checkmark circles, progress rings |

---

### Iconography

- All icons use **SF Symbols**, weight `medium`, scale `.default`.
- Habit icons are 22pt SF Symbols placed inside a 36×36pt circle with the habit's pastel as the background fill and `textPrimary` as the symbol color.
- No icon libraries. No custom icon assets. System symbols only — this keeps the app feeling native and lightweight.

| Habit | SF Symbol |
|---|---|
| Workout | `figure.run` |
| Water | `drop.fill` |
| Diet | `leaf.fill` |
| Reading | `book.closed.fill` |
| Steps | `shoeprints.fill` |
| No Alcohol | `xmark.circle.fill` |
| Progress Photo | `camera.fill` |
| Custom | `star.fill` |

---

### Component Design Rules

These rules must be applied to every new component without exception.

**Habit Row (the core UI unit):**
```
[Pastel icon circle 36pt]  [Habit name — headline]          [Pastel ring OR black check 24pt]
                           [Completion time — caption gray]
```
- Row height: 64pt minimum.
- Separator: 1pt `divider` color hairline, inset to align with text (not full-bleed).
- Background: `surface` (white card).
- On complete: habit name color shifts from `textPrimary` → `textSecondary`. Timestamp fades in with a 0.2s ease.

**Progress Ring:**
- Stroke width: 4pt for small (lock screen widget), 6pt for medium (home widget), 8pt for main daily view.
- Track color (incomplete): `surfaceSecondary`.
- Fill color: **black** (`textPrimary`). Not the pastel — the ring fill is always black to keep the overall impression neutral. Pastels only on per-habit row indicators.
- Cap style: `.round`.

**Cards / Sheets:**
- Always `surface` (white / soft black) background.
- Shadow in light mode: `y: 2, blur: 12, color: black @ 6% opacity`. No shadow in dark mode.
- Corner radius: `radiusLarge` (22pt) for full sheets, `radiusMedium` (14pt) for inline cards.

**Buttons:**
- Primary: `textPrimary` background, `surface` text. Full-width, 54pt height, `radiusSmall`.
- Secondary: `surfaceSecondary` background, `textPrimary` text. Same dimensions.
- Ghost: no background, `textPrimary` text, 1pt `divider` border.
- No gradient buttons anywhere in the app.

**Bottom sheets:**
- Always presented with a 6pt wide, 36pt long drag handle pill in `divider` color at the top center.
- Background `surface`, `radiusLarge` top corners.

---

### Animation & Motion Rules

- **Spring, not easing.** Use `.spring(response: 0.35, dampingFraction: 0.72)` for all state-driven UI changes.
- **Checkmark completion:** scale `0.7 → 1.15 → 1.0` over 0.35s with a simultaneous opacity `0 → 1`.
- **Progress ring fill:** always animated, never instant. Duration 0.4s spring.
- **Sheet presentation:** use `.sheet` / `.fullScreenCover` defaults — do not override the system sheet animation.
- **No bouncing loaders, spinning indicators, or skeleton screens.** Data either exists or shows an elegant empty state. Never show activity indicators for local SwiftData reads.
- **Fail-state:** the only place where a dramatic animation is permitted. Everything else is subtle.

---

### What This Aesthetic Is NOT

To keep the team aligned, here is an explicit do-not list:

- No colored gradients (no pink-to-purple, no gold shimmer).
- No dark background with colored neon text.
- No rounded "bubble" UI with thick colored borders.
- No emoji in UI labels or buttons.
- No confetti or particle effects except the fail-state reset animation.
- No bold colored backgrounds on any full screen (fail-state destructive red is the only exception).
- No font mixing beyond Playfair Display + SF Pro.

---

## 2. Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| UI | SwiftUI | Native, declarative, animations first-class |
| Persistence | SwiftData (iOS 17+) | Schema-first, zero boilerplate ORM |
| State | `@Observable` macro + `@Environment` | Replaces `ObservableObject`, less boilerplate |
| Timers | `Timer.publish` + `BackgroundTasks` | Foreground countdown + background keepalive |
| Haptics | `CoreHaptics` (`CHHapticEngine`) | Custom haptic patterns per interaction |
| Photos | `PhotosUI` (`PhotosPicker`) + `UIImagePickerController` | In-app camera for verification photos |
| Local photo storage | `FileManager` + app's `Documents/Scrapbook/` | Keeps photos off Camera Roll |
| Widgets | `WidgetKit` + `SwiftUI` (widget extension target) | Home screen + lock screen widgets |
| Notifications | `UserNotifications` framework | Midnight fail-check + daily reminders |
| Background processing | `BGAppRefreshTask` | Midnight streak evaluation when app is backgrounded |
| Sharing | `UIActivityViewController` + `ImageRenderer` | Before/after export with watermark |
| Phase 2 — Backend | Supabase (PostgreSQL + Realtime + Auth + Storage) | BaaS with Swift SDK; social feed, nudges |
| Phase 2 — Networking | `async/await` + `URLSession` | No third-party HTTP library needed |

> **No third-party UI libraries.** All components are custom SwiftUI. This keeps binary size small and the aesthetic fully controlled.

---

## 3. MVVM Architecture & Folder Layout

### Architecture Pattern

**MVVM + Service Layer + SwiftData ModelContainer**

```
View  ──observes──►  ViewModel  ──calls──►  Service  ──reads/writes──►  SwiftData / FileManager / Network
```

- **Views** are pure SwiftUI — no business logic.
- **ViewModels** (`@Observable` class) hold derived state, call services, and transform model objects into display-ready values.
- **Services** are `actor`-isolated structs/classes handling persistence, camera, haptics, notifications, and (Phase 2) networking.
- **Models** are SwiftData `@Model` classes — treated as the single source of truth.

---

### Folder Layout

```
GlowProtocol/
├── GlowProtocolApp.swift            # @main; injects ModelContainer + root navigation
│
├── DesignSystem/
│   ├── Colors.swift                 # All Color tokens (light + dark)
│   ├── Typography.swift             # Font extensions + ViewModifiers
│   ├── Spacing.swift                # CGFloat spacing constants
│   ├── Animations.swift             # Shared Animation + Transition values
│   └── Components/
│       ├── GlowButton.swift         # Primary / secondary / ghost button styles
│       ├── HabitRow.swift           # Reusable checklist row with haptic tap
│       ├── ProgressRing.swift       # Circular progress view (used everywhere)
│       ├── DayBadge.swift           # "Day 47" pill
│       ├── ScrapbookCell.swift      # Calendar grid photo thumbnail
│       └── CheckmarkView.swift      # Animated checkmark (spring + haptic)
│
├── Resources/
│   └── Fonts/
│       ├── PlayfairDisplay-Bold.ttf
│       ├── PlayfairDisplay-BoldItalic.ttf
│       └── PlayfairDisplay-Regular.ttf
│
├── Models/
│   ├── ProtocolConfig.swift         # SwiftData: user's chosen difficulty + habit list
│   ├── DayLog.swift                 # SwiftData: one record per calendar day
│   ├── HabitEntry.swift             # SwiftData: individual habit completion record
│   └── ScrapbookPhoto.swift         # SwiftData: metadata for a saved photo
│
├── Services/
│   ├── StreakService.swift          # Streak calculation, fail-state evaluation, grace-day logic
│   ├── HapticService.swift          # CHHapticEngine wrapper; named patterns
│   ├── PhotoService.swift           # FileManager read/write for scrapbook photos
│   ├── NotificationService.swift    # Schedule + cancel local notifications
│   └── BackgroundTaskService.swift  # Register + handle BGAppRefreshTask
│
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingViewModel.swift
│   │   ├── DifficultyPickerView.swift
│   │   └── HabitCustomizerView.swift
│   │
│   ├── DailyGlow/
│   │   ├── DailyGlowView.swift      # The main checklist screen
│   │   ├── DailyGlowViewModel.swift
│   │   ├── WorkoutTimerView.swift
│   │   ├── WaterTrackerView.swift
│   │   └── PhotoCaptureView.swift
│   │
│   ├── Scrapbook/
│   │   ├── ScrapbookView.swift      # Calendar grid
│   │   ├── ScrapbookViewModel.swift
│   │   └── BeforeAfterSliderView.swift
│   │
│   ├── Progress/
│   │   ├── ProgressView.swift       # Stats dashboard
│   │   └── ProgressViewModel.swift
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── SettingsViewModel.swift
│   │
│   └── FailState/
│       ├── FailStateView.swift      # Full-screen reset animation
│       └── GraceDayConfirmView.swift
│
└── Shared/
    ├── Extensions/
    │   ├── Date+Glow.swift          # startOfDay, daysSince, formatted helpers
    │   ├── Color+Glow.swift         # hex init, adaptive convenience
    │   └── View+Glow.swift          # reusable ViewModifiers
    └── Utilities/
        └── ImageRenderer+Watermark.swift  # Before/after export helper

GlowProtocolWidgets/                 # Separate widget extension target
├── GlowProtocolWidgets.swift        # @main for widget bundle
├── GlowWidgetProvider.swift         # TimelineProvider
├── HomeScreenWidgetView.swift       # Medium widget UI
└── LockScreenWidgetView.swift       # Accessory circular widget UI
```

---

## 4. SwiftData Models

All models live in the `GlowProtocol` module and are registered in a single `ModelContainer` at app startup.

---

### `ProtocolConfig`

Stores the user's chosen ruleset. Only one instance ever exists (enforced in `StreakService`).

```swift
@Model
final class ProtocolConfig {
    var difficultyPreset: DifficultyPreset       // .hard | .medium | .soft
    var graceDaysPerMonth: Int                    // 0–5; default varies by preset
    var graceUsedThisMonth: Int
    var graceResetDate: Date                      // First day of current month
    var startDate: Date                           // Day 1 anchor
    var targetDays: Int                           // 75 for Hard, configurable otherwise

    // Habit toggles
    var workoutEnabled: Bool
    var workoutMinutes: Int                       // Default 45
    var workoutCountPerDay: Int                   // Default 2
    var waterEnabled: Bool
    var waterGallons: Double                      // Default 1.0
    var dietEnabled: Bool
    var readingEnabled: Bool
    var readingPages: Int                         // Default 10
    var noAlcoholEnabled: Bool
    var progressPhotoEnabled: Bool
    var stepsEnabled: Bool
    var stepTarget: Int                           // Default 10_000

    // Up to 3 custom habits (nil = slot unused)
    var customHabit1: String?
    var customHabit2: String?
    var customHabit3: String?

    // Computed
    var currentDay: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date.now)
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, days + 1)
    }
    var isCompleted: Bool { currentDay > targetDays }
}

enum DifficultyPreset: String, Codable {
    case hard    // All habits on, 0 grace days
    case medium  // All habits on, 2 grace days/month
    case soft    // User picks habits, 3 grace days/month
}
```

---

### `DayLog`

One record per calendar day. Created automatically at midnight by `StreakService` for the new day, or on first app open of a given day.

```swift
@Model
final class DayLog {
    var date: Date                   // Normalized to startOfDay
    var dayNumber: Int               // 1-based index from ProtocolConfig.startDate
    var streakHeld: Bool             // true = this day did not break streak
    var graceDayUsed: Bool
    var completedAt: Date?           // Timestamp when all habits checked
    var photoFileURL: String?        // Relative path inside Documents/Scrapbook/

    @Relationship(deleteRule: .cascade)
    var habitEntries: [HabitEntry]

    // Computed
    var allRequiredComplete: Bool { habitEntries.filter(\.isRequired).allSatisfy(\.isComplete) }
    var completionPercentage: Double {
        let required = habitEntries.filter(\.isRequired)
        guard !required.isEmpty else { return 0 }
        return Double(required.filter(\.isComplete).count) / Double(required.count)
    }
    var isArchived: Bool { false }  // Set to true when StreakService.hardReset() archives this run
}
```

---

### `HabitEntry`

One record per habit per day. Seeded from `ProtocolConfig` when a new `DayLog` is created.

```swift
@Model
final class HabitEntry {
    var habitID: HabitID             // Stable enum value (see below)
    var customLabel: String?         // Only set when habitID == .custom1/2/3
    var isRequired: Bool
    var isComplete: Bool
    var completedAt: Date?
    var validationMetadata: String?  // JSON blob — workout seconds elapsed, water taps, etc.

    @Relationship(inverse: \DayLog.habitEntries)
    var dayLog: DayLog?
}

enum HabitID: String, Codable, CaseIterable {
    case workout1, workout2
    case water
    case diet
    case reading
    case noAlcohol
    case progressPhoto
    case steps
    case custom1, custom2, custom3
}
```

---

### `ScrapbookPhoto`

Metadata for photos saved to the app's private directory. Actual image data lives on disk under `Documents/Scrapbook/<ISO-date>.jpg`.

```swift
@Model
final class ScrapbookPhoto {
    var date: Date                   // Normalized to startOfDay — matches DayLog.date
    var dayNumber: Int
    var fileURL: String              // Relative path; resolved via PhotoService
    var thumbnailData: Data?         // Low-res JPEG for grid rendering (≤ 20 KB)
    var capturedAt: Date             // Full timestamp
}
```

---

### `ProtocolRun` — Archive Model

When `StreakService.hardReset()` fires, all current `DayLog` records are stamped with a `runID` UUID and become read-only archived data. A new run begins. This is a lightweight wrapper — no new `@Model` class needed; `runID` is added to `DayLog`.

```swift
// Add to DayLog:
var runID: UUID          // Groups all DayLogs belonging to one continuous streak attempt
var isCurrentRun: Bool   // Only DayLogs in the active run have isCurrentRun = true
```

`StreakService.hardReset()` steps:
1. Fetch all `DayLog` where `isCurrentRun == true`.
2. Set each to `isCurrentRun = false` (archived).
3. Create fresh `DayLog` for today, `runID = UUID()`, `isCurrentRun = true`.
4. Update `ProtocolConfig.startDate = Date.now`.

The Scrapbook and Progress screens filter by `isCurrentRun == true` by default. A **"Past Runs"** row at the bottom of the Progress screen lets the user browse archived runs grouped by their `runID` and date range.

---

### `ProtocolConfig` Singleton Pattern

Only one `ProtocolConfig` record ever exists. The canonical fetch-or-create pattern used everywhere:

```swift
// In StreakService / any service that needs config:
func fetchOrCreateConfig(in context: ModelContext) -> ProtocolConfig {
    let descriptor = FetchDescriptor<ProtocolConfig>()
    if let existing = try? context.fetch(descriptor).first {
        return existing
    }
    let config = ProtocolConfig()   // initializes with Hard preset defaults
    context.insert(config)
    return config
}
```

`ProtocolConfig` must have a no-argument initializer that sets all defaults:

```swift
init() {
    self.difficultyPreset = .hard
    self.graceDaysPerMonth = 0
    self.graceUsedThisMonth = 0
    self.graceResetDate = Calendar.current.startOfDay(for: Date.now)
    self.startDate = Date.now
    self.targetDays = 75
    self.workoutEnabled = true
    self.workoutMinutes = 45
    self.workoutCountPerDay = 2
    self.waterEnabled = true
    self.waterGallons = 1.0
    self.dietEnabled = true
    self.readingEnabled = true
    self.readingPages = 10
    self.noAlcoholEnabled = true
    self.progressPhotoEnabled = true
    self.stepsEnabled = true
    self.stepTarget = 10_000
}
```

---

### `pendingGraceDecision` — State Location

Stored in `UserDefaults` via `@AppStorage` so it survives app termination (e.g. the OS wakes the app for a background task at 11:59 PM, evaluates the day, sets this flag, then the app is killed before the user sees it).

```swift
// In any View that needs to present FailStateView:
@AppStorage("pendingGraceDecision") var pendingGraceDecision: Bool = false
@AppStorage("pendingFailDate") var pendingFailDateInterval: Double = 0

// StreakService sets these keys directly:
UserDefaults.standard.set(true, forKey: "pendingGraceDecision")
UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: "pendingFailDate")
```

`RootView` checks `pendingGraceDecision` on every `.onAppear` and foreground transition (`scenePhase == .active`). If `true`, it presents `FailStateView` as a `fullScreenCover`.

After the user resolves the fail state (uses grace or accepts reset), both keys are cleared:
```swift
UserDefaults.standard.set(false, forKey: "pendingGraceDecision")
UserDefaults.standard.set(0, forKey: "pendingFailDate")
```

---

### Custom Font Registration

**Source:** Download Playfair Display from [Google Fonts](https://fonts.google.com/specimen/Playfair+Display). Required files: `PlayfairDisplay-Bold.ttf`, `PlayfairDisplay-BoldItalic.ttf`, `PlayfairDisplay-Regular.ttf`, `PlayfairDisplay-Italic.ttf`.

**Bundle registration** — add to the generated `Info.plist` via build settings. In the main app target's build settings, under `Info.plist Values`, add:

```
UIAppFonts = (
    PlayfairDisplay-Bold.ttf,
    PlayfairDisplay-BoldItalic.ttf,
    PlayfairDisplay-Regular.ttf,
    PlayfairDisplay-Italic.ttf
)
```

Or in a manual `Info.plist` file:
```xml
<key>UIAppFonts</key>
<array>
    <string>PlayfairDisplay-Bold.ttf</string>
    <string>PlayfairDisplay-BoldItalic.ttf</string>
    <string>PlayfairDisplay-Regular.ttf</string>
    <string>PlayfairDisplay-Italic.ttf</string>
</array>
```

Font name strings for `UIFont` / SwiftUI `Font.custom(_, size:)`:
- `"PlayfairDisplay-Bold"`
- `"PlayfairDisplay-BoldItalic"`
- `"PlayfairDisplay-Regular"`
- `"PlayfairDisplay-Italic"`

**Verify** registration is working by running `UIFont.familyNames` in a debug print — `"Playfair Display"` must appear in the list.

---

### Background Task Registration

The `BGTaskSchedulerPermittedIdentifiers` key must be present in the generated `Info.plist` or the OS will never permit the background task to run (it silently fails with no error).

Add to build settings `Info.plist Values`:
```
BGTaskSchedulerPermittedIdentifiers = (
    sam.GlowProtocol.midnight-check
)
```

In `BackgroundTaskService.swift`, register using this exact identifier:
```swift
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "sam.GlowProtocol.midnight-check",
    using: nil
) { task in
    self.handleMidnightCheck(task: task as! BGAppRefreshTask)
}
```

Schedule the next task after each evaluation:
```swift
func scheduleMidnightCheck() {
    let request = BGAppRefreshTaskRequest(identifier: "sam.GlowProtocol.midnight-check")
    // Target 23:59:50 tonight
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: Date.now)
    components.hour = 23; components.minute = 59; components.second = 50
    request.earliestBeginDate = calendar.date(from: components)
    try? BGTaskScheduler.shared.submit(request)
}
```

---

### `HabitSummary` — Widget Type

Used in `GlowWidgetProvider`'s `TimelineEntry`. Must be defined in a file shared between the main app target and the widget extension target (add to both targets in Xcode's target membership).

```swift
// Shared/Models/HabitSummary.swift  (member of BOTH GlowProtocol + GlowProtocolWidgets targets)
struct HabitSummary: Codable, Identifiable {
    let id: String          // HabitID raw value
    let label: String       // Display name, e.g. "Workout 1"
    let isComplete: Bool
    let pastelColorHex: String  // The habit's assigned pastel, e.g. "#D4E8C2"
}
```

`GlowWidgetProvider` builds up to 3 `HabitSummary` items by fetching today's `DayLog` from the shared SwiftData store and picking the first 3 incomplete habits (or all complete habits if the day is done).

---

### Container Setup in `GlowProtocolApp.swift`

**Default appearance on first launch:** Light mode. The app sets `UIWindow.appearance().overrideUserInterfaceStyle = .light` on first launch, then respects the user's preference from Settings thereafter. The preference is stored in `@AppStorage("appearancePreference")` as a `String` (`"light"`, `"dark"`, `"system"`).

```swift
// In GlowProtocolApp.swift
@AppStorage("appearancePreference") var appearancePreference: String = "light"

var body: some Scene {
    WindowGroup {
        RootView()
            .preferredColorScheme(colorScheme(for: appearancePreference))
    }
    .modelContainer(sharedModelContainer)
}

func colorScheme(for preference: String) -> ColorScheme? {
    switch preference {
    case "light": return .light
    case "dark":  return .dark
    default:      return nil   // nil = follow system
    }
}
```

**Onboarding gating in `RootView`:**

```swift
// RootView.swift
@AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
@AppStorage("pendingGraceDecision") var pendingGraceDecision: Bool = false

var body: some View {
    Group {
        if !hasCompletedOnboarding {
            OnboardingView()   // fullScreenCover equivalent — takes over the whole screen
        } else {
            MainTabView()
        }
    }
    .fullScreenCover(isPresented: $pendingGraceDecision) {
        FailStateView()
    }
}
```

`hasCompletedOnboarding` is set to `true` at the end of `GraceDayPickerView` when the user taps "Start Day 1." After that, onboarding is never shown again — reconfiguration happens entirely through Settings. When the user taps "Reset protocol" in Settings, only `ProtocolConfig` and `DayLog` data are reset; `hasCompletedOnboarding` stays `true`.

```swift
@main
struct GlowProtocolApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// Shared container for both main app and widget extension:
var sharedModelContainer: ModelContainer = {
    let storeURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.sam.GlowProtocol")!
        .appendingPathComponent("GlowProtocol.store")
    let config = ModelConfiguration(url: storeURL)
    return try! ModelContainer(
        for: ProtocolConfig.self, DayLog.self, HabitEntry.self, ScrapbookPhoto.self,
        configurations: config
    )
}()
```

---

## 5. Screen Inventory & Navigation Map

### Navigation Architecture

The app uses a `TabView` with a custom tab bar (hidden system bar, custom overlay). Three primary tabs; no deeply nested navigation stacks except Onboarding which is a full-screen `.sheet` / `.fullScreenCover` shown on first launch.

```
RootView
├── Onboarding (fullScreenCover, first launch only)
│   ├── WelcomeSlideView          — hero animation + "Start Your Protocol"
│   ├── DifficultyPickerView      — Hard / Medium / Soft cards
│   ├── HabitCustomizerView       — toggle list + custom habit inputs
│   └── GraceDayPickerView        — stepper, explanation copy
│
├── Tab 1 — Daily Glow (house icon)
│   ├── DailyGlowView             — THE main checklist screen
│   │   ├── WorkoutTimerView      — sheet: 45-min countdown
│   │   ├── WaterTrackerView      — sheet: tap-to-fill fluid animation
│   │   └── PhotoCaptureView      — sheet: in-app camera
│   └── FailStateView             — fullScreenCover: triggered at midnight
│       └── GraceDayConfirmView   — sheet within FailState if grace available
│
├── Tab 2 — Scrapbook (grid icon)
│   ├── ScrapbookView             — calendar grid of daily photos
│   └── BeforeAfterSliderView     — sheet: day picker + drag-to-compare + export
│
└── Tab 3 — Progress (chart icon)
    ├── ProgressView              — streak stats, habit completion rates
    └── SettingsView              — sheet: edit protocol, notifications, appearance
```

---

### Screen-by-Screen Specs

| Screen | Key UI Elements | Primary Action |
|---|---|---|
| `WelcomeSlideView` | Full-bleed serif headline, paged scroll with 3 value props | "Begin Protocol" → DifficultyPicker |
| `DifficultyPickerView` | 3 large cards (Hard/Medium/Soft), icon, subtitle copy | Select card → HabitCustomizer |
| `HabitCustomizerView` | Toggle list with icons + 3 text fields for custom habits | "Confirm Habits" → GraceDayPicker |
| `GraceDayPickerView` | Stepper (0–5), descriptive text, contextual hint | "Start Day 1" → save config, dismiss |
| `DailyGlowView` | Day badge, master progress ring, scrollable habit list | Check habits, tap special validators |
| `WorkoutTimerView` | Full-screen countdown, pause/resume, session number indicator | Timer completes → auto-check habit |
| `WaterTrackerView` | Animated fill bottle graphic, tap regions | Fill completes → auto-check habit |
| `PhotoCaptureView` | Camera viewfinder, capture button, retake option | Photo captured → saved, auto-check |
| `FailStateView` | Full-screen dramatic animation, day counter resets to 1 | "Accept Reset" or "Use Grace Day" |
| `GraceDayConfirmView` | Grace days remaining count, confirmation copy | Confirm → streak preserved |
| `ScrapbookView` | Calendar grid, month navigation, empty-state prompt | Tap cell → fullscreen photo view |
| `BeforeAfterSliderView` | Split-view drag slider, day selectors, watermark preview | "Share" → `UIActivityViewController` |
| `ProgressView` | Streak length, total % complete, per-habit completion bars | Tap stat → detail sheet |
| `SettingsView` | Appearance toggle, notification times, protocol reset | Edits saved immediately |

---

## 6. Phase 1 Feature Specs

### 6.1 Difficulty Presets & Habit Customizer

**Preset defaults:**

| Preset | Habits | Grace Days/Month | Target Days |
|---|---|---|---|
| Hard | All 8 defaults ON, 2 workouts/day | 0 | 75 |
| Medium | All 8 defaults ON, 1 workout/day | 2 | 75 |
| Soft | User selects; minimum 4 habits | 3 | 75 |

**Habit Customizer UX:**
- Each default habit is a toggle row with a subtle icon and label.
- Disabling a habit on Hard preset shows a confirmation bottom sheet ("This makes your protocol easier — are you sure?").
- Three optional custom habit input fields appear below the defaults. Each is a `TextField` with a 40-character limit. Empty fields are ignored when seeding `HabitEntry` records.
- Real-time validation: at least 4 habits must remain active before "Confirm" is enabled.

---

### 6.2 Daily Glow Checklist

**Layout:** Vertical `ScrollView` with a sticky header (`DayBadge` + master `ProgressRing`) and a `LazyVStack` of `HabitRow` items.

**`HabitRow` interaction:**
1. User taps a row.
2. For standard habits (diet, reading, no-alcohol, custom): triggers inline validator (see below). On pass, `isComplete = true`, `completedAt = now`.
3. `CheckmarkView` plays a spring scale animation (0.6 → 1.2 → 1.0 over 0.35s).
4. `HapticService.play(.habitComplete)` fires — a short crisp tap pattern.
5. Master `ProgressRing` animates its fill percentage via `.animation(.spring(response: 0.4))`.
6. When all habits complete, a full-bleed "All Done" banner fades in for 2s with a celebratory multi-tap haptic pattern.

---

### 6.3 Habit Validators

#### Water (1 Gallon)
- Sheet: A tall cylinder graphic. Divided into 8 equal "tap zones."
- Each tap animates a fluid fill rising in the cylinder (using `Shape` with animated `trim`).
- Completing all 8 zones = habit complete.
- State persisted in `validationMetadata` as `{"tapsCompleted": 8}`.

#### Workout (45-Minute Timer)
- Sheet: Full-screen `WorkoutTimerView`.
- Displays MM:SS countdown from 45:00.
- A `ProgressRing` behind the timer fills over the session.
- Pause/resume with a haptic on each state change.
- Background audio session (`AVAudioSession.Category.playback`) keeps timer running when phone locks.
- `BGAppRefreshTask` registered to validate timer continuation.
- On completion: sheet dismisses, haptic burst fires, habit auto-checks.
- If Hard preset (2 workouts/day): `workout1` and `workout2` are separate `HabitEntry` records. First completion marks `workout1`, second marks `workout2`.
- Timer abort (dismiss before completion) does not mark complete and shows a "Don't quit — come back!" toast.

#### Progress Photo
- Sheet: `PhotoCaptureView` uses `UIImagePickerController` in camera mode (`.camera` source type).
- On capture: image is compressed to JPEG (quality 0.82), written to `Documents/Scrapbook/<ISO-date>.jpg`.
- A low-res thumbnail (≤ 20 KB) is generated and stored as `ScrapbookPhoto.thumbnailData`.
- `ScrapbookPhoto` record created; `DayLog.photoFileURL` updated.
- Habit auto-checked after successful write. Cannot be marked complete any other way.

#### Steps (10,000)
- No pedometer integration in Phase 1 (avoids HealthKit entitlement complexity for initial submission).
- Manual honor-system toggle with a confirmation bottom sheet: "Did you hit 10,000 steps today?"
- Phase 2 roadmap: add `CoreMotion.CMPedometer` and HealthKit read permission.

#### Reading (10 Pages)
- Manual toggle. On tap: a small numeric stepper appears inline in the row to log actual pages read (optional, stored in `validationMetadata`).
- Complete at any value ≥ `ProtocolConfig.readingPages`.

#### Diet, No Alcohol, Custom Habits
- Simple tap-to-complete toggle. No validator required.
- Tapping a completed item shows an "Undo?" sheet — prevents accidental checks.

---

### 6.4 Midnight Fail-State & Streak Logic

**Evaluation trigger:** `NotificationService` schedules a silent local notification for 23:59:50 each night. On receipt (foreground or `BGAppRefreshTask` background), `StreakService.evaluateDay()` runs.

**`StreakService.evaluateDay()` logic:**

```
1. Fetch today's DayLog (where isCurrentRun == true, date == startOfDay(today)).
2. If allRequiredComplete == true:
     → dayLog.streakHeld = true
     → Schedule tomorrow's DayLog seeding via scheduleMidnightCheck()
     → Return (no action needed)
3. If allRequiredComplete == false:
     a. Check ProtocolConfig.graceUsedThisMonth < graceDaysPerMonth
        → If grace available:
             UserDefaults.standard.set(true, forKey: "pendingGraceDecision")
             UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: "pendingFailDate")
             Post local notification "You have a grace day available — open Glow Protocol"
             → On next app foreground, RootView detects pendingGraceDecision = true → presents FailStateView with grace option
        → If no grace: trigger archive + reset (step 4)
4. Archive + reset:
     → Fetch all DayLog where isCurrentRun == true
     → Set each isCurrentRun = false (archived — preserved for "Past Runs" in Progress screen)
     → Create new DayLog for today, runID = UUID(), isCurrentRun = true
     → Update ProtocolConfig.startDate = startOfDay(today)
     → UserDefaults.standard.set(true, forKey: "pendingGraceDecision") with graceAvailable = false
        (FailStateView reads UserDefaults to determine whether to show the grace button)
     → On next app foreground, RootView presents FailStateView (no grace option)
```

**Grace Day expiry:** `graceUsedThisMonth` resets to 0 when `Date.now > graceResetDate.addingTimeInterval(30 days)`. `graceResetDate` advances by one month.

**Habit checklist ordering:** Habits are displayed with **incomplete habits at the top, completed habits at the bottom**. Within each group, the original fixed order is preserved (Workout → Water → Diet → Reading → Steps → No Alcohol → Photo → Custom). When a habit is checked, it animates downward into the completed section with a spring move transition (`.move(edge: .bottom)` combined with `.opacity`). This ordering is computed in `DailyGlowViewModel` — the view always renders a sorted array, never reorders in-place.

---

### 6.5 Fail-State Animation (`FailStateView`)

- `fullScreenCover` with a black background.
- Phase 1: Large serif text "Day 1" slides in from below with a spring animation.
- Background: a slow particle effect using `Canvas` — 40 white dots drifting upward and fading (symbolizes resetting, not punishment).
- If grace days remain: a secondary button "Use Grace Day →" appears after a 1.5s delay.
- Hard reset path: after 3s, a single "Accept & Restart" button fades in. Tapping triggers `StreakService.hardReset()`, dismisses the cover, and the tab bar is back with Day 1 showing.
- Haptic: `UINotificationFeedbackGenerator.notificationOccurred(.warning)` on presentation.

---

### 6.6 Scrapbook Grid & Before/After Slider

#### Scrapbook Grid (`ScrapbookView`)
- `LazyVGrid` with 3 columns, adaptive cells.
- Each cell shows `ScrapbookPhoto.thumbnailData` if a photo exists, or a subtle placeholder (camera icon with day number) if not.
- Cells are grouped by month; a month header uses `displaySmall` typography.
- Tapping a filled cell: full-screen photo zoom using `.matchedGeometryEffect` for a fluid expand transition.

#### Before/After Slider (`BeforeAfterSliderView`)
- Two `DayPicker` controls at the top: "Before" (defaults to Day 1) and "After" (defaults to most recent).
- Images loaded from disk via `PhotoService.loadImage(for:)`.
- A `DragGesture` moves a vertical divider across the overlaid images — the left side reveals "Before," the right side reveals "After."
- A "Glow Protocol" wordmark + day range label is composited as an overlay using `ImageRenderer` at export time.
- "Share" button: `ImageRenderer` renders the current slider state (at the drag position) to a `UIImage`, then presents `UIActivityViewController`.

---

## 7. Widget Specs

### Widget Extension Target: `GlowProtocolWidgets`

A separate Xcode target added to the main project. Shares SwiftData read access via an **App Group** (`group.sam.GlowProtocol`). The widget reads data but never writes.

---

### 7.1 Medium Home Screen Widget

**Family:** `.systemMedium`

**Layout (horizontal split):**

```
┌─────────────────────────────────────────┐
│  ProgressRing (48pt)  │  Day 47          │
│       76%             │  ██████░░░ 76%   │
│                       │  ○ Workout 1     │
│   Glow Protocol       │  ● Water         │
│                       │  ○ Reading       │
└─────────────────────────────────────────┘
```

- Left: `ProgressRing` with master completion percentage; "Glow Protocol" label below.
- Right: Day number in `displaySmall`, progress bar, and the top 3 incomplete (or most-recently-completed) habits with completion dot indicators.
- Background: `Color.background` (adaptive), rounded rect at system widget radius.
- Deep link: tapping anywhere opens the app directly to `DailyGlowView`.

**`GlowWidgetProvider`:**
- `TimelineEntry` includes: `dayNumber`, `completionPct`, `topHabits: [HabitSummary]`, `date`.
- `HabitSummary` is defined in `Shared/Models/HabitSummary.swift` and added to both the main app target and the widget extension target (see Section 4 container setup for the full definition).
- Timeline refreshes every 30 minutes and on every habit completion via `WidgetCenter.shared.reloadAllTimelines()` called from `DailyGlowViewModel`.
- Widget fetches data by reading the shared SwiftData store at the App Group URL and filtering `DayLog` records where `isCurrentRun == true` and `date == startOfDay(today)`.

---

### 7.2 Lock Screen Accessory Widget

**Family:** `.accessoryCircular`

**Layout:**
- A single `ProgressRing` (fills the circle) with the day number in `mono` font at center.
- Uses `.widgetAccentable()` modifier so the system tints it with the user's lock screen accent color.
- Tapping opens the app.

---

### 7.3 Widget App Group Setup

1. In Xcode, add the App Groups capability to both the main app target and the widget extension target.
2. Group identifier: `group.sam.GlowProtocol`.
3. Create a shared `ModelContainer` pointing to the App Group container URL:

```swift
let storeURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: "group.sam.GlowProtocol")!
    .appendingPathComponent("GlowProtocol.store")

let config = ModelConfiguration(url: storeURL)
let container = try ModelContainer(
    for: ProtocolConfig.self, DayLog.self, HabitEntry.self, ScrapbookPhoto.self,
    configurations: config
)
```

This same `storeURL` is used in both the main app and the widget extension.

---

## 8. Phase 2 Social Feature Specs

Phase 2 begins after the App Store listing is live and initial organic/marketing downloads generate an install base. All social features require a backend.

### 8.1 Backend: Supabase

| Table | Key columns | Notes |
|---|---|---|
| `users` | `id`, `username`, `display_name`, `avatar_url`, `created_at` | Auth via Supabase Auth (email + Apple Sign In) |
| `friendships` | `requester_id`, `addressee_id`, `status` | `status`: pending / accepted / blocked |
| `day_summaries` | `user_id`, `date`, `day_number`, `completion_pct`, `habit_flags` (jsonb) | Written by app on day completion; no raw photos |
| `nudges` | `sender_id`, `recipient_id`, `sent_at`, `message_key` | Rate-limited: 3 nudges per user per day |
| `verification_photos` | `user_id`, `date`, `storage_path`, `is_public` | Optional; stored in Supabase Storage |

### 8.2 Glow Circle (Friends Tab)

- New **Tab 4** added post-Phase 1: friends icon.
- **Add Friend:** Search by exact username → send friend request.
- **Friend List:** Cards showing avatar, username, current day number, and today's completion ring.
- Friend data is fetched from `day_summaries` via Supabase Realtime subscription — updates live without pull-to-refresh.

### 8.3 Passive Social Feed

Inspired directly by the reference UI (image_0.png):

- Vertical scrollable feed, one card per friend per day.
- Each card shows: circular avatar, name, "Day X" badge, and a horizontal list of habit rows with completion checkmarks and timestamps.
- Only shows habits the friend has opted to share (privacy toggle in their settings).
- No comments, no likes — read-only feed. Intentionally minimal to keep focus on personal discipline.

### 8.4 Nudge Notification

- Each friend card has a subtle "nudge" icon button (a small lightning bolt).
- Tapping: calls `NudgeService.send(to: friendID)`.
- Backend inserts a row into `nudges` table, which triggers a Supabase Edge Function.
- Edge Function calls APNs (via Firebase Cloud Messaging or direct APNs HTTP/2) to deliver a high-priority push notification to the recipient:

  > **"[SenderName] nudged you — time to glow! 💪"**

- Rate limit: 3 nudges sent per user per day (enforced in Edge Function).
- Recipient can disable nudges per-friend in settings.

### 8.5 Verification Photo Feed (Advanced)

- Opt-in per day: after taking a progress photo, a toggle appears — "Share to Glow Circle?"
- Shared photos upload to Supabase Storage (`verification_photos` bucket, path: `<user_id>/<date>.jpg`).
- Visible to accepted friends only in the feed card for that day.
- No global public feed — privacy first.

---

## 9. Xcode Capability Checklist

Each capability below must be manually enabled in Xcode → Target → Signing & Capabilities before the associated feature will work. Several also require `Info.plist` usage description strings.

| # | Capability | Feature requires it | Entitlement key | Info.plist key |
|---|---|---|---|---|
| 1 | **App Groups** | Widgets (shared SwiftData store) | `com.apple.security.application-groups` | — |
| 2 | **Push Notifications** | Phase 2 Nudges | `aps-environment` (development / production) | — |
| 3 | **Background Modes → Background fetch** | Midnight streak evaluation | `UIBackgroundModes: fetch` | — |
| 4 | **Background Modes → Audio** | Workout timer continues when screen locks | `UIBackgroundModes: audio` | — |
| 5 | **Camera** | Progress photo capture | — | `NSCameraUsageDescription` |
| 6 | **Photo Library (add only)** | Optional: save to Camera Roll from scrapbook | — | `NSPhotoLibraryAddUsageDescription` |
| 7 | **Sign in with Apple** | Phase 2 Supabase Auth | `com.apple.developer.applesignin` | — |
| 8 | **HealthKit (read)** | Phase 2 step count automation | `com.apple.developer.healthkit` | `NSHealthShareUsageDescription` |

### `GlowProtocol.entitlements` (Phase 1 minimum)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ...>
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.sam.GlowProtocol</string>
    </array>
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>audio</string>
    </array>
</dict>
</plist>
```

### `Info.plist` additions (generated via build settings)

Add these `INFOPLIST_KEY_*` entries in the target's build settings or a manual `Info.plist`:

```
NSCameraUsageDescription = "Glow Protocol uses your camera to capture your daily progress photo."
NSPhotoLibraryAddUsageDescription = "Allow Glow Protocol to save your before/after comparison to your photo library."
```

---

## 10. May 25–31 Development Schedule

### Overview

```
Mon 25  →  Tue 26  →  Wed 27  →  Thu 28  →  Fri 29  →  Sat 30  →  Sun 31
Design      Models     Camera     Timer      SwiftUI    Marketing  Submit
System     + Streak   + Scrap-   + Widgets  Layout     Assets     + Review
Setup        Logic     book                 Polish
```

---

### Day-by-Day Breakdown

---

#### Monday, May 25 — Foundation & Design System
**Session (Evening, 2–3 hrs)**

Goal: Bootstrap the project with the full folder structure and design system so every subsequent session has zero setup friction.

**Files to create/edit:**

| File | Work |
|---|---|
| `GlowProtocolApp.swift` | Add `ModelContainer` with all 4 model types; inject into environment |
| `DesignSystem/Colors.swift` | All color tokens (light + dark), `Color` extension |
| `DesignSystem/Typography.swift` | All font styles, `Font` extension, `ViewModifier` for `.glowStyle(.headline)` |
| `DesignSystem/Spacing.swift` | All `CGFloat` spacing constants |
| `DesignSystem/Animations.swift` | Shared `Animation` and `Transition` values |
| `Resources/Fonts/` | Add Playfair Display TTF files to the bundle; register in build settings |
| `Assets.xcassets/AccentColor` | Set accent color to `#C8A882` |
| `GlowProtocol.entitlements` | Create with App Groups + Background Modes |
| `Xcode capabilities` | Enable App Groups (group.sam.GlowProtocol), Background Modes (fetch + audio) |

**Deliverable:** App launches with correct fonts and color scheme. `ContentView` replaced with a placeholder showing design tokens working in both light and dark mode.

---

#### Tuesday, May 26 — Data Models & Streak Engine
**Session (Morning, 8am–11am)**

Goal: Complete the entire persistence and business logic layer. This is the hardest day — get it right before building UI on top of it.

**Files to create/edit:**

| File | Work |
|---|---|
| `Models/ProtocolConfig.swift` | Full SwiftData model (see Section 4) |
| `Models/DayLog.swift` | Full SwiftData model |
| `Models/HabitEntry.swift` | Full SwiftData model + `HabitID` enum |
| `Models/ScrapbookPhoto.swift` | Full SwiftData model |
| `Services/StreakService.swift` | `evaluateDay()`, `hardReset()`, `seedNewDay()`, grace-day logic |
| `Services/NotificationService.swift` | Schedule 23:59:50 nightly evaluation notification; daily reminder notifications |
| `Services/BackgroundTaskService.swift` | Register + handle `BGAppRefreshTask` for midnight evaluation |
| `Shared/Extensions/Date+Glow.swift` | `startOfDay`, `daysSince`, `isSameDay` helpers |
| `GlowProtocolTests/StreakServiceTests.swift` | Unit tests: normal completion, miss, grace day, grace exhausted |

**Deliverable:** All SwiftData models compile. `StreakService` unit tests pass for all streak scenarios (complete day, missed day, grace used, grace exhausted, month rollover).

---

#### Wednesday, May 27 — Camera & Scrapbook
**Session (Morning, 8am–11am)**

Goal: Implement the photo pipeline end-to-end: capture → write → display in grid.

**Files to create/edit:**

| File | Work |
|---|---|
| `Services/PhotoService.swift` | `savePhoto(_:forDate:)`, `loadImage(for:)`, `loadThumbnail(for:)`, App Group–aware `Documents/Scrapbook/` path |
| `Features/DailyGlow/PhotoCaptureView.swift` | `UIImagePickerController` wrapper as `UIViewControllerRepresentable`, capture flow |
| `Features/Scrapbook/ScrapbookViewModel.swift` | Fetch `ScrapbookPhoto` records, group by month |
| `Features/Scrapbook/ScrapbookView.swift` | `LazyVGrid` 3-col layout, `ScrapbookCell`, month headers, placeholder cells |
| `DesignSystem/Components/ScrapbookCell.swift` | Thumbnail display + empty state |
| `Features/Scrapbook/BeforeAfterSliderView.swift` | Day picker, drag-gesture divider, `ImageRenderer` watermark export |
| `Shared/Utilities/ImageRenderer+Watermark.swift` | Compositing helper |
| `Info.plist` keys | `NSCameraUsageDescription`, `NSPhotoLibraryAddUsageDescription` |

**Deliverable:** Can take a photo in-app, see it in the scrapbook grid, and export a watermarked before/after comparison image to the share sheet.

---

#### Thursday, May 28 — Timer, Widgets & Notifications
**Session (Morning, 8am–11am)**

Goal: Build the workout timer (with background audio), both widget layouts, and wire up all local notifications.

**Files to create/edit:**

| File | Work |
|---|---|
| `Features/DailyGlow/WorkoutTimerView.swift` | `Timer.publish` countdown, pause/resume, `AVAudioSession` keepalive, background task registration |
| `Services/HapticService.swift` | `CHHapticEngine` setup, named patterns: `.habitComplete`, `.timerFinish`, `.failState`, `.graceDayPulse` |
| `GlowProtocolWidgets/GlowProtocolWidgets.swift` | Widget bundle `@main` |
| `GlowProtocolWidgets/GlowWidgetProvider.swift` | `TimelineProvider` reading shared SwiftData store |
| `GlowProtocolWidgets/HomeScreenWidgetView.swift` | Medium widget UI |
| `GlowProtocolWidgets/LockScreenWidgetView.swift` | `.accessoryCircular` widget UI |
| Xcode project | Add `GlowProtocolWidgets` extension target; add to App Groups |
| `DesignSystem/Components/ProgressRing.swift` | Shared ring component (used in main app + widgets) |

**Deliverable:** Widgets appear in the widget gallery showing real data. Workout timer runs correctly when the screen is locked. All notification types are scheduled and fire correctly on the simulator.

---

#### Friday, May 29 — Full SwiftUI Layout & Polish
**Session (Morning, 8am–11am)**

Goal: Build all remaining screens, wire navigation, and implement the fail-state animation. This is the biggest UI day.

**Files to create/edit:**

| File | Work |
|---|---|
| `Features/Onboarding/` | All 4 onboarding screens, `OnboardingViewModel`, guard for `ProtocolConfig` existence |
| `Features/DailyGlow/DailyGlowView.swift` | Full checklist layout: sticky header, `LazyVStack`, "All Done" banner |
| `Features/DailyGlow/DailyGlowViewModel.swift` | Wire `StreakService`, `HapticService`; handle `WidgetCenter.reloadAllTimelines()` on every completion |
| `Features/DailyGlow/WaterTrackerView.swift` | Fluid fill animation with `Shape` + `trim` |
| `Features/FailState/FailStateView.swift` | Full-screen reset animation, particle `Canvas`, grace day button |
| `Features/FailState/GraceDayConfirmView.swift` | Confirmation bottom sheet |
| `Features/Progress/ProgressView.swift` | Streak stats, per-habit completion bar chart |
| `Features/Settings/SettingsView.swift` | Appearance, notification times, protocol reset |
| `DesignSystem/Components/HabitRow.swift` | Full interaction: tap validators, undo sheet, spring + haptic |
| `DesignSystem/Components/CheckmarkView.swift` | Spring scale animation |
| `DesignSystem/Components/GlowButton.swift` | Primary, secondary, ghost variants |
| `DesignSystem/Components/DayBadge.swift` | "Day 47" pill |
| `RootView.swift` | `TabView` with custom tab bar overlay |

**Deliverable:** Full app flow navigable end-to-end. Onboarding → Daily Glow → Scrapbook → Progress. Fail-state animation plays. All three habit validators work. Dark/light mode looks correct on all screens.

---

#### Saturday, May 30 — App Store Assets & Final Integration
**Session (All day, non-code)**

Goal: Complete all App Store submission requirements and create marketing assets.

**Tasks:**

- [ ] Write App Store listing: name, subtitle (30 chars), description (4000 chars), keywords (100 chars)
- [ ] Generate 6.7" iPhone screenshots (1290×2796): Daily Glow, Scrapbook, Progress, Widget preview
- [ ] Generate 5.5" iPhone screenshots: same 4 screens
- [ ] App preview video (optional, 15–30s): screen recording of checking off habits with haptics visible
- [ ] App icon: 1024×1024 export; dark and tinted variants for iOS 18 adaptive icons
- [ ] Privacy Policy URL: a simple HTML page hosted on GitHub Pages or similar
- [ ] Age rating questionnaire: Healthcare & Fitness, no user-generated content (Phase 1)
- [ ] Create 15 marketing assets (Pinterest/Instagram format) using the aesthetic from reference images
- [ ] Final code review pass: remove all `print()` statements, TODO comments, unused code

---

#### Sunday, May 31 — Validation & Submission
**Session (All day)**

Goal: Ship it.

**Checklist:**

- [ ] Run on physical iPhone (iOS 18+): test all habit flows, camera, timer lock-screen behavior
- [ ] Run on iPad: verify layout scales acceptably (app supports iPhone + iPad per build settings)
- [ ] Test midnight fail-state: set device clock to 23:59, confirm notification fires and `StreakService.evaluateDay()` runs
- [ ] Test widget: add both widget types to home screen, confirm data displays, confirm deep link opens app
- [ ] Test cold launch after streak reset: confirm Day 1 shows correctly
- [ ] Archive build (Product → Archive) with Release configuration
- [ ] Upload to App Store Connect via Xcode Organizer
- [ ] Complete App Store Connect metadata: version, what's new, screenshots, preview
- [ ] Submit for Review

**Expected review timeline:** 24–48 hours for first submission in Healthcare & Fitness category.

---

## Appendix: File Creation Order (Critical Path)

```
Day 1 (Mon)  GlowProtocolApp.swift → DesignSystem/* → entitlements
Day 2 (Tue)  Models/* → Services/StreakService → Services/NotificationService → Tests
Day 3 (Wed)  Services/PhotoService → Features/DailyGlow/PhotoCaptureView → Features/Scrapbook/*
Day 4 (Thu)  Features/DailyGlow/WorkoutTimerView → Services/HapticService → GlowProtocolWidgets/*
Day 5 (Fri)  Features/Onboarding/* → Features/DailyGlow/* → Features/FailState/* → RootView
Day 6 (Sat)  Zero code — App Store assets
Day 7 (Sun)  QA → Archive → Submit
```

Each day's files depend on the previous day's output. Do not skip days.

---

---

## 11. Screen-by-Screen UI Design Specification

> **Font shorthand used throughout this section:**
> - **Serif** = Playfair Display (the high-contrast editorial font from the reference image — used for any moment that needs to feel elevated, aspirational, or emotional)
> - **Sans** = SF Pro Text / SF Pro Display (clean, system-native — used for all functional UI: habit names, timestamps, captions, buttons, labels)
>
> The split is always the same: serif for *feeling*, sans for *function*. Never both on the same element.

---

### 11.1 Launch Screen

**Purpose:** The first impression. Should feel like opening a luxury editorial app, not a fitness tracker.

**Layout:**
- Full-bleed `background` color (`#F7F5F2` light / `#0C0C0C` dark).
- Centered vertically and horizontally: a single logotype treatment.
  - Line 1: `GLOW` — Serif Bold, 52pt, tracked out `+8pt` letter-spacing, `textPrimary` color.
  - Line 2: `PROTOCOL` — Sans Medium, 13pt, `+6pt` letter-spacing, `textSecondary` color.
  - A 1pt horizontal rule, 48pt wide, `divider` color, sits between the two lines.
- No icon. No logo mark. The name is the brand.

**Animation:**
- On app ready: `GLOW` fades in over 0.6s, then `PROTOCOL` fades in over 0.4s with a 0.15s delay, then the rule draws in left-to-right over 0.3s.
- Total: under 1.2s. Never slow down the user unnecessarily.

**Transition out:** The entire logotype scales up very slightly (to 1.04×) and fades out simultaneously as the first real screen fades in underneath. Feels like the brand receding to let the app breathe.

---

### 11.2 Onboarding — Welcome Hero (`WelcomeSlideView`)

**Purpose:** Sell the lifestyle, not the app. The user should feel something before they ever tap a button.

**Layout (3 paged slides, horizontal swipe):**

**Slide 1 — The Statement**
- Top 60% of screen: full-bleed background `#F7F5F2`. No image.
- Hero text block, left-aligned, 24pt left margin:
  - Line 1: `Do it` — Serif Bold, 48pt, `textPrimary`.
  - Line 2: `with` — Serif Regular, 48pt, `textPrimary`.
  - Line 3: `discipline.` — Serif Bold Italic, 48pt, `textPrimary`. Italic on the last word is intentional — it mirrors the reference image's treatment of *friends* in italic.
- Below the hero text, 32pt gap:
  - 1–2 lines of body copy in Sans Regular 15pt, `textSecondary`: `"75 days. Your rules. Your transformation."`
- Bottom 40% of screen: a subtle decorative element — a single thin horizontal rule 120pt wide, left-aligned, `divider` color, at the text baseline.
- No illustration. No photography. The typography is the hero.

**Slide 2 — The Proof**
- Same layout shell.
- Hero text: `Your protocol.` in Serif Bold Italic 44pt.
- Below: three horizontal fact rows, each with a small circular dot (8pt, `textSecondary`) as bullet:
  - `Customizable difficulty` — Sans Semibold 15pt, `textPrimary`.
  - `Grace days built in` — same.
  - `Private photo scrapbook` — same.
- Each row fades in sequentially with a 0.12s stagger as the slide appears.

**Slide 3 — The Invitation**
- Hero text: `Ready to glow?` — Serif Bold Italic 44pt.
- Body: `"Your 75 days start the moment you say so."` — Sans Regular 15pt, `textSecondary`.
- A large primary button at the bottom: `Begin Protocol` — Sans Semibold 17pt, `surface` color text on `textPrimary` background. Full-width minus 32pt margins. 54pt height. `radiusSmall` (8pt) corners.

**Pagination indicator:** Three 4pt dots, horizontally centered, 32pt from bottom safe area. Active dot is 20pt wide (pill shape), `textPrimary`. Inactive dots are 4pt circles, `divider` color. Smooth width animation between states.

**Skip button:** Top-right, Sans Regular 14pt, `textSecondary` color. "Skip" — only visible on slides 1 and 2.

---

### 11.3 Onboarding — Difficulty Picker (`DifficultyPickerView`)

**Purpose:** The user's first real commitment. Make the choices feel weighty and considered.

**Layout:**
- Navigation header: Back chevron (left), `Choose your protocol` in Sans Semibold 17pt centered, no right item.
- Below header, 24pt padding: Serif Bold Italic 32pt headline — `How hard are you going?`
- Body copy below, 8pt gap: Sans Regular 14pt, `textSecondary` — `"Pick the version that matches where you are right now. You can adjust later."`
- 32pt gap, then three stacked cards. Each card is `surface` background, `radiusLarge` corners, shadow (`y:2, blur:12, opacity:6%`), full-width minus 32pt margins.

**Card anatomy (each 100pt tall):**
```
 ┌────────────────────────────────────────────────┐
 │  [Icon 32pt]   HARD                  [→ 20pt]  │
 │                No grace days · All habits       │
 └────────────────────────────────────────────────┘
```
- Icon: SF Symbol in a 44×44pt circle, `surfaceSecondary` fill, `textPrimary` symbol.
  - Hard: `flame.fill`
  - Medium: `bolt.fill`
  - Soft: `leaf.fill`
- Title: Sans Bold 17pt, `textPrimary`, left-aligned inside card.
- Subtitle: Sans Regular 13pt, `textSecondary`.
- Trailing chevron: `chevron.right` SF Symbol, 16pt, `textSecondary`.
- Card spacing: 12pt between cards.

**Selected state:** The selected card's left edge gets a 3pt vertical bar in `textPrimary` color (like a bookmark), and the entire card background shifts to `surfaceSecondary`. The chevron disappears. No animation overkill — a simple 0.2s ease.

**Bottom CTA:** `Continue` primary button, disabled until a card is selected. When disabled: `surfaceSecondary` background, `textDisabled` text. When enabled: `textPrimary` background, `surface` text — transition with 0.25s ease.

---

### 11.4 Onboarding — Habit Customizer (`HabitCustomizerView`)

**Purpose:** The moment the user makes it their own. Should feel editorial, not like a settings screen.

**Layout:**
- Header: `Your daily habits` — Serif Bold Italic 32pt, left-aligned, 24pt left margin, 24pt top margin below nav bar.
- Subhead below, 8pt gap: Sans Regular 14pt, `textSecondary` — `"These are your non-negotiables. Toggle off anything that doesn't fit your life right now."`
- 24pt gap, then a `List`-style scroll view (no table chrome — custom rows on `surface` cards).

**Habit toggle row anatomy (72pt tall):**
```
 [Pastel icon circle 36pt]  [Habit name 17pt Sans Semibold]    [Toggle]
                            [Detail — 13pt Sans, textSecondary]
```
- The toggle is a custom component: not `UISwitch`. Instead, it's a 48×28pt pill shape. Off state: `surfaceSecondary` fill, a 24pt white circle inside sitting left. On state: `textPrimary` fill, white circle sitting right. Transition: spring 0.3s.
- Rows are grouped in a rounded `surface` card with 14pt radius. Inset dividers between rows (not full-bleed — starts after the icon).

**Detail row variations:**
- Workout row has a secondary line: `"45 min · 2× daily"` — tappable. Opens a small inline stepper for minutes (30 / 45 / 60) and count (1× / 2×).
- Water row has: `"1 gallon / day"`.
- Reading row has: `"10 pages"` — tappable stepper (5 / 10 / 20 / 30).
- Steps row has: `"10,000 steps"`.

**Custom habits section** — appears below the default habits, separated by a 24pt gap and a section label `Add your own` in Sans Bold 13pt, `textSecondary`, all caps, `+1pt` tracking:
- Three input rows, each identical: 56pt tall, `surfaceSecondary` background, `radiusMedium` corners, `textPrimary` placeholder text `"Custom habit (optional)"` in Sans Regular 15pt, `textDisabled` color.
- A small SF Symbol `plus.circle.fill` in `textSecondary` color sits at the right end of each empty field. When focused: it becomes `xmark.circle.fill` in `textSecondary`.
- Character counter appears at right when typing: `"12 / 40"` in Sans Regular 11pt, `textSecondary`.

**Bottom:** `Confirm habits` primary button. Disabled until minimum 4 habits are active. A small helper text appears when fewer than 4 are active: `"Enable at least 4 habits to continue"` in Sans Regular 12pt, `destructive` color, fading in with 0.2s ease.

---

### 11.5 Onboarding — Grace Day Picker (`GraceDayPickerView`)

**Purpose:** Explain grace days before asking. Make the user feel smart for understanding the mechanic, not guilty for wanting flexibility.

**Layout:**
- Large serif headline: `Your grace days.` — Serif Bold Italic 36pt, left-aligned.
- 16pt gap: a longer editorial body paragraph in Sans Regular 15pt, `textSecondary`, line-height 1.5×:
  > `"Life happens. Grace days let you miss one habit without resetting your streak. Use them intentionally — they're not a habit. They're a lifeline."`
- 48pt gap: a large centered stepper control.

**Stepper control (custom — not system Stepper):**
```
         [ − ]   2   [ + ]
         grace days / month
```
- The number `2` is displayed in Serif Bold 64pt, `textPrimary`, centered.
- Below the number: `grace days / month` in Sans Regular 14pt, `textSecondary`.
- `−` and `+` are 44×44pt circular tap targets, `surfaceSecondary` fill, `textPrimary` SF Symbol `minus` and `plus`. At min (0) the `−` is `textDisabled`. At max (5) the `+` is `textDisabled`.
- Number changes with a cross-dissolve 0.2s when tapping.

**Below stepper, 32pt gap:** A contextual hint that changes based on the selected value:
- 0: `"Strict mode. No exceptions."` — Sans Regular 13pt, `textSecondary`.
- 1–2: `"A safety net for the unexpected."` — same.
- 3–5: `"Be honest with yourself."` — same.
- Hint text transitions with a cross-dissolve.

**Bottom:** `Start Day 1` — primary button. Always enabled once difficulty is set.

---

### 11.6 Root Navigation & Tab Bar

**Purpose:** The persistent chrome of the app. Must feel invisible when not needed and elegant when used.

**Tab bar design:**
- Not the system `UITabBar`. Fully custom SwiftUI overlay, floating above screen content.
- Sits 12pt above the home indicator, centered, with `radiusLarge` (22pt) corners.
- Width: screen width minus 48pt margins. Height: 64pt.
- Background: `surface` color, shadow `y:4, blur:20, opacity:10%`.
- Three tab items, evenly distributed:

| Tab | SF Symbol (unselected) | SF Symbol (selected) | Label |
|---|---|---|---|
| Daily Glow | `sun.min` | `sun.max.fill` | `Today` |
| Scrapbook | `square.grid.2x2` | `square.grid.2x2.fill` | `Scrapbook` |
| Progress | `chart.bar` | `chart.bar.fill` | `Progress` |

- Selected item: `textPrimary` color, label visible below icon in Sans Bold 10pt.
- Unselected: `textSecondary` color, label hidden (icon only). Label fades in on selection with 0.2s ease.
- Selection indicator: a 4pt wide, 4pt tall pill dot in `textPrimary` sits 6pt below the icon of the active tab. Animates horizontally between tabs with a spring.

**Navigation bar (per screen):**
- No system navigation bar chrome. All "nav bars" are custom SwiftUI views: `HStack` with back chevron, title, and optional trailing action. Background matches the screen's background color (no frosted glass).
- Title always uses Sans Semibold 17pt. Never serif in the nav bar.

---

### 11.7 Daily Glow — The Main Checklist (`DailyGlowView`)

**Purpose:** This screen is used every single day. It must be the most refined screen in the app. The user should feel a small dopamine hit on each check — this is the core retention mechanic.

**Overall layout:** A `ScrollView` with a sticky header.

---

**Sticky Header (always visible, 120pt tall):**

Left side:
- `Day 47` — Serif Bold Italic 38pt, `textPrimary`. This is the most prominent number on screen.
- Below: `of 75` — Sans Regular 14pt, `textSecondary`.

Right side:
- Master progress ring: 72×72pt. 8pt stroke width. Track: `surfaceSecondary`. Fill: `textPrimary`. Animated. Inside the ring, centered: completion percentage in Sans Bold 15pt, `textPrimary`.

Header background: `background` color, with a very subtle bottom gradient (8pt) fading to transparent, so content scrolls under it gracefully.

---

**Date strip** (just below header, scrolls with content):
- `Monday, May 25` — Sans Regular 13pt, `textSecondary`. Left-aligned.
- Right-aligned: a small `All done ✓` label that only appears when all habits are complete, fades in softly, Sans Medium 13pt, `textPrimary`.

---

**Habit rows** (the main content):

Grouped into a single `surface` card (white, `radiusLarge`, full-width minus 0pt — edge to edge with 0pt corner radius on the sides if it's full-bleed, OR 16pt margin with corner radius). Recommend full-bleed card with clipped bottom, feels more substantial.

Each row:

```
[Pastel icon 36pt]  [Habit name — Sans Semibold 17pt]              [Ring/Check 28pt]
                    [Status — Sans Regular 13pt, textSecondary]
```

Row height: 72pt. Internal padding: 16pt left, 16pt right.

**Status line variations:**
- Unchecked: `"Tap to complete"` — `textDisabled`.
- In-progress (workout timer running): `"Timer running — 32:14 remaining"` in `textSecondary` with a pulsing green dot (4pt, sage green) to the left.
- Complete: `"Done · 11:45am"` — `textSecondary`.

**The check indicator (right side, 28pt):**
- Unchecked: a 28pt circle, 2pt stroke, the habit's pastel color. Interior is transparent.
- Checked: the circle fills to solid `textPrimary` (near-black). A white SF Symbol `checkmark` (weight: bold, size: 13pt) appears inside with a spring scale animation (0.6→1.2→1.0). The pastel ring is gone — replaced entirely by the black filled circle.
- Transition takes 0.35s. Simultaneously: the habit name color shifts from `textPrimary` to `textSecondary`, and the status line updates.

**Inset dividers** between rows: 1pt, `divider` color, starting at x=68pt (after the icon circle).

---

**Special habit rows — visual variations:**

*Workout (requires timer):*
- Status shows `"Tap to start 45-min timer"` when unchecked.
- If Hard mode (2× workouts): two separate rows labeled `Workout 1` and `Workout 2`. After Workout 1 completes, a small `#2` badge appears on the second row in Sans Bold 11pt.
- Tapping opens `WorkoutTimerView` as a `.sheet`.

*Water (tap-to-fill):*
- Status shows `"0 / 8 glasses"` updating live.
- The check ring is replaced by a small segmented arc (8 equal segments in sky blue pastel, filling clockwise as glasses are logged).
- Tapping opens `WaterTrackerView` sheet.

*Progress Photo:*
- If today's photo exists: a 36×36pt circular thumbnail of the photo sits in place of the icon circle. Tapping opens the full photo.
- If not: camera icon in `surfaceSecondary` circle. Tapping opens `PhotoCaptureView`.

---

**All-done state:**
When the last habit is checked:
1. All rows momentarily do a staggered shimmer effect — each row's background flashes `surfaceSecondary` then returns to `surface`, staggered 0.06s per row.
2. A full-width banner slides up from below the last row:
   - Background: `textPrimary` color. Height 72pt. `radiusMedium` corners.
   - Text: `Protocol complete for today.` — Sans Semibold 17pt, `surface` color.
   - Below: `"Come back tomorrow · Day 48"` — Sans Regular 13pt, `surface` color at 60% opacity.
   - A subtle multi-tap haptic pattern fires (3 taps with increasing intensity).
3. Banner stays visible. It does not auto-dismiss.

---

### 11.8 Workout Timer (`WorkoutTimerView`)

**Purpose:** The user runs a 45-minute timer and the app must keep them in a focused, motivating headspace. No distractions.

**Presentation:** `.sheet` with a large detent (nearly full screen). Background: `background` color.

**Layout:**
- Top: a 4pt drag handle pill, `divider` color, centered.
- 24pt below: `Workout 1` in Sans Semibold 17pt, `textSecondary`, centered. (Or "Workout 2" for second session.)
- The ring: a large `ProgressRing`, 240×240pt centered on screen. 12pt stroke. Track: `surfaceSecondary`. Fill: `textPrimary`, filling clockwise over 45 minutes.
- Inside the ring: the time remaining in `mono` (SF Mono) Regular 48pt, `textPrimary`. Format: `44:58`.
- Below the ring time, inside, 8pt gap: `remaining` in Sans Regular 13pt, `textSecondary`.
- Below the ring, 40pt gap: two buttons side by side:
  - Pause/Resume: 54pt tall, `surfaceSecondary` background, `textPrimary` text, Sans Semibold 17pt, half-width minus 6pt gap.
  - `End Session` ghost button: same dimensions, no background, 1pt `divider` border, `textSecondary` text.
- Below both buttons, 16pt gap: a small disclaimer line: `"Leave this screen — timer keeps running"` in Sans Regular 12pt, `textDisabled`, centered.

**Pause state:**
- Ring fill animation pauses.
- `paused` label appears inside the ring in Sans Regular 13pt, `textSecondary`, fading in below the time.
- Resume button pulses subtly (opacity 1.0 → 0.7 → 1.0, repeating, 1.2s period) to draw the eye back.

**Completion:**
- Ring completes. A 0.4s fill animation completes the final arc.
- Time reads `00:00`.
- Inside the ring: the checkmark animation from `CheckmarkView` — circle fills black, white check spring-scales in.
- Text below ring changes to `Workout complete` in Sans Semibold 17pt, `textPrimary`.
- A haptic burst fires (4 taps, medium intensity).
- After 1.5s: sheet dismisses automatically. Habit auto-checks on the main list.

---

### 11.9 Water Tracker (`WaterTrackerView`)

**Purpose:** A tactile, satisfying ritual. Tapping the bottle should feel like physically drinking water.

**Presentation:** `.sheet`, medium detent (~50% screen height). Background: `surface`.

**Layout:**
- Handle pill at top.
- Title: `Water intake` — Sans Semibold 17pt, centered, 16pt below handle.
- Subtitle: `"Tap a glass to log it"` — Sans Regular 13pt, `textSecondary`, centered, 4pt below title.
- 24pt gap: the main visual — a tall water bottle silhouette drawn in SwiftUI `Path`.
  - Bottle dimensions: approximately 80pt wide × 200pt tall, centered.
  - The bottle interior is divided into 8 equal horizontal bands.
  - Unfilled bands: `surfaceSecondary` fill.
  - Filled bands: sky-blue pastel (`#C2DCF0`), animated filling upward with each tap. Each new band fills with a fluid-like `Shape` trim animation over 0.4s.
  - The bottle outline: 2pt stroke, `divider` color.
- Below bottle: `4 / 8 glasses` in Serif Regular 24pt, `textPrimary`, centered. Updates live.
- Each band of the bottle is a tap target. Tapping any unfilled band fills it (and all below it). This allows logging multiple at once.
- A haptic tap fires per glass logged (`UIImpactFeedbackGenerator`, `.light`).
- When all 8 are filled: the bottle outline strokes to `textPrimary` color, and the label below reads `1 gallon complete` in Serif Regular 24pt. Sheet auto-dismisses after 1s.

---

### 11.10 Photo Capture (`PhotoCaptureView`)

**Purpose:** Fast, frictionless, no distractions. The user takes the photo and gets out.

**Presentation:** `fullScreenCover`. Background: `#000000` pure black (this is a camera context, dark is correct).

**Layout:**
- Full-bleed camera viewfinder occupies the top ~75% of screen.
- Bottom panel (25%, `#0C0C0C`):
  - Centered: a 72×72pt circular capture button. Outer ring: 3pt white stroke. Inner fill: white. Tapping triggers a brief white flash overlay (0.1s opacity spike then fade).
  - Left of shutter: `Cancel` text button, Sans Regular 17pt, white.
  - Right of shutter: if a photo was already taken today, show a circular thumbnail (44×44pt) of the previous photo. Tapping it lets the user view and retake.
- After capture:
  - Viewfinder freezes on the captured frame.
  - A `retake` / `use photo` choice appears below the preview — same layout as the standard iOS camera.
  - Tapping `Use Photo`: image writes to disk, `ScrapbookPhoto` created, habit auto-checks, `fullScreenCover` dismisses.

---

### 11.11 Fail State (`FailStateView`)

**Purpose:** The most dramatic screen in the app. It must feel like a moment, not an error message. The tone is solemn, not punishing — this is a reset, not a failure.

**Presentation:** `fullScreenCover`. Cannot be dismissed by swipe — must be acknowledged.

**Background:** Pure `#0C0C0C` (dark regardless of system mode). This is intentional — the contrast with the normally soft app is the emotional signal.

**Layout:**
- Center of screen: the number `1` in Serif Bold 160pt, `#F0EDE8` (warm white). This is the entire focal point of the screen. Nothing else competes with it.
- Below the `1`, 12pt gap: `Day One.` in Serif Regular Italic 28pt, `#F0EDE8`.
- Below, 24pt gap: a narrow body paragraph, Sans Regular 15pt, `#6B6560` (dark-mode textSecondary), centered, max 280pt wide:
  > `"Every great streak starts here. What matters is that you came back."`
- 64pt gap below: the action area.
  - If grace days remain: `Use grace day (2 remaining)` — primary button, `#F0EDE8` background, `#0C0C0C` text. Full-width minus 48pt. Below it: `Accept reset` ghost button, `#6B6560` text, no border.
  - If no grace days: only `Begin again` primary button.

**Background animation (Canvas-based):**
- 30 tiny white dots (`#F0EDE8` at 15% opacity, 2pt radius) are positioned randomly and drift upward very slowly (20pt over 6 seconds, then loop). No bounce, no randomness in movement — slow, deliberate upward drift, like breath.
- This is subtle. If you notice it immediately, it's too prominent.

**Entry animation:**
- Screen fades in over 0.5s.
- The large `1` starts at 80% scale and springs to 100% (response: 0.6, damping: 0.65) — a single heavy thud feeling.
- Haptic: `UINotificationFeedbackGenerator.notificationOccurred(.warning)` — fires once on the `1`'s arrival.
- Grace day button fades in after a 1.5s delay. Forces the user to sit with the reset for a moment.

---

### 11.12 Grace Day Confirm (`GraceDayConfirmView`)

**Purpose:** The relief valve. Should feel like a considered, mature decision — not a cheat button.

**Presentation:** `.sheet` from within `FailStateView`. Medium detent.

**Background:** `#161616` (matches the fail state dark mode surface).

**Layout:**
- Handle pill at top, `#2C2C2C`.
- 24pt below: `Use a grace day?` — Serif Bold Italic 28pt, `#F0EDE8`, centered.
- 12pt below: `"Grace days: 2 remaining this month"` — Sans Regular 14pt, `#6B6560`.
- 24pt gap: a horizontal info card, `#1F1F1F` background, `radiusMedium`, 16pt internal padding:
  - Body copy: `"Your streak holds. This grace day will be deducted from your monthly allowance. Grace days reset on the 1st of each month."` — Sans Regular 14pt, `#6B6560`.
- 32pt gap below: two full-width buttons:
  - `Confirm grace day` — `#F0EDE8` background, `#0C0C0C` text, Sans Semibold 17pt, 54pt tall, `radiusSmall`.
  - `No — accept reset` — ghost, `#6B6560` text, no background.

---

### 11.13 Scrapbook (`ScrapbookView`)

**Purpose:** A private visual diary. Should feel like flipping through a high-end photo book, not a social media grid.

**Layout:**
- Custom navigation bar: `Scrapbook` in Sans Semibold 17pt, left-aligned (not centered — this is intentional, editorial asymmetry). Right: a small `•••` SF Symbol `ellipsis` button for future export options.
- Below nav: the month/year — `May 2026` — in Serif Bold Italic 28pt, `textPrimary`, left-aligned, 24pt left margin.
- A horizontal scroll strip of month pills (past months) sits 8pt below: each is a 28pt tall pill, `surfaceSecondary` background, `textSecondary` text, `radiusFull`. Active month: `textPrimary` background, `surface` text.

**Grid:**
- `LazyVGrid`, 3 columns, 2pt gap between cells. No margins — cells go edge to edge. This makes it feel like a real photo grid.
- Each cell is square, 1/3 of screen width.
- **Filled cell:** full-bleed photo thumbnail. In the bottom-left corner: a small pill `Day 47` in Sans Bold 9pt, white text, `#00000066` (black 40% alpha) background. `radiusFull`.
- **Empty cell (day passed, no photo):** `surfaceSecondary` background. A small `camera.fill` SF Symbol in `textDisabled` color, centered. Day number in Sans Regular 11pt, `textDisabled`, 4pt below the icon.
- **Future cell (day not yet reached):** completely empty — `background` color. No icon, no number. These are the blanks that motivate the user to fill them.
- **Today's cell:** has a 2pt `textPrimary` color border overlay — the only bordered cell. Draws the eye to the current day.

**Photo tap:**
- Tapping a filled cell: the photo expands to full-screen using `.matchedGeometryEffect`. The photo animates from its grid position to full-screen with a spring. Background fades to black.
- Full-screen view: swipe down to dismiss (physics-based), swipe left/right to navigate between filled days.
- Bottom overlay (full-screen): `Day 47 · May 25, 2026` in Sans Regular 14pt, white, left-aligned. Right: a share icon (box with upward arrow SF Symbol).

---

### 11.14 Before/After Slider (`BeforeAfterSliderView`)

**Purpose:** The most shareable screen in the app. Every design decision should optimize for a screenshot-worthy moment.

**Presentation:** `.sheet`, large detent, from the Scrapbook.

**Layout:**
- Handle pill at top.
- Title: `Before & After` — Serif Bold Italic 28pt, `textPrimary`, centered, 16pt below handle.
- 16pt gap: two compact day-pickers in a horizontal `HStack`:
  - Left picker: `Before — Day 1` in Sans Regular 14pt, `textSecondary`. A `<` `>` chevron to change the day. Tapping the label opens a scroll picker.
  - Right picker: `After — Day 47` same pattern.
  - A thin 1pt `divider` vertical line separates them.
- 24pt gap: the comparison frame — a square 1:1 region (full width minus 0pt margin), clipped.
  - The "Before" photo occupies the left half; the "After" photo occupies the right half.
  - A thin 2pt `surface`-colored vertical bar (the divider handle) is draggable. The user drags left/right to reveal more of either photo. The handle has a small circular thumb (28pt, `surface` fill, shadow) for grip.
  - A small `BEFORE` label in Sans Bold 10pt, white, `+2pt` tracking sits top-left of the left photo, 12pt inset. Same for `AFTER` top-right.
- Below the frame, 24pt gap:
  - The watermark preview: `Glow Protocol · Day 1 → 47` in Sans Regular 12pt, `textSecondary`, centered. This is what will appear on the exported image.
- Bottom: `Share` primary button. On tap: `ImageRenderer` renders the comparison frame with the `GLOW PROTOCOL` wordmark composited in the top-left corner (Serif Bold 14pt, white, on a transparent background). Presents `UIActivityViewController`.

---

### 11.15 Progress (`ProgressView`)

**Purpose:** The long-view mirror. The user should see momentum and feel proud. No shame for missed days — just honest data.

**Layout:**
- Screen title: `Progress` in Sans Semibold 17pt nav bar.
- Top hero card (`surface`, `radiusLarge`, full-width minus 32pt margin, 24pt internal padding):
  - Left column:
    - `Day 47` — Serif Bold 52pt, `textPrimary`.
    - `of 75` — Sans Regular 15pt, `textSecondary`.
    - 8pt gap: `63% complete` — Sans Regular 14pt, `textSecondary`.
  - Right column: the master `ProgressRing` at 88×88pt, 8pt stroke, `textPrimary` fill.
  - Card bottom: a thin progress bar, full-width inside the card, 4pt tall, `surfaceSecondary` track, `textPrimary` fill, `radiusFull` caps. Animates to current % on appear.

- **Streak section** (below hero, 24pt gap):
  - Section label: `STREAK` — Sans Bold 11pt, `textSecondary`, `+2pt` tracking, all caps.
  - Stat row: `47 days` in Serif Bold Italic 36pt, `textPrimary`. Below: `Personal best: 47 days` in Sans Regular 13pt, `textSecondary`.
  - If the user is on their personal best streak: a small `New record` pill badge in Sans Bold 11pt, `textPrimary` background, `surface` text, appears to the right of the streak number.

- **Grace days used section:**
  - Label: `GRACE DAYS` — same label style.
  - `1 used · 1 remaining this month` — Sans Regular 15pt, `textPrimary`.
  - Visual: three small dots (or however many per month). Filled dot: `textPrimary`. Empty dot: `surfaceSecondary`.

- **Per-habit breakdown** (below, 24pt gap):
  - Section label: `HABIT COMPLETION`.
  - For each enabled habit: a row with the pastel icon circle (28pt), habit name in Sans Semibold 15pt, and a progress bar on the right.
    - Progress bar: full-width minus icon/name, 6pt tall, `surfaceSecondary` track, habit's pastel color fill (this is one of the only places pastels appear as a fill beyond the row indicator — it works here because it's a data visualization).
    - Percentage in Sans Bold 13pt, `textPrimary` at far right.
  - All bars animate in from left on screen appear, staggered 0.05s per row.

- **Calendar heatmap** (bottom section):
  - A 7-column grid (one column per day of week) showing all 75 days.
  - Filters to `isCurrentRun == true` DayLogs by default.
  - Completed day: `textPrimary` fill, 8×8pt square, `radiusSmall`.
  - Missed/archived day: `destructive` color fill.
  - Grace day: `gracePulse` (amber) fill.
  - Future day: `surfaceSecondary` fill.
  - 2pt gap between squares. Month label above each month's start in Sans Regular 11pt, `textSecondary`.

- **Past Runs section** (below heatmap, only visible if any archived runs exist):
  - Section label: `PAST RUNS` — Sans Bold 11pt, `textSecondary`, all caps.
  - One row per archived run, showing: run date range (`"Jan 3 – Feb 8"`), days reached (`"36 days"`), and a small mini-heatmap strip (compact version of the heatmap, 4pt squares, single row). All in `surface` card with `radiusLarge`.
  - Tapping a past run row expands it to show the full per-habit completion breakdown for that run.
  - These rows are read-only — no interaction beyond viewing.
  - **Scrapbook note:** The Scrapbook grid also shows past-run photos by default (photos are never deleted on reset). A subtle `ARCHIVED` pill badge appears on photos from past runs when the user is browsing the full grid.

---

### 11.16 Settings (`SettingsView`)

**Purpose:** Functional and clean. Should not look like a settings screen — it should look like a personal profile and preferences page.

**Presentation:** Sheet from a `gear` icon in the Progress tab nav bar.

**Layout:**
- Handle pill at top.
- `Preferences` — Serif Bold Italic 28pt, `textPrimary`, left-aligned, 24pt left margin.
- Sections separated by 24pt gaps and `SECTION NAME` labels in Sans Bold 11pt, `textSecondary`, all caps.

**Section: APPEARANCE**
- `Theme` row: left `textPrimary` label, right a segmented control with three options: `Light` / `Dark` / `System`. Segmented control uses custom styling — `surface` background, 1pt `divider` border, selected segment has `textPrimary` background `surface` text, `radiusMedium`, spring transition.

**Section: PROTOCOL**
- `Difficulty` row: current selection shown in `textSecondary` on right, chevron, tapping opens `DifficultyPickerView` as nested sheet.
- `Edit habits` row: tapping opens `HabitCustomizerView`.
- `Grace days` row: current monthly allowance in `textSecondary`, tapping opens `GraceDayPickerView`.

**Section: REMINDERS**
- `Daily reminder` toggle row: custom toggle (same as onboarding). Shows time on right (`8:00 AM` in `textSecondary`) when enabled. Tapping the time opens a `DatePicker` sheet.
- `Midnight check` row: informational only — `"Streak evaluates at 11:59 PM daily"` in `textSecondary` Sans Regular 13pt. No interaction.

**Section: DANGER ZONE**
- `Reset protocol` row: text in `destructive` color. Tapping presents a confirmation `Alert` with `destructive` button style. Resets all data.

**Section: ABOUT**
- `Version 1.0` in `textSecondary`.
- `Privacy Policy` — tappable, opens `SafariViewController`.
- `Rate Glow Protocol` — opens App Store review prompt via `SKStoreReviewController`.

---

### 11.17 Design Consistency Checklist (Build-Time Reference)

Before shipping any screen, verify the following:

- [ ] Only one Playfair Display element per screen. No serif stacking.
- [ ] Background color is `#F7F5F2` (light) or `#0C0C0C` (dark) — not pure white or pure black at the root level.
- [ ] No colored text outside of `destructive` error states.
- [ ] All tappable elements have at least a 44×44pt touch target.
- [ ] Dividers are inset — not full-bleed — wherever they sit inside content cards.
- [ ] Progress rings always animate; never appear at their final value instantly.
- [ ] All checkmarks use the spring scale animation (`0.6 → 1.2 → 1.0`).
- [ ] No `UISwitch` — always use the custom pill toggle.
- [ ] Pastel colors only appear on habit row indicators and the Progress habit bars. Nowhere else.
- [ ] The floating tab bar does not overlap any primary CTA button.
- [ ] Dark mode tested on every screen — no hardcoded colors, only semantic tokens.
- [ ] Haptic fires on every check completion. Never skip the haptic.
- [ ] Font: Playfair Display is a registered font resource, `UIFont` registered in `Info.plist`.

---

*Blueprint authored May 25, 2026. Last updated: May 25, 2026.*
