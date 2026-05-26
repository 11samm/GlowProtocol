//
//  HabitCustomizerView.swift
//  GlowProtocol
//
//  Step 3 — toggle the default habits + optional custom inputs.
//

import SwiftUI

struct HabitCustomizerView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                navBar
                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                        Text("Your daily\nhabits.")
                            .font(.glowSerif(size: 32, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .padding(.top, GlowSpacing.s24)
                        Text("These are your non-negotiables. Toggle off anything that doesn't fit your life right now.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)
                            .padding(.bottom, GlowSpacing.s8)

                        defaultHabitsCard
                            .padding(.top, GlowSpacing.s16)

                        Text("ADD YOUR OWN")
                            .glowText(.badge)
                            .foregroundStyle(Color.glowTextSecondary)
                            .tracking(1)
                            .padding(.top, GlowSpacing.s24)

                        VStack(spacing: GlowSpacing.s8) {
                            customField(text: $viewModel.custom1)
                            customField(text: $viewModel.custom2)
                            customField(text: $viewModel.custom3)
                        }

                        if !viewModel.canContinueFromHabits {
                            Text("Enable at least 4 habits to continue")
                                .glowText(.caption)
                                .foregroundStyle(Color.glowDestructive)
                                .padding(.top, GlowSpacing.s8)
                        }
                    }
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, 120)
                }
                GlowButton(
                    title: "Confirm habits",
                    enabled: viewModel.canContinueFromHabits
                ) {
                    onConfirm()
                }
                .padding(.horizontal, GlowSpacing.s16)
                .padding(.bottom, GlowSpacing.s24)
            }
        }
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
            Text("Customize")
                .glowText(.headline)
                .foregroundStyle(Color.glowTextPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }

    private var defaultHabitsCard: some View {
        VStack(spacing: 0) {
            habitToggleRow(
                id: .workout1,
                title: "Workout",
                detail: "\(viewModel.workoutMinutes) min · \(viewModel.workoutCount)× daily",
                isOn: $viewModel.workoutEnabled
            )
            divider
            habitToggleRow(
                id: .water,
                title: "Water",
                detail: "1 gallon / day",
                isOn: $viewModel.waterEnabled
            )
            divider
            habitToggleRow(
                id: .diet,
                title: "Stick to diet",
                detail: "Your chosen plan",
                isOn: $viewModel.dietEnabled
            )
            divider
            habitToggleRow(
                id: .reading,
                title: "Reading",
                detail: "\(viewModel.readingPages) pages",
                isOn: $viewModel.readingEnabled
            )
            divider
            habitToggleRow(
                id: .steps,
                title: "10,000 steps",
                detail: "Manual confirmation",
                isOn: $viewModel.stepsEnabled
            )
            divider
            habitToggleRow(
                id: .noAlcohol,
                title: "No alcohol",
                detail: "Discipline",
                isOn: $viewModel.noAlcoholEnabled
            )
            divider
            habitToggleRow(
                id: .progressPhoto,
                title: "Progress photo",
                detail: "Daily reflection",
                isOn: $viewModel.photoEnabled
            )
        }
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .fill(Color.glowSurface)
        )
        .glowCardShadow()
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.glowDivider)
            .frame(height: 1)
            .padding(.leading, 68)
    }

    private func habitToggleRow(id: HabitID, title: String, detail: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(id.pastel).frame(width: 36, height: 36)
                Image(systemName: id.symbolName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.glowTextPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .glowText(.headline)
                    .foregroundStyle(Color.glowTextPrimary)
                Text(detail)
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
            }
            Spacer()
            GlowToggle(isOn: isOn)
        }
        .padding(.horizontal, GlowSpacing.s16)
        .frame(minHeight: 72)
    }

    private func customField(text: Binding<String>) -> some View {
        HStack {
            TextField("Custom habit (optional)", text: text)
                .glowText(.body)
                .foregroundStyle(Color.glowTextPrimary)
                .submitLabel(.done)
                .onChange(of: text.wrappedValue) { _, newValue in
                    if newValue.count > 40 {
                        text.wrappedValue = String(newValue.prefix(40))
                    }
                }
            if !text.wrappedValue.isEmpty {
                Text("\(text.wrappedValue.count) / 40")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
                Button {
                    text.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.glowTextSecondary)
                }
            } else {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.glowTextSecondary)
            }
        }
        .padding(.horizontal, GlowSpacing.s16)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .fill(Color.glowSurfaceSecondary)
        )
    }
}
