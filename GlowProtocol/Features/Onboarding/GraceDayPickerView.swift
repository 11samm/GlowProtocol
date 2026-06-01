//
//  GraceDayPickerView.swift
//  GlowProtocol
//
//  Step 4 — choose grace day allowance. Closes onboarding and seeds Day 1.
//

import SwiftUI

struct GraceDayPickerView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                navBar
                VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                    Text(headline)
                        .font(.glowSerif(size: 36, weight: .bold, italic: true))
                        .foregroundStyle(Color.glowTextPrimary)
                        .padding(.top, GlowSpacing.s24)
                    Text("Life happens. Grace days let you miss a day without losing your streak. Use them wisely — they're rare.")
                        .glowText(.body)
                        .foregroundStyle(Color.glowTextSecondary)
                        .lineSpacing(4)

                    Spacer().frame(height: GlowSpacing.s32)
                    stepper
                        .frame(maxWidth: .infinity)

                    Text(hint)
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, GlowSpacing.s32)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.graceDays)

                    Spacer()
                    GlowButton(title: "Start Day 1", action: onStart)
                        .padding(.bottom, GlowSpacing.s24)
                }
                .padding(.horizontal, GlowSpacing.s16)
            }
        }
    }

    private var headline: String {
        viewModel.hasName ? "Your safety net,\n\(viewModel.trimmedName)." : "Your grace days."
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
            Text("Grace")
                .glowText(.headline)
                .foregroundStyle(Color.glowTextPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }

    private var stepper: some View {
        VStack(spacing: GlowSpacing.s8) {
            HStack(spacing: GlowSpacing.s32) {
                stepperButton(symbol: "minus", disabled: viewModel.graceDays <= 0) {
                    if viewModel.graceDays > 0 { viewModel.graceDays -= 1 }
                }
                Text("\(viewModel.graceDays)")
                    .font(.glowSerif(size: 64, weight: .bold))
                    .foregroundStyle(Color.glowTextPrimary)
                    .contentTransition(.numericText(value: Double(viewModel.graceDays)))
                    .frame(minWidth: 60)
                stepperButton(symbol: "plus", disabled: viewModel.graceDays >= 5) {
                    if viewModel.graceDays < 5 { viewModel.graceDays += 1 }
                }
            }
            Text("grace days / month")
                .glowText(.caption)
                .foregroundStyle(Color.glowTextSecondary)
        }
    }

    private func stepperButton(symbol: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticService.shared.play(.lightTap)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.glowSurfaceSecondary)
                    .frame(width: 44, height: 44)
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(disabled ? Color.glowTextDisabled : Color.glowTextPrimary)
            }
        }
        .disabled(disabled)
    }

    private var hint: String {
        switch viewModel.graceDays {
        case 0: return "Strict mode. No exceptions."
        case 1...2: return "A safety net for the unexpected."
        default: return "Be honest with yourself."
        }
    }
}
