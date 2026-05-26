//
//  ProtocolConfig.swift
//  GlowProtocol
//
//  The user's chosen ruleset. Singleton — only one instance ever exists in the store.
//

import Foundation
import SwiftData

enum DifficultyPreset: String, Codable, CaseIterable, Identifiable {
    case hard
    case medium
    case soft

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hard: return "Hard"
        case .medium: return "Medium"
        case .soft: return "Soft"
        }
    }

    var subtitle: String {
        switch self {
        case .hard: return "No grace days · All habits"
        case .medium: return "2 grace days · All habits"
        case .soft: return "3 grace days · Your habits"
        }
    }

    var iconName: String {
        switch self {
        case .hard: return "flame.fill"
        case .medium: return "bolt.fill"
        case .soft: return "leaf.fill"
        }
    }

    var defaultGraceDays: Int {
        switch self {
        case .hard: return 0
        case .medium: return 2
        case .soft: return 3
        }
    }

    var defaultWorkoutCount: Int {
        switch self {
        case .hard: return 2
        case .medium, .soft: return 1
        }
    }
}

@Model
final class ProtocolConfig {
    var difficultyPresetRaw: String
    var graceDaysPerMonth: Int
    var graceUsedThisMonth: Int
    var graceResetDate: Date
    var startDate: Date
    var targetDays: Int

    var workoutEnabled: Bool
    var workoutMinutes: Int
    var workoutCountPerDay: Int
    var waterEnabled: Bool
    var waterGallons: Double
    var dietEnabled: Bool
    var readingEnabled: Bool
    var readingPages: Int
    var noAlcoholEnabled: Bool
    var progressPhotoEnabled: Bool
    var stepsEnabled: Bool
    var stepTarget: Int

    var customHabit1: String?
    var customHabit2: String?
    var customHabit3: String?

    // Custom habit icon overrides (SF Symbol names; nil = "star.fill")
    var customHabit1Icon: String?
    var customHabit2Icon: String?
    var customHabit3Icon: String?

    // Custom habit color overrides (light-mode pastel hex; nil = "#E0E0E0")
    var customHabit1ColorHex: String?
    var customHabit2ColorHex: String?
    var customHabit3ColorHex: String?

    init() {
        self.difficultyPresetRaw = DifficultyPreset.hard.rawValue
        self.graceDaysPerMonth = 0
        self.graceUsedThisMonth = 0
        self.graceResetDate = Calendar.current.startOfDay(for: .now)
        self.startDate = .now
        self.targetDays = 75
        self.workoutEnabled = true
        self.workoutMinutes = 45
        self.workoutCountPerDay = 2
        self.waterEnabled = true
        self.waterGallons = 1.0
        self.dietEnabled = true
        self.readingEnabled = true
        self.readingPages = 10
        self.noAlcoholEnabled = true
        self.progressPhotoEnabled = true
        self.stepsEnabled = true
        self.stepTarget = 10_000
        self.customHabit1 = nil
        self.customHabit2 = nil
        self.customHabit3 = nil
        self.customHabit1Icon = nil
        self.customHabit2Icon = nil
        self.customHabit3Icon = nil
        self.customHabit1ColorHex = nil
        self.customHabit2ColorHex = nil
        self.customHabit3ColorHex = nil
    }

    var difficultyPreset: DifficultyPreset {
        get { DifficultyPreset(rawValue: difficultyPresetRaw) ?? .hard }
        set { difficultyPresetRaw = newValue.rawValue }
    }

    /// 1-based day index from `startDate`, clamped to at least 1.
    var currentDay: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: .now)
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, days + 1)
    }

    var isCompleted: Bool { currentDay > targetDays }

    /// Total habit count that will be required each day given the current preset.
    var enabledHabitCount: Int {
        var count = 0
        if workoutEnabled { count += max(1, workoutCountPerDay) }
        if waterEnabled { count += 1 }
        if dietEnabled { count += 1 }
        if readingEnabled { count += 1 }
        if stepsEnabled { count += 1 }
        if noAlcoholEnabled { count += 1 }
        if progressPhotoEnabled { count += 1 }
        if customHabit1?.isEmpty == false { count += 1 }
        if customHabit2?.isEmpty == false { count += 1 }
        if customHabit3?.isEmpty == false { count += 1 }
        return count
    }

    /// Applies preset defaults — used both at initial onboarding selection and after a reset.
    func applyPresetDefaults(_ preset: DifficultyPreset) {
        difficultyPreset = preset
        graceDaysPerMonth = preset.defaultGraceDays
        graceUsedThisMonth = 0
        graceResetDate = Calendar.current.startOfDay(for: .now)
        switch preset {
        case .hard, .medium:
            workoutEnabled = true
            waterEnabled = true
            dietEnabled = true
            readingEnabled = true
            noAlcoholEnabled = true
            progressPhotoEnabled = true
            stepsEnabled = true
            workoutCountPerDay = preset.defaultWorkoutCount
        case .soft:
            workoutCountPerDay = 1
        }
    }
}
