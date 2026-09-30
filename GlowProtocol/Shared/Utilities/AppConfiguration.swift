import Foundation

enum AppConfiguration {
    static let supportEmail = "glowprotocol.info@gmail.com"
    static let supportMailURL = URL(string: "mailto:glowprotocol.info@gmail.com")!

    /// Public connection settings; row-level security must protect app data.
    static var supabaseProjectURL: URL? {
        guard let value = publicSetting("SupabaseProjectURL"),
              let url = URL(string: value),
              url.scheme == "https", url.host != nil else { return nil }
        return url
    }

    static var supabasePublishableKey: String? {
        publicSetting("SupabasePublishableKey")
    }

    private static func publicSetting(_ name: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: name) as? String else { return nil }
        let setting = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return setting.isEmpty ? nil : setting
    }

    /// Superwall's public iOS SDK key. Private dashboard keys never belong here.
    static var superwallPublicAPIKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SuperwallPublicAPIKey") as? String else {
            return nil
        }
        let key = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return key.isEmpty || key == "SUPERWALL_API_KEY" ? nil : key
    }
}
