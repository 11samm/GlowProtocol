//
//  ScrapbookViewModel.swift
//  GlowProtocol
//
//  Fetches ScrapbookPhoto records and groups them by month.
//

import Foundation
import Observation
import SwiftData
import UIKit

@MainActor
@Observable
final class ScrapbookViewModel {
    var photos: [ScrapbookPhoto] = []
    var config: ProtocolConfig?

    private var context: ModelContext?

    func bind(context: ModelContext) {
        self.context = context
        let service = StreakService(context: context)
        self.config = service.fetchOrCreateConfig()
        refresh()
    }

    func refresh() {
        guard let context else { return }
        let descriptor = FetchDescriptor<ScrapbookPhoto>(
            sortBy: [SortDescriptor(\ScrapbookPhoto.date, order: .reverse)]
        )
        photos = (try? context.fetch(descriptor)) ?? []
    }

    /// The protocol's start day, normalized.
    var startDay: Date { (config?.startDate ?? Date.now).glowStartOfDay }

    /// Total number of days the grid spans (the protocol length).
    var targetDays: Int { config?.targetDays ?? 75 }

    /// Editorial header label — the month/year the protocol began.
    var headerLabel: String { startDay.glowMonthYearLabel }

    /// Ordered protocol days (Day 1 → targetDays), so Day 1 is always the
    /// first cell in the grid regardless of which calendar day it falls on.
    var protocolDates: [Date] {
        let calendar = Calendar.current
        return (0..<max(1, targetDays)).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startDay)
        }
    }

    func photo(for date: Date) -> ScrapbookPhoto? {
        // Prefer the active run so archived photos on the same calendar day
        // don't appear in the grid while being excluded from Before & After.
        photos.first {
            Calendar.current.isDate($0.date, inSameDayAs: date) && $0.isCurrentRun
        }
    }

    /// Returns cell state for a given calendar date in a month.
    func cellState(for date: Date) -> ScrapbookCell.State {
        let effectiveNow = Date.glowEffectiveNow
        let isToday = Calendar.current.isDate(date, inSameDayAs: effectiveNow)
        if date > effectiveNow.glowStartOfDay {
            return .future
        }
        if let photo = photo(for: date), let data = photo.thumbnailData, let thumb = UIImage(data: data) {
            let archived = !photo.isCurrentRun
            return .filled(thumbnail: thumb, dayNumber: photo.dayNumber, isToday: isToday, isArchived: archived)
        }
        let dayNumber = dayNumber(for: date)
        return .empty(dayNumber: dayNumber, isToday: isToday)
    }

    func dayNumber(for date: Date) -> Int {
        let days = Calendar.current.dateComponents([.day],
                                                   from: startDay,
                                                   to: date.glowStartOfDay).day ?? 0
        return max(1, days + 1)
    }

    /// Whether a given protocol date can accept a photo (today or in the past).
    func isCaptureable(_ date: Date) -> Bool {
        date.glowStartOfDay <= Date.glowEffectiveNow.glowStartOfDay
    }

    /// The runID of the active protocol run, ensuring today's log exists.
    func currentRunID() -> UUID {
        guard let context else { return UUID() }
        return StreakService(context: context).currentDayLog().runID
    }
}
