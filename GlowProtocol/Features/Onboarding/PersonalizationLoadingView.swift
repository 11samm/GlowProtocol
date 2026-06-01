//
//  PersonalizationLoadingView.swift
//  GlowProtocol
//
//  Step 10 — the psychological anchor. A short animated "build" that makes the
//  protocol feel custom-made. Auto-advances after ~2.8s. No back button.
//

import SwiftUI

struct PersonalizationLoadingView: View {
    let userName: String
    let onComplete: () -> Void

    @State private var progress: CGFloat = 0
    @State private var messageIndex = 0
    @State private var finished = false

    private var messages: [String] {
        let scrapbookOwner = userName.isEmpty ? "your" : "\(userName)'s"
        return [
            "Customizing your habit schedule...",
            "Setting up \(scrapbookOwner) scrapbook...",
            "Calculating your streak tracker...",
            "Almost ready...",
        ]
    }

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(spacing: GlowSpacing.s32) {
                Text("Building your protocol...")
                    .font(.glowSerif(size: 28, weight: .regular, italic: true))
                    .foregroundStyle(Color.glowTextPrimary)
                    .multilineTextAlignment(.center)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.glowSurfaceSecondary)
                        Capsule()
                            .fill(Color.glowTextPrimary)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 4)

                Text(messages[min(messageIndex, messages.count - 1)])
                    .glowText(.subheadline)
                    .foregroundStyle(Color.glowTextSecondary)
                    .id(messageIndex)
                    .transition(.opacity)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, GlowSpacing.s48)
        }
        .task { await runSequence() }
    }

    private func runSequence() async {
        for index in 0..<messages.count {
            withAnimation(GlowAnimation.cross) { messageIndex = index }
            withAnimation(GlowAnimation.standard) {
                progress = CGFloat(index + 1) / CGFloat(messages.count)
            }
            try? await Task.sleep(for: .seconds(0.7))
        }
        guard !finished else { return }
        finished = true
        onComplete()
    }
}
