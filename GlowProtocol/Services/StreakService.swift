//
//  StreakService.swift
//  GlowProtocol
//
//  Business-logic engine: streak evaluation, grace-day handling, day seeding,
//  and hard reset / archive transitions.
//

import Foundation
import SwiftData

@MainActor
final class StreakService {
    static let pendingGraceDecisionKey = "pendingGraceDecision"
    static let pendingFailDateKey = "pendingFailDate"
    static let pendingGraceAvailableKey = "pendingGraceAvailable"

    private let context: ModelContext
    private let userDefaults: UserDefaults

    init(context: ModelContext, userDefaults: UserDefaults = .standard) {
        self.context = context
        self.userDefaults = userDefaults
    }

    // MARK: - Config

    @discardableResult
    func fetchOrCreateConfig() -> ProtocolConfig {
        let descriptor = FetchDescriptor<ProtocolConfig>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let cfg = ProtocolConfig()
        context.insert(cfg)
        try? context.save()
        return cfg
    }

    // MARK: - Habit seeding

    /// Returns the list of (habitID, customLabel, customSymbol, customColorHex) tuples to seed for a day.
    func enabledHabits(for config: ProtocolConfig) -> [(HabitID, String?, String?, String?)] {
        var items: [(HabitID, String?, String?, String?)] = []

        if config.workoutEnabled {
            let workout1Label: String? = config.workout1Outdoors ? "Workout 1 · Outdoors" : nil
            items.append((.workout1, workout1Label, nil, nil))
            if config.workoutCountPerDay >= 2 {
                items.append((.workout2, nil, nil, nil))
            }
        }
        if config.waterEnabled { items.append((.water, nil, nil, nil)) }
        if config.dietEnabled { items.append((.diet, nil, nil, nil)) }
        if config.readingEnabled { items.append((.reading, nil, nil, nil)) }
        if config.stepsEnabled { items.append((.steps, nil, nil, nil)) }
        if config.noAlcoholEnabled { items.append((.noAlcohol, nil, nil, nil)) }
        if config.progressPhotoEnabled { items.append((.progressPhoto, nil, nil, nil)) }
        if let c = config.customHabit1, !c.isEmpty {
            items.append((.custom1, c,
                config.customHabit1Icon ?? "star.fill",
                config.customHabit1ColorHex ?? "#E0E0E0"))
        }
        if let c = config.customHabit2, !c.isEmpty {
            items.append((.custom2, c,
                config.customHabit2Icon ?? "star.fill",
                config.customHabit2ColorHex ?? "#E0E0E0"))
        }
        if let c = config.customHabit3, !c.isEmpty {
            items.append((.custom3, c,
                config.customHabit3Icon ?? "star.fill",
                config.customHabit3ColorHex ?? "#E0E0E0"))
        }

        return items
    }

    // MARK: - DayLog accessors

    /// Returns today's DayLog (creating + seeding one if needed).
    @discardableResult
    func currentDayLog() -> DayLog {
        let config = fetchOrCreateConfig()
        rolloverGraceDaysIfNeeded(config: config)
        let today = Date.glowEffectiveNow.glowStartOfDay

        if let existing = fetchDayLog(on: today) {
            return existing
        }

        return seedDayLog(for: today, config: config)
    }

    func fetchDayLog(on date: Date) -> DayLog? {
        let target = date.glowStartOfDay
        let descriptor = FetchDescriptor<DayLog>(
            predicate: #Predicate<DayLog> { $0.isCurrentRun == true }
        )
        let logs = (try? context.fetch(descriptor)) ?? []
        return logs.first { $0.date.glowStartOfDay == target }
    }

