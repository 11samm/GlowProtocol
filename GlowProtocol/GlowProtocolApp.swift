//
//  GlowProtocolApp.swift
//  GlowProtocol
//
//  @main entry point. Owns the SwiftData ModelContainer + global appearance.
//

import SwiftUI
import SwiftData

@main
struct GlowProtocolApp: App {
    @AppStorage("appearancePreference") private var appearancePreference: String = "light"

    /// Shared container — uses the App Group container when available so the
    /// widget extension can read the same store; otherwise falls back to the
    /// app's own Documents directory.
    let sharedModelContainer: ModelContainer = {
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
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Last-ditch in-memory fallback so the app at least launches.
            return try! ModelContainer(
                for: schema,
                configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
            )
        }
    }()

    init() {
        BackgroundTaskService.shared.register(container: sharedModelContainer)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(colorScheme(for: appearancePreference))
        }
        .modelContainer(sharedModelContainer)
    }

    private func colorScheme(for preference: String) -> ColorScheme? {
        switch preference {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }
}
