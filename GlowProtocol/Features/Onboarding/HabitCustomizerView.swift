//
//  HabitCustomizerView.swift
//  GlowProtocol
//
//  Step 3 — toggle habits + custom habit builder.
//  Hard: all habits locked on, two workout rows, pencil icon to edit descriptions.
//  Medium/Soft: toggles + pencil icon to edit descriptions.
//  All difficulties: HabitEditCard overlay for description editing with suggestion chips.
//

import SwiftUI

// MARK: - EditableHabit

/// Represents a habit row that can have its description edited.
private enum EditableHabit: Identifiable {
    case water
    case reading
    case workout1
    case workout2
    case diet

    var id: String {
        switch self {
        case .water: return "water"
        case .reading: return "reading"
        case .workout1: return "workout1"
        case .workout2: return "workout2"
        case .diet: return "diet"
        }
    }

    var title: String {
        switch self {
        case .water: return "Water"
        case .reading: return "Reading"
        case .workout1: return "Workout 1"
        case .workout2: return "Workout 2"
        case .diet: return "Diet"
        }
    }

    var suggestions: [String] {
        switch self {
        case .water: return ["1 non-water drink allowed per week"]
        case .reading: return ["Reading the Bible", "Audiobooks count"]
        case .workout1: return ["Outdoors not required"]
        case .workout2: return ["45 min", "60 min"]
        case .diet: return ["Cheat meal once per week"]
        }
    }

    func currentDetail(in viewModel: OnboardingViewModel) -> String {
        switch self {
        case .water: return viewModel.hardWaterDetail
        case .reading: return viewModel.hardReadingDetail
        case .workout1: return viewModel.workout1Detail
        case .workout2: return viewModel.hardWorkout2Detail
        case .diet: return viewModel.hardDietDetail
        }
    }

    func applyDetail(_ text: String, to viewModel: OnboardingViewModel) {
        switch self {
        case .water:
            viewModel.hardWaterDetail = text
        case .reading:
            viewModel.hardReadingDetail = text
        case .workout1:
            viewModel.workout1Outdoors = text.localizedCaseInsensitiveContains("outdoor")
            if !text.localizedCaseInsensitiveContains("outdoor") && viewModel.workout1Outdoors {
                viewModel.workout1Outdoors = false
            }
        case .workout2:
            viewModel.hardWorkout2Detail = text
        case .diet:
            viewModel.hardDietDetail = text
        }
    }
}

// MARK: - HabitCustomizerView

