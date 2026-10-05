#if DEBUG
import Foundation
import SimpleKeychain

/// Prépare l'app pour les tests UI (XCUITest) quand elle est lancée avec l'argument `-UITestMode`.
///
/// - branche `NetworkManager` sur `StubBackend` (aucun appel réseau réel)
/// - crée un faux utilisateur connecté pour passer directement sur l'accueil
/// - charge les fake data du `home/summary` depuis `UITEST_EVENTS` (events séparés par des virgules)
/// - écrit chaque requête dans le fichier `UITEST_REQUEST_LOG` pour que le test les vérifie
enum UITestBootstrap {
    static let launchArgument = "-UITestMode"
    static let eventsEnvKey = "UITEST_EVENTS"
    static let requestLogEnvKey = "UITEST_REQUEST_LOG"
    /// Simule une dernière connexion il y a N jours (règle J14 du parcours de bienvenue).
    static let lastConnectionDaysAgoEnvKey = "UITEST_LAST_CONNECTION_DAYS_AGO"
    /// Simule un compte créé il y a N jours (règle J30 du parcours de bienvenue).
    static let accountAgeDaysEnvKey = "UITEST_ACCOUNT_AGE_DAYS"
    /// Retarde la réponse du skip de N millisecondes (serveur lent).
    static let skipDelayMsEnvKey = "UITEST_SKIP_DELAY_MS"

    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }

    /// À appeler dans `didFinishLaunching`, une fois l'environnement initialisé.
    static func configureIfNeeded() {
        guard isActive else { return }
        let env = ProcessInfo.processInfo.environment

        if let logPath = env[requestLogEnvKey], !logPath.isEmpty {
            StubBackend.shared.requestLogURL = URL(fileURLWithPath: logPath)
        }
        let events = (env[eventsEnvKey] ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        StubBackend.shared.reset(events: events)
        StubBackend.shared.skipResponseDelay = (Double(env[skipDelayMsEnvKey] ?? "") ?? 0) / 1000
        NetworkManager.sharedInstance.setProtocolClasses([StubURLProtocol.self])

        // Faux utilisateur connecté + état propre du parcours de bienvenue.
        var user = User()
        user.sid = 1
        user.uuid = "uitest-uuid" // requis par la chaîne de chargement de l'accueil (getMyGroups…)
        user.token = "uitest-token"
        user.firebaseProperties = [:]

        // `created_at` est une propriété privée du modèle : on passe par un aller-retour JSON
        // (à partir d'un utilisateur complet, le décodage exigeant toutes les clés non optionnelles).
        if let ageDays = Int(env[accountAgeDaysEnvKey] ?? ""),
           let data = try? JSONEncoder().encode(user),
           var json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
            json["created_at"] = formatter.string(from: Date().addingTimeInterval(-Double(ageDays) * 86_400))
            if let patched = try? JSONSerialization.data(withJSONObject: json),
               let decoded = try? JSONDecoder().decode(User.self, from: patched) {
                user = decoded
            }
        }
        UserDefaults.currentUser = user

        if let daysAgo = Int(env[lastConnectionDaysAgoEnvKey] ?? "") {
            WelcomeJourneyAutoSkip.recordConnection(at: Date().addingTimeInterval(-Double(daysAgo) * 86_400 - 60))
        } else {
            UserDefaults.standard.removeObject(forKey: WelcomeJourneyAutoSkip.lastConnectionKey)
        }
        A0SimpleKeychain().setString("uitest", forKey: kKeychainPassword)
        UserDefaults.standard.removeObject(forKey: "hasShownWelcomeCelebration")
        UserDefaults.standard.removeObject(forKey: "hasShownWelcomeNationalGroupSnackbar")
    }
}
#endif
