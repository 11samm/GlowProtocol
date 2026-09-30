import SwiftUI

/// StoreKit pricing and purchase buttons are rendered by Superwall.
struct SubscriptionAccessView: View {
    var placement = "subscription_access"
    var onAccess: () -> Void = {}
    @State private var subscription = SubscriptionService.shared

    var body: some View {
        VStack(spacing: GlowSpacing.s24) {
            Text("Unlock your protocol")
                .font(.glowSerif(size: 28, weight: .bold, italic: true))
            Text("Subscribe or restore your subscription to continue. Your saved progress is still here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.glowTextSecondary)
            GlowButton(title: "View subscription options") {
                subscription.requestAccess(placement: placement, onAccess: onAccess)
            }
            .disabled(subscription.isBusy)
            Button("Restore purchases") {
                Task { await subscription.restore(onAccess: onAccess) }
            }
            .disabled(subscription.isBusy)
            if subscription.isBusy { ProgressView() }
            Link("Contact support", destination: AppConfiguration.supportMailURL)
                .foregroundStyle(Color.glowTextSecondary)
            if let error = subscription.errorMessage {
                Text(error)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.glowTextSecondary)
            }
        }
        .padding(GlowSpacing.s24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.glowBackground.ignoresSafeArea())
    }
}

struct PaywallView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        SubscriptionAccessView(placement: "onboarding_complete", onAccess: onContinue)
    }
}
