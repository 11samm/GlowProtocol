//
//  Animations.swift
//  GlowProtocol
//
//  Shared animation curves. The whole app uses springs, not easing.
//

import SwiftUI

enum GlowAnimation {
    /// Standard spring for state-driven UI changes (button presses, toggles, row sorts).
    static let standard = Animation.spring(response: 0.35, dampingFraction: 0.72)

    /// Slightly slower spring for ring fills and percentage transitions.
    static let ring = Animation.spring(response: 0.45, dampingFraction: 0.80)

    /// Soft cross-dissolve.
    static let cross = Animation.easeInOut(duration: 0.25)

    /// Subtle highlight flash (used in all-done shimmer).
    static let flash = Animation.easeInOut(duration: 0.15)

    /// Heavy "thud" spring for fail-state numeral arrival.
    static let thud = Animation.spring(response: 0.6, dampingFraction: 0.65)
}

extension AnyTransition {
    /// Soft slide-and-fade — used when habits move between incomplete/complete buckets.
    static var glowMove: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
}
