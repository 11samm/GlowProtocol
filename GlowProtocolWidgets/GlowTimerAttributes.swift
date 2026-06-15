//
//  GlowTimerAttributes.swift
//  GlowProtocolWidgets
//
//  Duplicate of GlowProtocol/Models/GlowTimerAttributes.swift.
//  Both copies are compiled with PRODUCT_MODULE_NAME = GlowProtocol so ActivityKit
//  sees an identical fully-qualified type name from either side.
//

import ActivityKit
import Foundation

struct GlowTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// The real finish timestamp while running.
        /// Set to `Date.distantFuture` when the timer is paused so the
        /// native `Text(timerInterval:)` countdown freezes automatically.
        var endDate: Date
        /// Frozen remaining seconds — displayed as a static string when isPaused is true.
        var remainingSeconds: Int
        var isPaused: Bool
    }

    /// Habit label shown on the Dynamic Island and Lock Screen (e.g. "Workout 1").
    var workoutLabel: String
    /// Full planned duration in seconds — used to compute the progress arc.
    var totalSeconds: Int
}
