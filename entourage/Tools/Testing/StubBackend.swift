#if DEBUG
import Foundation

/// Faux backend en mémoire, utilisé par les tests (unitaires et UI) et par le mode `-UITestMode`.
///
/// Il est branché sur `NetworkManager` via `StubURLProtocol` : aucun appel ne part vers le vrai serveur.
/// Il sert un `home/summary` configurable (fake data), répond aux routes du parcours de bienvenue
/// et enregistre chaque requête pour que les tests puissent vérifier "où ça part".
final class StubBackend {
    static let shared = StubBackend()

    struct RecordedRequest {
        let method: String
        /// Chemin sans le préfixe `/api/v1/` ni le query string (ex. `users/onboarding_step_skipped`).
        let path: String
        let body: [String: Any]

        var signature: String { "\(method) \(path)" }
    }

    private let lock = NSLock()
    private var storedEvents: [String] = []
    private var storedRequests: [RecordedRequest] = []
    /// Messages postés dans la conversation de test (relus au rechargement de l'écran).
    private var storedConversationMessages: [[String: Any]] = []
    private var nextCreatedId = 9000
    /// Objets créés pendant le scénario, relus par leur détail (`GET contributions/9001`…).
    private var storedCreated: [String: [String: Any]] = [:]

    /// Si renseigné, chaque requête est aussi écrite (une ligne JSON) dans ce fichier :
    /// c'est ainsi que le process XCUITest lit ce que l'app a réellement envoyé.
    var requestLogURL: URL?

    /// Délai artificiel avant la réponse du `POST users/onboarding_step_skipped` (serveur lent simulé).
    /// Sert à vérifier que l'interface n'attend pas le serveur pour afficher l'étape "Passée".
    var skipResponseDelay: TimeInterval = 0

    private init() {}

    // MARK: - État

    func reset(events: [String] = []) {
        lock.lock(); defer { lock.unlock() }
        storedEvents = events
        storedRequests = []
        storedConversationMessages = [Self.firstConversationMessage]
        nextCreatedId = 9000
        storedCreated = [:]
        if let url = requestLogURL {
            try? Data().write(to: url)
        }
    }

    var events: [String] {
        lock.lock(); defer { lock.unlock() }
        return storedEvents
    }

    var requests: [RecordedRequest] {
        lock.lock(); defer { lock.unlock() }
        return storedRequests
    }

    // MARK: - Fake data

    /// Les noms d'events sont volontairement écrits en dur (contrat backend) et non déduits du code de l'app,
    /// pour que les tests détectent une régression de mapping.
    private static let skippedEventByStep: [String: String] = [
        "welcome_watched": "onboarding.resource.welcome_watched_skipped",
        "webinar_or_first_steps": "onboarding.outing.webinar_or_first_steps_skipped",
        "papotages": "onboarding.outing.papotages_skipped",
        "neighborhood_national": "onboarding.neighborhood.national_skipped"
    ]

    private static let welcomeResourceId = 4242

    func summaryJSON() -> Data {
        let user: [String: Any] = [
            "id": 1,
            "display_name": "Camille Test",
            "meetings_count": 0,
            "chat_messages_count": 0,
            "outing_participations_count": 0,
            "neighborhood_participations_count": 0,
            "past_outing_participations_count": 0,
            "action_creations_count": 0,
            "neighborhood_messages_count": 0,
            "conversation_members_count": 0,
            "recommandations": [Any](),
            "congratulations": [Any](),
            "events": events
        ]
        return Self.json(["user": user])
    }

