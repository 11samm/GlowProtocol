//
//  GlowButton.swift
//  GlowProtocol
//
//  Three button variants: primary (filled), secondary (filled gray), ghost (outlined).
//

import SwiftUI

struct GlowButton: View {
    enum Style {
        case primary
        case secondary
        case ghost
        case destructive
    }

    let title: String
    var style: Style = .primary
    var enabled: Bool = true
    var fullWidth: Bool = true
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticService.shared.play(.lightTap)
            action()
        }) {
            Text(title)
                .glowText(.headline)
                .foregroundStyle(foreground)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: 54)
                .padding(.horizontal, fullWidth ? 0 : 24)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: GlowRadius.small, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GlowRadius.small, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )
                .scaleEffect(isPressed ? 0.985 : 1)
                .animation(.spring(response: 0.18, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in isPressed = true }
            .onEnded { _ in isPressed = false })
    }

    private var foreground: Color {
        guard enabled else { return .glowTextDisabled }
        switch style {
        case .primary: return .glowSurface
        case .secondary: return .glowTextPrimary
        case .ghost: return .glowTextPrimary
        case .destructive: return .glowSurface
        }
    }

    private var background: Color {
        guard enabled else { return .glowSurfaceSecondary }
        switch style {
        case .primary: return .glowTextPrimary
        case .secondary: return .glowSurfaceSecondary
        case .ghost: return .clear
        case .destructive: return .glowDestructive
        }
    }

    private var borderColor: Color {
        switch style {
        case .ghost: return .glowDivider
        default: return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .ghost: return 1
        default: return 0
        }
    }
}
