//
//  WorkoutTimerView.swift
//  GlowProtocol
//
//  Full-screen workout countdown sheet.
//  All timer state lives in WorkoutTimerService — this view is purely presentational.
//  Swiping the sheet down is allowed at any time; the timer keeps ticking in the
//  service until the user either completes the workout or taps "End Session".
//

import SwiftUI

struct WorkoutTimerView: View {
    let entry: HabitEntry
    @Bindable var viewModel: DailyGlowViewModel
    @Environment(\.dismiss) private var dismiss

    private var service: WorkoutTimerService { WorkoutTimerService.shared }

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
                        progress: service.progress,
                        lineWidth: 12,
                        trackColor: .glowSurfaceSecondary,
                        fillColor: .glowTextPrimary,
                        animation: .linear(duration: 1)
                    )
                    .frame(width: 240, height: 240)

                    if service.completedAnimation {
                        CheckmarkView(isComplete: true, size: 120, pastel: .glowDivider)
                    } else {
                        VStack(spacing: 6) {
                            Text(service.timeString)
                                .font(.glowMono(size: 48, weight: .regular))
                                .foregroundStyle(Color.glowTextPrimary)
                                .monospacedDigit()
                            Text(service.isPaused ? "paused" : "remaining")
                                .glowText(.caption)
                                .foregroundStyle(Color.glowTextSecondary)
                        }
                    }
                }

                if service.completedAnimation {
                    Text("Workout complete")
                        .glowText(.headline)
                        .foregroundStyle(Color.glowTextPrimary)
                        .padding(.top, GlowSpacing.s8)
                }

                Spacer()

                if !service.completedAnimation {
                    HStack(spacing: 12) {
                        GlowButton(title: service.isPaused ? "Resume" : "Pause", style: .secondary) {
                            service.togglePause()
                        }
                        GlowButton(title: "End Session", style: .ghost) {
                            service.endSession()
                            dismiss()
                        }
                    }
                    .padding(.horizontal, GlowSpacing.s24)

                    Text("Swipe down — timer keeps running")
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextDisabled)
                        .padding(.bottom, GlowSpacing.s24)
                }
            }
            .padding(.top, GlowSpacing.s24)
        }
        .onAppear(perform: attachOrStart)
        .onChange(of: service.completedAnimation) { _, completed in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }

    private func attachOrStart() {
        guard !service.isRunning(for: entry) else { return }
        service.start(
            entry: entry,
            workoutMinutes: viewModel.config?.workoutMinutes ?? 45
        ) { [weak viewModel] completedEntry, metadata in
            viewModel?.completeHabit(completedEntry, metadata: metadata)
        }
    }
}