    func fetchAllCurrentRunLogs() -> [DayLog] {
        let descriptor = FetchDescriptor<DayLog>(
            predicate: #Predicate<DayLog> { $0.isCurrentRun == true },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchAllArchivedLogs() -> [DayLog] {
        let descriptor = FetchDescriptor<DayLog>(
            predicate: #Predicate<DayLog> { $0.isCurrentRun == false },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    private func fetchAllCurrentRunPhotos() -> [ScrapbookPhoto] {
        let descriptor = FetchDescriptor<ScrapbookPhoto>(
            predicate: #Predicate<ScrapbookPhoto> { $0.isCurrentRun == true }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    @discardableResult
    func seedDayLog(for date: Date, config: ProtocolConfig) -> DayLog {
        let startOfDay = date.glowStartOfDay
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: config.startDate.glowStartOfDay, to: startOfDay).day ?? 0
        let dayNumber = max(1, daysSinceStart + 1)

        let runID = currentRunID() ?? UUID()
        let log = DayLog(
            date: startOfDay,
            dayNumber: dayNumber,
            runID: runID,
            isCurrentRun: true
        )
        for (habitID, label, symbol, colorHex) in enabledHabits(for: config) {
            let entry = HabitEntry(
                habitID: habitID,
                customLabel: label,
                customSymbolName: symbol,
                customColorHex: colorHex,
                isRequired: true
            )
            entry.dayLog = log
            log.habitEntries.append(entry)
            context.insert(entry)
        }
        context.insert(log)
        try? context.save()
        return log
    }

    /// Returns the runID for any current-run DayLog, creating a new one if needed.
    private func currentRunID() -> UUID? {
        let logs = fetchAllCurrentRunLogs()
        return logs.first?.runID
    }

    // MARK: - Habit completion

    func toggleHabit(_ entry: HabitEntry, metadata: String? = nil) {
        if entry.isComplete {
            entry.isComplete = false
            entry.completedAt = nil
        } else {
            entry.isComplete = true
            entry.completedAt = .now
            if let metadata { entry.validationMetadata = metadata }
        }
        if let log = entry.dayLog {
            if log.allRequiredComplete {
                log.completedAt = .now
                log.streakHeld = true
            } else {
                log.completedAt = nil
            }
        }
        try? context.save()
    }

    func markHabitComplete(_ entry: HabitEntry, metadata: String? = nil) {
        entry.isComplete = true
        entry.completedAt = .now
        if let metadata { entry.validationMetadata = metadata }
        if let log = entry.dayLog, log.allRequiredComplete {
            log.completedAt = .now
            log.streakHeld = true
        }
        try? context.save()
    }

    func attachPhoto(_ relativePath: String, to log: DayLog) {
        log.photoFileURL = relativePath
        try? context.save()
    }

    // MARK: - Midnight evaluation

    /// Pure-logic outcome of `evaluateDay()` — exposed for testability.
    enum EvaluateOutcome: Equatable {
        case streakHeld
        case graceAvailable
        case hardReset
    }

    /// Marks a day log as streak-held without requiring habit completion.
    /// Used by the dev skip control so day advancement doesn't trigger a fail state.
    func markDayHeld(_ log: DayLog) {
        log.streakHeld = true
        try? context.save()
    }

    /// Evaluates `date`'s DayLog and applies streak/grace/reset logic. Returns the outcome.
    @discardableResult
    func evaluateDay(_ date: Date = Date.glowEffectiveNow) -> EvaluateOutcome {
        let config = fetchOrCreateConfig()
        rolloverGraceDaysIfNeeded(config: config)
        let targetDate = date.glowStartOfDay
        let log = fetchDayLog(on: targetDate) ?? seedDayLog(for: targetDate, config: config)

        // Already evaluated (e.g. completed normally, used grace, or marked held by dev skip).
        if log.streakHeld {
            return .streakHeld
        }

        if log.allRequiredComplete {
            log.streakHeld = true
            try? context.save()
            return .streakHeld
        }

        // Soft mode: never fail — mark the day as held regardless of completion.
        if config.noPunishment {
            log.streakHeld = true
            try? context.save()
            return .streakHeld
        }

        if config.graceUsedThisMonth < config.graceDaysPerMonth {
            userDefaults.set(true, forKey: Self.pendingGraceDecisionKey)
            userDefaults.set(true, forKey: Self.pendingGraceAvailableKey)
            userDefaults.set(Date.glowEffectiveNow.timeIntervalSince1970, forKey: Self.pendingFailDateKey)
            return .graceAvailable
        }

        // Defer the actual reset until the user taps "Begin again" in FailStateView.
        // This prevents silent auto-resets when the user misses multiple days.
        userDefaults.set(true, forKey: Self.pendingGraceDecisionKey)
        userDefaults.set(false, forKey: Self.pendingGraceAvailableKey)
        userDefaults.set(Date.glowEffectiveNow.timeIntervalSince1970, forKey: Self.pendingFailDateKey)
        return .hardReset
    }

    /// Apply a grace day to the most recent failed day. Resolves the pending decision flag.
    func useGraceDay() {
        let config = fetchOrCreateConfig()
        rolloverGraceDaysIfNeeded(config: config)
        guard config.graceUsedThisMonth < config.graceDaysPerMonth else {
            clearPendingDecision()
            return
        }
        let pendingInterval = userDefaults.double(forKey: Self.pendingFailDateKey)
        let referenceDate = pendingInterval > 0 ? Date(timeIntervalSince1970: pendingInterval) : Date.now
        let log = fetchDayLog(on: referenceDate) ?? seedDayLog(for: referenceDate, config: config)
        log.graceDayUsed = true
        log.streakHeld = true
        config.graceUsedThisMonth += 1
        try? context.save()
        clearPendingDecision()
    }

    /// Hard reset: archive current run, start fresh. Public for the explicit "Reset protocol" affordance.
    func performHardReset(triggerFromEvaluation: Bool = false) {
        let config = fetchOrCreateConfig()
        let logs = fetchAllCurrentRunLogs()
        for log in logs {
            log.isCurrentRun = false
        }
        let photos = fetchAllCurrentRunPhotos()
        for photo in photos {
            photo.isCurrentRun = false
        }
        config.startDate = Date.glowEffectiveNow.glowStartOfDay
        let newRunID = UUID()
        let _ = seedDayLogIfMissing(for: Date.glowEffectiveNow.glowStartOfDay, config: config, runID: newRunID)
        try? context.save()
        _ = triggerFromEvaluation
    }

    private func seedDayLogIfMissing(for date: Date, config: ProtocolConfig, runID: UUID) -> DayLog {
        if let existing = fetchDayLog(on: date) {
            return existing
        }
        let startOfDay = date.glowStartOfDay
        let log = DayLog(date: startOfDay, dayNumber: 1, runID: runID, isCurrentRun: true)
        for (habitID, label, symbol, colorHex) in enabledHabits(for: config) {
            let entry = HabitEntry(
                habitID: habitID,
                customLabel: label,
                customSymbolName: symbol,
                customColorHex: colorHex,
                isRequired: true
            )
            entry.dayLog = log
            log.habitEntries.append(entry)
            context.insert(entry)
        }
        context.insert(log)
        return log
    }

    /// Syncs today's existing DayLog to match the current config.
    /// Adds any newly-enabled habit entries that aren't already in the log.
    /// Never removes entries — completed history is always preserved.
    func resyncTodayHabits(config: ProtocolConfig) {
        let today = Date.now.glowStartOfDay
        guard let log = fetchDayLog(on: today) else { return }

        let existingIDs = Set(log.habitEntries.map { $0.habitID })

        for (habitID, label, symbol, colorHex) in enabledHabits(for: config) {
            guard !existingIDs.contains(habitID) else { continue }
            let entry = HabitEntry(
                habitID: habitID,
                customLabel: label,
                customSymbolName: symbol,
                customColorHex: colorHex,
                isRequired: true
            )
            entry.dayLog = log
            log.habitEntries.append(entry)
            context.insert(entry)
        }
        try? context.save()
    }

    func clearPendingDecision() {
        userDefaults.set(false, forKey: Self.pendingGraceDecisionKey)
        userDefaults.set(false, forKey: Self.pendingGraceAvailableKey)
        userDefaults.set(0, forKey: Self.pendingFailDateKey)
    }

    // MARK: - Grace day rollover

    /// Resets `graceUsedThisMonth` to 0 when the calendar month has advanced past `graceResetDate`.
    func rolloverGraceDaysIfNeeded(config: ProtocolConfig) {
        let cal = Calendar.current
        let now = Date.glowEffectiveNow
        let resetMonth = cal.component(.month, from: config.graceResetDate)
        let nowMonth = cal.component(.month, from: now)
        let resetYear = cal.component(.year, from: config.graceResetDate)
        let nowYear = cal.component(.year, from: now)
        if nowYear > resetYear || (nowYear == resetYear && nowMonth > resetMonth) {
            config.graceUsedThisMonth = 0
            var comps = cal.dateComponents([.year, .month], from: now)
            comps.day = 1
            config.graceResetDate = cal.date(from: comps) ?? now.glowStartOfDay
            try? context.save()
        }
    }

    // MARK: - Stats

    /// Returns the current uninterrupted streak length for the active run.
    func currentStreakLength() -> Int {
        let logs = fetchAllCurrentRunLogs().sorted(by: { $0.date < $1.date })
        let calendar = Calendar.current
        let today = Date.glowEffectiveNow.glowStartOfDay
        var streak = 0
        var cursor = today
        // Walk backwards day-by-day; count any day that either held the streak or
        // used a grace day. Today counts only when it's fully complete.
        while true {
            if let log = logs.first(where: { calendar.isDate($0.date, inSameDayAs: cursor) }) {
                let counts: Bool
                if calendar.isDate(cursor, inSameDayAs: today) {
                    counts = log.allRequiredComplete
                } else {
                    counts = log.streakHeld
                }
                if counts {
                    streak += 1
                    cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
                    continue
                }
            }
            break
        }
        return streak
    }

    /// Returns the longest streak observed across all runs (archived + current).
    func personalBestStreak() -> Int {
        let allLogs = (fetchAllCurrentRunLogs() + fetchAllArchivedLogs())
            .sorted(by: { $0.date < $1.date })
        var best = 0
        var current = 0
        let cal = Calendar.current
        var previous: Date?
        for log in allLogs {
            if log.streakHeld {
                if let prev = previous,
                   cal.dateComponents([.day], from: prev, to: log.date).day == 1 {
                    current += 1
                } else {
                    current = 1
                }
                best = max(best, current)
                previous = log.date
            } else {
                current = 0
                previous = nil
            }
        }
        return best
    }

    /// Per-habit completion percentage across the current run.
    /// Returns (habitID, rate, customLabel, customSymbolName, customColorHex).
    func habitCompletionRates() -> [(HabitID, Double, String?, String?, String?)] {
        let logs = fetchAllCurrentRunLogs()
        var totals: [HabitID: (complete: Int, total: Int, label: String?, symbol: String?, colorHex: String?)] = [:]
        for log in logs {
            for entry in log.habitEntries {
                let id = entry.habitID
                var bucket = totals[id] ?? (0, 0, entry.customLabel, entry.customSymbolName, entry.customColorHex)
                bucket.total += 1
                if entry.isComplete { bucket.complete += 1 }
                if bucket.label == nil { bucket.label = entry.customLabel }
                if bucket.symbol == nil { bucket.symbol = entry.customSymbolName }
                if bucket.colorHex == nil { bucket.colorHex = entry.customColorHex }
                totals[id] = bucket
            }
        }
        return totals.compactMap { (id, value) -> (HabitID, Double, String?, String?, String?)? in
            guard value.total > 0 else { return nil }
            return (id, Double(value.complete) / Double(value.total), value.label, value.symbol, value.colorHex)
        }.sorted { lhs, rhs in
            let order = HabitID.displayOrder
            let li = order.firstIndex(of: lhs.0) ?? Int.max
            let ri = order.firstIndex(of: rhs.0) ?? Int.max
            return li < ri
        }
    }
}
