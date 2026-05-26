//
//  CustomHabitIconPickerSheet.swift
//  GlowProtocol
//
//  Reusable sheet for picking a custom habit's SF Symbol icon and pastel color.
//  Presented from HabitCustomizerView (onboarding) and EditHabitsSheet (settings).
//

import SwiftUI

struct CustomHabitIconPickerSheet: View {
    @Binding var selectedSymbol: String
    @Binding var selectedColorHex: String
    var onDone: () -> Void

    static let icons: [String] = [
        "star.fill",       "dumbbell.fill",    "cross.fill",       "headphones",
        "nosign",          "heart.fill",        "bolt.fill",        "moon.fill",
        "flame.fill",      "figure.walk",       "music.note",       "pencil",
        "bed.double.fill", "brain.fill",        "fork.knife",       "leaf.fill",
    ]

    static let pastels: [(hex: String, color: Color)] = [
        ("#D4E8C2", .habitWorkout),
        ("#C2DCF0", .habitWater),
        ("#F5E6C8", .habitDiet),
        ("#E8D4F0", .habitReading),
        ("#C8EAE0", .habitSteps),
        ("#FAE0E0", .habitNoAlcohol),
        ("#FFF0C2", .habitPhoto),
        ("#E0E0E0", .habitCustom),
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GlowSheetHandle()
                .padding(.top, GlowSpacing.s8)

            Text("Customize icon")
                .font(.glowSerif(size: 24, weight: .bold, italic: true))
                .foregroundStyle(Color.glowTextPrimary)
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.top, GlowSpacing.s16)

            // MARK: Icon section
            Text("ICON")
                .glowText(.badge)
                .foregroundStyle(Color.glowTextSecondary)
                .tracking(1)
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.top, GlowSpacing.s16)
                .padding(.bottom, GlowSpacing.s8)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Self.icons, id: \.self) { symbol in
                    let isSelected = selectedSymbol == symbol
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                            selectedSymbol = symbol
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.glowTextPrimary : Color.glowSurfaceSecondary)
                                .frame(width: 48, height: 48)
                            Image(systemName: symbol)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(isSelected ? Color.glowSurface : Color.glowTextPrimary)
                        }
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3, dampingFraction: 0.72), value: selectedSymbol)
                }
            }
            .padding(.horizontal, GlowSpacing.s24)

            // MARK: Color section
            Text("COLOR")
                .glowText(.badge)
                .foregroundStyle(Color.glowTextSecondary)
                .tracking(1)
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.top, GlowSpacing.s16)
                .padding(.bottom, GlowSpacing.s8)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 8),
                spacing: 8
            ) {
                ForEach(Self.pastels, id: \.hex) { pastel in
                    let isSelected = selectedColorHex == pastel.hex
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                            selectedColorHex = pastel.hex
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: pastel.hex))
                                .frame(width: 36, height: 36)
                            if isSelected {
                                Circle()
                                    .strokeBorder(Color.glowTextPrimary, lineWidth: 2.5)
                                    .frame(width: 36, height: 36)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: selectedColorHex)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, GlowSpacing.s24)

            GlowButton(title: "Done") {
                onDone()
            }
            .padding(.horizontal, GlowSpacing.s24)
            .padding(.top, GlowSpacing.s16)
            .padding(.bottom, GlowSpacing.s16)

            Spacer()
        }
        .background(Color.glowBackground.ignoresSafeArea())
        .presentationDetents([.medium])
    }
}
