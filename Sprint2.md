# Sprint 2 — Steps Fix & Custom Habits with Icon/Color Picker

> **Sprint goal:** Remove the iOS native confirmation dialog from the 10k steps habit so it animates inline like every other simple habit, and overhaul the custom habit system to support per-habit icon selection (16-icon grid) and pastel color selection (8-swatch bar) — all consistent with the BLUEPRINT aesthetic.

---

## Table of Contents

1. [Sprint Overview](#1-sprint-overview)
2. [Feature 1 — Steps: Remove Confirmation Dialog](#2-feature-1--steps-remove-confirmation-dialog)
3. [Feature 2 — Custom Habits with Icon + Color Picker](#3-feature-2--custom-habits-with-icon--color-picker)
   - [3.1 Data Model Changes](#31-data-model-changes)
   - [3.2 StreakService Seeding Changes](#32-streakservice-seeding-changes)
   - [3.3 New Component: CustomHabitIconPickerSheet](#33-new-component-customhabiticonpickersheet)
   - [3.4 HabitRow Override Parameters](#34-habitrow-override-parameters)
   - [3.5 HabitCustomizerView — Onboarding](#35-habitcustomizerview--onboarding)
   - [3.6 OnboardingViewModel — New State](#36-onboardingviewmodel--new-state)
   - [3.7 EditHabitsSheet — Settings](#37-edithabitssheet--settings)
   - [3.8 DailyGlowView — Wire Custom Overrides](#38-dailyglowview--wire-custom-overrides)
4. [Design Specifications](#4-design-specifications)
   - [4.1 Icon Grid](#41-icon-grid)
   - [4.2 Color Swatch Bar](#42-color-swatch-bar)
   - [4.3 Custom Field Row (Onboarding + Settings)](#43-custom-field-row-onboarding--settings)
5. [File Change Summary](#5-file-change-summary)
6. [Implementation Order & Critical Path](#6-implementation-order--critical-path)
7. [Design Consistency Checklist](#7-design-consistency-checklist)

---

## 1. Sprint Overview

| # | Feature | Files touched | Complexity |
|---|---------|--------------|------------|
| 1 | Steps — remove iOS confirmation dialog | `DailyGlowView.swift` | Low |
| 2a | Data model: icon + color on `ProtocolConfig` and `HabitEntry` | `ProtocolConfig.swift`, `HabitEntry.swift` | Medium |
| 2b | StreakService seeding carries icon + color | `StreakService.swift` | Low |
| 2c | New picker sheet component | `CustomHabitIconPickerSheet.swift` (new) | Medium |
| 2d | `HabitRow` accepts icon/color overrides | `HabitRow.swift` | Low |
| 2e | Onboarding customizer redesigned custom field rows | `HabitCustomizerView.swift`, `OnboardingViewModel.swift` | Medium |
| 2f | Settings EditHabitsSheet gains custom habit editing | `SettingsView.swift` | Medium |
| 2g | DailyGlowView passes entry overrides to HabitRow | `DailyGlowView.swift` | Low |

**Total new files:** 1 (`CustomHabitIconPickerSheet.swift`)
**Total modified files:** 7

---

## 2. Feature 1 — Steps: Remove Confirmation Dialog

### Problem

`DailyGlowView` uses `.confirmationDialog(...)` when the user taps the steps row. On iOS this renders as a native bottom action sheet — a system-level overlay that breaks the app's custom visual language. Every other simple habit (diet, reading, no alcohol, custom) calls `viewModel.completeHabit(entry)` directly and gets the inline spring animation + `CheckmarkView` bounce + row sliding down into the completed section.

### Root Cause

In `handleRowTap(_ entry:, log:)` the `.steps` case sets `stepsConfirmEntry = entry`, which triggers `.confirmationDialog`. This was a Phase 1 placeholder to avoid silent accidental completion.

### Fix

**`GlowProtocol/Features/DailyGlow/DailyGlowView.swift`**

1. Remove the `@State private var stepsConfirmEntry: HabitEntry?` property.
2. Remove the entire `.confirmationDialog(...)` modifier block (lines 81–93).
3. In `handleRowTap`, change the `.steps` case:

```swift
// BEFORE
case .steps:
    stepsConfirmEntry = entry

// AFTER
case .steps:
    viewModel.completeHabit(entry, metadata: #"{"confirmed":true}"#)
```

That is the complete change. The metadata JSON string is preserved so historical entries with `confirmed: true` remain valid. The steps row will now complete immediately on tap, fire the `CheckmarkView` spring animation (scale 0.6 → 1.2 → 1.0), trigger `HapticService.play(.habitComplete)`, update the progress ring, and animate the row down into the completed section — identical to diet, reading, and no-alcohol habits.

No other files need to change for this feature.

---

## 3. Feature 2 — Custom Habits with Icon + Color Picker

### Architecture overview

```
ProtocolConfig (stores icon + color hex per custom slot)
       ↓ written by
OnboardingViewModel.finalize()   ←→   SettingsViewModel (edit post-onboarding)
       ↓ read by
StreakService.enabledHabits()
       ↓ seeds
HabitEntry (stores customSymbolName + customColorHex per entry)
       ↓ read by
DailyGlowView → HabitRow (iconSymbolOverride + iconColorOverride)
```

The picker itself (`CustomHabitIconPickerSheet`) is a reusable sheet used in both the onboarding customizer and the settings edit-habits sheet.

---

### 3.1 Data Model Changes

#### `GlowProtocol/Models/ProtocolConfig.swift`

Add 6 new stored properties immediately after the existing `customHabit3` line:

```swift
// Custom habit icon overrides (SF Symbol names; nil = "star.fill")
var customHabit1Icon: String?
var customHabit2Icon: String?
var customHabit3Icon: String?

// Custom habit color overrides (light-mode pastel hex; nil = "#E0E0E0")
var customHabit1ColorHex: String?
var customHabit2ColorHex: String?
var customHabit3ColorHex: String?
```

In `init()`, set all six to `nil` (the system will fall back to `"star.fill"` / `"#E0E0E0"` at display time).

No migration script is needed — SwiftData handles `nil` optional additions on existing stores automatically.

#### `GlowProtocol/Models/HabitEntry.swift`

Add 2 new stored properties in `HabitEntry` after the existing `customLabel` line:

```swift
var customSymbolName: String?   // non-nil only when habitID == .custom1/2/3
var customColorHex: String?     // non-nil only when habitID == .custom1/2/3
```

Update the `init(...)` to accept these:

```swift
init(
    habitID: HabitID,
    customLabel: String? = nil,
    customSymbolName: String? = nil,
    customColorHex: String? = nil,
    isRequired: Bool = true,
    isComplete: Bool = false,
    completedAt: Date? = nil,
    validationMetadata: String? = nil
) {
    self.habitIDRaw = habitID.rawValue
    self.customLabel = customLabel
    self.customSymbolName = customSymbolName
    self.customColorHex = customColorHex
    ...
}
```

Add a convenience computed property on `HabitID` (inside the `HabitEntry.swift` file, on the `HabitID` enum):

```swift
var isCustom: Bool {
    switch self {
    case .custom1, .custom2, .custom3: return true
    default: return false
    }
}
```

---

### 3.2 StreakService Seeding Changes

**`GlowProtocol/Services/StreakService.swift`**

The `enabledHabits(for:)` method currently returns `[(HabitID, String?)]` (habitID, customLabel). Extend the tuple to carry icon and color:

```swift
// Old return type
func enabledHabits(for config: ProtocolConfig) -> [(HabitID, String?)]

// New return type — (habitID, customLabel, customSymbol, customColorHex)
func enabledHabits(for config: ProtocolConfig) -> [(HabitID, String?, String?, String?)]
```

Update the body so the three custom habit entries pass through their config values:

```swift
if let c = config.customHabit1, !c.isEmpty {
    items.append((.custom1, c,
        config.customHabit1Icon ?? "star.fill",
        config.customHabit1ColorHex ?? "#E0E0E0"))
}
if let c = config.customHabit2, !c.isEmpty {
    items.append((.custom2, c,
        config.customHabit2Icon ?? "star.fill",
        config.customHabit2ColorHex ?? "#E0E0E0"))
}
if let c = config.customHabit3, !c.isEmpty {
    items.append((.custom3, c,
        config.customHabit3Icon ?? "star.fill",
        config.customHabit3ColorHex ?? "#E0E0E0"))
}
```

For all non-custom habits the tuple still returns `(habitID, nil, nil, nil)` — the nil values are ignored at the `HabitEntry` init site.

In `seedDayLog(for:config:)` (or wherever `enabledHabits` output is iterated to create `HabitEntry` objects), destructure the new tuple and pass `customSymbolName` and `customColorHex` to the `HabitEntry` init:

```swift
for (habitID, label, symbol, colorHex) in enabledHabits(for: config) {
    let entry = HabitEntry(
        habitID: habitID,
        customLabel: label,
        customSymbolName: symbol,
        customColorHex: colorHex
    )
    log.habitEntries.append(entry)
}
```

---

### 3.3 New Component: CustomHabitIconPickerSheet

**New file: `GlowProtocol/DesignSystem/Components/CustomHabitIconPickerSheet.swift`**

This sheet is presented from both the onboarding customizer and the settings edit-habits sheet whenever the user taps an icon circle on a custom habit row.

```swift
struct CustomHabitIconPickerSheet: View {
    @Binding var selectedSymbol: String
    @Binding var selectedColorHex: String
    var onDone: () -> Void

    static let icons: [String] = [
        "star.fill",       "dumbbell.fill",    "cross.fill",       "headphones",
        "nosign",          "heart.fill",        "bolt.fill",        "moon.fill",
        "flame.fill",      "figure.walk",       "music.note",       "pencil",
        "bed.double.fill", "brain.fill",        "fork.knife",       "leaf.fill"
    ]

    static let pastels: [(hex: String, token: Color)] = [
        ("#D4E8C2", .habitWorkout),
        ("#C2DCF0", .habitWater),
        ("#F5E6C8", .habitDiet),
        ("#E8D4F0", .habitReading),
        ("#C8EAE0", .habitSteps),
        ("#FAE0E0", .habitNoAlcohol),
        ("#FFF0C2", .habitPhoto),
        ("#E0E0E0", .habitCustom),
    ]
}
```

**Layout (top to bottom):**

1. `GlowSheetHandle()` — centered at top, standard pill in `glowDivider`.
2. Title: `"Customize icon"` — `Font.glowSerif(size: 24, weight: .bold, italic: true)`, `glowTextPrimary`, left-aligned, `24pt` horizontal padding, `16pt` top padding.
3. Section label: `"ICON"` — `.glowText(.badge)`, `glowTextSecondary`, `+1pt` tracking, left-aligned, `24pt` horizontal padding.
4. **Icon grid** — `LazyVGrid` with 4 fixed-width columns, `12pt` spacing:
   - Each cell: a 48×48pt `Button` containing a `ZStack`
   - Background circle: `glowTextPrimary` fill when selected, `glowSurfaceSecondary` fill when not
   - SF Symbol inside: 20pt, weight `.medium`, `glowSurface` color when selected, `glowTextPrimary` when not
   - Spring animation on selection: `.spring(response: 0.3, dampingFraction: 0.7)`
   - Grid has `16pt` horizontal padding
5. Section label: `"COLOR"` — same badge style, `16pt` top gap.
6. **Color swatch bar** — `HStack(spacing: 10)` centered (or `LazyVGrid` 4-column):
   - 8 × 36pt `Button` circles, each filled with their pastel `Color(hex:)`
   - Selected state: `Circle().strokeBorder(Color.glowTextPrimary, lineWidth: 2.5)` overlay
   - Unselected: no border
   - Spring scale animation (`0.9 → 1.05 → 1.0`) on selection
   - `16pt` horizontal padding
7. `GlowButton(title: "Done")` — primary style, calls `onDone()`, `24pt` horizontal padding, `16pt` bottom padding.
8. `Spacer()` to keep content top-aligned when presented at medium detent.

**Presentation:** always `.presentationDetents([.medium])`. Sheet background `glowBackground`.

---

### 3.4 HabitRow Override Parameters

**`GlowProtocol/DesignSystem/Components/HabitRow.swift`**

Add two optional parameters after the existing `photoThumbnail` parameter:

```swift
var iconSymbolOverride: String? = nil
var iconColorOverride: Color? = nil
```

Update `iconView` to use these when non-nil:

```swift
@ViewBuilder private var iconView: some View {
    if habitID == .progressPhoto, let thumb = photoThumbnail {
        Image(uiImage: thumb)
            .resizable()
            .scaledToFill()
            .frame(width: 36, height: 36)
            .clipShape(Circle())
    } else {
        let effectiveSymbol = iconSymbolOverride ?? habitID.symbolName
        let effectiveColor  = iconColorOverride  ?? habitID.pastel
        ZStack {
            Circle()
                .fill(effectiveColor)
                .frame(width: 36, height: 36)
            Image(systemName: effectiveSymbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.glowTextPrimary)
        }
    }
}
```

Also update the `trailingView` to pass `effectiveColor` as the `pastel` on `CheckmarkView` and `SegmentedRing`. Extract the computed color into a private property:

```swift
private var effectivePastel: Color {
    iconColorOverride ?? habitID.pastel
}
```

Then use `effectivePastel` everywhere `habitID.pastel` was used inside `trailingView`. This ensures the checkmark ring also uses the user's custom pastel, not the fallback grey.

---

### 3.5 HabitCustomizerView — Onboarding

**`GlowProtocol/Features/Onboarding/HabitCustomizerView.swift`**

Redesign the "ADD YOUR OWN" section. The three simple `TextField` rows are replaced with three **custom habit builder rows**, each showing a tappable icon circle on the left (matching the default habit row anatomy from the BLUEPRINT), a text field in the center, and the character counter / clear button on the right.

**Custom habit builder row anatomy (72pt min-height):**

```
[Colored icon circle 36pt]  [Text field "Custom habit (optional)"]  [counter / xmark]
```

- **Icon circle (left):**
  - When the text field is **empty**: a `plus.circle.fill` SF Symbol, 20pt, in `glowTextDisabled` on `glowSurfaceSecondary` background circle. Non-tappable (button disabled with `.opacity(0.5)`).
  - When the text field has **content**: the user's chosen SF Symbol at their chosen pastel color. Tappable — presents `CustomHabitIconPickerSheet`.
- **Text field (center):** same as before, `40`-char limit, `.glowText(.body)`, `glowTextPrimary`. Placeholder `"Custom habit (optional)"` in `glowTextDisabled`.
- **Counter / clear (right):** unchanged from current implementation.
- The entire row sits inside a `RoundedRectangle(cornerRadius: GlowRadius.medium)` with `glowSurfaceSecondary` fill (matching current field background).
- Sheet state: add `@State private var iconPickerTarget: Int?` (which slot is being edited: 1, 2, or 3). Present `CustomHabitIconPickerSheet` with `.sheet(item: $iconPickerTarget)`.

**Bindings into `OnboardingViewModel`:** each row binds to `viewModel.custom1`/`custom2`/`custom3` for the text, `viewModel.customIcon1`/`customIcon2`/`customIcon3` for the symbol, and `viewModel.customColor1`/`customColor2`/`customColor3` for the color hex.

The section label `"ADD YOUR OWN"` and dividers between rows remain as-is. The card visual (rounded surface background on the group) is removed because the rows are now self-contained cards (each row is its own rounded rect, consistent with the custom habit field's current appearance).

---

### 3.6 OnboardingViewModel — New State

**`GlowProtocol/Features/Onboarding/OnboardingViewModel.swift`**

Add six new properties after `custom3`:

```swift
var customIcon1: String = "star.fill"
var customIcon2: String = "star.fill"
var customIcon3: String = "star.fill"
var customColor1: String = "#E0E0E0"
var customColor2: String = "#E0E0E0"
var customColor3: String = "#E0E0E0"
```

In `finalize(in:)`, after the existing `config.customHabit3 = ...` line, add:

```swift
config.customHabit1Icon     = customIcon1
config.customHabit2Icon     = customIcon2
config.customHabit3Icon     = customIcon3
config.customHabit1ColorHex = customColor1
config.customHabit2ColorHex = customColor2
config.customHabit3ColorHex = customColor3
```

No other logic changes are needed in the view model.

---

### 3.7 EditHabitsSheet — Settings

**`GlowProtocol/Features/Settings/SettingsView.swift`** (`EditHabitsSheet` struct)

Currently `EditHabitsSheet` only has toggles for the seven default habits. Add a custom habits editing section below the existing toggle list.

**Section label:** `"CUSTOM HABITS"` — `.glowText(.badge)`, `glowTextSecondary`, `+1pt` tracking, matching the section labels used in `SettingsView`.

**Three custom habit editing rows** (one per slot), each in a `VStack` inside a `surface`-filled `RoundedRectangle(cornerRadius: GlowRadius.medium)`:

Each row (72pt min-height):
```
[Colored icon circle 36pt]  [Text field with current label]  [xmark / counter]
```

- Icon circle: tappable when text is non-empty, presenting `CustomHabitIconPickerSheet`.
- Text field: binds to the corresponding `ProtocolConfig` property (`cfg.customHabit1` etc.) via `Binding`.
- Character limit: 40, same as onboarding.
- On text clear: icon and color reset to defaults (`"star.fill"`, `"#E0E0E0"`).

**SettingsViewModel state needed:** `EditHabitsSheet` is a `@Bindable var viewModel: SettingsViewModel`. `SettingsViewModel` needs three pairs of draft icon/color properties:

```swift
var draftCustomIcon1: String = "star.fill"
var draftCustomIcon2: String = "star.fill"
var draftCustomIcon3: String = "star.fill"
var draftCustomColor1: String = "#E0E0E0"
var draftCustomColor2: String = "#E0E0E0"
var draftCustomColor3: String = "#E0E0E0"
```

On sheet `.onAppear`, populate these from `config.customHabit1Icon ?? "star.fill"` etc. On **Save**, write the draft values back to `config` before calling `viewModel.save()`.

The existing `GlowButton(title: "Save")` at the bottom of the sheet handles the final write.

---

### 3.8 DailyGlowView — Wire Custom Overrides

**`GlowProtocol/Features/DailyGlow/DailyGlowView.swift`**

In `habitListCard(log:)`, update the `HabitRow(...)` call to pass the entry's custom overrides when the entry is a custom habit:

```swift
HabitRow(
    label: entry.displayLabel,
    habitID: entry.habitID,
    isComplete: entry.isComplete,
    statusText: status,
    statusEmphasis: emphasis,
    trailing: viewModel.trailingStyle(for: entry),
    photoThumbnail: photoThumbnail(for: entry, log: log),
    iconSymbolOverride: entry.habitID.isCustom ? entry.customSymbolName : nil,
    iconColorOverride: entry.habitID.isCustom
        ? entry.customColorHex.map { Color(hex: $0) }
        : nil,
    onTap: { handleRowTap(entry, log: log) }
)
```

`Color(hex:)` already exists in `Colors.swift`. No new utilities needed.

---

## 4. Design Specifications

### 4.1 Icon Grid

The 16 icons are arranged in a `LazyVGrid` with 4 equal columns. Icons are chosen to cover the full range of personal discipline goals — fitness, health, mental, lifestyle, nutrition, rest.

| Row | SF Symbol | Semantic label |
|-----|-----------|---------------|
| 1 | `star.fill` | General / favourite |
| 1 | `dumbbell.fill` | Strength training |
| 1 | `cross.fill` | Medical / health |
| 1 | `headphones` | Listening / podcast / music |
| 2 | `nosign` | Restriction / no-X habit |
| 2 | `heart.fill` | Self-care / cardio |
| 2 | `bolt.fill` | Energy / performance |
| 2 | `moon.fill` | Sleep / rest |
| 3 | `flame.fill` | Intensity / streak |
| 3 | `figure.walk` | Daily movement / steps variant |
| 3 | `music.note` | Music / creative practice |
| 3 | `pencil` | Journaling / writing |
| 4 | `bed.double.fill` | Sleep hygiene |
| 4 | `brain.fill` | Mindfulness / mental health |
| 4 | `fork.knife` | Nutrition / meal prep |
| 4 | `leaf.fill` | Nature / plant-based |

**Cell design (48×48pt):**
- Background: `Circle().fill(glowTextPrimary)` when selected, `Circle().fill(glowSurfaceSecondary)` when unselected.
- Icon: `Image(systemName:)` at `Font.system(size: 20, weight: .medium)`, `glowSurface` when selected, `glowTextPrimary` when unselected.
- Touch target: the entire 48pt circle. Minimum touch area 44pt is satisfied.
- Selection animation: `.animation(.spring(response: 0.3, dampingFraction: 0.72), value: selectedSymbol)` on the background fill.
- No labels under icons — the visual is self-explanatory at this size.

**Grid dimensions:** 4 columns, rows expand as needed (will always be exactly 4 rows for 16 icons). Cell spacing: 12pt. Horizontal padding: 24pt.

---

### 4.2 Color Swatch Bar

8 pastel circles in a horizontal `HStack`. These are the exact 8 habit pastels defined in `Colors.swift` — no new colors are introduced, keeping the total color count in the app constant.

| # | Hex | Maps to design token |
|---|-----|----------------------|
| 1 | `#D4E8C2` | `.habitWorkout` (sage green) |
| 2 | `#C2DCF0` | `.habitWater` (sky blue) |
| 3 | `#F5E6C8` | `.habitDiet` (peach cream) |
| 4 | `#E8D4F0` | `.habitReading` (lavender) |
| 5 | `#C8EAE0` | `.habitSteps` (mint) |
| 6 | `#FAE0E0` | `.habitNoAlcohol` (blush) |
| 7 | `#FFF0C2` | `.habitPhoto` (soft yellow) |
| 8 | `#E0E0E0` | `.habitCustom` (cool silver — default) |

**Swatch design (36×36pt circle):**
- Fill: `Color(hex: pastelHex)` — light mode value only. Dark mode rendering: since pastels only appear as small indicators, the light-mode hex looks acceptable even in dark mode (and matches how they appear on habit rows). Note: the sheet is always presented in the same mode as the app, so no special dark treatment is needed beyond what `habitWorkout` etc. already handle.
- Selected: `overlay { Circle().strokeBorder(Color.glowTextPrimary, lineWidth: 2.5) }` — a bold ring around the chosen swatch.
- Unselected: no border.
- Animation on selection: spring scale `0.9 → 1.05 → 1.0`, `.spring(response: 0.28, dampingFraction: 0.65)`.
- Touch target: 44pt via `.frame(width: 44, height: 44)` wrapper with the 36pt circle centered inside.
- Bar layout: `HStack(spacing: 8)` inside `.padding(.horizontal, 24)`. Total width of 8 × 44 + 7 × 8 = 408pt — fits on all current iPhone widths (375pt+). If the sheet width is narrow, fall back to a `LazyVGrid` with 4 columns.
- To safely fit all screen widths, use a `LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8))` approach so the system distributes width adaptively.

---

### 4.3 Custom Field Row (Onboarding + Settings)

Both locations use the same visual anatomy, derived directly from the BLUEPRINT's "Habit Row" spec and the existing `habitToggleRow` in `HabitCustomizerView`:

```
┌──────────────────────────────────────────────────────┐
│  [Icon ○ 36pt]  [TextField "Custom habit…"]  [·· 40] │
└──────────────────────────────────────────────────────┘
```

Row height: 72pt minimum (matching all other habit rows in the app).
Background: `RoundedRectangle(cornerRadius: GlowRadius.medium).fill(glowSurfaceSecondary)` — matching the current custom field style.
Internal horizontal padding: 16pt (matching `habitToggleRow`).
Divider between rows: **none** (each row is a standalone card; they are separated by `GlowSpacing.s8` vertical gap, matching the existing custom field spacing).

**Icon circle states:**

| State | Background | Symbol | Tap behavior |
|-------|-----------|--------|--------------|
| Empty field | `glowSurfaceSecondary` | `plus.circle.fill` 20pt `glowTextDisabled` | No-op (disabled) |
| Non-empty field | User's chosen pastel (`Color(hex:)`) | User's chosen SF Symbol 16pt `glowTextPrimary` | Opens `CustomHabitIconPickerSheet` |

When the user clears the text field, the icon circle reverts to the empty state and the stored icon/color reset to defaults (`"star.fill"` / `"#E0E0E0"`).

**Transition:** when a user types the first character into an empty field, the icon circle transitions from the placeholder state to the colored state with a `.spring(response: 0.3, dampingFraction: 0.72)` animation — same as the `GlowToggle` transition.

---

## 5. File Change Summary

| File | Change type | Description |
|------|-------------|-------------|
| `Features/DailyGlow/DailyGlowView.swift` | Modify | Remove `stepsConfirmEntry` + `.confirmationDialog`; steps case → direct `completeHabit`; pass `iconSymbolOverride`/`iconColorOverride` to `HabitRow` |
| `Models/ProtocolConfig.swift` | Modify | Add `customHabit1/2/3Icon: String?` + `customHabit1/2/3ColorHex: String?` (6 new properties) |
| `Models/HabitEntry.swift` | Modify | Add `customSymbolName: String?` + `customColorHex: String?` stored properties; update `init`; add `isCustom` to `HabitID` enum |
| `Services/StreakService.swift` | Modify | `enabledHabits` return tuple gains 2 extra fields (symbol, colorHex); `seedDayLog` passes them to `HabitEntry` init |
| `DesignSystem/Components/HabitRow.swift` | Modify | Add `iconSymbolOverride: String?` + `iconColorOverride: Color?` params; update `iconView` + `trailingView` to use `effectivePastel` |
| `DesignSystem/Components/CustomHabitIconPickerSheet.swift` | **New** | Reusable sheet: 4×4 icon grid + 8-swatch color bar + Done button |
| `Features/Onboarding/HabitCustomizerView.swift` | Modify | Replace plain `customField(text:)` with new `customHabitBuilderRow(index:)` that shows icon circle + text field + opens picker sheet |
| `Features/Onboarding/OnboardingViewModel.swift` | Modify | Add `customIcon1/2/3: String` + `customColor1/2/3: String`; update `finalize()` to write them |
| `Features/Settings/SettingsView.swift` | Modify | `EditHabitsSheet` gains "CUSTOM HABITS" section with three icon-circle + text-field rows; `SettingsViewModel` gets 6 draft icon/color properties |

---

## 6. Implementation Order & Critical Path

The features can be built in this order. Each step has no circular dependencies on the next.

```
Step 1  →  DailyGlowView.swift — remove confirmationDialog (5 min, zero risk)

Step 2  →  ProtocolConfig.swift — add 6 new optional properties

Step 3  →  HabitEntry.swift — add customSymbolName + customColorHex + HabitID.isCustom

Step 4  →  StreakService.swift — expand enabledHabits tuple + update seedDayLog

Step 5  →  CustomHabitIconPickerSheet.swift — build the new sheet (most self-contained)

Step 6  →  HabitRow.swift — add override params (depends on step 5 being done first
           so you can test them together)

Step 7  →  OnboardingViewModel.swift — add icon/color state + finalize() writes

Step 8  →  HabitCustomizerView.swift — redesign custom rows (depends on step 5, 7)

Step 9  →  SettingsView.swift EditHabitsSheet — add custom section (depends on step 5)

Step 10 →  DailyGlowView.swift — wire iconSymbolOverride/iconColorOverride to HabitRow
           (depends on steps 3, 4, 6)
```

Steps 1–4 are pure data/logic with no UI risk. Steps 5–6 are UI only, no data risk. Steps 7–10 wire it all together.

---

## 7. Design Consistency Checklist

Before closing Sprint 2, verify each item against the BLUEPRINT.

- [ ] Steps row completes inline with spring animation — no system sheet appears.
- [ ] Steps checkmark animates scale `0.6 → 1.2 → 1.0` and row slides to completed section.
- [ ] Steps haptic fires on completion (same `habitComplete` pattern as other habits).
- [ ] Custom habit icon circle uses the user's chosen pastel as background — never a saturated color.
- [ ] Custom habit icon circle symbol is 20pt SF Symbol weight `.medium` — matches BLUEPRINT iconography spec.
- [ ] Selected icon in grid: `glowTextPrimary` background (near-black), `glowSurface` symbol — matches the completed checkmark aesthetic.
- [ ] Color swatch selection ring uses `glowTextPrimary` stroke — consistent with selection indicators elsewhere (difficulty card left bar, segmented control selected segment).
- [ ] `CustomHabitIconPickerSheet` has `GlowSheetHandle()` at top.
- [ ] Sheet title uses Playfair Display Bold Italic — only one serif element on the sheet.
- [ ] Section labels (`"ICON"`, `"COLOR"`) use `.glowText(.badge)` + `glowTextSecondary` + `+1pt` tracking — matching all section labels in Settings.
- [ ] Done button uses `GlowButton(title: "Done")` primary style — consistent with all CTAs.
- [ ] Custom field row height is 72pt minimum — matches every other habit row.
- [ ] Empty custom field icon is `glowTextDisabled` — not a fully visible interactive element.
- [ ] Icon/color reset to defaults when the text field is cleared — no orphaned custom icon on an empty slot.
- [ ] `HabitRow` trailing `CheckmarkView` uses `effectivePastel` (the user's chosen color) not the static `.habitCustom` grey.
- [ ] Dark mode tested: the custom pastel circles inside `CustomHabitIconPickerSheet` render with the light-mode hex values — same behavior as all other pastel indicators in the app (which also use light-mode hex via `Color(hex:)` in non-adaptive contexts like `HabitSummary` in widgets).
- [ ] No new font sizes below 11pt introduced.
- [ ] All tappable elements in the picker have at least 44×44pt touch targets.
- [ ] No hardcoded colors outside `Colors.swift` tokens — only `Color(hex:)` calls for the pastel swatches, which reference the same hex values already in `Colors.swift`.
- [ ] Haptic fires when an icon is selected in the picker (`UIImpactFeedbackGenerator(.light)` — same as water tracker glass tap).

---

*Sprint 2 authored May 26, 2026.*