    private static func json(_ object: Any) -> Data {
        (try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])) ?? Data("{}".utf8)
    }

    // MARK: - Routage

    func handle(_ request: URLRequest) -> (status: Int, data: Data) {
        let method = request.httpMethod ?? "GET"
        let path = Self.normalizedPath(of: request.url)
        let body = Self.readBody(of: request)
        record(RecordedRequest(method: method, path: path, body: body))

        // Détail utilisateur : on renvoie l'utilisateur courant (encodé avec le même Codable que l'app),
        // sinon l'app considère la session invalide et déconnecte.
        if method == "GET", path.range(of: "^users/[0-9]+$", options: .regularExpression) != nil,
           let user = UserDefaults.currentUser,
           let data = try? JSONEncoder().encode(user),
           let object = try? JSONSerialization.jsonObject(with: data) {
            return (200, Self.json(["user": object]))
        }

        switch (method, path) {
        case ("GET", "home/summary"):
            return (200, summaryJSON())

        case ("POST", "users/onboarding_step_skipped"):
            guard let step = body["step"] as? String, let event = Self.skippedEventByStep[step] else {
                return (422, Self.json(["error": ["code": "INVALID_STEP", "message": "unknown step"]]))
            }
            addEvent(event)
            return (200, Self.json(["status": "ok"]))

        case ("GET", "resources/welcome"):
            let resource: [String: Any] = [
                "id": Self.welcomeResourceId, "uuid_v2": "uitest-welcome", "name": "Vidéo de bienvenue",
                "category": "understand", "watched": false
            ]
            return (200, Self.json(["resource": resource]))

        case ("POST", "resources/\(Self.welcomeResourceId)/users"):
            addEvent("onboarding.resource.welcome_watched")
            return (200, Self.json(["status": "ok"]))

        case ("GET", "neighborhoods/national"):
            return (200, Self.json(["neighborhoods": [Any]()]))

        case ("GET", "outings/firsts_steps"), ("GET", "outings/webinar"), ("GET", "outings/papotages"):
            return (200, Self.json(["outings": [Any]()]))


        // --- Référentiels (catégories, rubriques d'entraide, images de la galerie)
        case ("GET", "home/metadata"):
            return (200, Self.json(["tags": [
                "interests": [["id": "activites", "name": "Activités manuelles"], ["id": "animaux", "name": "Animaux"], ["id": "cuisine", "name": "Cuisine"]],
                "sections": [["id": "social", "name": "Temps de partage", "subname": "café, activité..."],
                             ["id": "services", "name": "Service", "subname": "lessive, impression de documents..."]],
                "signals": [["id": "spam", "name": "Spam"]]
            ], "reactions": [Any]()]))

        case ("GET", "neighborhood_images"):
            return (200, Self.json(["neighborhood_images": [["id": 15, "title": "Image 15", "image_url": "https://example.org/groups/15.jpg"]]]))

        case ("GET", "entourage_images"):
            return (200, Self.json(["entourage_images": [["id": 32, "title": "Image 32", "landscape_url": "https://example.org/events/32.jpg",
                                                            "landscape_small_url": "https://example.org/events/32_small.jpg",
                                                            "portrait_url": "https://example.org/events/32_p.jpg",
                                                            "portrait_small_url": "https://example.org/events/32_p_small.jpg"]]]))

        // --- Créations : la réponse reprend ce que l'app a envoyé, avec un identifiant fabriqué
        case ("POST", "neighborhoods"):
            let sent = body["neighborhood"] as? [String: Any] ?? [:]
            let id = takeCreatedId()
            return (201, Self.json(["neighborhood": [
                "id": id, "uuid_v2": "stub-group-\(id)", "name": sent["name"] ?? "", "description": sent["description"] ?? "",
                "interests": sent["interests"] ?? [Any](), "past_outings_count": 0, "future_outings_count": 0,
                "has_ongoing_outing": false, "members_count": 1, "member": true, "members": [Any](),
                "user": ["id": 1, "display_name": "Camille Test"]
            ] as [String: Any]]))

        case ("POST", "outings"):
            let sent = body["outing"] as? [String: Any] ?? [:]
            let id = takeCreatedId()
            return (201, Self.json(["outing": [
                "id": id, "uuid": "stub-event-\(id)", "uuid_v2": "stub-event-\(id)", "status": "open",
                "title": sent["title"] ?? "", "description": sent["description"] ?? "", "online": sent["online"] ?? false
            ] as [String: Any]]))

        case ("POST", "contributions"), ("POST", "solicitations"):
            let key = path == "contributions" ? "contribution" : "solicitation"
            let sent = body[key] as? [String: Any] ?? [:]
            let id = takeCreatedId()
            let action: [String: Any] = [
                "id": id, "uuid": "stub-action-\(id)", "uuid_v2": "stub-action-\(id)", "status": "open",
                "title": sent["title"] ?? "", "description": sent["description"] ?? "", "section": sent["section"] ?? "",
                "author": ["id": 1, "display_name": "Camille Test"]
            ]
            remember(action, at: "\(path)/\(id)")
            return (201, Self.json([key: action]))

        case ("GET", _) where storedCreatedObject(at: path) != nil:
            let key = path.hasPrefix("contributions") ? "contribution" : path.hasPrefix("solicitations") ? "solicitation" : path.hasPrefix("outings") ? "outing" : "neighborhood"
            return (200, Self.json([key: storedCreatedObject(at: path) as Any]))

        // --- Conversation : une discussion privée avec un message reçu, puis ceux que l'utilisateur envoie
        case ("GET", "conversations/memberships"):
            // Pagination réaliste : seule la première page contient la conversation.
            if Self.page(of: request) > 1 { return (200, Self.json(["memberships": [Any]()])) }
            lock.lock(); let last = storedConversationMessages.first; lock.unlock()
            return (200, Self.json(["memberships": [[
                "status": "accepted", "joinable_status": "accepted", "name": "Jean M.", "subname": "",
                "joinable_type": "conversation", "joinable_id": Self.conversationId, "number_of_people": 2,
                "number_of_root_chat_messages": 1, "number_of_unread_messages": 0,
                "last_chat_message": last?["content"] ?? "", "last_chat_message_datetime": "2026-05-01T09:15:00.000+0000"
            ] as [String: Any]]]))

        case ("GET", "conversations"):
            return (200, Self.json(["conversations": [conversationJSON()]]))

        case ("GET", "conversations/\(Self.conversationId)"):
            return (200, Self.json(["conversation": conversationJSON()]))

        case ("GET", "conversations/\(Self.conversationId)/chat_messages"):
            lock.lock(); let messages = storedConversationMessages; lock.unlock()
            return (200, Self.json(["chat_messages": messages]))

        case ("POST", "conversations/\(Self.conversationId)/chat_messages"):
            let sent = body["chat_message"] as? [String: Any] ?? [:]
            let message: [String: Any] = [
                "id": takeCreatedId(), "content": sent["content"] ?? "", "content_html": sent["content"] ?? "",
                "created_at": "2026-05-01T09:20:00.000+0000", "message_type": "text", "has_comments": false,
                "user": ["id": 1, "display_name": "Camille Test"]
            ]
            lock.lock(); storedConversationMessages.insert(message, at: 0); lock.unlock()
            return (201, Self.json(["chat_message": message]))

        default:
            // Toute autre route de l'app (notifs, groupes, ressources…) répond vide pour ne rien casser.
            return (200, Self.json([String: Any]()))
        }
    }


    // MARK: - Conversation de test

    private static let conversationId = 301

    private static let firstConversationMessage: [String: Any] = [
        "id": 8000, "content": "Bonjour, comment ça va ?", "content_html": "Bonjour, comment ça va ?",
        "created_at": "2026-05-01T09:15:00.000+0000", "message_type": "text", "has_comments": false,
        "user": ["id": 3, "display_name": "Jean M."]
    ]

    private func remember(_ object: [String: Any], at path: String) {
        lock.lock(); storedCreated[path] = object; lock.unlock()
    }

    private func storedCreatedObject(at path: String) -> [String: Any]? {
        lock.lock(); defer { lock.unlock() }
        return storedCreated[path]
    }

    private func takeCreatedId() -> Int {
        lock.lock(); defer { lock.unlock() }
        nextCreatedId += 1
        return nextCreatedId
    }

    private func conversationJSON() -> [String: Any] {
        lock.lock(); let last = storedConversationMessages.first; lock.unlock()
        return [
            "id": Self.conversationId, "uuid": "1_list_me_with_3", "uuid_v2": "1_list_me_with_3", "type": "private", "name": "Jean M.",
            "number_of_unread_messages": 0, "section": "social", "has_personal_post": true, "member": true, "members_count": 2,
            "creator": true,
            "last_message": ["text": last?["content"] ?? "", "date": "2026-05-01T09:15:00.000+0000"],
            "user": ["id": 3, "display_name": "Jean M."],
            "author": ["id": 3, "display_name": "Jean M."],
            "members": [["id": 3, "display_name": "Jean M."], ["id": 1, "display_name": "Camille Test"]]
        ]
    }

    private func addEvent(_ event: String) {
        lock.lock(); defer { lock.unlock() }
        if !storedEvents.contains(event) { storedEvents.append(event) }
    }

    private func record(_ request: RecordedRequest) {
        lock.lock()
        storedRequests.append(request)
        let url = requestLogURL
        lock.unlock()

        guard let url = url else { return }
        let line: [String: Any] = ["method": request.method, "path": request.path, "body": request.body]
        guard var data = try? JSONSerialization.data(withJSONObject: line, options: [.sortedKeys]) else { return }
        data.append(0x0A)
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(data)
            try? handle.close()
        } else {
            try? data.write(to: url)
        }
    }

    private static func page(of request: URLRequest) -> Int {
        guard let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return 1 }
        return components.queryItems?.first { $0.name == "page" }?.value.flatMap(Int.init) ?? 1
    }

    private static func normalizedPath(of url: URL?) -> String {
        guard let path = url?.path else { return "" }
        let trimmed = path.components(separatedBy: "/api/v1/").last ?? path
        return trimmed.hasPrefix("/") ? String(trimmed.dropFirst()) : trimmed
    }

    private static func readBody(of request: URLRequest) -> [String: Any] {
        var data = request.httpBody
        if data == nil, let stream = request.httpBodyStream {
            stream.open()
            defer { stream.close() }
            var collected = Data()
            var buffer = [UInt8](repeating: 0, count: 1024)
            while stream.hasBytesAvailable {
                let count = stream.read(&buffer, maxLength: buffer.count)
                if count <= 0 { break }
                collected.append(buffer, count: count)
            }
            data = collected
        }
        guard let data = data, !data.isEmpty,
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
        return object
    }
}

/// `URLProtocol` qui redirige tout vers `StubBackend`. À installer via `NetworkManager.setProtocolClasses`.
final class StubURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        // La requête est enregistrée tout de suite ; seule la réponse peut être retardée.
        let result = StubBackend.shared.handle(request)
        let isSkip = request.httpMethod == "POST" && request.url?.path.hasSuffix("users/onboarding_step_skipped") == true
        let delay = isSkip ? StubBackend.shared.skipResponseDelay : 0

        let respond = { [self] in
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: result.status, httpVersion: "HTTP/1.1",
                                                 headerFields: ["Content-Type": "application/json"]) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: result.data)
            client?.urlProtocolDidFinishLoading(self)
        }

        if delay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: respond)
        } else {
            respond()
        }
    }

    override func stopLoading() {}
}
#endif
