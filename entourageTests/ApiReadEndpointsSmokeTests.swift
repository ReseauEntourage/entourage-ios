import XCTest
@testable import entourage

/// Smoke test de lecture (équivalent iOS de `ApiReadEndpointsSmokeTest`) : appelle les principaux endpoints GET du
/// staging avec le compte de test et vérifie que chaque réponse 2xx se décode dans les VRAIS modèles de l'app.
/// Les services de l'app avalent les erreurs de décodage (`try?`) ; ce test, lui, les fait remonter avec le nom de
/// l'endpoint. Lecture seule : rien n'est créé ni modifié.
///
/// Les statuts 4xx/5xx et les erreurs réseau ne sont pas des échecs (endpoint indisponible, compte sans données) ;
/// seuls les échecs de décodage le sont.
///
/// Identifiants : variables d'environnement `TEST_ACCOUNT_LOGIN` / `TEST_ACCOUNT_PWD` (jamais écrits dans le repo).
/// Avec xcodebuild : `TEST_RUNNER_TEST_ACCOUNT_LOGIN=… TEST_RUNNER_TEST_ACCOUNT_PWD=… xcodebuild … test`.
/// Sans identifiants, le test est ignoré.
final class ApiReadEndpointsSmokeTests: XCTestCase {

    private struct Outcome {
        let name: String
        let status: String
        let failure: String?
    }

    private var outcomes: [Outcome] = []
    private var previousUser: User?
    private var token = ""
    private var myId = 0

    override func setUpWithError() throws {
        try super.setUpWithError()
        let env = ProcessInfo.processInfo.environment
        guard let phone = env["TEST_ACCOUNT_LOGIN"], !phone.isEmpty,
              let password = env["TEST_ACCOUNT_PWD"], !password.isEmpty else {
            throw XCTSkip("TEST_ACCOUNT_LOGIN / TEST_ACCOUNT_PWD absents : smoke test ignoré")
        }
        previousUser = UserDefaults.currentUser
        NetworkManager.sharedInstance.setProtocolClasses(nil)
        try login(phone: phone, password: password)
    }

    override func tearDown() {
        UserDefaults.currentUser = previousUser
        super.tearDown()
    }

    // MARK: - Helpers

    /// Connexion directe (sans `AuthService.postLogin`, qui écrit le téléphone et le mot de passe dans le Keychain).
    private func login(phone: String, password: String) throws {
        let body = try JSONSerialization.data(withJSONObject: ["user": ["phone": phone, "sms_code": password]])
        let done = expectation(description: "login")
        var logged: User?
        NetworkManager.sharedInstance.requestPost(endPoint: kAPILogin, headers: nil, body: body) { data, resp, _ in
            if let data, (resp as? HTTPURLResponse)?.statusCode ?? 500 < 300 {
                logged = UserService.parsingDataUser(data: data).user
            }
            done.fulfill()
        }
        wait(for: [done], timeout: 30)
        let user = try XCTUnwrap(logged, "La connexion préalable a échoué : compte de test invalide ou staging indisponible")
        UserDefaults.currentUser = user
        token = user.token ?? ""
        myId = user.sid
    }

    /// Appelle `endpoint`, puis décode `key` (objet ou tableau) dans `T`. Renvoie la réponse JSON brute si 2xx.
    @discardableResult
    private func get<T: Decodable>(_ name: String, _ endpoint: String, key: String? = nil, as type: T.Type) -> [String: Any]? {
        let done = expectation(description: name)
        var result: (data: Data?, status: Int?)?
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, _ in
            result = (data, (resp as? HTTPURLResponse)?.statusCode)
            done.fulfill()
        }
        wait(for: [done], timeout: 60)

