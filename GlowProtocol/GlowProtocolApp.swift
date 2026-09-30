//
//  GlowProtocolApp.swift
//  GlowProtocol
//
//  @main entry point. Owns the SwiftData ModelContainer + global appearance.
//

import SwiftUI
import SwiftData
import SuperwallKit

@main
struct GlowProtocolApp: App {
    @AppStorage("appearancePreference") private var appearancePreference: String = "light"

    /// Shared container — uses the App Group container when available so the
    /// widget extension can read the same store; otherwise falls back to the
    /// app's own Documents directory.
    let sharedModelContainer: ModelContainer? = {
        let schema = Schema([
            ProtocolConfig.self,
            DayLog.self,
            HabitEntry.self,
            ScrapbookPhoto.self,
        ])
        let appGroupID = "group.sam.GlowProtocol"
        let storeURL: URL = {
            if let groupURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
                return groupURL.appendingPathComponent("GlowProtocol.store")
            }
            let docs = try? FileManager.default.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true
            )
            return (docs ?? URL.documentsDirectory).appendingPathComponent("GlowProtocol.store")
        }()
        let config = ModelConfiguration(schema: schema, url: storeURL)
        // Keep the original store intact if opening or migrating it fails.
        return try? ModelContainer(for: schema, configurations: [config])
    }()

    init() {
        SubscriptionService.shared.configure()
        FriendsService.shared.configure()
        if let sharedModelContainer {
            BackgroundTaskService.shared.register(container: sharedModelContainer)
        }
    }

    var body: some Scene {
        WindowGroup {
            if let sharedModelContainer {
                RootView()
                    .modelContainer(sharedModelContainer)
                    .preferredColorScheme(colorScheme(for: appearancePreference))
                    .onOpenURL { url in
                        if FriendInvitation.code(from: url) != nil {
                            FriendsService.shared.receiveInvite(url)
                            FriendsService.shared.requestedHomeTab = "friends"
                        } else if url.scheme == "glowprotocol", url.host == "today" {
                            FriendsService.shared.requestedHomeTab = "daily"
                        } else {
                            Superwall.handleDeepLink(url)
                        }
                    }
            } else {
                ContentUnavailableView(
                    "Progress couldn't be opened",
                    systemImage: "externaldrive.badge.exclamationmark",
                    description: Text("Your saved progress has been preserved. Please contact support before reinstalling or deleting the app.")
                )
            }
        }
    }

    private func colorScheme(for preference: String) -> ColorScheme? {
        switch preference {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }
}
