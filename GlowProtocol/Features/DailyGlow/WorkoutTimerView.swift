//
//  WorkoutTimerView.swift
//  GlowProtocol
//
//  Full-screen workout countdown with background-audio session for lock-screen continuity.
//

import SwiftUI
import AVFoundation

struct WorkoutTimerView: View {
    let entry: HabitEntry
    @Bindable var viewModel: DailyGlowViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var totalSeconds: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var isPaused: Bool = false
    @State private var endDate: Date?
    @State private var timer: Timer?
    @State private var completedAnimation: Bool = false

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            VStack(spacing: GlowSpacing.s24) {
                GlowSheetHandle()
                Text(entry.displayLabel)
                    .glowText(.headline)
                    .foregroundStyle(Color.glowTextSecondary)

                Spacer()

                ZStack {
                    ProgressRing(
                        progress: progress,
                        lineWidth: 12,
                        trackColor: .glowSurfaceSecondary,
                        fillColor: .glowTextPrimary,
                        animation: .linear(duration: 1)
                    )
                    .frame(width: 240, height: 240)

                    if completedAnimation {
                        CheckmarkView(isComplete: true, size: 120, pastel: .glowDivider)
                    } else {
                        VStack(spacing: 6) {
                            Text(timeString)
                                .font(.glowMono(size: 48, weight: .regular))
                                .foregroundStyle(Color.glowTextPrimary)
                                .monospacedDigit()
                            Text(isPaused ? "paused" : "remaining")
                                .glowText(.caption)
                                .foregroundStyle(Color.glowTextSecondary)
                        }
                    }
                }

                if completedAnimation {
                    Text("Workout complete")
                        .glowText(.headline)
                        .foregroundStyle(Color.glowTextPrimary)
                        .padding(.top, GlowSpacing.s8)
                }

                Spacer()

                if !completedAnimation {
                    HStack(spacing: 12) {
                        GlowButton(title: isPaused ? "Resume" : "Pause", style: .secondary) {
                            togglePause()
                        }
                        GlowButton(title: "End Session", style: .ghost) {
                            endSession()
                        }
                    }
                    .padding(.horizontal, GlowSpacing.s24)

                    Text("Leave this screen — timer keeps running")
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextDisabled)
                        .padding(.bottom, GlowSpacing.s24)
                }
            }
            .padding(.top, GlowSpacing.s24)
        }
        .interactiveDismissDisabled(!completedAnimation)
        .onAppear(perform: start)
        .onDisappear(perform: stop)
    }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    private var timeString: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func start() {
        let minutes = viewModel.config?.workoutMinutes ?? 45
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
        endDate = Date.now.addingTimeInterval(TimeInterval(totalSeconds))
        configureAudio()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in self.tick() }
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        teardownAudio()
    }

    private func tick() {
        guard !isPaused else { return }
        guard let end = endDate else { return }
        let now = Date.now
        let remaining = max(0, Int(end.timeIntervalSince(now).rounded()))
        remainingSeconds = remaining
        if remaining <= 0 {
            finish()
        }
    }

    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
            HapticService.shared.play(.lightTap)
        } else {
            endDate = Date.now.addingTimeInterval(TimeInterval(remainingSeconds))
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                Task { @MainActor in self.tick() }
            }
            HapticService.shared.play(.lightTap)
        }
    }

    private func endSession() {
        timer?.invalidate()
        dismiss()
    }

    private func finish() {
        timer?.invalidate()
        HapticService.shared.play(.timerFinish)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            completedAnimation = true
        }
        viewModel.completeHabit(entry, metadata: #"{"secondsElapsed":\#(totalSeconds)}"#)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }

    // MARK: - Background audio (keeps the timer alive when the screen is locked)

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
}
