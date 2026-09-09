# GlowProtocol

**Build a daily routine. Track your consistency. See your progress.**

GlowProtocol is a native iOS habit tracker built around a customizable 75-day challenge. It brings daily check-ins, workout timers, hydration tracking, progress photos, and streaks into one SwiftUI app, with Hard, Medium, and Soft modes for different levels of commitment.

## Highlights

- **Make the challenge yours** — personalize your goals, difficulty, daily habits, and grace-day settings during onboarding.
- **Track the essentials** — log workouts, water, reading, diet, steps, alcohol-free days, and progress photos; add up to three custom habits.
- **Stay focused during workouts** — use a workout timer with Live Activity support for the Lock Screen and Dynamic Island on supported devices.
- **Follow your consistency** — review daily completion and streaks in the progress dashboard, with mode-specific reset and grace-day behavior.
- **Keep a visual record** — capture a photo scrapbook and compare progress with a before-and-after slider.
- **Keep your routine close** — use local reminders, a timer Live Activity, and light or dark appearance.

## Built with

**Swift · SwiftUI · SwiftData · WidgetKit · ActivityKit · App Intents**

Habit records are stored locally with SwiftData. Scrapbook images are saved to the filesystem. The app and widget extension use an App Group to share supported data.

## Getting started

You’ll need a Mac with Xcode and an iOS 18 SDK. An iOS 18.2 or newer simulator is a convenient choice for the app and test targets in this project.

1. Clone the repository:

   ```sh
   git clone https://github.com/11samm/GlowProtocol.git
   cd GlowProtocol
   open GlowProtocol.xcodeproj
   ```

2. Select the **GlowProtocol** scheme and an iPhone simulator or connected device.
3. For device builds, choose your development team under **Signing & Capabilities**. Update bundle identifiers and provision the shared App Group for both the app and widget targets if needed. Keep the App Group identifier consistent with the identifiers used in the source.
4. Build and run with **⌘R**.

Use a physical iPhone to validate camera capture, notifications, and Live Activity behavior. The repository includes unit and UI test targets, available through **Product → Test** in Xcode.

## Project structure

```text
GlowProtocol/
├── DesignSystem/     # Colors, typography, animations, and reusable controls
├── Features/         # Onboarding, daily tracking, progress, scrapbook, settings
├── Models/           # SwiftData records and challenge configuration
├── Services/         # Timers, streaks, photos, notifications, background tasks
└── Shared/           # Extensions and utilities
GlowProtocolWidgets/  # Timer intents and Live Activity views
GlowProtocolTests/    # Unit tests
GlowProtocolUITests/  # UI tests
```

## Development status

The repository contains the app’s tracking and progress flows and a timer Live Activity extension. Home Screen widgets are not yet included. The onboarding paywall is a **development placeholder**: unlock and restore advance onboarding without a StoreKit purchase.

The current SwiftData recovery path can recreate an incompatible local store after a migration failure. Preserve any development data you need before testing schema changes.

For product direction and development notes, see [BLUEPRINT.md](BLUEPRINT.md) and [Sprint2.md](Sprint2.md). These documents include plans beyond the implemented app.
