import SwiftUI
import AuthenticationServices
import SwiftData

struct FriendsView: View {
    /// Account recovery/deletion stays reachable even after subscription expiry.
    var accountOnly = false
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var friends = FriendsService.shared
    @State private var subscription = SubscriptionService.shared
    @State private var displayName = ""
    @State private var code = ""
    @State private var showAccount = false
    @State private var showPrivacy = false
    @State private var share = false
    @State private var reportTarget: FriendConnection?
    @State private var destructiveTarget: FriendConnection?
    @State private var destructiveIsBlock = false
    @ScaledMetric private var titleSize = 36.0

    private var paid: Bool { subscription.hasAccess && !accountOnly }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                if friends.isRestoringSession {
                    ProgressView("Opening your account…").frame(maxWidth: .infinity).padding(.vertical, 40)
                } else if friends.accountID == nil {
                    signIn
                } else if friends.profile == nil {
                    profileSetup
                } else {
                    inviteCard
                    codeEntry
                    if paid {
                        sharingCard
                        requests
                        circle
                    } else {
                        Text("Your account and invitations are available here. A subscription unlocks tracking and friends' daily summaries.")
                            .foregroundStyle(FriendsStyle.secondary)
                    }
                }
                messages
                HStack(spacing: 20) {
                    Button("Privacy") { showPrivacy = true }
                    Link("Support", destination: AppConfiguration.supportMailURL)
                }
                .font(.footnote)
                .foregroundStyle(FriendsStyle.secondary)
                Color.clear.frame(height: accountOnly ? 24 : 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .background(Color.glowBackground.ignoresSafeArea())
        .refreshable { await friends.refresh(); syncSummary() }
        .task {
            friends.configure()
            code = friends.pendingInviteCode ?? ""
            await friends.refresh()
            syncSummary()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await friends.refresh(); syncSummary() } }
        }
        .onChange(of: friends.pendingInviteCode) { _, value in if let value { code = value } }
        .onChange(of: friends.accountID) { _, _ in displayName = ""; showAccount = false }
        .sheet(isPresented: $showAccount) { FriendsAccountView() }
        .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
        .sheet(isPresented: $share) {
            if let profile = friends.profile { FriendsShareSheet(items: [FriendInvitation.shareText(profile: profile)]) }
        }
        .sheet(item: $reportTarget) { friend in FriendReportView(friend: friend) }
        .confirmationDialog(destructiveIsBlock ? "Block this person?" : "Remove this connection?", isPresented: Binding(get: { destructiveTarget != nil }, set: { if !$0 { destructiveTarget = nil } }), titleVisibility: .visible) {
            Button(destructiveIsBlock ? "Block" : "Remove", role: .destructive) {
                if let friend = destructiveTarget {
                    Task {
                        if destructiveIsBlock { await friends.block(friend) } else { await friends.remove(friend) }
                    }
                }
                destructiveTarget = nil
            }
        } message: {
            Text(destructiveIsBlock ? "This removes your connection, hides shared progress, and prevents new requests between you." : "Your daily summaries will no longer be visible to each other.")
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Friends").font(.glowSerif(size: titleSize, italic: true))
                Text("A little company for your 75 days.")
                    .font(.subheadline).foregroundStyle(FriendsStyle.secondary)
            }
            Spacer()
            if friends.accountID != nil {
                Button { showAccount = true } label: {
                    Image(systemName: "person.crop.circle").font(.title2)
                        .frame(width: 48, height: 48).background(Color.glowSurface, in: Circle())
                }
                .accessibilityLabel("Account and privacy")
            }
        }
        .foregroundStyle(Color.glowTextPrimary)
    }

    private var signIn: some View {
        VStack(alignment: .leading, spacing: 24) {
            FriendsMotif().frame(height: 125).frame(maxWidth: .infinity).accessibilityHidden(true)
            Text("Better, together.").font(.glowSerif(size: 30))
            Text("Invite someone you know. Keep each other company, and choose whether to share your daily completion.")
                .font(.body).foregroundStyle(FriendsStyle.secondary)
            SignInWithAppleButton(.continue, onRequest: friends.prepareApple) { result in
                Task { await friends.finishApple(result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52).clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(friends.isBusy)
            Button { Task { await friends.googleSignIn() } } label: {
                Text("Continue with Google").font(.body.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.glowSurface, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.glowDivider))
            }
            .disabled(friends.isBusy)
            Text("An account is needed for Friends. Solo tracking doesn't require one.")
                .font(.footnote).foregroundStyle(FriendsStyle.secondary)
        }
        .foregroundStyle(Color.glowTextPrimary)
    }

    private var profileSetup: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Make yourself at home.").font(.glowSerif(size: 28))
            Text("What should your friends call you? This is the name they'll see on your invitation and in their circle.")
                .foregroundStyle(FriendsStyle.secondary)
            TextField("Your first name or nickname", text: $displayName)
                .textContentType(.nickname).submitLabel(.done).friendsField()
                .onChange(of: displayName) { _, value in displayName = String(value.prefix(32)) }
            FriendsPrimaryButton(title: "Create my profile", disabled: friends.isBusy || displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                Task { await friends.saveProfile(name: displayName) }
            }
            Button("Refresh account") { Task { await friends.refresh() } }.font(.footnote)
        }.friendsCard()
    }

    private var inviteCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("SOMEONE IN YOUR CORNER").font(.caption2.weight(.semibold)).tracking(1.5)
                Spacer()
                Image(systemName: "heart").foregroundStyle(FriendsStyle.secondary)
            }
            Text("Your invitation").font(.glowSerif(size: 27))
            Text("Send a little encouragement. Your friend can enter this code in Friends to request a connection.")
                .font(.subheadline).foregroundStyle(FriendsStyle.secondary)
            if let profile = friends.profile {
                HStack {
                    Text(profile.inviteCode).font(.system(.title3, design: .monospaced).weight(.medium)).textSelection(.enabled)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = profile.inviteCode
                        friends.notice = "Invitation code copied."
                    } label: { Image(systemName: "doc.on.doc").frame(width: 44, height: 44) }
                    .accessibilityLabel("Copy invitation code")
                }
            }
            FriendsPrimaryButton(title: "Invite a friend", icon: "square.and.arrow.up") { share = true }
        }.friendsCard()
    }

    private var codeEntry: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Have a friend's code?").font(.subheadline.weight(.semibold))
            TextField("12-character invitation code", text: $code)
                .textInputAutocapitalization(.characters).autocorrectionDisabled().friendsField()
                .onChange(of: code) { _, value in code = String(value.prefix(12)) }
            Button("Send connection request") { Task { await friends.requestFriend(code: code) } }
                .font(.subheadline.weight(.semibold)).frame(minHeight: 44)
                .disabled(friends.isBusy || FriendInvitation.normalizedCode(code) == nil)
            Text("They'll accept before you can see each other's shared progress.")
                .font(.footnote).foregroundStyle(FriendsStyle.secondary)
        }
    }

    private var sharingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Share my daily completion", isOn: Binding(
                get: { friends.canPublish },
                set: { enabled in Task { await friends.setSharing(enabled); syncSummary() } }
            ))
            .tint(FriendsStyle.sageInk).disabled(friends.isBusy)
            Text("Accepted friends can see your day number and completion percentage. Your photos and habit details stay private.")
                .font(.footnote).foregroundStyle(FriendsStyle.secondary)
            if friends.profile?.sharingEnabled == true && !friends.canPublish {
                Text("Sharing was enabled on your account. Confirm above to share this device's routine, or turn account sharing off below.")
                    .font(.footnote).foregroundStyle(FriendsStyle.secondary)
                Button("Turn account sharing off") { Task { await friends.setSharing(false) } }
                    .font(.footnote).disabled(friends.isBusy)
            }
        }.friendsCard()
    }

    @ViewBuilder private var requests: some View {
        if !friends.requests.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                sectionTitle("Invitations", count: friends.requests.count)
                ForEach(friends.requests) { friend in
                    VStack(alignment: .leading, spacing: 12) {
                        personHeading(friend)
                        if friend.incoming {
                            HStack(spacing: 20) {
                                Button("Accept") { Task { await friends.respond(friend, accept: true) } }.fontWeight(.semibold)
                                Button("Decline") { Task { await friends.respond(friend, accept: false) } }.foregroundStyle(FriendsStyle.secondary)
                            }.frame(minHeight: 44).disabled(friends.isBusy)
                        } else {
                            HStack {
                                Text("Waiting for acceptance").font(.footnote).foregroundStyle(FriendsStyle.secondary)
                                Spacer()
                                Button("Cancel") { Task { await friends.remove(friend) } }.font(.footnote).frame(minHeight: 44).disabled(friends.isBusy)
                            }
                        }
                    }.friendsCard()
                }
            }
        }
    }
    private var circle: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Your circle", count: friends.accepted.count)
            if friends.accepted.isEmpty {
                VStack(spacing: 14) {
                    FriendsMotif().frame(height: 70).accessibilityHidden(true)
                    Text("Your circle starts here.").font(.glowSerif(size: 23))
                    Text("Invite a friend, accept their request, and take it one day at a time.")
                        .font(.subheadline).multilineTextAlignment(.center).foregroundStyle(FriendsStyle.secondary)
                }.frame(maxWidth: .infinity).padding(.vertical, 24)
            }
            ForEach(friends.accepted) { friend in
                VStack(alignment: .leading, spacing: 18) {
                    personHeading(friend)
                    if let day = friend.dayNumber, let percent = friend.completionPercent, let date = friend.localDate {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle().stroke(Color.glowDivider, lineWidth: 4)
                                Circle().trim(from: 0, to: CGFloat(percent) / 100).stroke(FriendsStyle.sageInk, style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90))
                                Text("\(percent)%").font(.caption.weight(.semibold))
                            }.frame(width: 56, height: 56)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Day \(day) of 75").font(.subheadline.weight(.medium))
                                Text("Shared \(date)").font(.footnote).foregroundStyle(FriendsStyle.secondary)
                            }
                        }.accessibilityElement(children: .combine)
                    } else {
                        Text("No shared update yet.").font(.subheadline).foregroundStyle(FriendsStyle.secondary)
                    }
                }.friendsCard()
            }
        }
    }
    private func sectionTitle(_ title: String, count: Int) -> some View {
        HStack {
            Text(title).font(.glowSerif(size: 24))
            Spacer()
            Text("\(count)").font(.footnote).foregroundStyle(FriendsStyle.secondary)
        }
    }
    private func personHeading(_ friend: FriendConnection) -> some View {
        HStack(spacing: 12) {
            Text(String(friend.displayName.prefix(1)).uppercased())
                .font(.glowSerif(size: 22)).frame(width: 48, height: 48).background(FriendsStyle.sage, in: Circle())
            Text(friend.displayName).font(.body.weight(.semibold))
            Spacer()
            Menu {
                Button("Report", systemImage: "flag") { reportTarget = friend }
                Button("Remove", systemImage: "person.badge.minus", role: .destructive) { destructiveTarget = friend; destructiveIsBlock = false }
                Button("Block", systemImage: "hand.raised", role: .destructive) { destructiveTarget = friend; destructiveIsBlock = true }
            } label: { Image(systemName: "ellipsis").frame(width: 44, height: 44) }
            .accessibilityLabel("Manage connection with \(friend.displayName)").disabled(friends.isBusy)
        }
    }
    @ViewBuilder private var messages: some View {
        if friends.isBusy { ProgressView("One moment…").frame(maxWidth: .infinity) }
        if let error = friends.errorMessage {
            VStack(alignment: .leading, spacing: 10) {
                Text(error).font(.subheadline)
                Button("Try refreshing") { Task { await friends.refresh() } }.frame(minHeight: 44)
            }.foregroundStyle(FriendsStyle.secondary)
        }
        if let notice = friends.notice { Text(notice).font(.subheadline).foregroundStyle(FriendsStyle.secondary).accessibilityAddTraits(.updatesFrequently) }
    }
    private func syncSummary() {
        guard friends.canPublish else { return }
        let service = StreakService(context: context)
        let log = service.currentDayLog()
        friends.publish(date: log.date, day: log.dayNumber, fraction: log.completionPercentage)
    }
}

