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
import SuperwallKit

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
                    onContinue: { registerPaywall() }
                )
                .transition(.opacity)

            // .paywall is bypassed — Superwall presents its paywall from .summary.
            // This case is a safe fallback in case any navigation path lands here.
            case .paywall:
                PaywallView(viewModel: viewModel) { viewModel.step = .notifications }

            case .notifications:
                NotificationPermissionView(onFinish: { finish() })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
        .alert("Subscription unavailable", isPresented: Binding(
            get: { SubscriptionService.shared.errorMessage != nil },
            set: { if !$0 { SubscriptionService.shared.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { SubscriptionService.shared.errorMessage = nil }
        } message: {
            Text(SubscriptionService.shared.errorMessage ?? "Please try again.")
        }
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

    /// Triggers the Superwall placement. Superwall checks subscription status:
    /// - Already subscribed → closure runs immediately, advancing the flow.
    /// - Not subscribed → Superwall presents its paywall; closure runs on purchase.
    /// - Dismissed without purchase → nothing happens; user stays on the summary.
    private func registerPaywall() {
        SubscriptionService.shared.setOnboardingAttributes(
            preset: (viewModel.preset ?? .hard).rawValue,
            habitCount: viewModel.enabledCount
        )
        SubscriptionService.shared.requestAccess(placement: "onboarding_complete") {
            viewModel.step = .notifications
        }
    }

    private func finish() {
        guard SubscriptionService.shared.hasAccess else {
            viewModel.step = .summary
            return
        }
        viewModel.finalize(in: modelContext)
        hasCompletedOnboarding = true
        Task { await NotificationService.shared.scheduleMidnightCheck() }
        BackgroundTaskService.shared.scheduleMidnightCheck()
    }
}
