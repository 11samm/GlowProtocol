//
//  DayLog.swift
//  GlowProtocol
//
//  One record per calendar day. Holds the day's habit entries and streak metadata.
//

import Foundation
import SwiftData

@Model
final class DayLog {
    var date: Date
    var dayNumber: Int
    var streakHeld: Bool
    var graceDayUsed: Bool
    var completedAt: Date?
    var photoFileURL: String?
    var runID: UUID
    var isCurrentRun: Bool

    @Relationship(deleteRule: .cascade, inverse: \HabitEntry.dayLog)
    var habitEntries: [HabitEntry] = []

    init(
        date: Date,
        dayNumber: Int,
        runID: UUID,
        isCurrentRun: Bool = true,
        streakHeld: Bool = false,
        graceDayUsed: Bool = false,
        completedAt: Date? = nil,
        photoFileURL: String? = nil
    ) {
        self.date = date
        self.dayNumber = dayNumber
        self.runID = runID
        self.isCurrentRun = isCurrentRun
        self.streakHeld = streakHeld
        self.graceDayUsed = graceDayUsed
        self.completedAt = completedAt
        self.photoFileURL = photoFileURL
    }

    var allRequiredComplete: Bool {
        let required = habitEntries.filter(\.isRequired)
        guard !required.isEmpty else { return false }
        return required.allSatisfy(\.isComplete)
    }

    var completionPercentage: Double {
        let required = habitEntries.filter(\.isRequired)
        guard !required.isEmpty else { return 0 }
        return Double(required.filter(\.isComplete).count) / Double(required.count)
    }
}
