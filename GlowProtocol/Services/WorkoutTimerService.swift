//
//  WorkoutTimerService.swift
//  GlowProtocol
//
//  Singleton that owns the workout countdown so it survives sheet dismissal.
//  Manages the foreground Timer, the AVAudioSession (keeps ticking on lock screen),
//  and the ActivityKit Live Activity shown in the Dynamic Island and Lock Screen.
//

import Foundation
import Observation
import ActivityKit
import AVFoundation
import SwiftUI

@MainActor
@Observable
final class WorkoutTimerService {
    static let shared = WorkoutTimerService()

    // MARK: - Observable state (read by WorkoutTimerView)

    private(set) var activeEntry: HabitEntry?
    private(set) var workoutLabel: String = ""
    private(set) var totalSeconds: Int = 0
    private(set) var remainingSeconds: Int = 0
    private(set) var isPaused: Bool = false
    private(set) var completedAnimation: Bool = false

    // MARK: - Private

    private var endDate: Date?
    private var ticker: Timer?
    private var liveActivity: Activity<GlowTimerAttributes>?
    private var onFinish: ((HabitEntry, String) -> Void)?

    private let defaults = UserDefaults(suiteName: "group.sam.GlowProtocol") ?? .standard

    private init() {}

    // MARK: - Computed helpers

    var hasActiveSession: Bool { activeEntry != nil && !completedAnimation }

    func isRunning(for entry: HabitEntry) -> Bool {
        activeEntry?.persistentModelID == entry.persistentModelID
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Start

    func start(entry: HabitEntry, workoutMinutes: Int, onFinish: @escaping (HabitEntry, String) -> Void) {
        // Already running this entry — just refresh the callback, don't restart.
        if let current = activeEntry, current.persistentModelID == entry.persistentModelID {
            self.onFinish = onFinish
            return
        }

        // Different entry running — tear it down first.
        if activeEntry != nil { cleanupInternal() }

        self.activeEntry = entry
        self.workoutLabel = entry.displayLabel
        self.onFinish = onFinish
        self.totalSeconds = workoutMinutes * 60
        self.remainingSeconds = totalSeconds
        self.isPaused = false
        self.completedAnimation = false
        self.endDate = Date.now.addingTimeInterval(TimeInterval(totalSeconds))

        persistState()
        configureAudio()
        scheduleTicker()
        startLiveActivity()
    }

    // MARK: - Pause / Resume

    func pause() {
        guard !isPaused else { return }
        isPaused = true
        ticker?.invalidate()
        ticker = nil
        persistState()
        updateLiveActivity()
        HapticService.shared.play(.lightTap)
    }

    func resume() {
        guard isPaused else { return }
        isPaused = false
        endDate = Date.now.addingTimeInterval(TimeInterval(remainingSeconds))
        persistState()
        scheduleTicker()
        updateLiveActivity()
        HapticService.shared.play(.lightTap)
    }

    func togglePause() {
        if isPaused { resume() } else { pause() }
    }

    // MARK: - End session (abandon without completing)

    func endSession() {
        cleanupInternal()
    }

    // MARK: - Sync from Live Activity intents

    /// Call this whenever the app comes to the foreground to pick up any
    /// pause/resume that was triggered via the Dynamic Island or Lock Screen.
    func syncFromIntent() {
        guard activeEntry != nil else { return }

        let intentPaused = defaults.bool(forKey: "glowTimerPausedByIntent")
        let intentResumed = defaults.bool(forKey: "glowTimerResumedByIntent")

        if intentPaused && !isPaused {
            defaults.removeObject(forKey: "glowTimerPausedByIntent")
            if let end = endDate, end.timeIntervalSinceNow < 86_400 {
                remainingSeconds = max(0, Int(end.timeIntervalSince(Date.now).rounded()))
            }
            isPaused = true
            ticker?.invalidate()
            ticker = nil
            persistState()
        } else if intentResumed && isPaused {
            defaults.removeObject(forKey: "glowTimerResumedByIntent")
            isPaused = false
            endDate = Date.now.addingTimeInterval(TimeInterval(remainingSeconds))
            persistState()
            scheduleTicker()
        }
    }

    // MARK: - Private: ticker

    private func scheduleTicker() {
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }

    private func tick() {
        guard !isPaused, let end = endDate else { return }
        let remaining = max(0, Int(end.timeIntervalSince(Date.now).rounded()))
        remainingSeconds = remaining
        if remaining <= 0 { finish() }
    }

    // MARK: - Private: finish

    private func finish() {
        ticker?.invalidate()
        ticker = nil

        guard let entry = activeEntry else {
            cleanupInternal()
            return
        }

        HapticService.shared.play(.timerFinish)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            completedAnimation = true
        }

        let metadata = "{\"secondsElapsed\":\(totalSeconds)}"
        onFinish?(entry, metadata)

        endLiveActivity()
        clearPersistedState()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.activeEntry = nil
            self?.completedAnimation = false
            self?.teardownAudio()
        }
    }

    private func cleanupInternal() {
        ticker?.invalidate()
        ticker = nil
        endLiveActivity()
        activeEntry = nil
        isPaused = false
        completedAnimation = false
        endDate = nil
        onFinish = nil
        teardownAudio()
        clearPersistedState()
    }

    // MARK: - Private: state persistence (App Group UserDefaults)

    private func persistState() {
        defaults.set(endDate?.timeIntervalSince1970, forKey: "glowActiveTimerEndDate")
        defaults.set(remainingSeconds, forKey: "glowActiveTimerRemaining")
        defaults.set(isPaused, forKey: "glowActiveTimerPaused")
        defaults.set(totalSeconds, forKey: "glowActiveTimerTotal")
        defaults.set(workoutLabel, forKey: "glowActiveTimerLabel")
    }

    private func clearPersistedState() {
        ["glowActiveTimerEndDate", "glowActiveTimerRemaining",
         "glowActiveTimerPaused", "glowActiveTimerTotal", "glowActiveTimerLabel"]
            .forEach { defaults.removeObject(forKey: $0) }
    }

    // MARK: - Private: audio session

    private func configureAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Non-fatal; the visible countdown still ticks while foregrounded.
        }
    }

    private func teardownAudio() {
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    // MARK: - Private: Live Activity

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // Snapshot any stale activities from a previous run *before* requesting the
        // new one. The cleanup below must never enumerate `activities` after the
        // request, otherwise it would immediately end the activity we just created.
        let staleActivities = Activity<GlowTimerAttributes>.activities

        let attributes = GlowTimerAttributes(
            workoutLabel: workoutLabel,
            totalSeconds: totalSeconds
        )
        let state = GlowTimerAttributes.ContentState(
            endDate: endDate ?? Date.now.addingTimeInterval(TimeInterval(totalSeconds)),
            remainingSeconds: totalSeconds,
            isPaused: false
        )
        do {
            liveActivity = try Activity<GlowTimerAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Non-fatal — in-app timer still works.
            return
        }

        // End only the previously-existing activities, never the new one.
        let newID = liveActivity?.id
        if !staleActivities.isEmpty {
            Task {
                for stale in staleActivities where stale.id != newID {
                    await stale.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }

    private func updateLiveActivity() {
        guard let liveActivity else { return }
        let state = GlowTimerAttributes.ContentState(
            endDate: isPaused ? .distantFuture : (endDate ?? .distantFuture),
            remainingSeconds: remainingSeconds,
            isPaused: isPaused
        )
        Task {
            await liveActivity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = liveActivity else { return }
        liveActivity = nil
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
