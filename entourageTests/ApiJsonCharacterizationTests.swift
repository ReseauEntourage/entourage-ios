import XCTest
@testable import entourage

/// Filet de sécurité du format réseau (équivalent iOS de `ApiJsonCharacterizationTest` / `UserJsonCharacterizationTest`
/// côté Android) : chaque fixture de `Fixtures/api/` est une réponse d'API représentative, partagée à l'identique
/// avec Android (même contrat serveur). Les tests figent le décodage ACTUEL des modèles ; un test rouge signifie que
/// le format lu ou écrit par l'app a changé.
final class ApiJsonCharacterizationTests: XCTestCase {

    // MARK: - Chargement des fixtures

    /// `<racine>/entourageTests/ApiJsonCharacterizationTests.swift` → `<racine>/entourageTests/Fixtures/api`
    static let fixturesRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().appendingPathComponent("Fixtures/api", isDirectory: true)

    static func fixtureData(_ name: String, file: StaticString = #filePath, line: UInt = #line) -> Data {
        do {
            return try Data(contentsOf: fixturesRoot.appendingPathComponent(name))
        } catch {
            XCTFail("Fixture illisible : \(name) (\(error))", file: file, line: line)
            return Data()
        }
    }

    /// Les modèles iOS exigent certaines clés que les fixtures partagées (écrites pour Android) n'ont pas : le décodeur
    /// synthétisé refuse une clé absente dès que la propriété n'est pas optionnelle. `adding` complète la fixture avec
    /// ces clés ; `testRequiredKeysAreTheOnesTheServerAlwaysSends` fige la liste.
    private func decode<T: Decodable>(_ type: T.Type, _ fixture: String, key: String? = nil, adding: [String: Any] = [:],
                                      file: StaticString = #filePath, line: UInt = #line) throws -> T {
        var data = Self.fixtureData(fixture, file: file, line: line)
        if let key {
            let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any], file: file, line: line)
            data = try JSONSerialization.data(withJSONObject: try XCTUnwrap(json[key], "clé \(key) absente", file: file, line: line),
                                              options: [.fragmentsAllowed])
        }
        if !adding.isEmpty, var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            json.merge(adding) { current, _ in current }
            data = try JSONSerialization.data(withJSONObject: json)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private static let eventRequiredKeys: [String: Any] = ["uuid": "e-uuid", "uuid_v2": "e-v2"]
    private static let actionRequiredKeys: [String: Any] = ["uuid": "a-uuid"]
    private static let groupRequiredKeys: [String: Any] = ["past_outings_count": 0, "has_ongoing_outing": false]
    private static let userRequiredKeys: [String: Any] = ["user_type": "public"]

    private func utc(_ iso: String) -> Date? { Utils.getDateFromWSDateString(iso) }

    // MARK: - Événement

    func testEventParsesAllFieldKinds() throws {
        let event = try decode(Event.self, "event.json", adding: Self.eventRequiredKeys)
        XCTAssertEqual(event.uid, 4521)
        XCTAssertEqual(event.uuid_v2, "e_abc123")
        XCTAssertEqual(event.title, "Café partagé place de la République")
        XCTAssertEqual(event.descriptionEvent, "Venez prendre un café et discuter.")
        XCTAssertEqual(event.status, "open")
        XCTAssertEqual(event.imageUrl, "https://cdn.example.org/events/4521.jpg")
        XCTAssertEqual(event.isOnline, false)
        XCTAssertEqual(event.isMember, true)
        XCTAssertEqual(event.membersCount, 2)
        XCTAssertEqual(event.distance, 1.5)
        XCTAssertEqual(event.interests, ["sport", "culture"])
        XCTAssertEqual(event.neighborhoods?.map(\.name), ["Paris Centre"])
        XCTAssertEqual(event.members?.count, 2)
        XCTAssertEqual(event.titleTranslations?.translation, "Shared coffee")
        XCTAssertEqual(event.location?.latitude, 48.8675)
        XCTAssertEqual(event.location?.longitude, 2.3636)
    }

    func testEventMissingOptionalFieldsFallBackToDefaults() throws {
        let event = try JSONDecoder().decode(Event.self, from: Data(#"{"id": 1, "uuid": "u", "uuid_v2": "v", "status": "open", "title": "Minimal"}"#.utf8))
        XCTAssertEqual(event.uid, 1)
        XCTAssertEqual(event.title, "Minimal")
        XCTAssertEqual(event.status, "open")
        XCTAssertNil(event.interests)
        XCTAssertNil(event.metadata)
    }

    func testEventUnknownKeysAreIgnored() throws {
        let event = try JSONDecoder().decode(Event.self, from: Data(#"{"id": 2, "uuid": "u", "uuid_v2": "v", "status": "open", "title": "T", "champ_inconnu": {"a": 1}}"#.utf8))
        XCTAssertEqual(event.uid, 2)
    }

    func testServerDatesAreParsedInEveryKnownFormat() {
        // Le serveur envoie `+0000` : ni `Z` ni millisecondes ne sont garantis.
        XCTAssertNotNil(utc("2026-03-05T10:30:00.000+0000"))
        XCTAssertNotNil(utc("2026-03-05T10:30:00+0000"))
        XCTAssertNotNil(utc("2026-01-02T03:04:05.000Z"))
        XCTAssertNil(utc("pas une date"))
        XCTAssertNil(Utils.getDateFromWSDateString(nil))
    }

    func testRequiredKeysAreTheOnesTheServerAlwaysSends() {
        // Sans ces clés, le décodage échoue en entier (et l'écran reçoit nil) : c'est le contrat à ne pas casser.
        func assertRejects<T: Decodable>(_ type: T.Type, _ json: String, _ missing: String, line: UInt = #line) {
            XCTAssertThrowsError(try JSONDecoder().decode(T.self, from: Data(json.utf8)), "\(missing) devrait être exigé", line: line)
        }
        assertRejects(Event.self, #"{"id": 1, "title": "T", "uuid_v2": "v"}"#, "Event.uuid")
        assertRejects(Event.self, #"{"id": 1, "title": "T", "uuid": "u"}"#, "Event.uuid_v2")
        assertRejects(Event.self, #"{"id": 1, "title": "T", "uuid": "u", "uuid_v2": "v"}"#, "Event.status")
        assertRejects(Action.self, #"{"id": 1}"#, "Action.uuid")
    }

    // MARK: - Groupe

    func testGroupWrapperParsesNestedGroup() throws {
        let group = try decode(Neighborhood.self, "group.json", key: "neighborhood", adding: Self.groupRequiredKeys)
        XCTAssertEqual(group.uid, 12)
        XCTAssertEqual(group.uuid_v2, "n_xyz")
        XCTAssertEqual(group.name, "Paris Centre")
        XCTAssertEqual(group.aboutGroup, "Le groupe du centre de Paris")
        XCTAssertEqual(group.welcomeMessage, "Bienvenue !")
        XCTAssertEqual(group.membersCount, 42)
        XCTAssertTrue(group.isMember)
        XCTAssertEqual(group.national, false)
        XCTAssertEqual(group.future_outings_count, 1)
        XCTAssertEqual(group.interests, ["sport", "cuisine"])
        XCTAssertEqual(group.image_url, "https://cdn.example.org/groups/12.jpg")
        XCTAssertEqual(group.members.count, 1)
        XCTAssertEqual(group.unreadPostCount, 3)
    }

    // MARK: - Entraide

    func testActionParsesTheServerFields() throws {
        let action = try decode(Action.self, "action.json", adding: Self.actionRequiredKeys)
        XCTAssertEqual(action.id, 612)
        XCTAssertEqual(action.uuid_v2, "a_612")
        XCTAssertEqual(action.status, "open")
        XCTAssertEqual(action.title, "Don de vêtements chauds")
        XCTAssertEqual(action.description, "Manteaux et pulls")
        XCTAssertEqual(action.imageUrl, "https://cdn.example.org/actions/612.jpg")
        XCTAssertEqual(action.distance, 0.8)
        XCTAssertEqual(action.location?.latitude, 45.76)
        XCTAssertEqual(action.titleTranslations?.translation, "Warm clothes")
    }

    // MARK: - Conversation et messages

    func testConversationParsesAListItem() throws {
        let conversation = try decode(Conversation.self, "conversation.json")
        XCTAssertEqual(conversation.uid, 301)
        XCTAssertNil(conversation.uuid, "l'app lit `uuid`, la fixture n'envoie que `uuid_v2`")
        XCTAssertEqual(conversation.type, "private")
        XCTAssertTrue(conversation.isOneToOne())
        XCTAssertEqual(conversation.numberUnreadMessages, 2)
        XCTAssertEqual(conversation.members_count, 2)
        XCTAssertEqual(conversation.members?.count, 1)
    }

    func testPostParsesAllFieldKinds() throws {
        let post = try decode(PostMessage.self, "post.json")
        XCTAssertEqual(post.uid, 8001)
        XCTAssertEqual(post.content, "Bonjour à tous !")
        XCTAssertEqual(post.contentHtml, "<p>Bonjour à tous !</p>")
        XCTAssertEqual(post.parentPostId, 7000)
        XCTAssertEqual(post.hasComments, true)
        XCTAssertEqual(post.commentsCount, 4)
        XCTAssertEqual(post.messageImageUrl, "https://cdn.example.org/posts/8001.jpg")
        XCTAssertTrue(post.isPostImage)
        XCTAssertTrue(post.isRead)
        XCTAssertEqual(post.reactionId, 2)
        XCTAssertEqual(post.reactions?.count, 1)
        XCTAssertEqual(post.surveyResponse, [true, false])
        XCTAssertEqual(post.createdDate, utc("2026-02-10T18:00:00.000+0000"))
    }

    // MARK: - Utilisateur

    func testLoginResponseParsesTheWholeUser() throws {
        let user = try decode(User.self, "login.json", key: "user", adding: Self.userRequiredKeys)
        XCTAssertEqual(user.sid, 4079)
        XCTAssertEqual(user.email, "test@example.org")
        XCTAssertEqual(user.token, "fake-token-0000")
        XCTAssertEqual(user.firstname, "Test")
        XCTAssertEqual(user.lastname, "Utilisateur")
        XCTAssertEqual(user.about, "Bénévole depuis 2024")
        XCTAssertEqual(user.goal, "offer_help")
        XCTAssertTrue(user.isEngaged)
        XCTAssertEqual(user.unreadCount, 3)
        XCTAssertEqual(user.gender, "female")
        XCTAssertEqual(user.birthdate, "1990-05-17")
        XCTAssertEqual(user.interests, ["sport", "cuisine"])
        XCTAssertEqual(user.roles, ["Animateur Entourage"])
        XCTAssertEqual(user.availability?["1"], ["09:00-12:00", "14:00-18:00"])
        XCTAssertEqual(user.firebaseProperties?["ActionZoneCP"], "75003")
        XCTAssertEqual(user.organization?.name, "Asso Test")
        XCTAssertEqual(user.partner?.name, "Partenaire")
        XCTAssertEqual(user.creationDate, utc("2024-01-15T09:30:00.000+0000"))
        XCTAssertTrue(user.isAmbassador())
    }

    func testUserRoundTripKeepsTheIdentityAndTheToken() throws {
        // `UserDefaults.currentUser` stocke l'utilisateur en JSON : l'aller-retour ne doit rien perdre d'essentiel.
        let user = try decode(User.self, "login.json", key: "user", adding: Self.userRequiredKeys)
        let again = try JSONDecoder().decode(User.self, from: JSONEncoder().encode(user))
        XCTAssertEqual(again.sid, user.sid)
        XCTAssertEqual(again.token, user.token)
        XCTAssertEqual(again.email, user.email)
        XCTAssertEqual(again.roles, user.roles)
        XCTAssertEqual(again.isEngaged, user.isEngaged)
    }

    // MARK: - Accueil

    func testSummaryParsesCountersAndRecommendations() throws {
        let home = try decode(UserHome.self, "summary.json")
        XCTAssertEqual(home.id, 9)
        XCTAssertEqual(home.meetingsCount, 4)
        XCTAssertEqual(home.chatMessagesCount, 120)
        XCTAssertEqual(home.outingParticipationsCount, 6)
        XCTAssertEqual(home.neighborhoodParticipationsCount, 3)
        XCTAssertEqual(home.preference, "contribution")
        XCTAssertEqual(home.events, ["evt-1", "evt-2"])
        XCTAssertEqual(home.signablePermission, true)
    }
}
