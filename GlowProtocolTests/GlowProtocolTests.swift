//
//  GlowProtocolTests.swift
//  GlowProtocolTests
//
//  Streak engine unit tests covering: normal completion, miss with grace,
//  grace exhaustion, month rollover.
//

import Testing
import SwiftData
import Foundation
@testable import GlowProtocol

@MainActor
struct StreakServiceTests {

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            ProtocolConfig.self,
            DayLog.self,
            HabitEntry.self,
            ScrapbookPhoto.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    private func makeService() throws -> (StreakService, UserDefaults) {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let suiteName = "TestSuite-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return (StreakService(context: context, userDefaults: defaults), defaults)
    }

    @Test func fetchOrCreateConfigReturnsSingleton() throws {
        let (service, _) = try makeService()
        let a = service.fetchOrCreateConfig()
        let b = service.fetchOrCreateConfig()
        #expect(a.persistentModelID == b.persistentModelID)
    }

    @Test func newDayIsSeededWithEnabledHabits() throws {
        let (service, _) = try makeService()
        let log = service.currentDayLog()
        #expect(!log.habitEntries.isEmpty)
        #expect(log.dayNumber == 1)
        #expect(log.isCurrentRun)
    }

    @Test func completingAllHabitsHoldsStreak() throws {
        let (service, defaults) = try makeService()
        let log = service.currentDayLog()
        for entry in log.habitEntries {
            service.markHabitComplete(entry)
        }
        let outcome = service.evaluateDay()
        #expect(outcome == .streakHeld)
        #expect(log.streakHeld)
        #expect(defaults.bool(forKey: StreakService.pendingGraceDecisionKey) == false)
    }

    @Test func missingHabitsWithGraceAvailableQueuesGraceDecision() throws {
        let (service, defaults) = try makeService()
        let cfg = service.fetchOrCreateConfig()
        cfg.graceDaysPerMonth = 2
        cfg.graceUsedThisMonth = 0
        _ = service.currentDayLog()
        let outcome = service.evaluateDay()
        #expect(outcome == .graceAvailable)
        #expect(defaults.bool(forKey: StreakService.pendingGraceDecisionKey))
        #expect(defaults.bool(forKey: StreakService.pendingGraceAvailableKey))
    }

    @Test func usingGraceDayPreservesStreakAndIncrementsCounter() throws {
        let (service, defaults) = try makeService()
        let cfg = service.fetchOrCreateConfig()
        cfg.graceDaysPerMonth = 2
        cfg.graceUsedThisMonth = 0
        _ = service.currentDayLog()
        _ = service.evaluateDay()
        service.useGraceDay()
        let updated = service.fetchOrCreateConfig()
        #expect(updated.graceUsedThisMonth == 1)
        #expect(defaults.bool(forKey: StreakService.pendingGraceDecisionKey) == false)
    }

    @Test func missingHabitsWithNoGraceTriggersHardReset() throws {
        let (service, defaults) = try makeService()
        let cfg = service.fetchOrCreateConfig()
        cfg.graceDaysPerMonth = 0
        _ = service.currentDayLog()
        let outcome = service.evaluateDay()
        #expect(outcome == .hardReset)
        #expect(defaults.bool(forKey: StreakService.pendingGraceDecisionKey))
        #expect(defaults.bool(forKey: StreakService.pendingGraceAvailableKey) == false)

        // Archived current run is now isCurrentRun=false; a fresh current day exists.
        let current = service.fetchAllCurrentRunLogs()
        let archived = service.fetchAllArchivedLogs()
        #expect(current.count == 1)
        #expect(!archived.isEmpty)
    }

    @Test func graceUsageResetsOnMonthRollover() throws {
        let (service, _) = try makeService()
        let cfg = service.fetchOrCreateConfig()
        cfg.graceDaysPerMonth = 3
        cfg.graceUsedThisMonth = 2
        // Set the reset date back one full month so the rollover engages.
        cfg.graceResetDate = Calendar.current.date(byAdding: .month, value: -1, to: Date.now) ?? Date.now
        service.rolloverGraceDaysIfNeeded(config: cfg)
        #expect(cfg.graceUsedThisMonth == 0)
    }

    @Test func hardResetArchivesAndStartsFreshRun() throws {
        let (service, _) = try makeService()
        _ = service.currentDayLog()
        let logsBefore = service.fetchAllCurrentRunLogs()
        let originalRunID = logsBefore.first?.runID
        service.performHardReset()
        let archived = service.fetchAllArchivedLogs()
        let current = service.fetchAllCurrentRunLogs()
        #expect(archived.contains(where: { $0.runID == originalRunID }))
        #expect(current.count == 1)
        #expect(current.first?.runID != originalRunID)
    }
}
