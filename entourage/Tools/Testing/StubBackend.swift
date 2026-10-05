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

        default:
            // Toute autre route de l'app (notifs, groupes, ressources…) répond vide pour ne rien casser.
            return (200, Self.json([String: Any]()))
        }
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
