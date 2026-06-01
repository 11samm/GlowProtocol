//
//  GoalSelectionView.swift
//  GlowProtocol
//
//  Step 4 — why does this matter? Multi-select goal pills in a wrapping layout.
//

import SwiftUI

struct GoalSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onContinue: () -> Void

    private struct Goal: Identifiable {
        let id: String
        let label: String
    }

    private let goals: [Goal] = [
        .init(id: "confident", label: "Feel confident in my body"),
        .init(id: "discipline", label: "Build unshakeable discipline"),
        .init(id: "newchapter", label: "Start a new chapter"),
        .init(id: "proveit", label: "Prove it to myself"),
        .init(id: "clarity", label: "Mental clarity"),
        .init(id: "transformation", label: "Physical transformation"),
    ]

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar

                ScrollView {
                    VStack(alignment: .leading, spacing: GlowSpacing.s16) {
                        Text("Why does this\nmatter to you?")
                            .font(.glowSerif(size: 32, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .padding(.top, GlowSpacing.s24)

                        Text("Choose everything that applies.")
                            .glowText(.body)
                            .foregroundStyle(Color.glowTextSecondary)

                        GlowFlowLayout(spacing: GlowSpacing.s8) {
                            ForEach(goals) { goal in
                                pill(goal)
                            }
                        }
                        .padding(.top, GlowSpacing.s8)
                    }
                    .padding(.horizontal, GlowSpacing.s16)
                    .padding(.bottom, 120)
                }

                GlowButton(title: "Continue", enabled: viewModel.canContinueFromGoals) {
                    onContinue()
                }
                .padding(.horizontal, GlowSpacing.s16)
                .padding(.bottom, GlowSpacing.s24)
            }
        }
    }

    private func pill(_ goal: Goal) -> some View {
        let selected = viewModel.selectedGoalIDs.contains(goal.id)
        return Button {
            withAnimation(GlowAnimation.standard) {
                if selected {
                    viewModel.selectedGoalIDs.remove(goal.id)
                } else {
                    viewModel.selectedGoalIDs.insert(goal.id)
                }
            }
            HapticService.shared.play(.lightTap)
        } label: {
            Text(goal.label)
                .glowText(.subheadline)
                .foregroundStyle(selected ? Color.glowSurface : Color.glowTextPrimary)
                .padding(.horizontal, GlowSpacing.s16)
                .frame(height: 44)
                .background(
                    Capsule(style: .continuous)
                        .fill(selected ? Color.glowTextPrimary : Color.glowSurfaceSecondary)
                )
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

// MARK: - GlowFlowLayout

/// A simple wrapping layout — places subviews left-to-right, wrapping to a new
/// row when the available width is exceeded. Used for tag/pill groups.
struct GlowFlowLayout: Layout {
    var spacing: CGFloat = GlowSpacing.s8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[CGSize]] = [[]]
        var currentRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let needed = currentRowWidth == 0 ? size.width : currentRowWidth + spacing + size.width
            if needed > maxWidth, currentRowWidth > 0 {
                rows.append([size])
                currentRowWidth = size.width
            } else {
                rows[rows.count - 1].append(size)
                currentRowWidth = needed
            }
        }

        let totalHeight = rows.reduce(CGFloat.zero) { partial, row in
            let rowHeight = row.map(\.height).max() ?? 0
            return partial + rowHeight
        } + spacing * CGFloat(max(0, rows.count - 1))

        return CGSize(width: maxWidth == .infinity ? currentRowWidth : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.minX + maxWidth {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
