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

    func bind(context: ModelContext) {
        self.context = context
        service = StreakService(context: context)
        config = service?.fetchOrCreateConfig()
    }

    func save() {
        try? context?.save()
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
