import Foundation
import Observation
import Supabase
import AuthenticationServices
import CryptoKit
import Security

@MainActor
@Observable
final class FriendsService {
    static let shared = FriendsService()
    private(set) var accountID: UUID?
    private(set) var snapshot = FriendsSnapshot.empty
    private(set) var isBusy = false
    private(set) var isRestoringSession = true
    var errorMessage: String?
    var notice: String?
    var requestedHomeTab: String?
    var pendingInviteCode: String? = UserDefaults.standard.string(forKey: "pendingFriendInvite")
    private(set) var appleAccount = false
    private var client: SupabaseClient?
    private var authTask: Task<Void, Never>?
    private var generation = 0
    private var locallyApprovedSharingAccount: UUID?
    private var summaryTask: Task<Void, Never>?
    private var latestSummary: SharedDaySummary?
    private var nonce: String?
    private var deletionNonce: String?

    var profile: FriendsProfile? { snapshot.profile }
    var accepted: [FriendConnection] { snapshot.connections.filter(\.isAccepted) }
    var requests: [FriendConnection] { snapshot.connections.filter { !$0.isAccepted } }
    var canPublish: Bool {
        accountID != nil && accountID == locallyApprovedSharingAccount && profile?.sharingEnabled == true && SubscriptionService.shared.hasAccess
    }

    func configure() {
        guard client == nil else { return }
        guard let url = AppConfiguration.supabaseProjectURL, let key = AppConfiguration.supabasePublishableKey else {
            isRestoringSession = false
            errorMessage = "Accounts are unavailable. Please contact support."
            return
        }
        let client = SupabaseClient(supabaseURL: url, supabaseKey: key, options: .init(
            auth: .init(redirectToURL: URL(string: "glowprotocol://auth/callback"))
        ))
        self.client = client
        authTask = Task { [weak self] in
            for await (_, session) in client.auth.authStateChanges {
                guard let self else { return }
                self.isRestoringSession = false
                self.updateIdentity(session)
            }
        }
    }

    private func updateIdentity(_ session: Session?) {
        let nextID = session?.user.id
        appleAccount = session?.user.identities?.contains { $0.provider == "apple" } == true
        guard nextID != accountID else { return }
        generation += 1
        snapshot = .empty
        summaryTask?.cancel()
        latestSummary = nil
        locallyApprovedSharingAccount = nil
        accountID = nextID
        if let nextID {
            SubscriptionService.shared.identify(accountID: nextID)
            // Only the same account on the same device may reuse sharing consent.
            let remembered = UserDefaults.standard.string(forKey: "friendsSharingAccount")
            if remembered == nextID.uuidString { locallyApprovedSharingAccount = nextID }
            Task { await refresh() }
        } else {
            UserDefaults.standard.removeObject(forKey: "friendsSharingAccount")
            SubscriptionService.shared.resetIdentity()
        }
    }

    func googleSignIn() async {
        await perform {
            guard let client = self.client else { throw FriendsError.unavailable }
            let session = try await client.auth.signInWithOAuth(provider: .google)
            self.updateIdentity(session)
        }
        await refresh()
    }

    func prepareApple(_ request: ASAuthorizationAppleIDRequest) {
        nonce = Self.randomNonce()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.hash(nonce!)
    }

