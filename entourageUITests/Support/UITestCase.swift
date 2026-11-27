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
    ///   - skipDelayMs: retarde la réponse du serveur au « Passer » (serveur lent simulé).
    ///   - suggestions: scénario du faux moteur « Votre prochain pas » (`full`, `explorer_only`, `ignore_without_next`, `none`) ;
    ///     nil = aucune suggestion (le vrai fournisseur n'est pas activé).
    func launchApp(events: [String] = [], lastConnectionDaysAgo: Int? = nil, accountAgeDays: Int? = nil, skipDelayMs: Int? = nil,
                   suggestions: String? = nil) {
        app = XCUIApplication()
        app.launchArguments += ["-UITestMode", "-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
        app.launchEnvironment["UITEST_EVENTS"] = events.joined(separator: ",")
        if let days = lastConnectionDaysAgo { app.launchEnvironment["UITEST_LAST_CONNECTION_DAYS_AGO"] = String(days) }
        if let days = accountAgeDays { app.launchEnvironment["UITEST_ACCOUNT_AGE_DAYS"] = String(days) }
        if let delay = skipDelayMs { app.launchEnvironment["UITEST_SKIP_DELAY_MS"] = String(delay) }
        if let scenario = suggestions {
            app.launchArguments.append("-UITestSuggestions")
            app.launchEnvironment["UITEST_SUGGESTIONS"] = scenario
        }
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

    // MARK: - Audit d'accessibilité

    /// Passe l'audit d'accessibilité d'Apple (iOS 17+) sur l'écran affiché ; chaque écart est un échec du test.
    ///
    /// Types d'écarts ignorés, à retirer au fur et à mesure :
    /// - `.contrast` : le mode « contraste amélioré » n'est pas encore livré (change add-accessibility-mode, groupe 9) ;
    /// - `.dynamicType` : Dynamic Type est un change séparé.
    func auditAccessibility(_ screen: String, file: StaticString = #filePath, line: UInt = #line) {
        guard #available(iOS 17.0, *) else { return }
        XCTContext.runActivity(named: "Audit d'accessibilité : \(screen)") { _ in
            do {
                let types = XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])
                try app.performAccessibilityAudit(for: types) { issue in
                    // Le détail de chaque écart va au journal (l'erreur seule ne nomme pas l'élément).
                    let element = issue.element.map { "\($0.elementType) « \($0.label) » id=\($0.identifier) \($0.frame) \($0.debugDescription.prefix(160))" } ?? "élément inconnu"
                    print("[a11y-audit] \(screen) | \(issue.auditType) | \(issue.compactDescription) | \(issue.detailedDescription) | \(element)")
                    return Self.isKnownAuditIssue(screen: screen, issue: issue)   // true = écart connu, ignoré
                }
            } catch {
                XCTFail("Audit d'accessibilité « \(screen) » : \(error)", file: file, line: line)
            }
        }
    }

    /// Écarts relevés par le premier audit (24/11/2026), pas encore corrigés : à corriger puis à retirer d'ici.
    /// Tout autre écart fait échouer le test.
    @available(iOS 17.0, *)
    private static func isKnownAuditIssue(screen: String, issue: XCUIAccessibilityAuditIssue) -> Bool {
        let element = issue.element?.elementType
        switch (screen, issue.auditType) {
        // 3 filtres (120×32 pt) de l'onglet Entraide sans nom
        case ("Onglet actions", .sufficientElementDescription) where element == .button: return true
        // listes (groupes, messages) exposées comme un seul élément sans description
        case (_, .sufficientElementDescription) where element == .table: return true
        // accueil : du texte vu à l'écran mais absent de l'arbre d'accessibilité (élément non identifié) ; le parcours
        // de bienvenue est audité sur ce même écran (relevé seulement depuis que le parcours s'affiche à nouveau en test)
        case ("Accueil", .elementDetection), ("Onglet home", .elementDetection): return true
        case ("Parcours de bienvenue", .elementDetection): return issue.element == nil
        // nœuds SwiftUI de l'accueil et du parcours de bienvenue sous 44 pt (le cadre d'accessibilité SwiftUI
        // ne suit pas `minimumTouchTarget` : il faudrait un `.frame(minWidth:minHeight:)`, qui change la mise en page)
        case ("Accueil", .hitRegion), ("Onglet home", .hitRegion), ("Parcours de bienvenue", .hitRegion): return issue.element == nil
        default: return false
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
