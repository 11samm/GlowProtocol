//
//  WorkoutTimerIntent.swift
//  GlowProtocolWidgets
//
//  AppIntents that power the Pause and Resume buttons embedded in the Live Activity.
//  They run inside the widget extension process (no app launch needed), write a sync
//  flag to the shared App Group UserDefaults, and update the Activity ContentState
//  directly so the Dynamic Island / Lock Screen reflects the change immediately.
//
//  The main app's WorkoutTimerService reads these flags via syncFromIntent() whenever
//  the app comes to the foreground and mirrors the pause state in-process.
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

        return .result()
    }
}
