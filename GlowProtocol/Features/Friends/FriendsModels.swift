import Foundation

struct FriendsProfile: Codable, Equatable {
    let id: UUID
    let displayName: String
    let inviteCode: String
    let sharingEnabled: Bool
    enum CodingKeys: String, CodingKey {
        case id, displayName = "display_name", inviteCode = "invite_code", sharingEnabled = "sharing_enabled"
    }
}

struct FriendConnection: Codable, Identifiable, Equatable {
    let id: UUID
    let personID: UUID
    let displayName: String
    let status: String
    let incoming: Bool
    let dayNumber: Int?
    let completionPercent: Int?
    let localDate: String?
    var isAccepted: Bool { status == "accepted" }
    enum CodingKeys: String, CodingKey {
        case id, personID = "person_id", displayName = "display_name", status, incoming
        case dayNumber = "day_number", completionPercent = "completion_percent", localDate = "local_date"
    }
}

struct BlockedFriend: Codable, Identifiable {
    let id: UUID
    let displayName: String
    enum CodingKeys: String, CodingKey { case id, displayName = "display_name" }
}

struct FriendsSnapshot: Codable {
    let profile: FriendsProfile?
    let connections: [FriendConnection]
    let blocked: [BlockedFriend]
    static let empty = FriendsSnapshot(profile: nil, connections: [], blocked: [])
}

enum FriendInvitation {
    static func normalizedCode(_ value: String) -> String? {
        let code = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return code.count == 12 && code.allSatisfy { "0123456789ABCDEF".contains($0) } ? code : nil
    }
    static func code(from url: URL) -> String? {
        guard url.scheme == "glowprotocol", url.host == "invite",
              let value = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value else { return nil }
        return normalizedCode(value)
    }
    static func url(code: String) -> URL? {
        guard let code = normalizedCode(code) else { return nil }
        var components = URLComponents()
        components.scheme = "glowprotocol"
        components.host = "invite"
        components.queryItems = [URLQueryItem(name: "code", value: code)]
        return components.url
    }
    static func shareText(profile: FriendsProfile) -> String {
        "Join me on Glow Protocol — a little company for our 75 days. Open Friends and enter my code: \(profile.inviteCode).\n\(url(code: profile.inviteCode)?.absoluteString ?? "")\nA subscription is required to start tracking."
    }
}

struct SharedDaySummary: Encodable, Equatable {
    let summaryDate: String
    let summaryDay: Int
    let summaryPercent: Int
    enum CodingKeys: String, CodingKey {
        case summaryDate = "summary_date", summaryDay = "summary_day", summaryPercent = "summary_percent"
    }
    init(date: Date, day: Int, fraction: Double) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        summaryDate = formatter.string(from: date)
        summaryDay = min(75, max(1, day))
        summaryPercent = fraction.isFinite ? min(100, max(0, Int((fraction * 100).rounded()))) : 0
    }
}