struct FriendsAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var friends = FriendsService.shared
    @State private var name = ""
    @State private var deleteConfirm = false
    @State private var signOutConfirm = false
    @State private var appleDeletionReady = false
    var body: some View {
        NavigationStack {
            Form {
                Section("Display name") {
                    TextField("Name", text: $name).textContentType(.nickname)
                        .onChange(of: name) { _, value in name = String(value.prefix(32)) }
                    Button("Save name") { Task { await friends.saveProfile(name: name) } }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || friends.isBusy)
                }
                if !friends.snapshot.blocked.isEmpty {
                    Section("Blocked accounts") {
                        ForEach(friends.snapshot.blocked) { person in
                            HStack { Text(person.displayName); Spacer(); Button("Unblock") { Task { await friends.unblock(person) } }.disabled(friends.isBusy) }
                        }
                    }
                }
                Section("Account") {
                    Button("Sign out") { signOutConfirm = true }.disabled(friends.isBusy)
                    Button("Delete account", role: .destructive) { deleteConfirm = true }.disabled(friends.isBusy)
                    if appleDeletionReady {
                        Text("Confirm with Apple to revoke access and delete your account.").font(.footnote)
                        SignInWithAppleButton(.continue, onRequest: friends.prepareAppleDeletion) { result in Task { await friends.finishAppleDeletion(result) } }
                            .signInWithAppleButtonStyle(.black).frame(height: 48).disabled(friends.isBusy)
                    }
                }
                Section {
                    Link("Contact support", destination: AppConfiguration.supportMailURL)
                    Text("Account deletion removes your profile, connections, and shared summaries. Local progress and photos stay on this device. It does not cancel your Apple subscription.")
                        .font(.footnote).foregroundStyle(.secondary)
                    Link("Manage Apple subscriptions", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                }
                if friends.isBusy { ProgressView() }
                if let error = friends.errorMessage { Text(error).font(.footnote) }
            }
            .navigationTitle("Your account").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .onAppear { name = friends.profile?.displayName ?? "" }
            .onChange(of: friends.accountID) { _, id in if id == nil { dismiss() } }
            .alert("Sign out?", isPresented: $signOutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Sign out") { Task { await friends.signOut() } }
            } message: { Text("Your local progress and photos stay saved. Friends sharing from this device stops.") }
            .alert("Delete your account?", isPresented: $deleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete account", role: .destructive) {
                    if friends.appleAccount { appleDeletionReady = true }
                    else { Task { await friends.deleteAccount() } }
                }
            } message: { Text("This permanently removes your account and shared data. Your Apple subscription must be canceled separately.") }
        }
    }
}

