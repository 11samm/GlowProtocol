//
//  ProgressViewModel.swift
//  GlowProtocol
//
//  Derives stats used by the long-view Progress dashboard.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class GlowProgressViewModel {
    var config: ProtocolConfig?
    var currentLogs: [DayLog] = []
    var archivedRuns: [ArchivedRun] = []
    var currentStreak: Int = 0
    var personalBest: Int = 0
    var habitRates: [(HabitID, Double, String?, String?, String?)] = []

    private var context: ModelContext?
    private var service: StreakService?

    struct ArchivedRun: Identifiable {
        let runID: UUID
        var id: UUID { runID }
        let logs: [DayLog]
        var startDate: Date { logs.first?.date ?? Date.now }
        var endDate: Date { logs.last?.date ?? Date.now }
        var maxDayReached: Int { logs.map(\.dayNumber).max() ?? 0 }
    }

    func bind(context: ModelContext) {
        self.context = context
        let service = StreakService(context: context)
        self.service = service
        self.config = service.fetchOrCreateConfig()
        refresh()
    }

    func refresh() {
        guard let service else { return }
        currentLogs = service.fetchAllCurrentRunLogs()
        currentStreak = service.currentStreakLength()
        personalBest = service.personalBestStreak()
        habitRates = service.habitCompletionRates()

        let archived = service.fetchAllArchivedLogs()
        let grouped = Dictionary(grouping: archived, by: { $0.runID })
        archivedRuns = grouped.map { ArchivedRun(runID: $0.key, logs: $0.value.sorted(by: { $0.date < $1.date })) }
            .sorted { $0.startDate > $1.startDate }
    }

    var overallCompletion: Double {
        guard let config else { return 0 }
        return min(1.0, Double(config.currentDay - 1) / Double(config.targetDays))
    }

    var dayNumber: Int { config?.currentDay ?? 1 }
    var targetDays: Int { config?.targetDays ?? 75 }

    var graceUsedThisMonth: Int { config?.graceUsedThisMonth ?? 0 }
    var graceAvailable: Int { (config?.graceDaysPerMonth ?? 0) - graceUsedThisMonth }
    var graceTotal: Int { config?.graceDaysPerMonth ?? 0 }
}
