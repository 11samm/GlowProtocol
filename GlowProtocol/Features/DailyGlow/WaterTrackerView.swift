//
//  WaterTrackerView.swift
//  GlowProtocol
//
//  A tactile 8-band bottle that fills as the user taps. Auto-completes the habit.
//

import SwiftUI

struct WaterTrackerView: View {
    let entry: HabitEntry
    @Bindable var viewModel: DailyGlowViewModel
    @Environment(\.dismiss) private var dismiss

    private var taps: Int {
        get { viewModel.waterTaps[entry.persistentModelID.idString] ?? 0 }
    }

    private func setTaps(_ value: Int) {
        viewModel.waterTaps[entry.persistentModelID.idString] = value
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.glowSurface.ignoresSafeArea()
            VStack(spacing: GlowSpacing.s16) {
                GlowSheetHandle()
                Text("Water intake")
                    .glowText(.headline)
                    .foregroundStyle(Color.glowTextPrimary)
                Text("Tap a glass to log it")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
                    .padding(.bottom, GlowSpacing.s16)

                bottle
                    .padding(.horizontal, GlowSpacing.s48)

                Text(taps >= 8 ? "1 gallon complete" : "\(taps) / 8 glasses")
                    .font(.glowSerif(size: 24, weight: .regular))
                    .foregroundStyle(Color.glowTextPrimary)
                    .padding(.top, GlowSpacing.s12)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: taps)

                Spacer()

                GlowButton(title: "Done", style: .secondary) {
                    dismiss()
                }
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.bottom, GlowSpacing.s24)
            }
        }
        .onChange(of: taps) { _, newValue in
            if newValue >= 8 {
                viewModel.completeHabit(entry, metadata: #"{"tapsCompleted":8}"#)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }
    }

    private var bottle: some View {
        GeometryReader { geo in
            let bandHeight = geo.size.height / 8
            VStack(spacing: 0) {
                ForEach((0..<8).reversed(), id: \.self) { index in
                    band(index: index, height: bandHeight)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(taps >= 8 ? Color.glowTextPrimary : Color.glowDivider, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .frame(width: 120, height: 240)
        .frame(maxWidth: .infinity)
    }

    private func band(index: Int, height: CGFloat) -> some View {
        let filled = index < taps
        return Rectangle()
            .fill(filled ? Color.habitWater : Color.glowSurfaceSecondary)
            .frame(height: height)
            .contentShape(Rectangle())
            .onTapGesture {
                let newTaps = index + 1
                if newTaps != taps {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        setTaps(newTaps)
                    }
                    HapticService.shared.play(.waterTap)
                }
            }
    }
}
