//
//  GlowToggle.swift
//  GlowProtocol
//
//  Custom 48×28 pill toggle — never use UISwitch.
//

import SwiftUI

struct GlowToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        let trackColor = isOn ? Color.glowTextPrimary : Color.glowSurfaceSecondary
        let knobOffset: CGFloat = isOn ? 10 : -10
        Button(action: {
            HapticService.shared.play(.lightTap)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { isOn.toggle() }
        }) {
            Capsule()
                .fill(trackColor)
                .frame(width: 48, height: 28)
                .overlay(
                    Circle()
                        .fill(Color.glowSurface)
                        .frame(width: 22, height: 22)
                        .shadow(color: .black.opacity(0.08), radius: 1, y: 1)
                        .offset(x: knobOffset)
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}
