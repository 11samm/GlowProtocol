//
//  View+Glow.swift
//  GlowProtocol
//
//  Reusable ViewModifiers used across the app.
//

import SwiftUI

struct GlowCardShadow: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.shadow(
            color: scheme == .dark ? .clear : Color.black.opacity(0.06),
            radius: 12,
            x: 0,
            y: 2
        )
    }
}

struct GlowFloatingShadow: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.shadow(
            color: scheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.10),
            radius: 20,
            x: 0,
            y: 4
        )
    }
}

extension View {
    func glowCardShadow() -> some View { modifier(GlowCardShadow()) }
    func glowFloatingShadow() -> some View { modifier(GlowFloatingShadow()) }

    /// Embeds the view in a standard surface card.
    func glowSurfaceCard(radius: CGFloat = GlowRadius.large) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.glowSurface)
            )
            .glowCardShadow()
    }

    /// Hides the keyboard from anywhere in the view hierarchy.
    func glowDismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

struct GlowSheetHandle: View {
    var body: some View {
        Capsule()
            .fill(Color.glowDivider)
            .frame(width: 36, height: 6)
            .padding(.top, 8)
    }
}
