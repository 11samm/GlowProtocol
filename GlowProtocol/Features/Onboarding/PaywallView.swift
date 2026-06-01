//
//  PaywallView.swift
//  GlowProtocol
//
//  Step 12 — the hard paywall. Framed as "unlock your protocol," not "subscribe."
//
//  NOTE (dev build): payment is not wired to StoreKit yet. The unlock / restore
//  actions simply advance the flow as if the user has already paid.
//

import SwiftUI

struct PaywallView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @State private var selectedPlan: String = "monthly"

    private enum Badge {
        case mostPopular
        case savings(String)
    }

    private struct Plan: Identifiable {
        let id: String
        let name: String
        let sideNote: String?
        let price: String
        let period: String
        let badge: Badge?
    }

    // Order: Monthly (Most Popular) → Yearly (Save 86%) → Weekly.
    private let plans: [Plan] = [
        .init(id: "monthly", name: "Monthly", sideNote: nil, price: "$13", period: "/month", badge: .mostPopular),
        .init(id: "yearly", name: "Yearly", sideNote: "$3.75 / month", price: "$45", period: "/year", badge: .savings("Save 86%")),
        .init(id: "weekly", name: "Weekly", sideNote: nil, price: "$6", period: "/week", badge: nil),
    ]

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: GlowSpacing.s24) {
                        compactSummary
                            .padding(.top, GlowSpacing.s32)

                        VStack(spacing: GlowSpacing.s8) {
                            Text(headline)
                                .font(.glowSerif(size: 28, weight: .bold, italic: true))
                                .foregroundStyle(Color.glowTextPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Your protocol is ready. Unlock Glow Protocol to begin Day 1.")
                                .glowText(.body)
                                .foregroundStyle(Color.glowTextSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(spacing: GlowSpacing.s16) {
                            ForEach(plans) { plan in
                                planCard(plan)
                            }
                        }
                        .padding(.top, GlowSpacing.s8)
                    }
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, GlowSpacing.s24)
                }

                footer
            }
        }
    }

    private var headline: String {
        viewModel.hasName ? "Make it official, \(viewModel.trimmedName)." : "Make it official."
    }

    // MARK: - Compact summary

    private var compactSummary: some View {
        HStack(spacing: GlowSpacing.s12) {
            HStack(spacing: -10) {
                ForEach(Array(viewModel.summaryHabits.prefix(5))) { habit in
                    ZStack {
                        Circle().fill(habit.color)
                        Circle().strokeBorder(Color.glowSurface, lineWidth: 2)
                        Image(systemName: habit.symbol)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.glowTextPrimary)
                    }
                    .frame(width: 32, height: 32)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\((viewModel.preset ?? .hard).displayName) Protocol")
                    .glowText(.headline)
                    .foregroundStyle(Color.glowTextPrimary)
                Text("75 days · \(viewModel.enabledCount) daily habits")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
            }
            Spacer()
        }
        .padding(GlowSpacing.s16)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .fill(Color.glowSurface)
        )
        .glowCardShadow()
    }

    // MARK: - Plan card

    private func planCard(_ plan: Plan) -> some View {
        let selected = selectedPlan == plan.id
        return Button {
            withAnimation(GlowAnimation.standard) { selectedPlan = plan.id }
            HapticService.shared.play(.lightTap)
        } label: {
            HStack(spacing: GlowSpacing.s12) {
                ZStack {
                    Circle()
                        .strokeBorder(selected ? Color.glowTextPrimary : Color.glowDivider, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle().fill(Color.glowTextPrimary).frame(width: 12, height: 12)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.name)
                        .glowText(.headline)
                        .foregroundStyle(Color.glowTextPrimary)
                    if let sideNote = plan.sideNote {
                        Text(sideNote)
                            .glowText(.caption)
                            .foregroundStyle(Color.glowTextSecondary)
                    }
                }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(plan.price)
                        .glowText(.headline)
                        .foregroundStyle(Color.glowTextPrimary)
                    Text(plan.period)
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextSecondary)
                }
            }
            .padding(.horizontal, GlowSpacing.s16)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                    .fill(selected ? Color.glowSurfaceSecondary : Color.glowSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                    .strokeBorder(selected ? Color.glowTextPrimary : Color.glowDivider,
                                  lineWidth: selected ? 2 : 1)
            )
            .glowCardShadow()
            .overlay(alignment: .top) {
                badgeView(for: plan.badge)
                    .offset(y: -11)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func badgeView(for badge: Badge?) -> some View {
        switch badge {
        case .mostPopular:
            Text("MOST POPULAR")
                .glowText(.badge)
                .foregroundStyle(Color.glowSurface)
                .padding(.horizontal, GlowSpacing.s12)
                .frame(height: 22)
                .background(Capsule().fill(Color.glowTextPrimary))
        case .savings(let text):
            Text(text.uppercased())
                .glowText(.badge)
                .foregroundStyle(.white)
                .padding(.horizontal, GlowSpacing.s12)
                .frame(height: 22)
                .background(Capsule().fill(Color.glowSavings))
        case .none:
            EmptyView()
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: GlowSpacing.s12) {
            GlowButton(title: "Unlock my protocol", action: onContinue)

            Text("Recurring billing · cancel anytime in Settings. By continuing you agree to our Terms & Privacy Policy.")
                .font(.glowSans(size: 11, weight: .regular))
                .foregroundStyle(Color.glowTextDisabled)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onContinue) {
                Text("Restore purchases")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, GlowSpacing.s16)
        .padding(.top, GlowSpacing.s12)
        .padding(.bottom, GlowSpacing.s24)
        .background(
            Color.glowBackground
                .shadow(color: .black.opacity(0.04), radius: 8, y: -4)
                .ignoresSafeArea()
        )
    }
}
