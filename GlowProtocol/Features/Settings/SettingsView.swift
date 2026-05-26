//
//  SettingsView.swift
//  GlowProtocol
//
//  Appearance, reminders, protocol management, danger zone, about.
//

import SwiftUI
import SwiftData
import StoreKit
import SafariServices

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel = SettingsViewModel()

    @AppStorage("appearancePreference") private var appearancePreference: String = "light"
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled: Bool = false
    @AppStorage("dailyReminderHour") private var dailyReminderHour: Int = 8
    @AppStorage("dailyReminderMinute") private var dailyReminderMinute: Int = 0

    @State private var showResetConfirm = false
    @State private var showDifficultyEditor = false
    @State private var showHabitEditor = false
    @State private var showGraceEditor = false
    @State private var showPrivacyPolicy = false
    @State private var showTimePicker = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.glowBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                GlowSheetHandle()
                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s24) {
                        Text("Preferences")
                            .font(.glowSerif(size: 28, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .padding(.top, GlowSpacing.s24)

                        appearanceSection
                        protocolSection
                        remindersSection
                        dangerSection
                        aboutSection
                        Color.clear.frame(height: 60)
                    }
                    .padding(.horizontal, GlowSpacing.s24)
                }
            }
        }
        .onAppear { viewModel.bind(context: context) }
        .alert("Reset protocol?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetProtocol()
                dismiss()
            }
        } message: {
            Text("This deletes all progress and photos and returns you to Day 1.")
        }
        .sheet(isPresented: $showDifficultyEditor) {
            EditDifficultySheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showHabitEditor) {
            EditHabitsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showGraceEditor) {
            EditGraceSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                hour: $dailyReminderHour,
                minute: $dailyReminderMinute,
                onSave: {
                    Task { await NotificationService.shared.scheduleDailyReminder(
                        hour: dailyReminderHour,
                        minute: dailyReminderMinute
                    ) }
                }
            )
            .presentationDetents([.height(360)])
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s12) {
            sectionLabel("APPEARANCE")
            HStack {
                Text("Theme")
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextPrimary)
                Spacer()
                segmentedTheme
            }
        }
    }

    private var segmentedTheme: some View {
        let options: [(String, String)] = [("light", "Light"), ("dark", "Dark"), ("system", "System")]
        return HStack(spacing: 0) {
            ForEach(options, id: \.0) { option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        appearancePreference = option.0
                    }
                } label: {
                    Text(option.1)
                        .glowText(.caption)
                        .foregroundStyle(appearancePreference == option.0 ? Color.glowSurface : Color.glowTextSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: GlowRadius.medium)
                                .fill(appearancePreference == option.0 ? Color.glowTextPrimary : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium)
                .strokeBorder(Color.glowDivider, lineWidth: 1)
        )
    }

    private var protocolSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s12) {
            sectionLabel("PROTOCOL")
            row(title: "Difficulty", trailing: viewModel.config?.difficultyPreset.displayName ?? "—") {
                showDifficultyEditor = true
            }
            row(title: "Edit habits", trailing: nil) { showHabitEditor = true }
            row(title: "Grace days", trailing: "\(viewModel.config?.graceDaysPerMonth ?? 0)") {
                showGraceEditor = true
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s12) {
            sectionLabel("REMINDERS")
            HStack {
                Text("Daily reminder")
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextPrimary)
                Spacer()
                if dailyReminderEnabled {
                    Button {
                        showTimePicker = true
                    } label: {
                        Text(formattedTime)
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                }
                GlowToggle(isOn: Binding(
                    get: { dailyReminderEnabled },
                    set: { newValue in
                        dailyReminderEnabled = newValue
                        if newValue {
                            Task { await NotificationService.shared.scheduleDailyReminder(
                                hour: dailyReminderHour,
                                minute: dailyReminderMinute
                            ) }
                        } else {
                            NotificationService.shared.cancelDailyReminder()
                        }
                    }
                ))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Midnight check")
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextPrimary)
                Text("Streak evaluates at 11:59 PM daily.")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
            }
        }
    }

    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s12) {
            sectionLabel("DANGER ZONE")
            Button {
                showResetConfirm = true
            } label: {
                HStack {
                    Text("Reset protocol")
                        .glowText(.body)
                        .foregroundStyle(Color.glowDestructive)
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.glowDestructive)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s12) {
            sectionLabel("ABOUT")
            HStack {
                Text("Version")
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextPrimary)
                Spacer()
                Text("1.0")
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextSecondary)
            }
            Button { showPrivacyPolicy = true } label: {
                HStack {
                    Text("Privacy Policy")
                        .glowText(.body)
                        .foregroundStyle(Color.glowTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.glowTextSecondary)
                }
            }
            .buttonStyle(.plain)
            Button {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    AppStore.requestReview(in: scene)
                }
            } label: {
                HStack {
                    Text("Rate Glow Protocol")
                        .glowText(.body)
                        .foregroundStyle(Color.glowTextPrimary)
                    Spacer()
                    Image(systemName: "star")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.glowTextSecondary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func row(title: String, trailing: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextPrimary)
                Spacer()
                if let trailing {
                    Text(trailing)
                        .glowText(.body)
                        .foregroundStyle(Color.glowTextSecondary)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.glowTextSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .glowText(.badge)
            .foregroundStyle(Color.glowTextSecondary)
            .tracking(2)
    }

    private var formattedTime: String {
        var c = DateComponents()
        c.hour = dailyReminderHour
        c.minute = dailyReminderMinute
        if let date = Calendar.current.date(from: c) {
            return date.glowTimeLabel
        }
        return ""
    }
}

// MARK: - Edit sub-sheets

struct EditDifficultySheet: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s16) {
            GlowSheetHandle()
            Text("Difficulty")
                .font(.glowSerif(size: 28, weight: .bold, italic: true))
                .foregroundStyle(Color.glowTextPrimary)
                .padding(.top, GlowSpacing.s16)

