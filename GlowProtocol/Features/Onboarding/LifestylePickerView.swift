//
//  LifestylePickerView.swift
//  GlowProtocol
//
//  Step 5 — your ideal day. Drives the recommended difficulty preset.
//

import SwiftUI

struct LifestylePickerView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onContinue: () -> Void

    private struct Lifestyle: Identifiable {
        let id: String
        let icon: String
        let title: String
        let subtitle: String
    }

    private let lifestyles: [Lifestyle] = [
        .init(id: "rise", icon: "sunrise.fill", title: "5AM Rise", subtitle: "Early starts, maximum output."),
        .init(id: "intense", icon: "bolt.fill", title: "Intense & Focused", subtitle: "All in, no excuses."),
        .init(id: "balanced", icon: "heart.fill", title: "Balanced & Sustainable", subtitle: "Consistency over intensity."),
        .init(id: "soft", icon: "leaf.fill", title: "Soft & Intentional", subtitle: "Progress at your own pace."),
    ]

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar

                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                        Text("What does your\nideal day look like?")
                            .font(.glowSerif(size: 32, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .padding(.top, GlowSpacing.s24)

                        Text("This helps us recommend your difficulty level.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)

                        VStack(spacing: GlowSpacing.s12) {
                            ForEach(lifestyles) { lifestyle in
                                card(lifestyle)
                            }
                        }
                        .padding(.top, GlowSpacing.s16)
                    }
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, 120)
                }

                GlowButton(title: "Continue", enabled: viewModel.selectedLifestyleID != nil) {
                    onContinue()
                }
                .padding(.horizontal, GlowSpacing.s16)
                .padding(.bottom, GlowSpacing.s24)
            }
        }
    }

    private func card(_ lifestyle: Lifestyle) -> some View {
        let selected = viewModel.selectedLifestyleID == lifestyle.id
        return Button {
            withAnimation(GlowAnimation.standard) {
                viewModel.selectedLifestyleID = lifestyle.id
            }
            HapticService.shared.play(.lightTap)
        } label: {
            HStack(spacing: GlowSpacing.s16) {
                ZStack {
                    Circle()
                        .fill(Color.glowSurfaceSecondary)
                        .frame(width: 44, height: 44)
                    Image(systemName: lifestyle.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.glowTextPrimary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(lifestyle.title)
                        .glowText(.headline)
                        .foregroundStyle(Color.glowTextPrimary)
                    Text(lifestyle.subtitle)
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, GlowSpacing.s16)
            .frame(height: 100)
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
