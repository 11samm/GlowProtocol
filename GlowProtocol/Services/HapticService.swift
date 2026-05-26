//
//  HapticService.swift
//  GlowProtocol
//
//  Named haptic patterns built on CoreHaptics with UIKit fallbacks.
//

import Foundation
import CoreHaptics
import UIKit

@MainActor
final class HapticService {
    static let shared = HapticService()

    enum Pattern {
        case habitComplete
        case timerFinish
        case failState
        case graceDayPulse
        case waterTap
        case lightTap
    }

    private var engine: CHHapticEngine?
    private let supportsHaptics: Bool

    private init() {
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        prepare()
    }

    private func prepare() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                self?.startEngine()
            }
            engine?.stoppedHandler = { _ in }
            startEngine()
        } catch {
            engine = nil
        }
    }

    private func startEngine() {
        do { try engine?.start() } catch {}
    }

    func play(_ pattern: Pattern) {
        guard supportsHaptics, let engine else {
            fallback(for: pattern)
            return
        }
        startEngine()
        let events: [CHHapticEvent]
        switch pattern {
        case .habitComplete:
            events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.85),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7),
                ], relativeTime: 0),
            ]
        case .timerFinish:
            events = (0..<4).map { i in
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6),
                    ],
                    relativeTime: TimeInterval(i) * 0.12
                )
            }
        case .failState:
            events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4),
                ], relativeTime: 0),
            ]
        case .graceDayPulse:
            events = (0..<3).map { i in
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5 + 0.15 * Float(i)),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                    ],
                    relativeTime: TimeInterval(i) * 0.18
                )
            }
        case .waterTap:
            events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                ], relativeTime: 0),
            ]
        case .lightTap:
            events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                ], relativeTime: 0),
            ]
        }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            fallback(for: pattern)
        }
    }

    private func fallback(for pattern: Pattern) {
        switch pattern {
        case .habitComplete, .lightTap, .waterTap:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .timerFinish:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .failState:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .graceDayPulse:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
