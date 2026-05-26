//
//  Date+Glow.swift
//  GlowProtocol
//
//  Calendar helpers normalized to the user's current Calendar.
//

import Foundation

extension Date {
    var glowStartOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func glowDaysSince(_ other: Date) -> Int {
        let start = other.glowStartOfDay
        let end = self.glowStartOfDay
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }

    func glowIsSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var glowMonthKey: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM"
        return f.string(from: self)
    }

    var glowFullDayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: self)
    }

    var glowShortDayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: self)
    }

    var glowMonthYearLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: self)
    }

    var glowTimeLabel: String {
        let f = DateFormatter()
        f.dateFormat = "h:mma"
        f.amSymbol = "am"
        f.pmSymbol = "pm"
        return f.string(from: self)
    }
}

extension Calendar {
    /// First moment of next month, used for grace-day rollover boundaries.
    func glowNextMonthStart(after date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        var next = DateComponents()
        next.year = comps.year
        next.month = (comps.month ?? 1) + 1
        next.day = 1
        return self.date(from: next) ?? date
    }
}
