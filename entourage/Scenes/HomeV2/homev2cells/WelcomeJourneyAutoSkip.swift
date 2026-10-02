import Foundation

/// Règles qui passent automatiquement toutes les étapes du parcours de bienvenue (100 % front) :
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