    func finishApple(_ result: Result<ASAuthorization, Error>) async {
        let expectedNonce = nonce
        nonce = nil
        await perform {
            guard let client = self.client, let expectedNonce else { throw FriendsError.unavailable }
            let credential = try Self.appleCredential(result)
            guard let data = credential.identityToken, let token = String(data: data, encoding: .utf8) else { throw FriendsError.unavailable }
            let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: token, nonce: expectedNonce))
            self.updateIdentity(session)
        }
        await refresh()
    }

    func receiveInvite(_ url: URL) {
        guard let code = FriendInvitation.code(from: url) else { return }
        pendingInviteCode = code
        UserDefaults.standard.set(code, forKey: "pendingFriendInvite")
        notice = "An invitation is ready. Open Friends to send your request."
    }

    func refresh() async {
        guard let client, let id = accountID else { return }
        let version = generation
        do {
            let value: FriendsSnapshot = try await client.rpc("glow_friends_snapshot").execute().value
            guard accountID == id, generation == version else { return }
            snapshot = value
            errorMessage = nil
            if value.profile?.sharingEnabled != true { locallyApprovedSharingAccount = nil }
        } catch {
            guard accountID == id, generation == version else { return }
            // Do not keep potentially revoked private summaries on a failed refresh.
            snapshot = .empty
            errorMessage = "Friends couldn't refresh. Check your connection and try again. Your local progress is safe."
        }
    }

    func saveProfile(name: String) async {
        await mutate("glow_save_profile", params: ["name": name.trimmingCharacters(in: .whitespacesAndNewlines)])
    }
    func requestFriend(code: String) async {
        guard let normalized = FriendInvitation.normalizedCode(code) else {
            errorMessage = "Enter the 12-character code from your friend's invitation."
            return
        }
        let succeeded = await mutate("glow_request_friend", params: ["code": normalized])
        if succeeded {
            pendingInviteCode = nil
            UserDefaults.standard.removeObject(forKey: "pendingFriendInvite")
            notice = "Request sent. Your friend can accept it in Friends."
        }
    }
    func respond(_ friend: FriendConnection, accept: Bool) async {
        struct Params: Encodable { let connection_id: UUID; let accept: Bool }
        await mutate("glow_respond_friend", params: Params(connection_id: friend.id, accept: accept))
    }
    func remove(_ friend: FriendConnection) async {
        await mutate("glow_remove_friend", params: ["connection_id": friend.id.uuidString])
    }
    func block(_ friend: FriendConnection) async {
        await mutate("glow_block_friend", params: ["person_id": friend.personID.uuidString])
    }
    func unblock(_ person: BlockedFriend) async {
        await mutate("glow_unblock_friend", params: ["person_id": person.id.uuidString])
    }
    func report(_ friend: FriendConnection, reason: String, details: String) async {
        if await mutate("glow_report_friend", params: ["person_id": friend.personID.uuidString, "report_reason": reason, "report_details": String(details.prefix(500))]) {
            notice = "Report received. You can also block this person."
        }
    }
    func setSharing(_ enabled: Bool) async {
        guard let id = accountID else { return }
        // Stop queued writes immediately, even if the network fails.
        locallyApprovedSharingAccount = nil
        UserDefaults.standard.removeObject(forKey: "friendsSharingAccount")
        summaryTask?.cancel()
        if await mutate("glow_set_sharing", params: ["enabled": enabled]), enabled, accountID == id {
            locallyApprovedSharingAccount = id
            UserDefaults.standard.set(id.uuidString, forKey: "friendsSharingAccount")
        }
    }
    func publish(date: Date, day: Int, fraction: Double) {
        guard canPublish, let client, let id = accountID else { return }
        latestSummary = SharedDaySummary(date: date, day: day, fraction: fraction)
        guard summaryTask == nil else { return }
        let version = generation
        summaryTask = Task {
            defer { if generation == version { summaryTask = nil } }
            while let summary = latestSummary, !Task.isCancelled, canPublish, accountID == id, generation == version {
                latestSummary = nil
                do { try await client.rpc("glow_publish_summary", params: summary).execute() }
                catch {
                    if generation == version { errorMessage = "Today's summary hasn't synced. Reopen Friends to retry. Your local progress is saved." }
                    break
                }
            }
        }
    }
    func signOut() async {
        await perform {
            guard let client = self.client else { throw FriendsError.unavailable }
            try await client.auth.signOut(scope: .local)
            self.updateIdentity(nil)
        }
    }

    // Apple-linked accounts require fresh authorization so the server can revoke access.
    func prepareAppleDeletion(_ request: ASAuthorizationAppleIDRequest) {
        deletionNonce = Self.randomNonce()
        request.nonce = Self.hash(deletionNonce!)
    }
    func finishAppleDeletion(_ result: Result<ASAuthorization, Error>) async {
        let expected = deletionNonce
        deletionNonce = nil
        do {
            let credential = try Self.appleCredential(result)
            guard expected != nil, let data = credential.authorizationCode, let code = String(data: data, encoding: .utf8) else { throw FriendsError.unavailable }
            await deleteAccount(appleCode: code)
        } catch { handle(error) }
    }
    func deleteAccount(appleCode: String? = nil) async {
        await perform {
            guard let client = self.client else { throw FriendsError.unavailable }
            struct Body: Encodable { let apple_authorization_code: String? }
            struct Reply: Decodable { let deleted: Bool }
            let reply: Reply = try await client.functions.invoke("delete-account", options: .init(body: Body(apple_authorization_code: appleCode)))
            guard reply.deleted else { throw FriendsError.unavailable }
            try? await client.auth.signOut(scope: .local)
            self.updateIdentity(nil)
            self.notice = "Account deleted. Your local progress and photos are still on this device."
        }
    }

    @discardableResult
    private func mutate<P: Encodable>(_ function: String, params: P) async -> Bool {
        let id = accountID
        let result = await perform {
            guard let client = self.client, id != nil else { throw FriendsError.unavailable }
            try await client.rpc(function, params: params).execute()
        }
        let actionError = errorMessage
        if accountID == id { await refresh() }
        if !result { errorMessage = actionError }
        return result && accountID == id
    }
    @discardableResult
    private func perform(_ action: () async throws -> Void) async -> Bool {
        guard !isBusy else { return false }
        isBusy = true
        errorMessage = nil
        notice = nil
        defer { isBusy = false }
        do { try await action(); return true }
        catch { handle(error); return false }
    }
    private func handle(_ error: Error) {
        if (error as? ASAuthorizationError)?.code == .canceled || (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin { return }
        errorMessage = "That action couldn't finish. Check your connection and try again. If it persists, contact support."
    }
    private static func appleCredential(_ result: Result<ASAuthorization, Error>) throws -> ASAuthorizationAppleIDCredential {
        guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else { throw FriendsError.unavailable }
        return credential
    }
    private static func hash(_ value: String) -> String { SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined() }
    private static func randomNonce() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else { return UUID().uuidString + UUID().uuidString }
        return Data(bytes).base64EncodedString()
    }
}
private enum FriendsError: Error { case unavailable }
