//
//  LaunchView.swift
//  GlowProtocol
//
//  Editorial logotype shown during launch. Fades into the real screen.
//

import SwiftUI

struct LaunchView: View {
    @State private var showGlow = false
    @State private var showProtocol = false
    @State private var ruleDrawn = false

    var onComplete: () -> Void = {}

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            VStack(spacing: 8) {
                Text("GLOW")
                    .font(.glowSerif(size: 52, weight: .bold))
                    .tracking(8)
                    .foregroundStyle(Color.glowTextPrimary)
                    .opacity(showGlow ? 1 : 0)

                Rectangle()
                    .fill(Color.glowDivider)
                    .frame(width: ruleDrawn ? 48 : 0, height: 1)
                    .frame(width: 48, alignment: .leading)

                Text("PROTOCOL")
                    .font(.glowSans(size: 13, weight: .medium))
                    .tracking(6)
                    .foregroundStyle(Color.glowTextSecondary)
                    .opacity(showProtocol ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { showGlow = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.3)) { ruleDrawn = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation(.easeOut(duration: 0.4)) { showProtocol = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                onComplete()
            }
        }
    }
}

#Preview {
    LaunchView()
}
