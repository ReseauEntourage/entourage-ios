import Foundation

// MARK: - API models (from /user endpoint)

struct UserBadgeAPI: Codable {
    let name: String
    let awardedAt: String?
    let metadata: BadgeAPIMetadata?

    enum CodingKeys: String, CodingKey {
        case name
        case awardedAt = "awarded_at"
        case metadata
    }
}

struct BadgeAPIMetadata: Codable {
    let target: Int?
    let current: Int?
}

// MARK: - Badge keys (must match backend "name" values)

enum BadgeKey: String, CaseIterable {
    case premierPas      = "bienvenue"
    case premierLien     = "premier_contact"
    case diffuseurLiens  = "moteur_rencontres"
    case asPapotage      = "fidele_papotages"
    case tisseurLiens    = "voix_presente"
}

// MARK: - Badge definition (static metadata)

struct BadgeDefinition {
    let key: BadgeKey
    let emoji: String
    let titleKey: String
    let descriptionShortKey: String
    let howItWorksKey: String
    let whatItMeansKey: String
    let mechanismKey: String
    let isReversible: Bool
    let ctaLabelKey: String        // label when not obtained
    let ctaObtainedLabelKey: String
    let maxProgress: Int
    let unlockedMessageKey: String
}

let allBadgeDefinitions: [BadgeDefinition] = [
    BadgeDefinition(
        key: .premierPas,
        emoji: "👣",
        titleKey: "badge_premier_pas_title",
        descriptionShortKey: "badge_premier_pas_description_short",
        howItWorksKey: "badge_premier_pas_how_it_works",
        whatItMeansKey: "badge_premier_pas_what_it_means",
        mechanismKey: "badge_mechanism_irreversible",
        isReversible: false,
        ctaLabelKey: "badge_premier_pas_cta",
        ctaObtainedLabelKey: "badge_cta_see_badges",
        maxProgress: 1,
        unlockedMessageKey: "badge_premier_pas_unlocked_message"
    ),
    BadgeDefinition(
        key: .premierLien,
        emoji: "🤝",
        titleKey: "badge_premier_lien_title",
        descriptionShortKey: "badge_premier_lien_description_short",
        howItWorksKey: "badge_premier_lien_how_it_works",
        whatItMeansKey: "badge_premier_lien_what_it_means",
        mechanismKey: "badge_mechanism_irreversible",
        isReversible: false,
        ctaLabelKey: "badge_premier_lien_cta",
        ctaObtainedLabelKey: "badge_cta_see_badges",
        maxProgress: 1,
        unlockedMessageKey: "badge_premier_lien_unlocked_message"
    ),
    BadgeDefinition(
        key: .diffuseurLiens,
        emoji: "🪁",
        titleKey: "badge_diffuseur_liens_title",
        descriptionShortKey: "badge_diffuseur_liens_description_short",
        howItWorksKey: "badge_diffuseur_liens_how_it_works",
        whatItMeansKey: "badge_diffuseur_liens_what_it_means",
        mechanismKey: "badge_mechanism_reversible",
        isReversible: true,
        ctaLabelKey: "badge_diffuseur_liens_cta",
        ctaObtainedLabelKey: "badge_cta_see_badges",
        maxProgress: 3,
        unlockedMessageKey: "badge_diffuseur_liens_unlocked_message"
    ),
    BadgeDefinition(
        key: .asPapotage,
        emoji: "💬",
        titleKey: "badge_as_papotage_title",
        descriptionShortKey: "badge_as_papotage_description_short",
        howItWorksKey: "badge_as_papotage_how_it_works",
        whatItMeansKey: "badge_as_papotage_what_it_means",
        mechanismKey: "badge_mechanism_reversible",
        isReversible: true,
        ctaLabelKey: "badge_as_papotage_cta",
        ctaObtainedLabelKey: "badge_cta_see_badges",
        maxProgress: 3,
        unlockedMessageKey: "badge_as_papotage_unlocked_message"
    ),
    BadgeDefinition(
        key: .tisseurLiens,
        emoji: "🌱",
        titleKey: "badge_tisseur_liens_title",
        descriptionShortKey: "badge_tisseur_liens_description_short",
        howItWorksKey: "badge_tisseur_liens_how_it_works",
        whatItMeansKey: "badge_tisseur_liens_what_it_means",
        mechanismKey: "badge_mechanism_reversible",
        isReversible: true,
        ctaLabelKey: "badge_tisseur_liens_cta",
        ctaObtainedLabelKey: "badge_cta_see_badges",
        maxProgress: 3,
        unlockedMessageKey: "badge_tisseur_liens_unlocked_message"
    )
]

// MARK: - UserBadgeProgress (view model)

struct UserBadgeProgress: Identifiable {
    var id: String { definition.key.rawValue }
    let definition: BadgeDefinition
    let isObtained: Bool
    let progress: Int    // current count from API (0 if badge not returned by API)
    let target: Int      // target count (from API metadata.target or def.maxProgress)
    let obtainedDate: String?  // raw ISO8601 string from awarded_at
}

// MARK: - Builder

func buildBadgeProgress(apiBadges: [UserBadgeAPI]) -> [UserBadgeProgress] {
    return allBadgeDefinitions.map { def in
        let apiBadge = apiBadges.first { $0.name == def.key.rawValue }
        let isObtained = apiBadge?.awardedAt != nil
        let current = apiBadge?.metadata?.current ?? 0
        let target = apiBadge?.metadata?.target ?? def.maxProgress
        return UserBadgeProgress(
            definition: def,
            isObtained: isObtained,
            progress: current,
            target: target,
            obtainedDate: apiBadge?.awardedAt
        )
    }
}

// MARK: - Date formatting

func formatBadgeDate(_ isoString: String) -> String {
    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = iso.date(from: isoString) {
        return displayDate(date)
    }
    iso.formatOptions = [.withInternetDateTime]
    if let date = iso.date(from: isoString) {
        return displayDate(date)
    }
    return isoString
}

private func displayDate(_ date: Date) -> String {
    let fmt = DateFormatter()
    fmt.locale = Locale.getPreferredLocale()
    fmt.dateFormat = "dd/MM/yyyy"
    return fmt.string(from: date)
}
