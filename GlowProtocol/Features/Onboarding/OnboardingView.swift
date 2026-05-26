//
//  OnboardingView.swift
//  GlowProtocol
//
//  Container that drives the 4-step onboarding flow and writes the
//  resulting configuration when the user taps "Start Day 1."
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            switch viewModel.step {
            case .welcome:
                WelcomeSlideView(onBegin: { viewModel.nextStep() })
                    .transition(.opacity)
            case .difficulty:
                DifficultyPickerView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onContinue: { viewModel.nextStep() }
                )
                .transition(.opacity)
            case .habits:
                HabitCustomizerView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onConfirm: { viewModel.nextStep() }
                )
                .transition(.opacity)
            case .grace:
                GraceDayPickerView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onStart: { finish() }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
    }

    private func finish() {
        viewModel.finalize(in: modelContext)
        hasCompletedOnboarding = true
        Task { await NotificationService.shared.scheduleMidnightCheck() }
        BackgroundTaskService.shared.scheduleMidnightCheck()
    }
}
