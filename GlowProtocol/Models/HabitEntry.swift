//
//  HabitEntry.swift
//  GlowProtocol
//
//  Individual habit completion record. Seeded from ProtocolConfig when a new DayLog is created.
//

import Foundation
import SwiftData
import SwiftUI

enum HabitID: String, Codable, CaseIterable {
    case workout1
    case workout2
    case water
    case diet
    case reading
    case noAlcohol
    case progressPhoto
    case steps
    case custom1
    case custom2
    case custom3

    /// The canonical display ordering for the daily checklist.
    static let displayOrder: [HabitID] = [
        .workout1, .workout2,
        .water,
        .diet,
        .reading,
        .steps,
        .noAlcohol,
        .progressPhoto,
        .custom1, .custom2, .custom3,
    ]

    var defaultLabel: String {
        switch self {
        case .workout1: return "Workout 1"
        case .workout2: return "Workout 2"
        case .water: return "Water"
        case .diet: return "Stick to diet"
        case .reading: return "Reading"
        case .noAlcohol: return "No alcohol"
        case .progressPhoto: return "Progress photo"
        case .steps: return "10,000 steps"
        case .custom1, .custom2, .custom3: return "Custom habit"
        }
    }

    var symbolName: String {
        switch self {
        case .workout1, .workout2: return "figure.run"
        case .water: return "drop.fill"
        case .diet: return "leaf.fill"
        case .reading: return "book.closed.fill"
        case .steps: return "shoeprints.fill"
        case .noAlcohol: return "xmark.circle.fill"
        case .progressPhoto: return "camera.fill"
        case .custom1, .custom2, .custom3: return "star.fill"
        }
    }

    var pastel: Color {
        switch self {
        case .workout1, .workout2: return .habitWorkout
        case .water: return .habitWater
        case .diet: return .habitDiet
        case .reading: return .habitReading
        case .steps: return .habitSteps
        case .noAlcohol: return .habitNoAlcohol
        case .progressPhoto: return .habitPhoto
        case .custom1, .custom2, .custom3: return .habitCustom
        }
    }

    /// Hex string of the light-mode pastel — for sharing across the widget extension boundary.
    var pastelHex: String {
        switch self {
        case .workout1, .workout2: return "#D4E8C2"
        case .water: return "#C2DCF0"
        case .diet: return "#F5E6C8"
        case .reading: return "#E8D4F0"
        case .steps: return "#C8EAE0"
        case .noAlcohol: return "#FAE0E0"
        case .progressPhoto: return "#FFF0C2"
        case .custom1, .custom2, .custom3: return "#E0E0E0"
        }
    }

    var requiresValidatorSheet: Bool {
        switch self {
        case .workout1, .workout2, .water, .progressPhoto: return true
        default: return false
        }
    }

    var isCustom: Bool {
        switch self {
        case .custom1, .custom2, .custom3: return true
        default: return false
        }
    }
}

@Model
final class HabitEntry {
    var habitIDRaw: String
    var customLabel: String?
    var customSymbolName: String?   // non-nil only when habitID == .custom1/2/3
    var customColorHex: String?     // non-nil only when habitID == .custom1/2/3
    var isRequired: Bool
    var isComplete: Bool
    var completedAt: Date?
    var validationMetadata: String?

    var dayLog: DayLog?

    init(
        habitID: HabitID,
        customLabel: String? = nil,
        customSymbolName: String? = nil,
        customColorHex: String? = nil,
        isRequired: Bool = true,
        isComplete: Bool = false,
        completedAt: Date? = nil,
        validationMetadata: String? = nil
    ) {
        self.habitIDRaw = habitID.rawValue
        self.customLabel = customLabel
        self.customSymbolName = customSymbolName
        self.customColorHex = customColorHex
        self.isRequired = isRequired
        self.isComplete = isComplete
        self.completedAt = completedAt
        self.validationMetadata = validationMetadata
    }

    var habitID: HabitID {
        get { HabitID(rawValue: habitIDRaw) ?? .custom1 }
        set { habitIDRaw = newValue.rawValue }
    }

    /// Display label — prefers the user's custom label, falls back to the default for the habit.
    var displayLabel: String {
        if let custom = customLabel, !custom.isEmpty { return custom }
        return habitID.defaultLabel
    }
}
