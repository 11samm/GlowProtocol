//
//  RootView.swift
//  GlowProtocol
//
//  App-level router: shows the launch logotype briefly, then either onboarding
//  or the main tab view. Listens for `pendingGraceDecision` and presents the
//  fail-state cover.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("pendingGraceDecision") private var pendingGraceDecision: Bool = false
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    @State private var didFinishLaunch = false
    @State private var failStateShown = false

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            if didFinishLaunch {
                Group {
                    if hasCompletedOnboarding {
                        MainTabView()
                            .transition(.opacity)
                    } else {
                        OnboardingView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
            } else {
                LaunchView(onComplete: { withAnimation { didFinishLaunch = true } })
                    .transition(.opacity)
            }
        }
        .onAppear(perform: handleAppear)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active { evaluateForeground() }
        }
        .fullScreenCover(isPresented: $failStateShown, onDismiss: {
            pendingGraceDecision = false
        }) {
            FailStateView()
        }
        .onChange(of: pendingGraceDecision) { _, newValue in
            if newValue, hasCompletedOnboarding { failStateShown = true }
        }
    }

    private func handleAppear() {
        BackgroundTaskService.shared.scheduleMidnightCheck()
        Task { await NotificationService.shared.scheduleMidnightCheck() }
        evaluateForeground()
    }

    /// Called on initial appear and on each foreground transition. If the app
    /// was backgrounded across midnight, we evaluate the (now-yesterday) day
    /// before showing the main tab view.
    private func evaluateForeground() {
        guard hasCompletedOnboarding else { return }
        let service = StreakService(context: context)
        let cfg = service.fetchOrCreateConfig()
        service.rolloverGraceDaysIfNeeded(config: cfg)

        // Catch-up evaluation: if the most recent current-run day is older than
        // today, evaluate each missing day in chronological order.
        let today = Date.glowEffectiveNow.glowStartOfDay
        let logs = service.fetchAllCurrentRunLogs().sorted(by: { $0.date < $1.date })
        if let last = logs.last, last.date.glowStartOfDay < today {
            var cursor = last.date.glowStartOfDay
            while cursor < today {
                _ = service.evaluateDay(cursor)
                if pendingGraceDecision { break }
                cursor = Calendar.current.date(byAdding: .day, value: 1, to: cursor) ?? today
            }
        }

        // Synchronize the @State with the current persisted flag.
        if pendingGraceDecision {
            failStateShown = true
        }
    }
}
