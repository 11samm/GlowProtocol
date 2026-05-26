//
//  FailStateView.swift
//  GlowProtocol
//
//  Full-screen reset moment — the most dramatic screen in the app.
//

import SwiftUI
import SwiftData
import UIKit

struct FailStateView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @AppStorage("pendingGraceAvailable") private var graceAvailable: Bool = false

    @State private var showOne = false
    @State private var showActions = false
    @State private var showGraceSheet = false
    @State private var resolved = false

    var body: some View {
        ZStack {
            Color(hex: "#0C0C0C").ignoresSafeArea()
            ParticleCanvas()
                .opacity(0.4)

            VStack(spacing: GlowSpacing.s16) {
                Spacer()
                Text("1")
                    .font(.glowSerif(size: 160, weight: .bold))
                    .foregroundStyle(Color(hex: "#F0EDE8"))
                    .scaleEffect(showOne ? 1 : 0.8)
                    .opacity(showOne ? 1 : 0)
                    .animation(GlowAnimation.thud, value: showOne)
                Text("Day One.")
                    .font(.glowSerif(size: 28, weight: .regular, italic: true))
                    .foregroundStyle(Color(hex: "#F0EDE8"))
                    .padding(.top, GlowSpacing.s8)
                Text("Every great streak starts here.\nWhat matters is that you came back.")
                    .glowText(.body)
                    .foregroundStyle(Color(hex: "#6B6560"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
                    .padding(.top, GlowSpacing.s12)
                Spacer()
                actionArea
                    .padding(.horizontal, GlowSpacing.s24)
                    .padding(.bottom, GlowSpacing.s48)
                    .opacity(showActions ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: showActions)
            }
        }
        .interactiveDismissDisabled(!resolved)
        .onAppear {
            showOne = true
            HapticService.shared.play(.failState)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showActions = true
            }
        }
        .sheet(isPresented: $showGraceSheet) {
            GraceDayConfirmView(
                onConfirm: {
                    let service = StreakService(context: context)
                    service.useGraceDay()
                    resolved = true
                    showGraceSheet = false
                    dismiss()
                },
                onCancel: { showGraceSheet = false }
            )
            .presentationDetents([.medium])
            .preferredColorScheme(.dark)
        }
    }

    @ViewBuilder
    private var actionArea: some View {
        VStack(spacing: GlowSpacing.s12) {
            if graceAvailable {
                let remaining = remainingGraceDays
                GlowButton(title: "Use grace day (\(remaining) left)", style: .secondary) {
                    showGraceSheet = true
                }
                Button {
                    acceptReset()
                } label: {
                    Text("Accept reset")
                        .glowText(.body)
                        .foregroundStyle(Color(hex: "#6B6560"))
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    acceptReset()
                } label: {
                    Text("Begin again")
                        .glowText(.headline)
                        .foregroundStyle(Color(hex: "#0C0C0C"))
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(
                            RoundedRectangle(cornerRadius: GlowRadius.small)
                                .fill(Color(hex: "#F0EDE8"))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var remainingGraceDays: Int {
        let service = StreakService(context: context)
        let cfg = service.fetchOrCreateConfig()
        return max(0, cfg.graceDaysPerMonth - cfg.graceUsedThisMonth)
    }

    private func acceptReset() {
        let service = StreakService(context: context)
        // If grace was already exhausted, evaluateDay() already performed the hard reset.
        if graceAvailable {
            service.performHardReset()
        }
        service.clearPendingDecision()
        resolved = true
        dismiss()
    }
}

// MARK: - Particle background

private struct ParticleCanvas: View {
    @State private var particles: [Particle] = (0..<30).map { _ in Particle.random() }
    @State private var date: Date = .now

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var speed: CGFloat
        static func random() -> Particle {
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                speed: CGFloat.random(in: 0.04...0.10)
            )
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { ctx, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let progress = (p.y - CGFloat(now.truncatingRemainder(dividingBy: 6)) * p.speed)
                        .truncatingRemainder(dividingBy: 1)
                    let yPos = (progress < 0 ? progress + 1 : progress) * size.height
                    let xPos = p.x * size.width
                    let path = Path(ellipseIn: CGRect(x: xPos, y: yPos, width: 2, height: 2))
                    ctx.fill(path, with: .color(Color(hex: "#F0EDE8").opacity(0.15)))
                }
            }
        }
        .ignoresSafeArea()
    }
}
