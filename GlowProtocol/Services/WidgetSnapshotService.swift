import Foundation
import SwiftData
import WidgetKit

/// Widget contract v1. Keep the matching widget-target type in sync.
struct GlowWidgetSnapshot: Codable {
    var version = 1
    let date: Date
    let day: Int
    let target: Int
    let streak: Int
    let completed: Int
    let required: Int
    let remaining: [String]
    let hideHabitNames: Bool
    var hasAccess: Bool
}

@MainActor
final class WidgetSnapshotService {
    static let group = "group.sam.GlowProtocol"
    static let key = "glowWidgetSnapshot.v1"

    static func publish(context: ModelContext) {
        guard UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"),
              let config = try? context.fetch(FetchDescriptor<ProtocolConfig>()).first else {
            clear()
            return
        }
        let today = Date.now.glowStartOfDay
        let descriptor = FetchDescriptor<DayLog>(predicate: #Predicate { $0.isCurrentRun && $0.date == today })
        guard let log = try? context.fetch(descriptor).first else {
            clear()
            return
        }
        let hideNames = UserDefaults.standard.object(forKey: "widgetHideHabitNames") as? Bool ?? true
        let required = log.habitEntries.filter(\.isRequired)
        let remaining = required.filter { !$0.isComplete }.map(\.displayLabel)
        let value = GlowWidgetSnapshot(date: today, day: min(config.targetDays, config.currentDay), target: config.targetDays,
            streak: StreakService(context: context).currentStreakLength(), completed: required.filter(\.isComplete).count,
            required: required.count, remaining: hideNames ? [] : Array(remaining.prefix(3)), hideHabitNames: hideNames,
            hasAccess: SubscriptionService.shared.hasAccess)
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults(suiteName: group)?.set(data, forKey: key)
            WidgetCenter.shared.reloadTimelines(ofKind: "GlowDailyProgress")
        }
    }
    static func updateAccess(_ hasAccess: Bool) {
        let defaults = UserDefaults(suiteName: group)
        guard let data = defaults?.data(forKey: key), var value = try? JSONDecoder().decode(GlowWidgetSnapshot.self, from: data) else { return }
        value.hasAccess = hasAccess
        if let data = try? JSONEncoder().encode(value) { defaults?.set(data, forKey: key) }
        WidgetCenter.shared.reloadTimelines(ofKind: "GlowDailyProgress")
    }
    static func clear() {
        UserDefaults(suiteName: group)?.removeObject(forKey: key)
        WidgetCenter.shared.reloadTimelines(ofKind: "GlowDailyProgress")
    }
}
