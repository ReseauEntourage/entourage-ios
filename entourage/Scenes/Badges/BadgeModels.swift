import Foundation

enum BadgeKey: String, CaseIterable {
    case premierPas = "bienvenue"
    case premierLien = "premier_contact"
    case diffuseurLiens = "moteur_rencontres"
    case asPapotage = "fidele_papotages"
    case tisseurLiens = "voix_presente"
}

struct BadgeDefinition {
    let key: BadgeKey
    let emoji: String
    let titleKey: String
    let descriptionShortKey: String
    let howItWorksKey: String
    let whatItMeansKey: String
    let mechanismKey: String
    let isReversible: Bool
    let ctaLabelKey: String
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
        maxProgress: 3,
        unlockedMessageKey: "badge_tisseur_liens_unlocked_message"
    )
]

struct UserBadgeProgress: Identifiable {
    var id: String { definition.key.rawValue }
    let definition: BadgeDefinition
    let isObtained: Bool
    let progress: Int
    let obtainedDate: String?
}

func buildBadgeProgress(obtainedKeys: [String]) -> [UserBadgeProgress] {
    let demoInProgress: [BadgeKey: Int] = obtainedKeys.isEmpty ? [:] : [
        .asPapotage: 2,
        .tisseurLiens: 2
    ]
    return allBadgeDefinitions.map { def in
        let isObtained = obtainedKeys.contains(def.key.rawValue)
        let progress = isObtained ? def.maxProgress : (demoInProgress[def.key] ?? 0)
        return UserBadgeProgress(
            definition: def,
            isObtained: isObtained,
            progress: progress,
            obtainedDate: nil
        )
    }
}
