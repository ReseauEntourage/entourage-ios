import Foundation

/// Règles locales qui passent automatiquement toutes les étapes du parcours de bienvenue. Elles ne servent plus que de repli
/// quand `home/summary` ne renvoie pas `user.onboarding_journey` (backend ancien) : sinon le backend porte le retrait :
/// - J14 : 14 jours ou plus écoulés depuis la dernière connexion (date stockée localement) ;
/// - J30 : compte créé il y a 30 jours ou plus (`created_at` du profil).
/// Quand une règle s'applique, l'app envoie `POST users/onboarding_step_skipped` pour chaque étape encore à faire.
struct WelcomeJourneyAutoSkip {

    enum Reason: Equatable {
        case inactiveFor14Days
        case accountOlderThan30Days
    }

    static let inactivityDays = 14
    static let accountAgeDays = 30
    static let lastConnectionKey = "welcomeJourneyLastConnection"

    // MARK: - Règle

    /// Retourne la raison de tout passer, ou `nil` si le parcours doit rester tel quel.
    static func reason(now: Date,
                       lastConnection: Date?,
                       accountCreation: Date?,
                       calendar: Calendar = .current) -> Reason? {
        if let created = accountCreation, daysBetween(created, now, calendar) >= accountAgeDays {
            return .accountOlderThan30Days
        }
        if let last = lastConnection, daysBetween(last, now, calendar) >= inactivityDays {
            return .inactiveFor14Days
        }
        return nil
    }

    private static func daysBetween(_ from: Date, _ to: Date, _ calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    // MARK: - Dernière connexion (stockée en local, équivalent du "cookie")

    static func lastConnection(defaults: UserDefaults = .standard) -> Date? {
        defaults.object(forKey: lastConnectionKey) as? Date
    }

    static func recordConnection(at date: Date = Date(), defaults: UserDefaults = .standard) {
        defaults.set(date, forKey: lastConnectionKey)
    }
}

/// Masquage mémorisé localement, par utilisateur : repli quand le backend ne porte pas l'état du parcours
/// (`onboarding_journey` absent) ou quand `onboarding_journey_hidden` a échoué. Les étapes restantes sont alors passées
/// côté backend, ce qui arrête aussi les relances.
struct WelcomeJourneyHiddenFlag {

    private static func key(userId: String) -> String { "welcomeJourneyHidden_\(userId)" }

    static func isHidden(userId: String?, defaults: UserDefaults = .standard) -> Bool {
        guard let userId = userId, !userId.isEmpty else { return false }
        return defaults.bool(forKey: key(userId: userId))
    }

    static func markHidden(userId: String?, defaults: UserDefaults = .standard) {
        guard let userId = userId, !userId.isEmpty else { return }
        defaults.set(true, forKey: key(userId: userId))
    }
}