        guard let status = result?.status else {
            outcomes.append(Outcome(name: name, status: "réseau", failure: nil))
            return nil
        }
        guard let data = result?.data, status < 300 else {
            outcomes.append(Outcome(name: name, status: "HTTP \(status)", failure: nil))
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            if let key, let value = json[key] {
                if let array = value as? [Any] {
                    for element in array {
                        try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: element))
                    }
                } else {
                    try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: value))
                }
            }
            outcomes.append(Outcome(name: name, status: "HTTP \(status)", failure: nil))
            return json
        } catch {
            outcomes.append(Outcome(name: name, status: "ÉCHEC", failure: "\(error)"))
            return nil
        }
    }

    private func firstId(in json: [String: Any]?, key: String) -> Int? {
        (json?[key] as? [[String: Any]])?.first?["id"] as? Int
    }

    private func f(_ format: String, _ args: CVarArg...) -> String { String(format: format, arguments: args) }

    // MARK: - Test

    func testMainReadEndpointsDecode() {
        let t = token as NSString

        // --- Accueil / référentiels
        get("home/summary", f(kAPIHomeSummary, t), key: "user", as: UserHome.self)
        get("resources", f(kAPIHomeResources, t), key: "resources", as: PedagogicResource.self)
        get("entourage_images", f(kAPIEventImages, t), key: "entourage_images", as: EventImage.self)
        get("neighborhood_images", f(kAPIGetneighborhoodImages, t), key: "neighborhood_images", as: NeighborhoodImage.self)
        get("inapp_notifications", f(kAPINotifsGetNotifs, t, 1, 10), key: "inapp_notifications", as: NotifInApp.self)
        get("partners", f(kAPIGetAllAssociations, t), key: "partners", as: Partner.self)

        // --- Utilisateur
        get("users/{me}", f(kAPIGetDetailUser, "\(myId)" as NSString, t), key: "user", as: User.self)

        // --- Groupes
        let groups = get("neighborhoods", f(kAPIGetSuggestNeighborhoods, t, 1, 10), key: "neighborhoods", as: Neighborhood.self)
        if let groupId = firstId(in: groups, key: "neighborhoods") {
            get("neighborhoods/{id}", f(kAPIGetDetailNeighborhood, "\(groupId)" as NSString, t), key: "neighborhood", as: Neighborhood.self)
            get("neighborhoods/{id}/chat_messages", f(kAPIGetNeighborhoodPostsMessage, "\(groupId)" as NSString, t, 1, 10),
                key: "chat_messages", as: PostMessage.self)
        }

        // --- Événements
        let events = get("outings", f(kAPIEventGetAllDiscover, t, 1, 10), key: "outings", as: Event.self)
        if let eventId = firstId(in: events, key: "outings") {
            get("outings/{id}", f(kAPIEventDetail, "\(eventId)" as NSString, t), key: "outing", as: Event.self)
            get("outings/{id}/chat_messages", f(kAPIGetEventPostsMessage, "\(eventId)" as NSString, t, 1, 10),
                key: "chat_messages", as: PostMessage.self)
        }

        // --- Entraide
        let contributions = get("contributions", f(kAPIActionGetAllContribs, t, 1, 10), key: "contributions", as: Action.self)
        if let id = firstId(in: contributions, key: "contributions") {
            get("contributions/{id}", f(kAPIGetContrib, "\(id)" as NSString, t), key: "contribution", as: Action.self)
        }
        let solicitations = get("solicitations", f(kAPIActionGetAllSolicitations, t, 1, 10), key: "solicitations", as: Action.self)
        if let id = firstId(in: solicitations, key: "solicitations") {
            get("solicitations/{id}", f(kAPIGetSolicitation, "\(id)" as NSString, t), key: "solicitation", as: Action.self)
        }

        // --- Conversations
        let conversations = get("conversations", f(kAPIConversationGetAllConversations, t, 1, 10), key: "conversations", as: Conversation.self)
        if let id = firstId(in: conversations, key: "conversations") {
            get("conversations/{id}", f(kAPIConversationGetDetailConversation, "\(id)" as NSString, t), key: "conversation", as: Conversation.self)
        }

        let report = outcomes.map { "\($0.name) → \($0.status)" }.joined(separator: "\n")
        print("ApiReadEndpointsSmokeTests :\n\(report)")
        let failures = outcomes.compactMap { outcome in outcome.failure.map { "\(outcome.name) : \($0)" } }
        XCTAssertTrue(failures.isEmpty, "Réponses qui ne se décodent plus dans les modèles :\n\(failures.joined(separator: "\n"))")
    }
}
