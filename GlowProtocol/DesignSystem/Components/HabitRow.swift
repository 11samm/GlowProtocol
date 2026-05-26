//
//  HabitRow.swift
//  GlowProtocol
//
//  The core checklist row. 72pt tall, icon + label + status + check indicator.
//

import SwiftUI

struct HabitRow: View {
    let label: String
    let habitID: HabitID
    let isComplete: Bool
    let statusText: String
    let statusEmphasis: StatusEmphasis
    var trailing: TrailingStyle = .check
    var photoThumbnail: UIImage? = nil
    var iconSymbolOverride: String? = nil
    var iconColorOverride: Color? = nil
    var onTap: () -> Void

    enum StatusEmphasis {
        case disabled
        case secondary
        case running
    }

    enum TrailingStyle {
        case check
        case segmented(filled: Int, total: Int)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                iconView
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .glowText(.headline)
                        .foregroundStyle(isComplete ? Color.glowTextSecondary : Color.glowTextPrimary)
                        .strikethrough(false)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        if case .running = statusEmphasis {
                            Circle()
                                .fill(Color.habitWorkout)
                                .frame(width: 5, height: 5)
                                .modifier(PulseModifier())
                        }
                        Text(statusText)
                            .glowText(.caption)
                            .foregroundStyle(statusColor)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 8)
                trailingView
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 72)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var effectivePastel: Color {
        iconColorOverride ?? habitID.pastel
    }

    @ViewBuilder private var iconView: some View {
        if habitID == .progressPhoto, let thumb = photoThumbnail {
            Image(uiImage: thumb)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        } else {
            let effectiveSymbol = iconSymbolOverride ?? habitID.symbolName
            ZStack {
                Circle()
                    .fill(effectivePastel)
                    .frame(width: 36, height: 36)
                Image(systemName: effectiveSymbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.glowTextPrimary)
            }
        }
    }

    @ViewBuilder private var trailingView: some View {
        switch trailing {
        case .check:
            CheckmarkView(isComplete: isComplete, size: 28, pastel: effectivePastel)
        case .segmented(let filled, let total):
            SegmentedRing(filled: filled, total: total, pastel: effectivePastel, isComplete: isComplete)
                .frame(width: 28, height: 28)
        }
    }

    private var statusColor: Color {
        switch statusEmphasis {
        case .disabled: return .glowTextDisabled
        case .secondary: return .glowTextSecondary
        case .running: return .glowTextSecondary
        }
    }
}

struct SegmentedRing: View {
    let filled: Int
    let total: Int
    let pastel: Color
    let isComplete: Bool

    var body: some View {
        ZStack {
            ForEach(0..<total, id: \.self) { i in
                let startAngle = Angle.degrees(Double(i) / Double(total) * 360 - 90 + 2)
                let endAngle = Angle.degrees(Double(i + 1) / Double(total) * 360 - 90 - 2)
                Arc(start: startAngle, end: endAngle)
                    .stroke(
                        i < filled ? pastel : Color.glowSurfaceSecondary,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
            }
            if isComplete {
                CheckmarkView(isComplete: true, size: 28, pastel: pastel)
            }
        }
    }
}

struct Arc: Shape {
    let start: Angle
    let end: Angle

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2 - 2,
            startAngle: start,
            endAngle: end,
            clockwise: false
        )
        return p
    }
}

private struct PulseModifier: ViewModifier {
    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .opacity(animate ? 0.4 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}
