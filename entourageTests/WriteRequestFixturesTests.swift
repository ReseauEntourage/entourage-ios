import XCTest
@testable import entourage

/// Fixtures « en écriture » (équivalent iOS de `WriteRequestFixturesTest` côté Android) : chaque fichier de
/// `Fixtures/api/requests-ios/` est le corps EXACT que l'app envoie pour une création. Le test appelle le vrai
/// service, sur le faux backend, relit le corps reçu et le compare structurellement à la fixture.
///
/// Un test rouge = le serveur recevrait un corps différent d'avant. Si le changement est voulu, régénérer les
/// fixtures puis relire le diff :
/// `TEST_RUNNER_UPDATE_FIXTURES=1 xcodebuild … test -only-testing:entourageTests/WriteRequestFixturesTests`
final class WriteRequestFixturesTests: XCTestCase {

    private static let requestsRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().appendingPathComponent("Fixtures/api/requests-ios", isDirectory: true)

    private var previousUser: User?
    private var previousTimeZone: TimeZone!

    override func setUp() {
        super.setUp()
        previousUser = UserDefaults.currentUser
        previousTimeZone = NSTimeZone.default
        NSTimeZone.default = TimeZone(identifier: "Europe/Paris")!

        var user = User()
        user.sid = 1
        user.token = "unit-test-token"
        UserDefaults.currentUser = user

        StubBackend.shared.requestLogURL = nil
        StubBackend.shared.reset()
        NetworkManager.sharedInstance.setProtocolClasses([StubURLProtocol.self])
    }

    override func tearDown() {
        NetworkManager.sharedInstance.setProtocolClasses(nil)
        UserDefaults.currentUser = previousUser
        NSTimeZone.default = previousTimeZone
        super.tearDown()
    }

    // MARK: - Helpers

    /// Attend la requête `METHOD chemin` et la compare à la fixture (ou l'écrit en mode `UPDATE_FIXTURES`).
    private func assertSent(_ signature: String, matches fixture: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let deadline = Date().addingTimeInterval(5)
        var sent: StubBackend.RecordedRequest?
        while sent == nil, Date() < deadline {
            sent = StubBackend.shared.requests.first { $0.signature == signature }
            if sent == nil { RunLoop.current.run(until: Date().addingTimeInterval(0.05)) }
        }
        let request = try XCTUnwrap(sent, "requête jamais envoyée : \(signature) (envoyées : \(StubBackend.shared.requests.map(\.signature)))",
                                    file: file, line: line)
        let url = Self.requestsRoot.appendingPathComponent(fixture)

        if ProcessInfo.processInfo.environment["UPDATE_FIXTURES"] == "1" {
            try FileManager.default.createDirectory(at: Self.requestsRoot, withIntermediateDirectories: true)
            try JSONSerialization.data(withJSONObject: request.body, options: [.sortedKeys, .prettyPrinted]).write(to: url)
            return
        }

        let expected = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        XCTAssertEqual(NSDictionary(dictionary: request.body), NSDictionary(dictionary: try XCTUnwrap(expected, file: file, line: line)),
                       "Corps de requête différent de la fixture \(fixture)", file: file, line: line)
    }

    private func wait(_ description: String, _ work: (@escaping () -> Void) -> Void) {
        let done = expectation(description: description)
        work { done.fulfill() }
        wait(for: [done], timeout: 5)
    }

    // MARK: - Création

    func testCreateEvent() throws {
        var event = Event()
        event.title = "Unit test Event 1"
        event.descriptionEvent = "Evenement cree automatiquement par le test."
        event.imageId = 32
        event.isOnline = true
        event.onlineEventUrl = "https://www.entourage.social/"
        event.interests = ["activites"]
        var metadata = EventMetadata()
        metadata.starts_at = "2026-10-21 10:00:00 +0200"
        metadata.ends_at = "2026-10-21 12:00:00 +0200"
        event.metadata = metadata

        wait("createEvent") { done in EventService.createEvent(event: event) { _, _ in done() } }
        try assertSent("POST outings", matches: "create_event.json")
    }

    func testCreateGroup() throws {
        var group = Neighborhood()
        group.name = "Unit test group 1"
        group.aboutGroup = "Groupe cree automatiquement par le test."
        var address = Address()
        address.displayAddress = "Paris - 75004"
        address.latitude = 48.8566
        address.longitude = 2.3522
        group.address = address
        group.interests = ["activites"]
        group.neighborhood_image_id = 15

        wait("createNeighborhood") { done in NeighborhoodService.createNeighborhood(group: group) { _, _ in done() } }
        try assertSent("POST neighborhoods", matches: "create_group.json")
    }

    func testCreateContribution() throws {
        wait("createContribution") { done in
            ActionsService.createAction(isContrib: true, action: self.sampleAction(title: "Unit test Contribution 1"), autoPost: false) { _, _ in done() }
        }
        try assertSent("POST contributions", matches: "create_contribution.json")
    }

    func testCreateDemand() throws {
        wait("createDemand") { done in
            ActionsService.createAction(isContrib: false, action: self.sampleAction(title: "Unit test Demande 1"), autoPost: false) { _, _ in done() }
        }
        try assertSent("POST solicitations", matches: "create_demand.json")
    }

    func testCancelContribution() throws {
        wait("cancelContribution") { done in
            ActionsService.cancelAction(isContrib: true, actionId: 5, isClosedOk: true, message: nil) { _, _ in done() }
        }
        try assertSent("DELETE contributions/5", matches: "cancel_contribution.json")
    }

    func testCancelDemand() throws {
        wait("cancelDemand") { done in
            ActionsService.cancelAction(isContrib: false, actionId: 6, isClosedOk: true, message: nil) { _, _ in done() }
        }
        try assertSent("DELETE solicitations/6", matches: "cancel_demand.json")
    }

    // MARK: - Messages

    func testCreateGroupPost() throws {
        wait("createGroupPost") { done in
            NeighborhoodService.createPostMessage(groupId: 12, message: "Unit test post 1") { _ in done() }
        }
        try assertSent("POST neighborhoods/12/chat_messages", matches: "create_group_post.json")
    }

    func testConversationMessage() throws {
        wait("conversationMessage") { done in
            MessagingService.postCommentFor(conversationId: 301, message: "Unit test message 1") { _, _ in done() }
        }
        try assertSent("POST conversations/301/chat_messages", matches: "conversation_message.json")
    }

    func testCreateConversation() throws {
        wait("createConversation") { done in
            MessagingService.createOrGetConversation(userId: "42") { _, _ in done() }
        }
        try assertSent("POST conversations", matches: "create_conversation.json")
    }

    // MARK: - Données

    private func sampleAction(title: String) -> Action {
        var action = Action()
        action.title = title
        action.description = "Action creee automatiquement par le test."
        action.sectionName = "social"
        var location = EventLocation()
        location.latitude = 48.8566
        location.longitude = 2.3521983
        action.location = location
        return action
    }
}
