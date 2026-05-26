//
//  ProgressDashboardView.swift
//  GlowProtocol
//
//  Long-view stats: streak, grace, per-habit completion, calendar heatmap, past runs.
//  Named ProgressDashboardView to avoid collision with SwiftUI.ProgressView.
//

import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = GlowProgressViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: GlowSpacing.s24) {
                    navBar
                    heroCard
                    streakSection
                    graceSection
                    if !viewModel.habitRates.isEmpty {
                        habitBreakdown
                    }
                    heatmap
                    if !viewModel.archivedRuns.isEmpty {
                        pastRunsSection
                    }
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, GlowSpacing.s16)
            }
        }
        .onAppear { viewModel.bind(context: context) }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var navBar: some View {
        HStack {
            Text("Progress")
                .glowText(.headline)
                .foregroundStyle(Color.glowTextPrimary)
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.glowTextPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.top, GlowSpacing.s8)
    }

    private var heroCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Day \(viewModel.dayNumber)")
                        .font(.glowSerif(size: 52, weight: .bold))
                        .foregroundStyle(Color.glowTextPrimary)
                    Text("of \(viewModel.targetDays)")
                        .glowText(.body)
                        .foregroundStyle(Color.glowTextSecondary)
                    Text("\(Int(viewModel.overallCompletion * 100))% complete")
                        .glowText(.body)
                        .foregroundStyle(Color.glowTextSecondary)
                        .padding(.top, GlowSpacing.s8)
                }
                Spacer()
                ProgressRing(progress: viewModel.overallCompletion)
                    .frame(width: 88, height: 88)
            }
            // Linear progress bar at the bottom of the card.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.glowSurfaceSecondary).frame(height: 4)
                    Capsule().fill(Color.glowTextPrimary)
                        .frame(width: geo.size.width * viewModel.overallCompletion, height: 4)
                        .animation(GlowAnimation.ring, value: viewModel.overallCompletion)
                }
            }
            .frame(height: 4)
            .padding(.top, GlowSpacing.s24)
        }
        .padding(GlowSpacing.s24)
        .glowSurfaceCard()
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s8) {
            sectionLabel("STREAK")
            HStack(alignment: .firstTextBaseline) {
                Text("\(viewModel.currentStreak) days")
                    .font(.glowSerif(size: 36, weight: .bold, italic: true))
                    .foregroundStyle(Color.glowTextPrimary)
                if viewModel.currentStreak >= viewModel.personalBest, viewModel.currentStreak > 0 {
                    Text("New record")
                        .glowText(.badge)
                        .foregroundStyle(Color.glowSurface)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.glowTextPrimary))
                }
            }
            Text("Personal best: \(viewModel.personalBest) days")
                .glowText(.caption)
                .foregroundStyle(Color.glowTextSecondary)
        }
    }

    private var graceSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s8) {
            sectionLabel("GRACE DAYS")
            HStack(spacing: 6) {
                ForEach(0..<max(viewModel.graceTotal, 1), id: \.self) { i in
                    Circle()
                        .fill(i < viewModel.graceUsedThisMonth ? Color.glowGracePulse : Color.glowSurfaceSecondary)
                        .frame(width: 10, height: 10)
                }
            }
            Text("\(viewModel.graceUsedThisMonth) used · \(max(0, viewModel.graceAvailable)) remaining this month")
                .glowText(.body)
                .foregroundStyle(Color.glowTextPrimary)
        }
    }

    private var habitBreakdown: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s12) {
            sectionLabel("HABIT COMPLETION")
            VStack(spacing: GlowSpacing.s12) {
                ForEach(Array(viewModel.habitRates.enumerated()), id: \.offset) { idx, item in
                    let (id, rate, label) = item
                    habitBar(id: id, rate: rate, label: label ?? id.defaultLabel)
                        .padding(.vertical, 2)
                }
            }
        }
    }

    private func habitBar(id: HabitID, rate: Double, label: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(id.pastel).frame(width: 28, height: 28)
                Image(systemName: id.symbolName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.glowTextPrimary)
            }
            Text(label)
                .glowText(.subheadline)
                .foregroundStyle(Color.glowTextPrimary)
                .frame(width: 120, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.glowSurfaceSecondary).frame(height: 6)
                    Capsule().fill(id.pastel)
                        .frame(width: max(8, geo.size.width * rate), height: 6)
                }
            }
            .frame(height: 6)
            Text("\(Int(rate * 100))%")
                .glowText(.badge)
                .foregroundStyle(Color.glowTextPrimary)
                .frame(width: 38, alignment: .trailing)
        }
    }

    private var heatmap: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s8) {
            sectionLabel("RUN HEATMAP")
            let logs = viewModel.currentLogs
            let columns = Array(repeating: GridItem(.fixed(12), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<(viewModel.config?.targetDays ?? 75), id: \.self) { i in
                    RoundedRectangle(cornerRadius: GlowRadius.small, style: .continuous)
                        .fill(heatmapColor(for: i, logs: logs))
                        .frame(width: 12, height: 12)
                }
            }
        }
    }

    private func heatmapColor(for index: Int, logs: [DayLog]) -> Color {
        if let log = logs.first(where: { $0.dayNumber == index + 1 }) {
            if log.graceDayUsed { return .glowGracePulse }
            if log.streakHeld || log.allRequiredComplete { return .glowTextPrimary }
            if log.date < Date.now.glowStartOfDay { return .glowDestructive }
        }
        let today = (viewModel.config?.currentDay ?? 1)
        if index + 1 < today { return .glowDestructive }
        return .glowSurfaceSecondary
    }

    private var pastRunsSection: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s12) {
            sectionLabel("PAST RUNS")
            ForEach(viewModel.archivedRuns) { run in
                pastRunRow(run)
            }
        }
    }

    private func pastRunRow(_ run: GlowProgressViewModel.ArchivedRun) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(run.startDate.glowShortDayLabel) → \(run.endDate.glowShortDayLabel)")
                    .glowText(.subheadline)
                    .foregroundStyle(Color.glowTextPrimary)
                Spacer()
                Text("\(run.maxDayReached) days")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
            }
            HStack(spacing: 2) {
                ForEach(run.logs) { log in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(log.streakHeld ? Color.glowTextPrimary :
                              (log.graceDayUsed ? Color.glowGracePulse : Color.glowDestructive))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .padding(GlowSpacing.s16)
        .glowSurfaceCard()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .glowText(.badge)
            .foregroundStyle(Color.glowTextSecondary)
            .tracking(2)
    }
}

extension DayLog: Identifiable {
    public var id: PersistentIdentifier { persistentModelID }
}
