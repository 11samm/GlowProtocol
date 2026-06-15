//
//  GlowTimerLiveActivity.swift
//  GlowProtocolWidgets
//
//  Renders the workout timer on:
//    • Lock Screen / Notification banner (ActivityConfiguration leading closure)
//    • Dynamic Island compact leading/trailing
//    • Dynamic Island expanded (all three regions)
//    • Dynamic Island minimal
//
//  Text(timerInterval:countsDown:) is used for the running countdown — iOS renders
//  this natively without the app process needing to be alive.
//  When the timer is paused, endDate is set to Date.distantFuture by the service/intent
//  and the UI falls back to a static formatted string using remainingSeconds.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Shared helpers

private func timeString(_ seconds: Int) -> String {
    String(format: "%02d:%02d", seconds / 60, seconds % 60)
}

private func ringProgress(state: GlowTimerAttributes.ContentState, totalSeconds: Int) -> Double {
    let total = Double(totalSeconds)
    guard total > 0 else { return 0 }
    let remaining: Double = state.isPaused
        ? Double(state.remainingSeconds)
        : max(0, state.endDate.timeIntervalSince(Date.now))
    return max(0, min(1, 1.0 - (remaining / total)))
}

// MARK: - Progress ring (self-contained, no asset dependencies)

private struct LiveActivityRing: View {
    let progress: Double
    let isPaused: Bool
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    isPaused ? Color.white.opacity(0.45) : Color.white,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        // The stroke is centered on the circle's path, so half of `lineWidth`
        // overflows the frame and gets clipped (most visibly on the right edge).
        // Inset by half the line width so the whole ring fits inside its frame.
        .padding(lineWidth / 2)
    }
}

// MARK: - Lock Screen view

private struct LockScreenView: View {
    let context: ActivityViewContext<GlowTimerAttributes>

    var progress: Double { ringProgress(state: context.state, totalSeconds: context.attributes.totalSeconds) }

    var body: some View {
        HStack(spacing: 14) {
            LiveActivityRing(progress: progress, isPaused: context.state.isPaused, lineWidth: 5)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(context.attributes.workoutLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                countdownText
                    .font(.system(size: 30, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Text(context.state.isPaused ? "paused" : "remaining")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            pauseResumeButton
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var countdownText: some View {
        if context.state.isPaused {
            Text(timeString(context.state.remainingSeconds))
        } else {
            Text(timerInterval: Date.now...(context.state.endDate), countsDown: true)
        }
    }

    @ViewBuilder
    private var pauseResumeButton: some View {
        if context.state.isPaused {
            Button(intent: ResumeWorkoutTimerIntent()) {
                Image(systemName: "play.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.secondary.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
        } else {
            Button(intent: PauseWorkoutTimerIntent()) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.secondary.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Widget

struct GlowTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlowTimerAttributes.self) { context in
            LockScreenView(context: context)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: Expanded — leading
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.workoutLabel)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(context.state.isPaused ? "paused" : "remaining")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.leading, 6)
                    .padding(.top, 8)
                }

                // MARK: Expanded — trailing (progress ring)
                DynamicIslandExpandedRegion(.trailing) {
                    LiveActivityRing(
                        progress: ringProgress(state: context.state, totalSeconds: context.attributes.totalSeconds),
                        isPaused: context.state.isPaused,
                        lineWidth: 4
                    )
                    .frame(width: 38, height: 38)
                    .padding(.trailing, 6)
                    .padding(.top, 8)
                }

                // MARK: Expanded — bottom (countdown + pause/resume)
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 0) {
                        expandedCountdown(context: context)
                            .font(.system(size: 36, weight: .thin, design: .monospaced))
                            .foregroundStyle(.white)
                            .monospacedDigit()

                        Spacer(minLength: 12)

                        if context.state.isPaused {
                            Button(intent: ResumeWorkoutTimerIntent()) {
                                HStack(spacing: 5) {
                                    Image(systemName: "play.fill")
                                    Text("Resume")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.white, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button(intent: PauseWorkoutTimerIntent()) {
                                HStack(spacing: 5) {
                                    Image(systemName: "pause.fill")
                                    Text("Pause")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.white, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                }
            } compactLeading: {
                LiveActivityRing(
                    progress: ringProgress(state: context.state, totalSeconds: context.attributes.totalSeconds),
                    isPaused: context.state.isPaused,
                    lineWidth: 3
                )
                .frame(width: 22, height: 22)
                .padding(.leading, 2)
            } compactTrailing: {
                compactCountdown(context: context)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    // `Text(timerInterval:)` reserves generous width for the widest
                    // possible value, which leaves a large empty gap in the compact
                    // trailing slot. Clamp it to the width of "MM:SS".
                    .frame(width: 52, alignment: .trailing)
                    .padding(.trailing, 2)
            } minimal: {
                compactCountdown(context: context)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .widgetURL(URL(string: "glowprotocol://timer"))
            .keylineTint(.white.opacity(0.25))
        }
    }

    @ViewBuilder
    private func compactCountdown(context: ActivityViewContext<GlowTimerAttributes>) -> some View {
        if context.state.isPaused {
            Text(timeString(context.state.remainingSeconds))
        } else {
            Text(timerInterval: Date.now...(context.state.endDate), countsDown: true)
        }
    }

    @ViewBuilder
    private func expandedCountdown(context: ActivityViewContext<GlowTimerAttributes>) -> some View {
        if context.state.isPaused {
            Text(timeString(context.state.remainingSeconds))
        } else {
            Text(timerInterval: Date.now...(context.state.endDate), countsDown: true)
        }
    }
}
