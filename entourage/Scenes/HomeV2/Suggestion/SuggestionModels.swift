//
//  SuggestionModels.swift
//  entourage
//
//  Contrat de données du moteur de suggestion (EN-9473) : { hero, explorer[] }.
//  Le décodage est tolérant : un type, une raison ou une cible inconnus (ancienne
//  version de l'app face à un moteur plus récent) sont ignorés, jamais bloquants.
//

import Foundation

// MARK: - Types

enum SuggestionType: String, Decodable {
    case entraide
    case contenu
    case evenement
    case groupe
    case connexion
    case lieu
}

enum SuggestionCTA: String, Decodable {
    case answer      // Répondre
    case read        // Lire
    case participate // Je participe !
    case register    // Je m'inscris
    case join        // Rejoindre
    case sayHello    // Dire bonjour
    case seePlace    // Voir le lieu
}

enum SuggestionReasonKind: String, Decodable {
    case proximity
    case interests
    case moment
    case history
    case need
    case accessibility
    case socialProof = "social_proof"
}

/// Onglet / liste cible d'un accès Explorer ou du corps de la card.
enum SuggestionTarget: String, Decodable {
    case events
    case groups
    case demands
    case contributions
    case resources
    case places
}

// MARK: - Tolerant decoding

/// Tableau dont les éléments illisibles sont écartés au lieu de faire échouer tout le décodage.
struct LossyArray<Element: Decodable>: Decodable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var result = [Element]()
        while !container.isAtEnd {
            if let element = try? container.decode(Element.self) {
                result.append(element)
            } else {
                // Avance le curseur sur l'élément en échec.
                _ = try? container.decode(DiscardedValue.self)
            }
        }
        elements = result
    }

    private struct DiscardedValue: Decodable {
        init(from decoder: Decoder) throws {}
    }
}

// MARK: - Models

struct SuggestionReason: Decodable, Equatable {
    let kind: SuggestionReasonKind
    let text: String
}

struct SuggestionMeta: Decodable, Equatable {
    /// Emoji ou nom de symbole : le moteur ne fournit pas d'icônes, l'app a un repli par type.
    let icon: String?
    let text: String
}

struct SuggestionCard: Decodable {
    let id: String
    let type: SuggestionType
    /// Événement en visio : pas de distance, mention « En visio ».
    let isRemote: Bool
    /// Groupe national thématique : pas de distance, suggéré sur le thème.
    let isNational: Bool
    /// Chip secondaire du badge (catégorie d'entraide, « Quartier », « National »…).
    let chip: String?
    let authorName: String?
    let title: String
    /// Texte saisi par l'utilisateur (entraide) : affiché brut, jamais reformulé.
    let body: String?
    let metas: [SuggestionMeta]
    let mediaEmoji: String?
    let ctaOverride: SuggestionCTA?
    let reasons: [SuggestionReason]

    enum CodingKeys: String, CodingKey {
        case id, type, chip, title, body, metas, reasons
        case isRemote = "is_remote"
        case isNational = "is_national"
        case authorName = "author_name"
        case mediaEmoji = "media_emoji"
        case ctaOverride = "cta"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        type = try c.decode(SuggestionType.self, forKey: .type)
        title = try c.decode(String.self, forKey: .title)
        isRemote = (try? c.decode(Bool.self, forKey: .isRemote)) ?? false
        isNational = (try? c.decode(Bool.self, forKey: .isNational)) ?? false
        chip = try? c.decode(String.self, forKey: .chip)
        authorName = try? c.decode(String.self, forKey: .authorName)
        body = try? c.decode(String.self, forKey: .body)
        mediaEmoji = try? c.decode(String.self, forKey: .mediaEmoji)
        ctaOverride = try? c.decode(SuggestionCTA.self, forKey: .ctaOverride)
        // Chaque ligne de méta est optionnelle ; 3 au maximum.
        let lossyMetas = (try? c.decode(LossyArray<SuggestionMeta>.self, forKey: .metas))?.elements ?? []
        metas = Array(lossyMetas.prefix(3))
        reasons = (try? c.decode(LossyArray<SuggestionReason>.self, forKey: .reasons))?.elements ?? []
    }

    var cta: SuggestionCTA {
        if let override = ctaOverride { return override }
        switch type {
        case .entraide: return .answer
        case .contenu: return .read
        case .evenement: return isRemote ? .register : .participate
        case .groupe: return .join
        case .connexion: return .sayHello
        case .lieu: return .seePlace
        }
    }

    /// Cible ouverte par le CTA et par le tap sur le corps de la card.
    var target: SuggestionTarget {
        switch type {
        case .entraide: return .demands
        case .contenu: return .resources
        case .evenement: return .events
        case .groupe: return .groups
        case .connexion: return .groups
        case .lieu: return .places
        }
    }
}

struct ExplorerAccess: Decodable {
    let id: String
    let type: SuggestionType
    let label: String
    let context: String?
    let target: SuggestionTarget
}

struct SuggestionPayload: Decodable {
    let hero: SuggestionCard?
    let explorer: [ExplorerAccess]
    /// Profil « personne isolée » : la preuve sociale (« des voisins y participent ») est masquée.
    let isIsolatedProfile: Bool

    enum CodingKeys: String, CodingKey {
        case hero, explorer
        case isIsolatedProfile = "is_isolated_profile"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hero = try? c.decode(SuggestionCard.self, forKey: .hero)
        // Entre 2 et 4 accès affichés ; moins si le moteur en renvoie moins.
        let all = (try? c.decode(LossyArray<ExplorerAccess>.self, forKey: .explorer))?.elements ?? []
        explorer = Array(all.prefix(4))
        isIsolatedProfile = (try? c.decode(Bool.self, forKey: .isIsolatedProfile)) ?? false
    }

    var isEmpty: Bool { hero == nil && explorer.isEmpty }
}
