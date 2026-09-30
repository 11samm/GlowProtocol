import Foundation
import Testing
@testable import GlowProtocol

struct FriendsTests {
    @Test func invitationUsesOnlyTheExpectedSchemeAndCode() throws {
        let valid = try #require(URL(string: "glowprotocol://invite?code=abcdef123456"))
        #expect(FriendInvitation.code(from: valid) == "ABCDEF123456")
        #expect(FriendInvitation.code(from: URL(string: "https://invite?code=ABCDEF123456")!) == nil)
        #expect(FriendInvitation.code(from: URL(string: "glowprotocol://auth/callback?code=ABCDEF123456")!) == nil)
        #expect(FriendInvitation.normalizedCode("SHORT") == nil)
        #expect(FriendInvitation.normalizedCode("ABCDEF12345Z") == nil)
        #expect(FriendInvitation.code(from: FriendInvitation.url(code: "ABCDEF123456")!) == "ABCDEF123456")
    }
    @Test func summaryPayloadContainsOnlyPermittedFields() throws {
        let summary = SharedDaySummary(date: .now, day: 12, fraction: 0.725)
        let json = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(summary)) as? [String: Any])
        #expect(Set(json.keys) == Set(["summary_date", "summary_day", "summary_percent"]))
        #expect(json["summary_day"] as? Int == 12)
        #expect(json["summary_percent"] as? Int == 73)
        #expect(SharedDaySummary(date: .now, day: 200, fraction: 2).summaryPercent == 100)
        #expect(SharedDaySummary(date: .now, day: 200, fraction: 2).summaryDay == 75)
        #expect(SharedDaySummary(date: .now, day: -2, fraction: .nan).summaryPercent == 0)
    }
    @Test func pendingConnectionDoesNotImplyAcceptance() throws {
        let json = """
        {"profile":null,"connections":[{"id":"11111111-1111-1111-1111-111111111111","person_id":"22222222-2222-2222-2222-222222222222","display_name":"Ava","status":"pending","incoming":true,"day_number":null,"completion_percent":null,"local_date":null}],"blocked":[]}
        """
        let value = try JSONDecoder().decode(FriendsSnapshot.self, from: Data(json.utf8))
        #expect(value.connections.first?.isAccepted == false)
        #expect(value.connections.first?.completionPercent == nil)
    }
}
