//
//  GraceDayConfirmView.swift
//  GlowProtocol
//
//  Sheet that confirms grace-day usage before applying it.
//

import SwiftUI
import SwiftData

struct GraceDayConfirmView: View {
    @Environment(\.modelContext) private var context
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#161616").ignoresSafeArea()
            VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                Capsule()
                    .fill(Color(hex: "#2C2C2C"))
                    .frame(width: 36, height: 6)
                    .frame(maxWidth: .infinity)
                    .padding(.top, GlowSpacing.s8)

                Text("Use a grace day?")
                    .font(.glowSerif(size: 28, weight: .bold, italic: true))
                    .foregroundStyle(Color(hex: "#F0EDE8"))
                    .padding(.top, GlowSpacing.s12)
                Text("Grace days: \(remaining) remaining this month")
                    .glowText(.body)
                    .foregroundStyle(Color(hex: "#6B6560"))

                Text("Your streak holds. This grace day will be deducted from your monthly allowance. Grace days reset on the 1st of each month.")
                    .glowText(.body)
                    .foregroundStyle(Color(hex: "#6B6560"))
                    .padding(GlowSpacing.s16)
                    .background(
                        RoundedRectangle(cornerRadius: GlowRadius.medium)
                            .fill(Color(hex: "#1F1F1F"))
                    )

                VStack(spacing: GlowSpacing.s12) {
                    Button {
                        HapticService.shared.play(.graceDayPulse)
                        onConfirm()
                    } label: {
                        Text("Confirm grace day")
                            .glowText(.headline)
                            .foregroundStyle(Color(hex: "#0C0C0C"))
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(
                                RoundedRectangle(cornerRadius: GlowRadius.small)
                                    .fill(Color(hex: "#F0EDE8"))
                            )
                    }
                    .buttonStyle(.plain)
                    Button {
                        onCancel()
                    } label: {
                        Text("No — accept reset")
                            .glowText(.body)
                            .foregroundStyle(Color(hex: "#6B6560"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, GlowSpacing.s12)
                Spacer()
            }
            .padding(.horizontal, GlowSpacing.s24)
            .padding(.bottom, GlowSpacing.s24)
        }
        .preferredColorScheme(.dark)
    }

    private var remaining: Int {
        let cfg = StreakService(context: context).fetchOrCreateConfig()
        return max(0, cfg.graceDaysPerMonth - cfg.graceUsedThisMonth)
    }
}
