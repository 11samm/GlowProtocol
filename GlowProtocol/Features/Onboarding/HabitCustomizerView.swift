//
//  HabitCustomizerView.swift
//  GlowProtocol
//
//  Step 3 — toggle the default habits + custom habit builder rows with icon/color picker.
//

import SwiftUI

struct HabitCustomizerView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onConfirm: () -> Void

    @State private var iconPickerTarget: IconPickerSlot? = nil

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
                            customHabitBuilderRow(
                                text: $viewModel.custom1,
                                icon: $viewModel.customIcon1,
                                colorHex: $viewModel.customColor1,
                                slot: 1
                            )
                            customHabitBuilderRow(
                                text: $viewModel.custom2,
                                icon: $viewModel.customIcon2,
                                colorHex: $viewModel.customColor2,
                                slot: 2
                            )
                            customHabitBuilderRow(
                                text: $viewModel.custom3,
                                icon: $viewModel.customIcon3,
                                colorHex: $viewModel.customColor3,
                                slot: 3
                            )
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
        .sheet(item: $iconPickerTarget) { target in
            iconPickerSheet(for: target)
        }
    }

    // MARK: - Icon picker sheet builder

    @ViewBuilder
    private func iconPickerSheet(for target: IconPickerSlot) -> some View {
        switch target.id {
        case 1:
            CustomHabitIconPickerSheet(
                selectedSymbol: $viewModel.customIcon1,
                selectedColorHex: $viewModel.customColor1
            ) { iconPickerTarget = nil }
        case 2:
            CustomHabitIconPickerSheet(
                selectedSymbol: $viewModel.customIcon2,
                selectedColorHex: $viewModel.customColor2
            ) { iconPickerTarget = nil }
        default:
            CustomHabitIconPickerSheet(
                selectedSymbol: $viewModel.customIcon3,
                selectedColorHex: $viewModel.customColor3
            ) { iconPickerTarget = nil }
        }
    }

    // MARK: - Custom habit builder row

    private func customHabitBuilderRow(
        text: Binding<String>,
        icon: Binding<String>,
        colorHex: Binding<String>,
        slot: Int
    ) -> some View {
        HStack(spacing: 14) {
            // Icon circle
            let hasText = !text.wrappedValue.isEmpty
            Button {
                if hasText {
                    iconPickerTarget = IconPickerSlot(id: slot)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(hasText ? Color(hex: colorHex.wrappedValue) : Color.glowSurfaceSecondary)
                        .frame(width: 36, height: 36)
                    Image(systemName: hasText ? icon.wrappedValue : "plus.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(hasText ? Color.glowTextPrimary : Color.glowTextDisabled)
                }
            }
            .buttonStyle(.plain)
            .disabled(!hasText)
            .animation(.spring(response: 0.3, dampingFraction: 0.72), value: hasText)

            // Text field
            TextField("Custom habit (optional)", text: text)
                .glowText(.body)
                .foregroundStyle(Color.glowTextPrimary)
                .submitLabel(.done)
                .onChange(of: text.wrappedValue) { _, newValue in
                    if newValue.count > 40 {
                        text.wrappedValue = String(newValue.prefix(40))
                    }
                    // Reset icon/color to defaults when field is cleared
                    if newValue.isEmpty {
                        icon.wrappedValue = "star.fill"
                        colorHex.wrappedValue = "#E0E0E0"
                    }
                }

            // Counter / clear
            if !text.wrappedValue.isEmpty {
                Text("\(text.wrappedValue.count) / 40")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
                Button {
                    text.wrappedValue = ""
                    icon.wrappedValue = "star.fill"
                    colorHex.wrappedValue = "#E0E0E0"
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.glowTextSecondary)
                }
            }
        }
        .padding(.horizontal, GlowSpacing.s16)
        .frame(minHeight: 72)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .fill(Color.glowSurfaceSecondary)
        )
    }

    // MARK: - Default habits card

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
}

// MARK: - Supporting type

struct IconPickerSlot: Identifiable {
    let id: Int
}
