//
//  NotificationPermissionView.swift
//  GlowProtocol
//
//  Step 13 — post-paywall accountability ask. Lives after payment, where
//  goodwill is highest. Either action finishes onboarding.
//

import SwiftUI

struct NotificationPermissionView: View {
    let onFinish: () -> Void

    @State private var requesting = false

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: GlowSpacing.s24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.glowSurfaceSecondary)
                        .frame(width: 80, height: 80)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.glowTextPrimary)
                }

                Text("Let us keep\nyou accountable.")
                    .font(.glowSerif(size: 32, weight: .bold, italic: true))
                    .foregroundStyle(Color.glowTextPrimary)

                Text("We'll remind you each evening and alert you if your streak is at risk. You control the time.")
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                VStack(spacing: GlowSpacing.s12) {
                    GlowButton(title: "Enable notifications", enabled: !requesting) {
                        requesting = true
                        Task {
                            await NotificationService.shared.requestAuthorizationIfNeeded()
                            onFinish()
                        }
                    }
                    GlowButton(title: "Maybe later", style: .ghost, action: onFinish)
                }
                .padding(.bottom, GlowSpacing.s24)
            }
            .padding(.horizontal, GlowSpacing.s24)
        }
    }
}