            ForEach(DifficultyPreset.allCases) { preset in
                let selected = viewModel.config?.difficultyPreset == preset
                Button {
                    viewModel.config?.applyPresetDefaults(preset)
                    viewModel.save()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: preset.iconName)
                        Text(preset.displayName)
                            .glowText(.body)
                        Spacer()
                        if selected {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundStyle(Color.glowTextPrimary)
                    .padding(GlowSpacing.s16)
                    .background(
                        RoundedRectangle(cornerRadius: GlowRadius.medium)
                            .fill(selected ? Color.glowSurfaceSecondary : Color.glowSurface)
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, GlowSpacing.s24)
        .background(Color.glowBackground.ignoresSafeArea())
    }
}

struct EditHabitsSheet: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s16) {
            GlowSheetHandle()
            Text("Habits")
                .font(.glowSerif(size: 28, weight: .bold, italic: true))
                .foregroundStyle(Color.glowTextPrimary)
                .padding(.top, GlowSpacing.s16)

            if let cfg = viewModel.config {
                ScrollView {
                    VStack(spacing: GlowSpacing.s8) {
                        habitRow(title: "Workout", on: bind(\.workoutEnabled, on: cfg))
                        habitRow(title: "Water", on: bind(\.waterEnabled, on: cfg))
                        habitRow(title: "Diet", on: bind(\.dietEnabled, on: cfg))
                        habitRow(title: "Reading", on: bind(\.readingEnabled, on: cfg))
                        habitRow(title: "Steps", on: bind(\.stepsEnabled, on: cfg))
                        habitRow(title: "No alcohol", on: bind(\.noAlcoholEnabled, on: cfg))
                        habitRow(title: "Progress photo", on: bind(\.progressPhotoEnabled, on: cfg))
                    }
                }
            }
            GlowButton(title: "Save") {
                viewModel.save()
                dismiss()
            }
        }
        .padding(.horizontal, GlowSpacing.s24)
        .padding(.bottom, GlowSpacing.s24)
        .background(Color.glowBackground.ignoresSafeArea())
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<ProtocolConfig, Bool>, on cfg: ProtocolConfig) -> Binding<Bool> {
        Binding(
            get: { cfg[keyPath: keyPath] },
            set: { cfg[keyPath: keyPath] = $0 }
        )
    }

    private func habitRow(title: String, on: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .glowText(.body)
                .foregroundStyle(Color.glowTextPrimary)
            Spacer()
            GlowToggle(isOn: on)
        }
        .padding(GlowSpacing.s16)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium)
                .fill(Color.glowSurface)
        )
    }
}

