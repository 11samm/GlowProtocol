//
//  GlowTimerAttributes.swift
//  GlowProtocol
//
//  ActivityKit attributes for the workout timer Live Activity.
//
//  IMPORTANT: This file is compiled by both the GlowProtocol app target and the
//  GlowProtocolWidgets extension target (which sets PRODUCT_MODULE_NAME = GlowProtocol).
//  That makes the fully-qualified type name identical in both modules so ActivityKit
//  can decode the same activity from either side.
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
