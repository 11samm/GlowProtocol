//
//  DayBadge.swift
//  GlowProtocol
//
//  "Day 47" pill — small rounded badge used in the daily glow header and scrapbook cells.
//

import SwiftUI

struct DayBadge: View {
    let dayNumber: Int
    var style: Style = .primary

    enum Style {
        case primary
        case overlay
    }

    var body: some View {
        Text("Day \(dayNumber)")
            .glowText(.badge)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(background)
            )
    }

    private var foreground: Color {
        switch style {
        case .primary: return .glowTextPrimary
        case .overlay: return .white
        }
    }

    private var background: Color {
        switch style {
        case .primary: return Color.glowSurfaceSecondary
        case .overlay: return Color.black.opacity(0.4)
        }
    }
}
