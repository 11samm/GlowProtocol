//
//  DifficultyPickerView.swift
//  GlowProtocol
//
//  Step 2 — pick Hard, Medium, or Soft.
//

import SwiftUI

struct DifficultyPickerView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar
                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                        Text("How hard\nare you going?")
                            .font(.glowSerif(size: 32, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .padding(.top, GlowSpacing.s24)
                        Text("Pick the version that matches where you are right now. You can adjust later.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)

                        VStack(spacing: GlowSpacing.s12) {
                            ForEach(DifficultyPreset.allCases) { preset in
                                difficultyCard(preset)
                            }
                        }
                        .padding(.top, GlowSpacing.s16)
                    }
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, 120)
                }

                Spacer()
                GlowButton(title: "Continue", enabled: viewModel.preset != nil) {
                    onContinue()
                }
                .padding(.horizontal, GlowSpacing.s16)
                .padding(.bottom, GlowSpacing.s24)
            }
        }
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
            Text("Choose your protocol")
                .glowText(.headline)
                .foregroundStyle(Color.glowTextPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }

    private func difficultyCard(_ preset: DifficultyPreset) -> some View {
        let selected = viewModel.preset == preset
        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                viewModel.applyPreset(preset)
            }
            HapticService.shared.play(.lightTap)
        } label: {
            HStack(spacing: GlowSpacing.s16) {
                if selected {
                    Rectangle()
                        .fill(Color.glowTextPrimary)
                        .frame(width: 3)
                        .padding(.vertical, 12)
                }
                ZStack {
                    Circle()
                        .fill(Color.glowSurfaceSecondary)
                        .frame(width: 44, height: 44)
                    Image(systemName: preset.iconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.glowTextPrimary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.displayName.uppercased())
                        .glowText(.headline)
                        .foregroundStyle(Color.glowTextPrimary)
                        .tracking(2)
                    Text(preset.subtitle)
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextSecondary)
                }
                Spacer()
                if !selected {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.glowTextSecondary)
                        .padding(.trailing, GlowSpacing.s8)
                }
            }
            .padding(.horizontal, GlowSpacing.s16)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: GlowRadius.large, style: .continuous)
                    .fill(selected ? Color.glowSurfaceSecondary : Color.glowSurface)
            )
            .glowCardShadow()
        }
        .buttonStyle(.plain)
    }
}