struct HabitCustomizerView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onConfirm: () -> Void

    @State private var iconPickerTarget: IconPickerSlot? = nil
    @State private var editingHabit: EditableHabit? = nil
    @State private var editText: String = ""

    private let editSpring = Animation.spring(response: 0.38, dampingFraction: 0.78)

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar
                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                        Text("\(viewModel.possessiveName)\nnon-negotiables.")
                            .font(.glowSerif(size: 32, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .padding(.top, GlowSpacing.s24)

                        Text(descriptionText)
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
            .allowsHitTesting(editingHabit == nil)

            // Edit overlay — dimmed background + card
            if editingHabit != nil {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(editSpring) { editingHabit = nil }
                    }
                    .transition(.opacity)

                HabitEditCard(
                    habit: editingHabit!,
                    editText: $editText,
                    onCancel: {
                        withAnimation(editSpring) { editingHabit = nil }
                    },
                    onSave: {
                        editingHabit?.applyDetail(editText, to: viewModel)
                        withAnimation(editSpring) { editingHabit = nil }
                    },
                    onSuggestion: { chip in
                        editText = chip
                    }
                )
                .transition(.scale(scale: 0.95).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(editSpring, value: editingHabit?.id)
        .sheet(item: $iconPickerTarget) { target in
            iconPickerSheet(for: target)
        }
    }

    // MARK: - Description text

    private var descriptionText: String {
        viewModel.isHard
            ? "All habits are required. Tap any row to edit its description."
            : "Toggle habits on or off, and tap any row to customize its description."
    }

    // MARK: - Edit helper

    private func beginEditing(_ habit: EditableHabit) {
        editText = habit.currentDetail(in: viewModel)
        withAnimation(editSpring) { editingHabit = habit }
    }

    // MARK: - Default habits card

    @ViewBuilder
    private var defaultHabitsCard: some View {
        if viewModel.isHard {
            hardHabitsCard
        } else {
            mediumSoftHabitsCard
        }
    }

    // MARK: Hard card — locked rows, two workout entries, pencil icons

    private var hardHabitsCard: some View {
        VStack(spacing: 0) {
            // Workout 1
            lockedHabitRow(
                id: .workout1,
                title: "Workout 1",
                detail: viewModel.workout1Detail,
                editTarget: .workout1
            )
            divider
            // Workout 2
            lockedHabitRow(
                id: .workout2,
                title: "Workout 2",
                detail: viewModel.hardWorkout2Detail,
                editTarget: .workout2
            )
            divider
            lockedHabitRow(
                id: .water,
                title: "Water",
                detail: viewModel.hardWaterDetail,
                editTarget: .water
            )
            divider
            lockedHabitRow(
                id: .diet,
                title: "Stick to diet",
                detail: viewModel.hardDietDetail,
                editTarget: .diet
            )
            divider
            lockedHabitRow(
                id: .reading,
                title: "Reading",
                detail: viewModel.hardReadingDetail,
                editTarget: .reading
            )
            divider
            lockedHabitRow(
                id: .steps,
                title: "10,000 steps",
                detail: "Manual confirmation",
                editTarget: nil
            )
            divider
            lockedHabitRow(
                id: .noAlcohol,
                title: "No alcohol",
                detail: "Discipline",
                editTarget: nil
            )
            divider
            lockedHabitRow(
                id: .progressPhoto,
                title: "Progress photo",
                detail: "Daily reflection",
                editTarget: nil
            )
        }
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .fill(Color.glowSurface)
        )
        .glowCardShadow()
    }

    private func lockedHabitRow(
        id: HabitID,
        title: String,
        detail: String,
        editTarget: EditableHabit?
    ) -> some View {
        Button {
            if let target = editTarget { beginEditing(target) }
        } label: {
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
                if editTarget != nil {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.glowTextSecondary)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, GlowSpacing.s16)
            .frame(minHeight: 72)
        }
        .buttonStyle(.plain)
        .disabled(editTarget == nil)
    }

    // MARK: Medium/Soft card — toggles + pencil icons

    private var mediumSoftHabitsCard: some View {
        VStack(spacing: 0) {
            habitToggleRow(
                id: .workout1,
                title: "Workout",
                detail: "\(viewModel.workoutMinutes) min · \(viewModel.workoutCount)× daily",
                isOn: $viewModel.workoutEnabled,
                editTarget: nil
            )
            divider
            habitToggleRow(
                id: .water,
                title: "Water",
                detail: viewModel.hardWaterDetail,
                isOn: $viewModel.waterEnabled,
                editTarget: .water
            )
            divider
            habitToggleRow(
                id: .diet,
                title: "Stick to diet",
                detail: viewModel.hardDietDetail,
                isOn: $viewModel.dietEnabled,
                editTarget: .diet
            )
            divider
            habitToggleRow(
                id: .reading,
                title: "Reading",
                detail: viewModel.hardReadingDetail,
                isOn: $viewModel.readingEnabled,
                editTarget: .reading
            )
            divider
            habitToggleRow(
                id: .steps,
                title: "10,000 steps",
                detail: "Manual confirmation",
                isOn: $viewModel.stepsEnabled,
                editTarget: nil
            )
            divider
            habitToggleRow(
                id: .noAlcohol,
                title: "No alcohol",
                detail: "Discipline",
                isOn: $viewModel.noAlcoholEnabled,
                editTarget: nil
            )
            divider
            habitToggleRow(
                id: .progressPhoto,
                title: "Progress photo",
                detail: "Daily reflection",
                isOn: $viewModel.photoEnabled,
                editTarget: nil
            )
        }
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .fill(Color.glowSurface)
        )
        .glowCardShadow()
    }

    private func habitToggleRow(
        id: HabitID,
        title: String,
        detail: String,
        isOn: Binding<Bool>,
        editTarget: EditableHabit?
    ) -> some View {
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
            if let target = editTarget {
                Button {
                    beginEditing(target)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.glowTextSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            GlowToggle(isOn: isOn)
        }
        .padding(.horizontal, GlowSpacing.s16)
        .frame(minHeight: 72)
    }

    // MARK: - Shared helpers

    private var divider: some View {
        Rectangle()
            .fill(Color.glowDivider)
            .frame(height: 1)
            .padding(.leading, 68)
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

    // MARK: - Icon picker sheet

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
            let hasText = !text.wrappedValue.isEmpty
            Button {
                if hasText { iconPickerTarget = IconPickerSlot(id: slot) }
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

            TextField("Custom habit (optional)", text: text)
                .glowText(.body)
                .foregroundStyle(Color.glowTextPrimary)
                .submitLabel(.done)
                .onChange(of: text.wrappedValue) { _, newValue in
                    if newValue.count > 40 {
                        text.wrappedValue = String(newValue.prefix(40))
                    }
                    if newValue.isEmpty {
                        icon.wrappedValue = "star.fill"
                        colorHex.wrappedValue = "#E0E0E0"
                    }
                }

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
}

// MARK: - HabitEditCard

private struct HabitEditCard: View {
    let habit: EditableHabit
    @Binding var editText: String
    let onCancel: () -> Void
    let onSave: () -> Void
    let onSuggestion: (String) -> Void

    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.glowDivider)
                .frame(width: 36, height: 6)
                .padding(.top, GlowSpacing.s12)
                .padding(.bottom, GlowSpacing.s16)

            // Title
            Text(habit.title)
                .font(.glowSerif(size: 22, weight: .bold))
                .foregroundStyle(Color.glowTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, GlowSpacing.s24)

            // Text field
            TextField("Description", text: $editText)
                .glowText(.body)
                .foregroundStyle(Color.glowTextPrimary)
                .focused($fieldFocused)
                .padding(GlowSpacing.s12)
                .background(
                    RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                        .fill(Color.glowSurfaceSecondary)
                )
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.top, GlowSpacing.s16)

            // Suggestions
            if !habit.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: GlowSpacing.s8) {
                    Text("Suggestions")
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextSecondary)
                        .padding(.horizontal, GlowSpacing.s24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: GlowSpacing.s8) {
                            ForEach(habit.suggestions, id: \.self) { chip in
                                Button {
                                    editText = chip
                                    onSuggestion(chip)
                                } label: {
                                    Text(chip)
                                        .glowText(.caption)
                                        .foregroundStyle(Color.glowTextPrimary)
                                        .padding(.horizontal, GlowSpacing.s12)
                                        .padding(.vertical, GlowSpacing.s8)
                                        .background(
                                            RoundedRectangle(cornerRadius: GlowRadius.small, style: .continuous)
                                                .fill(Color.glowSurfaceSecondary)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: GlowRadius.small, style: .continuous)
                                                        .strokeBorder(Color.glowDivider, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, GlowSpacing.s24)
                    }
                }
                .padding(.top, GlowSpacing.s12)
            }

            // Action buttons
            HStack(spacing: GlowSpacing.s12) {
                GlowButton(title: "Cancel", style: .ghost, action: onCancel)
                GlowButton(title: "Save", action: onSave)
            }
            .padding(.horizontal, GlowSpacing.s24)
            .padding(.top, GlowSpacing.s16)
            .padding(.bottom, GlowSpacing.s24)
        }
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.large, style: .continuous)
                .fill(Color.glowSurface)
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 4)
        )
        .onAppear { fieldFocused = true }
    }
}

// MARK: - Supporting type

struct IconPickerSlot: Identifiable {
    let id: Int
}