private struct FriendReportView: View {
    let friend: FriendConnection
    @Environment(\.dismiss) private var dismiss
    @State private var reason = "unwanted_contact"
    @State private var details = ""
    @State private var friends = FriendsService.shared
    var body: some View {
        NavigationStack {
            Form {
                Section("Report \(friend.displayName)") {
                    Picker("Reason", selection: $reason) {
                        Text("Unwanted contact").tag("unwanted_contact")
                        Text("Inappropriate name").tag("inappropriate_name")
                        Text("Other").tag("other")
                    }
                    TextField("Anything else? (optional)", text: $details, axis: .vertical)
                        .onChange(of: details) { _, value in details = String(value.prefix(500)) }
                    Text("Your report is private. You can also block this person from their connection menu.").font(.footnote).foregroundStyle(.secondary)
                    Button("Send report") {
                        Task {
                            await friends.report(friend, reason: reason, details: details)
                            if friends.notice != nil { dismiss() }
                        }
                    }.disabled(friends.isBusy)
                    if let error = friends.errorMessage { Text(error).font(.footnote) }
                }
            }.navigationTitle("Report").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}

private struct FriendsShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: items, applicationActivities: nil) }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

private enum FriendsStyle {
    static let secondary = Color.dynamic(light: "#625D55", dark: "#B7B0A7")
    static let sage = Color.dynamic(light: "#E1E8DA", dark: "#283529")
    static let sageInk = Color.dynamic(light: "#52664E", dark: "#B5C9AA")
    static let blush = Color.dynamic(light: "#F0DFDA", dark: "#43302D")
}
private struct FriendsMotif: View {
    var body: some View {
        HStack(spacing: -16) {
            Circle().fill(FriendsStyle.sage).overlay(Image(systemName: "leaf").font(.title2).foregroundStyle(FriendsStyle.sageInk))
            Circle().fill(FriendsStyle.blush).overlay(Image(systemName: "heart").font(.title2).foregroundStyle(Color.glowTextPrimary))
        }.frame(width: 130)
    }
}
private struct FriendsPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var disabled = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon { Image(systemName: icon) }
                Text(title).font(.body.weight(.semibold))
            }.frame(maxWidth: .infinity, minHeight: 52)
                .foregroundStyle(Color.glowSurface).background(Color.glowTextPrimary, in: RoundedRectangle(cornerRadius: 16))
        }.buttonStyle(.plain).disabled(disabled).opacity(disabled ? 0.5 : 1)
    }
}
private extension View {
    func friendsCard() -> some View {
        self.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.glowSurface, in: RoundedRectangle(cornerRadius: 26))
            .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.glowDivider.opacity(0.6)))
            .foregroundStyle(Color.glowTextPrimary)
    }
    func friendsField() -> some View {
        self.padding(16).background(Color.glowSurfaceSecondary, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview("Friends — sign in") {
    FriendsView()
        .modelContainer(for: [ProtocolConfig.self, DayLog.self, HabitEntry.self, ScrapbookPhoto.self], inMemory: true)
}
