//
//  IdentitySelectionView.swift
//  GlowProtocol
//
//  Step 3 — who are you becoming? A 2×2 grid of identity cards.
//

import SwiftUI

struct IdentitySelectionView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onContinue: () -> Void

    private struct Identity: Identifiable {
        let id: String
        let icon: String
        let title: String
        let subtitle: String
    }

    private let identities: [Identity] = [
        .init(id: "athlete", icon: "figure.run", title: "The Athlete", subtitle: "Body is the priority."),
        .init(id: "disciplined", icon: "brain.head.profile", title: "The Disciplined", subtitle: "Prove it every day."),
        .init(id: "glowup", icon: "sparkles", title: "The Glow-Up Era", subtitle: "The whole transformation."),
        .init(id: "balanced", icon: "leaf.fill", title: "The Balanced One", subtitle: "Sustainable, not extreme."),
    ]

    private let columns = [
        GridItem(.flexible(), spacing: GlowSpacing.s12),
        GridItem(.flexible(), spacing: GlowSpacing.s12),
    ]

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar

                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s24) {
                        Text(headline)
                            .font(.glowSerif(size: 32, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, GlowSpacing.s24)

                        LazyVGrid(columns: columns, spacing: GlowSpacing.s12) {
                            ForEach(identities) { identity in
                                card(identity)
                            }
                        }
                    }
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, 120)
                }

                GlowButton(title: "Continue", enabled: viewModel.selectedIdentityID != nil) {
                    onContinue()
                }
                .padding(.horizontal, GlowSpacing.s16)
                .padding(.bottom, GlowSpacing.s24)
            }
        }
    }

    private var headline: String {
        viewModel.hasName
            ? "What kind of woman are you becoming, \(viewModel.trimmedName)?"
            : "What kind of woman are you becoming?"
    }

    private func card(_ identity: Identity) -> some View {
        let selected = viewModel.selectedIdentityID == identity.id
        return Button {
            withAnimation(GlowAnimation.standard) {
                viewModel.selectedIdentityID = identity.id
            }
            HapticService.shared.play(.lightTap)
        } label: {
            VStack(alignment: .leading, spacing: GlowSpacing.s4) {
                Image(systemName: identity.icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Color.glowTextPrimary)
                Spacer(minLength: GlowSpacing.s8)
                Text(identity.title)
                    .glowText(.headline)
                    .foregroundStyle(Color.glowTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(identity.subtitle)
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(GlowSpacing.s16)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: GlowRadius.large, style: .continuous)
                    .fill(selected ? Color.glowSurfaceSecondary : Color.glowSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GlowRadius.large, style: .continuous)
                    .strokeBorder(Color.glowTextPrimary, lineWidth: selected ? 2 : 0)
            )
            .glowCardShadow()
        }
        .buttonStyle(.plain)
    }

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.glowTextPrimary)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, GlowSpacing.s4)
    }
}
