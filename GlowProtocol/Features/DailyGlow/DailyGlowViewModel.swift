//
//  DailyGlowViewModel.swift
//  GlowProtocol
//
//  Derives display state for the main checklist screen.
//

import Foundation
import Observation
import SwiftData
import SwiftUI
import WidgetKit

@MainActor
@Observable
final class DailyGlowViewModel {
    var todayLog: DayLog?
    var config: ProtocolConfig?
    var pendingValidator: HabitEntry?

    private var modelContext: ModelContext?
    private var streakService: StreakService?

    // Per-habit transient validator state
    var waterTaps: [String: Int] = [:]
    var readingPages: [String: Int] = [:]

    func bind(context: ModelContext) {
        self.modelContext = context
        let service = StreakService(context: context)
        self.streakService = service
        self.config = service.fetchOrCreateConfig()
        self.todayLog = service.currentDayLog()
        ensureDayLogIsForToday()
    }

    func refresh() {
        guard let service = streakService else { return }
        config = service.fetchOrCreateConfig()
        todayLog = service.currentDayLog()
        ensureDayLogIsForToday()
    }

    private func ensureDayLogIsForToday() {
        guard let service = streakService else { return }
        let today = Date.now.glowStartOfDay
        if let log = todayLog, log.date.glowStartOfDay != today {
            // Day rolled over — evaluate yesterday then seed today.
            _ = service.evaluateDay(log.date)
            todayLog = service.currentDayLog()
        }
    }

    /// Sorted habit entries: incomplete first (in display order), then complete.
    var sortedEntries: [HabitEntry] {
        guard let log = todayLog else { return [] }
        let order = HabitID.displayOrder
        let incomplete = log.habitEntries
            .filter { !$0.isComplete }
            .sorted { (lhs, rhs) in
                let li = order.firstIndex(of: lhs.habitID) ?? Int.max
                let ri = order.firstIndex(of: rhs.habitID) ?? Int.max
                return li < ri
            }
        let complete = log.habitEntries
            .filter { $0.isComplete }
            .sorted { (lhs, rhs) in
                (lhs.completedAt ?? .distantPast) < (rhs.completedAt ?? .distantPast)
            }
        return incomplete + complete
    }

    var completionPercentage: Double {
        todayLog?.completionPercentage ?? 0
    }

    var dayNumber: Int { config?.currentDay ?? 1 }
    var targetDays: Int { config?.targetDays ?? 75 }
    var allComplete: Bool { todayLog?.allRequiredComplete ?? false }
    var todayPhotoURL: String? { todayLog?.photoFileURL }
    var runID: UUID { todayLog?.runID ?? UUID() }

    // MARK: - Actions

    func handleTap(on entry: HabitEntry) {
        if entry.isComplete {
            // For accidental check protection, the view presents an "undo" sheet.
            return
        }
        if entry.habitID.requiresValidatorSheet {
            pendingValidator = entry
            return
        }
        completeHabit(entry)
    }

    func completeHabit(_ entry: HabitEntry, metadata: String? = nil) {
        guard let service = streakService else { return }
        service.markHabitComplete(entry, metadata: metadata)
        HapticService.shared.play(.habitComplete)
        if todayLog?.allRequiredComplete == true {
            HapticService.shared.play(.timerFinish)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    func undoHabit(_ entry: HabitEntry) {
        guard let service = streakService else { return }
        service.toggleHabit(entry)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func attachPhoto(_ relativePath: String, for log: DayLog) {
        guard let service = streakService else { return }
        service.attachPhoto(relativePath, to: log)
    }

    func dismissValidator() {
        pendingValidator = nil
    }

    // MARK: - Display helpers

    func statusText(for entry: HabitEntry) -> (String, HabitRow.StatusEmphasis) {
        if entry.isComplete {
            if let ts = entry.completedAt {
                return ("Done · \(ts.glowTimeLabel)", .secondary)
            }
            return ("Done", .secondary)
        }
        switch entry.habitID {
        case .workout1, .workout2:
            return ("Tap to start \(config?.workoutMinutes ?? 45)-min timer", .disabled)
        case .water:
            let taps = waterTaps[entry.persistentModelID.idString] ?? 0
            return ("\(taps) / 8 glasses", .disabled)
        case .progressPhoto:
            return ("Tap to capture", .disabled)
        case .steps:
            return ("Did you hit \(config?.stepTarget ?? 10000) steps?", .disabled)
        case .reading:
            return ("\(config?.readingPages ?? 10) pages minimum", .disabled)
        default:
            return ("Tap to complete", .disabled)
        }
    }

    func trailingStyle(for entry: HabitEntry) -> HabitRow.TrailingStyle {
        switch entry.habitID {
        case .water where !entry.isComplete:
            let taps = waterTaps[entry.persistentModelID.idString] ?? 0
            return .segmented(filled: taps, total: 8)
        default:
            return .check
        }
    }
}

extension PersistentIdentifier {
    var idString: String {
        String(describing: self)
    }
}
