//
//  Colors.swift
//  GlowProtocol
//
//  The full color token system. Light + dark mode pairs for every UI surface.
//

import SwiftUI

extension Color {
    // MARK: - Hex initializer

    init(hex: String, alpha: Double = 1.0) {
        var clean = hex
        if clean.hasPrefix("#") { clean.removeFirst() }
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    // MARK: - Dynamic color helper

    static func dynamic(light: String, dark: String) -> Color {
        Color(UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(Color(hex: hex))
        })
    }

    // MARK: - Primary surfaces

    /// Root screen background — warm off-white (light) / near-black (dark).
    static let glowBackground = Color.dynamic(light: "#F7F5F2", dark: "#0C0C0C")

    /// Elevated card / sheet surface — pure white (light) / soft black (dark).
    static let glowSurface = Color.dynamic(light: "#FFFFFF", dark: "#161616")

    /// Input fields, secondary row fills.
    static let glowSurfaceSecondary = Color.dynamic(light: "#EFECE7", dark: "#1F1F1F")

    /// Hairlines and separators.
    static let glowDivider = Color.dynamic(light: "#E5E0D8", dark: "#2C2C2C")

    // MARK: - Text

    /// Headlines, habit names, body copy.
    static let glowTextPrimary = Color.dynamic(light: "#141414", dark: "#F0EDE8")

    /// Captions, timestamps.
    static let glowTextSecondary = Color.dynamic(light: "#9A9188", dark: "#6B6560")

    /// Placeholder text, unchecked habit labels in disabled state.
    static let glowTextDisabled = Color.dynamic(light: "#C5BFB7", dark: "#3A3A3A")

    // MARK: - Habit pastels

    static let habitWorkout = Color.dynamic(light: "#D4E8C2", dark: "#2A3D22")
    static let habitWater = Color.dynamic(light: "#C2DCF0", dark: "#1A2E3D")
    static let habitDiet = Color.dynamic(light: "#F5E6C8", dark: "#3D2E1A")
    static let habitReading = Color.dynamic(light: "#E8D4F0", dark: "#2E1A3D")
    static let habitSteps = Color.dynamic(light: "#C8EAE0", dark: "#1A3330")
    static let habitNoAlcohol = Color.dynamic(light: "#FAE0E0", dark: "#3D1F1F")
    static let habitPhoto = Color.dynamic(light: "#FFF0C2", dark: "#3D3010")
    static let habitCustom = Color.dynamic(light: "#E0E0E0", dark: "#282828")

    // MARK: - Semantic

    /// Filled checkmark circle (adapts to mode — black in light, warm white in dark).
    static let glowCheckComplete = Color.dynamic(light: "#141414", dark: "#F0EDE8")

    /// Destructive states (fail-state CTA, reset confirmation).
    static let glowDestructive = Color.dynamic(light: "#D94040", dark: "#FF6B6B")

    /// Background tint for soft destructive surfaces in light mode.
    static let glowDestructiveSoft = Color.dynamic(light: "#FAE8E8", dark: "#3D1F1F")

    /// Grace day pulse / accent — warm amber.
    static let glowGracePulse = Color.dynamic(light: "#F5DFA0", dark: "#8C6D2A")

    /// Savings badge accent — a refined forest green for the paywall "Save" tag.
    /// Used only as a small pill background, never a full surface.
    static let glowSavings = Color.dynamic(light: "#2E7D52", dark: "#3FA56E")
}
