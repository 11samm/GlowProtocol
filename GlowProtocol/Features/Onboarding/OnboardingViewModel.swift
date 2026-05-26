//
//  OnboardingViewModel.swift
//  GlowProtocol
//
//  Holds intermediate state during the four-step onboarding flow.
//  At `finalize()`, the values are flushed into the ProtocolConfig singleton.
//

import Foundation
import Observation
import SwiftData

@Observable
final class OnboardingViewModel {
    var step: Step = .welcome
    var preset: DifficultyPreset?
    var graceDays: Int = 0

    var workoutEnabled = true
    var workoutMinutes = 45
    var workoutCount = 2
    var waterEnabled = true
    var dietEnabled = true
    var readingEnabled = true
    var readingPages = 10
    var stepsEnabled = true
    var noAlcoholEnabled = true
    var photoEnabled = true

    var custom1: String = ""
    var custom2: String = ""
    var custom3: String = ""

    enum Step: Int, CaseIterable {
        case welcome
        case difficulty
        case habits
        case grace
    }

    var enabledCount: Int {
        var c = 0
        if workoutEnabled { c += max(1, workoutCount) }
        if waterEnabled { c += 1 }
        if dietEnabled { c += 1 }
        if readingEnabled { c += 1 }
        if stepsEnabled { c += 1 }
        if noAlcoholEnabled { c += 1 }
        if photoEnabled { c += 1 }
        if !custom1.trimmingCharacters(in: .whitespaces).isEmpty { c += 1 }
        if !custom2.trimmingCharacters(in: .whitespaces).isEmpty { c += 1 }
        if !custom3.trimmingCharacters(in: .whitespaces).isEmpty { c += 1 }
        return c
    }

    var canContinueFromHabits: Bool { enabledCount >= 4 }

    func applyPreset(_ preset: DifficultyPreset) {
        self.preset = preset
        self.graceDays = preset.defaultGraceDays
        self.workoutCount = preset.defaultWorkoutCount
        switch preset {
        case .hard, .medium:
            workoutEnabled = true
            waterEnabled = true
            dietEnabled = true
            readingEnabled = true
            noAlcoholEnabled = true
            photoEnabled = true
            stepsEnabled = true
        case .soft:
            break
        }
    }

    func nextStep() {
        if let next = Step(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    func previousStep() {
        if let prev = Step(rawValue: step.rawValue - 1) {
            step = prev
        }
    }

    @MainActor
    func finalize(in context: ModelContext) {
        let service = StreakService(context: context)
        let config = service.fetchOrCreateConfig()
        let chosen = preset ?? .hard
        config.applyPresetDefaults(chosen)

        config.workoutEnabled = workoutEnabled
        config.workoutMinutes = workoutMinutes
        config.workoutCountPerDay = max(1, workoutCount)
        config.waterEnabled = waterEnabled
        config.dietEnabled = dietEnabled
        config.readingEnabled = readingEnabled
        config.readingPages = readingPages
        config.stepsEnabled = stepsEnabled
        config.noAlcoholEnabled = noAlcoholEnabled
        config.progressPhotoEnabled = photoEnabled

        config.customHabit1 = custom1.trimmingCharacters(in: .whitespaces).nilIfEmpty
        config.customHabit2 = custom2.trimmingCharacters(in: .whitespaces).nilIfEmpty
        config.customHabit3 = custom3.trimmingCharacters(in: .whitespaces).nilIfEmpty

        config.graceDaysPerMonth = graceDays
        config.graceUsedThisMonth = 0
        config.graceResetDate = Date.now.glowStartOfDay
        config.startDate = Date.now

        // Wipe existing day logs (rare — but onboarding implies a fresh start).
        let descriptor = FetchDescriptor<DayLog>()
        if let existing = try? context.fetch(descriptor) {
            for log in existing { context.delete(log) }
        }
        try? context.save()

        _ = service.currentDayLog()
    }
}

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
