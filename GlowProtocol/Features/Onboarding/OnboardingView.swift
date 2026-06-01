//
//  OnboardingView.swift
//  GlowProtocol
//
//  Container that drives the expanded 13-step onboarding flow and writes the
//  resulting configuration once the user finishes the post-paywall steps.
//
//  Flow: Welcome → Name → Identity → Goal → Lifestyle → Social Proof →
//        Difficulty → Habits → Grace (Medium only) → Personalization Loading →
//        Protocol Summary → Paywall → Notification Permission → finalize.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("onboardingSkipsWelcome") private var onboardingSkipsWelcome = false

    var body: some View {
        ZStack {
            switch viewModel.step {
            case .welcome:
                WelcomeSlideView(onBegin: { viewModel.nextStep() })
                    .transition(.opacity)

            case .name:
                NameInputView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onContinue: { viewModel.nextStep() }
                )
                .transition(.opacity)

            case .identity:
                IdentitySelectionView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onContinue: { viewModel.nextStep() }
                )
                .transition(.opacity)

            case .goal:
                GoalSelectionView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onContinue: { viewModel.nextStep() }
                )
                .transition(.opacity)

            case .lifestyle:
                LifestylePickerView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onContinue: { viewModel.nextStep() }
                )
                .transition(.opacity)

            case .socialProof:
                SocialProofView(onContinue: { viewModel.nextStep() })
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
                    onConfirm: {
                        if viewModel.shouldShowGraceStep {
                            viewModel.nextStep()        // → .grace (Medium only)
                        } else {
                            viewModel.step = .loading   // Hard / Soft skip grace
                        }
                    }
                )
                .transition(.opacity)

            case .grace:
                GraceDayPickerView(
                    viewModel: viewModel,
                    onBack: { viewModel.previousStep() },
                    onStart: { viewModel.step = .loading }
                )
                .transition(.opacity)

            case .loading:
                PersonalizationLoadingView(
                    userName: viewModel.trimmedName,
                    onComplete: { viewModel.step = .summary }
                )
                .transition(.opacity)

            case .summary:
                ProtocolSummaryView(
                    viewModel: viewModel,
                    onBack: { viewModel.step = viewModel.shouldShowGraceStep ? .grace : .habits },
                    onContinue: { viewModel.nextStep() }
                )
                .transition(.opacity)

            case .paywall:
                PaywallView(
                    viewModel: viewModel,
                    onContinue: { viewModel.nextStep() }
                )
                .transition(.opacity)

            case .notifications:
                NotificationPermissionView(onFinish: { finish() })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
        .onAppear {
            // Restore the saved name so personalization works even when the
            // welcome/personalization steps are skipped (e.g. reconfigure).
            if viewModel.userName.isEmpty {
                viewModel.userName = UserDefaults.standard.string(forKey: "glowUserName") ?? ""
            }
            if onboardingSkipsWelcome {
                onboardingSkipsWelcome = false
                viewModel.step = .difficulty
            }
        }
    }

    private func finish() {
        viewModel.finalize(in: modelContext)
        hasCompletedOnboarding = true
        Task { await NotificationService.shared.scheduleMidnightCheck() }
        BackgroundTaskService.shared.scheduleMidnightCheck()
    }
}
