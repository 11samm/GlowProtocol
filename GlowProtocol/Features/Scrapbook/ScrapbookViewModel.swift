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

    /// All months between start date and today, newest first.
    var months: [Date] {
        guard let config else { return [Date.now.glowStartOfDay] }
        var results: [Date] = []
        let calendar = Calendar.current
        var cursor = calendar.date(from: calendar.dateComponents([.year, .month], from: config.startDate)) ?? Date.now
        let endMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date.now)) ?? Date.now
        while cursor <= endMonth {
            results.append(cursor)
            cursor = calendar.date(byAdding: .month, value: 1, to: cursor) ?? cursor
        }
        return results.reversed()
    }

    func photo(for date: Date) -> ScrapbookPhoto? {
        photos.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    /// Returns cell state for a given calendar date in a month.
    func cellState(for date: Date) -> ScrapbookCell.State {
        let isToday = Calendar.current.isDate(date, inSameDayAs: Date.now)
        if date > Date.now.glowStartOfDay {
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
        guard let config else { return 1 }
        let days = Calendar.current.dateComponents([.day],
                                                   from: config.startDate.glowStartOfDay,
                                                   to: date.glowStartOfDay).day ?? 0
        return max(1, days + 1)
    }

    /// All daily cells for a given month: returns dates from the 1st to last day.
    func daysIn(month: Date) -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: first)
        }
    }
}
