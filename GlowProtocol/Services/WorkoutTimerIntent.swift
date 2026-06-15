//
//  WorkoutTimerIntent.swift
//  GlowProtocol
//
//  App-target copy of the Pause/Resume LiveActivityIntents.
//
//  IMPORTANT: A `LiveActivityIntent` is always executed in the *app's* process,
//  not the widget extension. For that to work the intent type must be a member of
//  the app target. The widget extension keeps its own identical copy purely so the
//  `Button(intent:)` controls in the Live Activity UI can compile and reference the
//  same intent type name. When the button is tapped, iOS runs THIS copy in-process,
//  where `Activity<GlowTimerAttributes>.activities` resolves to the same type the
//  app used to request the activity — so the lookup and `update(_:)` succeed and the
//  Dynamic Island / Lock Screen reflect the change immediately.
//

import AppIntents
import ActivityKit
import Foundation

// MARK: - Pause

struct PauseWorkoutTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Pause Workout Timer"
    static let description = IntentDescription("Pauses the running workout timer.")
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.sam.GlowProtocol") ?? .standard
        defaults.set(true, forKey: "glowTimerPausedByIntent")
        defaults.removeObject(forKey: "glowTimerResumedByIntent")

        if let activity = Activity<GlowTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let remaining = max(0, Int(currentState.endDate.timeIntervalSince(Date.now).rounded()))
            let newState = GlowTimerAttributes.ContentState(
                endDate: .distantFuture,
                remainingSeconds: remaining,
                isPaused: true
            )
            await activity.update(ActivityContent(state: newState, staleDate: nil))
        }

        await WorkoutTimerService.shared.syncFromIntent()
        return .result()
    }
}

// MARK: - Resume

struct ResumeWorkoutTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Resume Workout Timer"
    static let description = IntentDescription("Resumes a paused workout timer.")
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.sam.GlowProtocol") ?? .standard
        defaults.set(true, forKey: "glowTimerResumedByIntent")
        defaults.removeObject(forKey: "glowTimerPausedByIntent")

        if let activity = Activity<GlowTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let newEnd = Date.now.addingTimeInterval(TimeInterval(currentState.remainingSeconds))
            let newState = GlowTimerAttributes.ContentState(
                endDate: newEnd,
                remainingSeconds: currentState.remainingSeconds,
                isPaused: false
            )
            await activity.update(ActivityContent(state: newState, staleDate: nil))
        }

        await WorkoutTimerService.shared.syncFromIntent()
        return .result()
    }
}
