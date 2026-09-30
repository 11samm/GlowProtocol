import Foundation
import Combine
import Observation
import SuperwallKit

/// Superwall owns StoreKit purchases and entitlement refreshes. Local progress
/// is never deleted when a subscription expires or an identity changes.
@MainActor
@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    private(set) var status: SubscriptionStatus = .unknown
    private(set) var isBusy = false
    var errorMessage: String?
    private var configured = false
    private var statusObserver: AnyCancellable?

    var hasAccess: Bool { status.isActive }

    func configure() {
        guard !configured, let key = AppConfiguration.superwallPublicAPIKey else { return }
        Superwall.configure(apiKey: key)
        configured = true
        status = Superwall.shared.subscriptionStatus
        statusObserver = Superwall.shared.$subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.status = value
                WidgetSnapshotService.updateAccess(value.isActive)
            }
        Superwall.shared.setUserAttributes(["app_cohort": "ios_v1"])
    }

    // The current app has no login. Keep Superwall's persistent anonymous ID.
    // Friends authentication must call these hooks with the account's UUID.
    func identify(accountID: UUID) {
        guard configured else { return }
        Superwall.shared.identify(userId: accountID.uuidString)
    }

    func resetIdentity() {
        guard configured else { return }
        Superwall.shared.reset()
    }

    func setOnboardingAttributes(preset: String, habitCount: Int) {
        guard configured else { return }
        Superwall.shared.setUserAttributes([
            "protocol_preset": preset,
            "enabled_habit_count": habitCount,
            "challenge_days": 75
        ])
    }

    func requestAccess(placement: String, onAccess: @escaping () -> Void) {
        guard configured else {
            errorMessage = "Subscriptions are unavailable. Please try again later."
            return
        }
        guard !isBusy else { return }
        if Superwall.shared.subscriptionStatus.isActive {
            status = Superwall.shared.subscriptionStatus
            onAccess()
            return
        }
        isBusy = true
        errorMessage = nil
        let handler = PaywallPresentationHandler()
        handler.onError { [weak self] _ in
            Task { @MainActor in
                self?.isBusy = false
                self?.errorMessage = "The subscription screen couldn't load. Check your connection and try again."
            }
        }
        handler.onDismiss { [weak self] _, _ in
            Task { @MainActor in self?.isBusy = false }
        }
        handler.onSkip { [weak self] _ in
            Task { @MainActor in
                self?.isBusy = false
                if !Superwall.shared.subscriptionStatus.isActive {
                    self?.errorMessage = "Subscriptions are unavailable. Please try again later."
                }
            }
        }
        Superwall.shared.register(placement: placement, handler: handler) { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.isBusy = false
                self.status = Superwall.shared.subscriptionStatus
                // Campaign omissions, holdouts, and non-gated dismissals must
                // never grant this app's mandatory subscription access.
                guard self.hasAccess else {
                    self.errorMessage = "An active subscription is required to unlock your protocol."
                    return
                }
                onAccess()
            }
        }
    }

    func restore(onAccess: @escaping () -> Void = {}) async {
        guard configured, !isBusy else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        let result = await Superwall.shared.restorePurchases()
        status = Superwall.shared.subscriptionStatus
        if case .restored = result, hasAccess {
            onAccess()
        } else {
            errorMessage = "No active subscription could be restored. Check your Apple Account or try again later."
        }
    }
}
