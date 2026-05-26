//
//  ProgressRing.swift
//  GlowProtocol
//
//  Circular progress view used everywhere: daily checklist, workout timer, widgets.
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var trackColor: Color = .glowSurfaceSecondary
    var fillColor: Color = .glowTextPrimary
    var animation: Animation? = GlowAnimation.ring

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(fillColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(animation, value: progress)
        }
    }
}

#Preview {
    ProgressRing(progress: 0.66)
        .frame(width: 120, height: 120)
        .padding()
}
