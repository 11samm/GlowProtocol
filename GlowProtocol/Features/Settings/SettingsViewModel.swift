//
//  SettingsViewModel.swift
//  GlowProtocol
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    var config: ProtocolConfig?
    private var context: ModelContext?
    private var service: StreakService?

    // Draft icon/color for EditHabitsSheet — populated on sheet appear, written on Save
    var draftCustomIcon1: String = "star.fill"
    var draftCustomIcon2: String = "star.fill"
    var draftCustomIcon3: String = "star.fill"
    var draftCustomColor1: String = "#E0E0E0"
    var draftCustomColor2: String = "#E0E0E0"
    var draftCustomColor3: String = "#E0E0E0"

    func bind(context: ModelContext) {
        self.context = context
        service = StreakService(context: context)
        config = service?.fetchOrCreateConfig()
    }

    func save() {
        // Persist config changes first, then sync today's habit entries to match.
        try? context?.save()
        if let cfg = config {
            service?.resyncTodayHabits(config: cfg)
        }
    }

    func resetProtocol() {
        guard let context, let service else { return }

        // Archive current run logs — keeps history visible on the Progress screen.
        let currentLogDesc = FetchDescriptor<DayLog>(
            predicate: #Predicate<DayLog> { $0.isCurrentRun == true }
        )
        if let logs = try? context.fetch(currentLogDesc) {
            for log in logs { log.isCurrentRun = false }
        }

        // Archive current run photos — same principle, keep them in past-run records.
        let currentPhotoDesc = FetchDescriptor<ScrapbookPhoto>(
            predicate: #Predicate<ScrapbookPhoto> { $0.isCurrentRun == true }
        )
        if let photos = try? context.fetch(currentPhotoDesc) {
            for p in photos { p.isCurrentRun = false }
        }

        if let cfg = config {
            cfg.applyPresetDefaults(.hard)
            cfg.startDate = Date.now.glowStartOfDay
            cfg.graceUsedThisMonth = 0
            cfg.graceResetDate = Date.now.glowStartOfDay
        }
        try? context.save()
        _ = service.currentDayLog()
    }
}