struct EditGraceSheet: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draftValue: Int = 0

    var body: some View {
        VStack(spacing: GlowSpacing.s24) {
            GlowSheetHandle()
            Text("Grace days / month")
                .font(.glowSerif(size: 24, weight: .bold, italic: true))
                .foregroundStyle(Color.glowTextPrimary)
            HStack(spacing: GlowSpacing.s32) {
                Button {
                    if draftValue > 0 { draftValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.glowSurfaceSecondary))
                        .foregroundStyle(Color.glowTextPrimary)
                }
                Text("\(draftValue)")
                    .font(.glowSerif(size: 64, weight: .bold))
                    .foregroundStyle(Color.glowTextPrimary)
                Button {
                    if draftValue < 5 { draftValue += 1 }
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.glowSurfaceSecondary))
                        .foregroundStyle(Color.glowTextPrimary)
                }
            }
            GlowButton(title: "Save") {
                viewModel.config?.graceDaysPerMonth = draftValue
                viewModel.save()
                dismiss()
            }
            Spacer()
        }
        .padding(.horizontal, GlowSpacing.s24)
        .padding(.bottom, GlowSpacing.s24)
        .background(Color.glowBackground.ignoresSafeArea())
        .onAppear {
            draftValue = viewModel.config?.graceDaysPerMonth ?? 0
        }
    }
}

struct TimePickerSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: GlowSpacing.s16) {
            GlowSheetHandle()
            Text("Daily reminder time")
                .font(.glowSerif(size: 24, weight: .bold, italic: true))
                .foregroundStyle(Color.glowTextPrimary)
            DatePicker(
                "Time",
                selection: Binding(
                    get: {
                        var c = DateComponents()
                        c.hour = hour
                        c.minute = minute
                        return Calendar.current.date(from: c) ?? Date.now
                    },
                    set: { newValue in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        hour = comps.hour ?? 8
                        minute = comps.minute ?? 0
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            GlowButton(title: "Save") {
                onSave()
                dismiss()
            }
        }
        .padding(.horizontal, GlowSpacing.s24)
        .padding(.bottom, GlowSpacing.s24)
        .background(Color.glowBackground.ignoresSafeArea())
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color.glowBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                GlowSheetHandle()
                Text("Privacy Policy")
                    .font(.glowSerif(size: 28, weight: .bold, italic: true))
                    .foregroundStyle(Color.glowTextPrimary)
                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s12) {
                        Text("Your data stays on your device.")
                            .glowText(.headline)
                        Text("Glow Protocol stores all of your habit data, photos, and progress locally on your device using Apple's SwiftData framework. We do not have a backend in Phase 1. Photos are written to your app sandbox and are never uploaded.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)
                        Text("Notifications")
                            .glowText(.headline)
                        Text("We use local notifications scheduled by your device to remind you about the daily check-in and the nightly streak evaluation. No notification content is sent over the network.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)
                        Text("Contact")
                            .glowText(.headline)
                        Text("Questions? Email support@glowprotocol.app.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, GlowSpacing.s24)
        }
    }
}
