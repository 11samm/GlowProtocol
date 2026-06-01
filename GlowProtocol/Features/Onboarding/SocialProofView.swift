//
//  SocialProofView.swift
//  GlowProtocol
//
//  Step 6 — a momentum screen: aspirational stat + a single testimonial.
//  No back chevron; this screen only moves forward.
//

import SwiftUI

struct SocialProofView: View {
    let onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: GlowSpacing.s64)

                // Hero stat — the single serif element on this screen.
                VStack(alignment: .leading, spacing: GlowSpacing.s8) {
                    Text("94,000")
                        .font(.glowSerif(size: 72, weight: .bold, italic: true))
                        .foregroundStyle(Color.glowTextPrimary)
                    Text("women have completed their protocol.")
                        .font(.glowSans(size: 16, weight: .regular))
                        .foregroundStyle(Color.glowTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

                Rectangle()
                    .fill(Color.glowDivider)
                    .frame(height: 1)
                    .padding(.vertical, GlowSpacing.s32)

                // Testimonial
                VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                    ZStack {
                        Circle()
                            .fill(Color.glowSurfaceSecondary)
                            .frame(width: 36, height: 36)
                        Text("A.M.")
                            .font(.glowSans(size: 12, weight: .semibold))
                            .foregroundStyle(Color.glowTextSecondary)
                    }

                    Text("\u{201C}I didn't think I could do 75 days. I did 75 days twice.\u{201D}")
                        .font(.glowSans(size: 20, weight: .regular))
                        .italic()
                        .foregroundStyle(Color.glowTextPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Day 150 · Hard Protocol")
                        .font(.glowSans(size: 13, weight: .regular))
                        .foregroundStyle(Color.glowTextSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

                Spacer()

                GlowButton(title: "I'm ready.", action: onContinue)
                    .padding(.bottom, GlowSpacing.s24)
            }
            .padding(.horizontal, GlowSpacing.s24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true }
        }
    }
}
