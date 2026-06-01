//
//  ProtocolSummaryView.swift
//  GlowProtocol
//
//  Step 11 — a full review of the protocol the user just built, right before
//  the paywall. They can see exactly what they're about to commit to.
//

import SwiftUI

/// A display-ready habit row used by the summary and paywall screens.
struct OnboardingHabitDisplay: Identifiable {
    let id: String
    let symbol: String
    let color: Color
    let label: String
}

struct ProtocolSummaryView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar

                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s24) {
                        Text(headline)
                            .font(.glowSerif(size: 32, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, GlowSpacing.s24)

                        summaryCard

                        Text("This is what you committed to. Let's make it real.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, 120)
                }

                GlowButton(title: "Make it official  →", action: onContinue)
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, GlowSpacing.s24)
            }
        }
    }

    private var headline: String {
        "\(viewModel.possessiveName) 75-day protocol."
    }

    private var summaryCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: GlowSpacing.s12) {
                Text(difficultyName.uppercased())
                    .glowText(.badge)
                    .foregroundStyle(Color.glowSurface)
                    .padding(.horizontal, GlowSpacing.s12)
                    .frame(height: 24)
                    .background(Capsule().fill(Color.glowTextPrimary))
                Text("75 days · \(viewModel.enabledCount) daily habits")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
                Spacer()
            }
            .padding(GlowSpacing.s16)

            divider

            VStack(spacing: 0) {
                ForEach(Array(viewModel.summaryHabits.enumerated()), id: \.element.id) { index, habit in
                    if index > 0 { divider }
                    habitRow(habit)
                }
            }

            divider

            HStack(spacing: GlowSpacing.s12) {
                ZStack {
                    Circle().fill(Color.glowGracePulse.opacity(0.5)).frame(width: 36, height: 36)
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.glowTextPrimary)
                }
                Text(graceText)
                    .glowText(.subheadline)
                    .foregroundStyle(Color.glowTextPrimary)
                Spacer()
            }
            .padding(.horizontal, GlowSpacing.s16)
            .frame(minHeight: 56)
        }
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.large, style: .continuous)
                .fill(Color.glowSurface)
        )
        .glowCardShadow()
    }

    private func habitRow(_ habit: OnboardingHabitDisplay) -> some View {
        HStack(spacing: GlowSpacing.s12) {
            ZStack {
                Circle().fill(habit.color).frame(width: 36, height: 36)
                Image(systemName: habit.symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.glowTextPrimary)
            }
            Text(habit.label)
                .glowText(.subheadline)
                .foregroundStyle(Color.glowTextPrimary)
            Spacer()
        }
        .padding(.horizontal, GlowSpacing.s16)
        .frame(minHeight: 56)
    }

    private var difficultyName: String {
        (viewModel.preset ?? .hard).displayName + " Protocol"
    }

    private var graceText: String {
        let days = viewModel.graceDays
        if days <= 0 { return "No grace days" }
        return "\(days) grace day\(days == 1 ? "" : "s") / month"
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.glowDivider)
            .frame(height: 1)
            .padding(.leading, 64)
    }

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.glowTextPrimary)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, GlowSpacing.s4)
    }
}
