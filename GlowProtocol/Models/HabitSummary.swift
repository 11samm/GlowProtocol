//
//  HabitSummary.swift
//  GlowProtocol
//
//  Plain-data summary of a habit row — designed for serialization across the
//  app/widget extension boundary (added to both targets in Xcode).
//

import Foundation

struct HabitSummary: Codable, Identifiable, Hashable {
    let id: String
    let label: String
    let isComplete: Bool
    let pastelColorHex: String
}
