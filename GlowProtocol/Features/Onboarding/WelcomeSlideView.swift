//
//  WelcomeSlideView.swift
//  GlowProtocol
//
//  Three-page paged onboarding intro.
//

import SwiftUI

struct WelcomeSlideView: View {
    @State private var page: Int = 0
    let onBegin: () -> Void

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            VStack {
                if page < 2 {
                    HStack {
                        Spacer()
                        Button("Skip") { page = 2 }
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)
                    }
                    .padding(.horizontal, GlowSpacing.s24)
                    .padding(.top, GlowSpacing.s12)
                } else {
                    Spacer().frame(height: 40)
                }

                TabView(selection: $page) {
                    statementSlide.tag(0)
                    proofSlide.tag(1)
                    invitationSlide.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                pagination
                    .padding(.bottom, GlowSpacing.s24)
            }
        }
    }

    // MARK: - Slides

    private var statementSlide: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s32) {
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text("Do it")
                    .font(.glowSerif(size: 48, weight: .bold))
                Text("with")
                    .font(.glowSerif(size: 48, weight: .regular))
                Text("discipline.")
                    .font(.glowSerif(size: 48, weight: .bold, italic: true))
            }
            .foregroundStyle(Color.glowTextPrimary)
            Text("75 days. Your rules. Your transformation.")
                .glowText(.body)
                .foregroundStyle(Color.glowTextSecondary)
            Rectangle()
                .fill(Color.glowDivider)
                .frame(width: 120, height: 1)
            Spacer().frame(height: 80)
        }
        .padding(.horizontal, GlowSpacing.s24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var proofSlide: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s32) {
            Spacer()
            Text("Your protocol.")
                .font(.glowSerif(size: 44, weight: .bold, italic: true))
                .foregroundStyle(Color.glowTextPrimary)

            VStack(alignment: .leading, spacing: 18) {
                proofRow("Customizable difficulty")
                proofRow("Grace days built in")
                proofRow("Private photo scrapbook")
            }
            Spacer().frame(height: 80)
        }
        .padding(.horizontal, GlowSpacing.s24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func proofRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.glowTextSecondary)
                .frame(width: 8, height: 8)
            Text(text)
                .glowText(.subheadline)
                .foregroundStyle(Color.glowTextPrimary)
        }
    }

    private var invitationSlide: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s24) {
            Spacer()
            Text("Ready to glow?")
                .font(.glowSerif(size: 44, weight: .bold, italic: true))
                .foregroundStyle(Color.glowTextPrimary)
            Text("Your 75 days start the moment you say so.")
                .glowText(.body)
                .foregroundStyle(Color.glowTextSecondary)
            Spacer()
            GlowButton(title: "Begin Protocol", action: onBegin)
                .padding(.bottom, GlowSpacing.s16)
        }
        .padding(.horizontal, GlowSpacing.s24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Pagination

    private var pagination: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Color.glowTextPrimary : Color.glowDivider)
                    .frame(width: i == page ? 20 : 4, height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: page)
            }
        }
    }
}
