//
//  CheckmarkView.swift
//  GlowProtocol
//
//  Animated checkmark with spring scale + opacity. Used everywhere a habit
//  flips from incomplete to complete.
//

import SwiftUI

struct CheckmarkView: View {
    let isComplete: Bool
    let size: CGFloat
    let pastel: Color

    @State private var animatedScale: CGFloat = 1.0

    init(isComplete: Bool, size: CGFloat = 28, pastel: Color = .glowDivider) {
        self.isComplete = isComplete
        self.size = size
        self.pastel = pastel
    }

    var body: some View {
        ZStack {
            // Incomplete pastel ring
            Circle()
                .stroke(pastel, lineWidth: 2)
                .frame(width: size, height: size)
                .opacity(isComplete ? 0 : 1)

            // Complete filled circle + check
            ZStack {
                Circle()
                    .fill(Color.glowCheckComplete)
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(Color.glowSurface)
            }
            .frame(width: size, height: size)
            .scaleEffect(isComplete ? animatedScale : 0.7)
            .opacity(isComplete ? 1 : 0)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: isComplete)
        .onChange(of: isComplete) { _, newValue in
            if newValue {
                animatedScale = 0.7
                withAnimation(.spring(response: 0.18, dampingFraction: 0.55)) { animatedScale = 1.15 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.18, dampingFraction: 0.85)) { animatedScale = 1.0 }
                }
            }
        }
    }
}
