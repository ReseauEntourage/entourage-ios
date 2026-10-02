import XCTest

/// Socle commun des tests end-to-end (XCUITest).
///
/// - Lance l'app en `-UITestMode` : faux utilisateur connecté, réseau branché sur le `StubBackend` de l'app
///   (aucun appel réel), fake data du `home/summary` passées via `launchEnvironment`.
/// - Relit le journal des requêtes envoyées par l'app (fichier JSON lines) pour vérifier "où ça part".
/// - Range une capture d'écran par étape dans `<racine du projet>/test-screenshots/<scénario>/NN_étape.png`
///   (et l'attache aussi au rapport `.xcresult`).
class UITestCase: XCTestCase {

    struct SentRequest: CustomStringConvertible {
        let method: String
        let path: String
        let body: [String: Any]

        var signature: String { "\(method) \(path)" }
        var description: String { "\(signature) \(body)" }
    }

    private(set) var app: XCUIApplication!

    private var screenshotIndex = 0
    private var requestLogURL: URL!

    // MARK: - Chemins

    /// `<racine>/entourageUITests/Support/UITestCase.swift` → `<racine>`
    private static let projectRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    private static let screenshotsRoot = projectRoot.appendingPathComponent("test-screenshots", isDirectory: true)

    /// Nom du scénario = nom de la méthode de test, sans le préfixe `test` (ex. `SkipPapotages`).
    private var scenarioName: String {
        let method = name.split(separator: " ").last.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "]")) } ?? name
        return method.hasPrefix("test") ? String(method.dropFirst(4)) : method
    }

    private var scenarioDirectory: URL {
        Self.screenshotsRoot.appendingPathComponent(scenarioName, isDirectory: true)
    }

    // MARK: - Cycle de vie

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        screenshotIndex = 0

        let fileManager = FileManager.default
        try? fileManager.removeItem(at: scenarioDirectory)
        try? fileManager.createDirectory(at: scenarioDirectory, withIntermediateDirectories: true)

        requestLogURL = fileManager.temporaryDirectory.appendingPathComponent("uitest-requests-\(UUID().uuidString).jsonl")
        fileManager.createFile(atPath: requestLogURL.path, contents: Data())
    }

    override func tearDown() {
        if (testRun?.totalFailureCount ?? 0) > 0, app != nil {
            // Une capture + l'arbre d'accessibilité aident à comprendre un échec sans rejouer le test.
            screenshot("ECHEC")
            try? app.debugDescription.write(to: scenarioDirectory.appendingPathComponent("ECHEC_hierarchie.txt"),
                                            atomically: true, encoding: .utf8)
            try? sentRequests.map(\.description).joined(separator: "\n")
                .write(to: scenarioDirectory.appendingPathComponent("ECHEC_requetes.txt"), atomically: true, encoding: .utf8)
        }
        try? FileManager.default.removeItem(at: requestLogURL)
        super.tearDown()
    }

    /// Lance l'app avec les fake data du summary (`events` = ce que renverrait `home/summary`).
    /// - Parameters:
    ///   - lastConnectionDaysAgo: simule une dernière connexion il y a N jours (nil = première connexion).
    ///   - accountAgeDays: simule un compte créé il y a N jours (nil = date inconnue).
    func launchApp(events: [String] = [], lastConnectionDaysAgo: Int? = nil, accountAgeDays: Int? = nil) {
        app = XCUIApplication()
        app.launchArguments += ["-UITestMode", "-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
        app.launchEnvironment["UITEST_EVENTS"] = events.joined(separator: ",")
        if let days = lastConnectionDaysAgo { app.launchEnvironment["UITEST_LAST_CONNECTION_DAYS_AGO"] = String(days) }
        if let days = accountAgeDays { app.launchEnvironment["UITEST_ACCOUNT_AGE_DAYS"] = String(days) }
        app.launchEnvironment["UITEST_REQUEST_LOG"] = requestLogURL.path
        app.launch()
    }

    // MARK: - Captures

    /// Capture l'écran et la range dans `test-screenshots/<scénario>/NN_<étape>.png`.
    func screenshot(_ step: String) {
        screenshotIndex += 1
        let slug = step.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "_")
        let fileName = String(format: "%02d_%@.png", screenshotIndex, slug)

        let screenshot = XCUIScreen.main.screenshot()
        try? screenshot.pngRepresentation.write(to: scenarioDirectory.appendingPathComponent(fileName))

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(scenarioName) – \(fileName)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Exécute une action de scénario puis capture l'écran (une capture par clic).
    func step(_ description: String, _ action: () -> Void) {
        XCTContext.runActivity(named: description) { _ in
            action()
            screenshot(description)
        }
    }

    // MARK: - Requêtes envoyées par l'app

    var sentRequests: [SentRequest] {
        guard let content = try? String(contentsOf: requestLogURL, encoding: .utf8) else { return [] }
        return content.split(separator: "\n").compactMap { line in
            guard let data = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let method = json["method"] as? String,
                  let path = json["path"] as? String else { return nil }
            return SentRequest(method: method, path: path, body: json["body"] as? [String: Any] ?? [:])
        }
    }

    /// Attend (max `timeout` s) qu'une requête `METHOD chemin` soit parvenue au faux backend.
    @discardableResult
    func waitForRequest(_ signature: String, timeout: TimeInterval = 10,
                        file: StaticString = #filePath, line: UInt = #line) -> SentRequest? {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if let found = sentRequests.first(where: { $0.signature == signature }) { return found }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline
        XCTFail("Requête jamais envoyée : \(signature). Envoyées : \(sentRequests.map(\.signature))", file: file, line: line)
        return nil
    }

    func requests(matching signature: String) -> [SentRequest] {
        sentRequests.filter { $0.signature == signature }
    }
}
