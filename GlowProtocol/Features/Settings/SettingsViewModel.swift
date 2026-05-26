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
        let descriptor = FetchDescriptor<DayLog>()
        if let logs = try? context.fetch(descriptor) {
            for log in logs { context.delete(log) }
        }
        let photoDesc = FetchDescriptor<ScrapbookPhoto>()
        if let photos = try? context.fetch(photoDesc) {
            for p in photos {
                PhotoService.shared.deletePhoto(p.fileURL)
                context.delete(p)
            }
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
