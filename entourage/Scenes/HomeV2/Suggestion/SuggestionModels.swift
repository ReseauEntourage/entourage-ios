//
//  SuggestionModels.swift
//  entourage
//
//  Modèles d'affichage du moteur de suggestion (EN-9473) : { hero, explorer[] }.
//  Le moteur (`/api/v1/next_steps`) est converti vers ces modèles par `NextStepAdapter`.
//  Le décodage JSON de ces types ne sert plus qu'au fournisseur factice (tests, prévisualisations) :
//  un type, une raison ou une cible inconnus (ancienne version de l'app face à un moteur plus récent)
//  sont ignorés, jamais bloquants.
//

import Foundation

// MARK: - Types

/// Les valeurs sont les `kind` du moteur. `connexion` n'est jamais envoyé par le moteur :
/// son affichage reste dans l'app, mais il n'est alimenté par rien.
enum SuggestionType: String, Decodable {
    case action                              // entraide
    case contentPath = "content_path"        // mini-parcours de contenus
    case outing                              // événement (papotage = événement en visio)
    case neighborhood                        // groupe local ou national
    case smalltalk                           // Bonnes ondes
    case poi                                 // lieu solidaire
    case postMessage = "post_message"        // poster un message dans un groupe
    case becomeAmbassador = "become_ambassador"
    case connexion
}

enum SuggestionCTA: String, Decodable {
    case answer      // Répondre
    case read        // Lire
    case participate // Je participe !
    case register    // Je m'inscris
    case join        // Rejoindre
    case sayHello    // Dire bonjour
    case seePlace    // Voir le lieu
    case smallTalk       // Essayer les Bonnes ondes
    case writeMessage    // Écrire un message
    case becomeAmbassador // Devenir Animateur
}

/// Onglet / liste cible d'un accès Explorer ou du corps de la card (fournisseur factice).
enum SuggestionTarget: String, Decodable {
    case events
    case groups
    case demands
    case contributions
    case resources
    case places
}

/// Ce que la card ou une ligne de l'Explorer ouvre : l'écran ou le flux existant du type.
enum SuggestionDestination: Equatable {
    case outing(id: Int)
    case neighborhood(id: Int)
    case action(id: Int, isContrib: Bool)
    case resource(id: Int)
    case poi(id: Int)
    case smallTalk
    case link(URL)
    case list(SuggestionTarget)
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

/// Une raison du « Pourquoi cette suggestion ? » : le code sert à choisir l'icône, la phrase
/// est celle du moteur, affichée telle quelle (déjà traduite, variante douce comprise).
struct SuggestionReason: Decodable, Equatable {
    let code: String
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
    /// Écran ou flux ouvert par le CTA et par le tap sur le corps de la card.
    let destination: SuggestionDestination
    /// Identifiant du prochain pas (`placement` hero) : nécessaire pour ignorer et pour la mesure.
    let nextStepId: Int?
    /// Identifiant de la cible (autre piste) : nécessaire pour la mesure.
    let targetId: Int?

    enum CodingKeys: String, CodingKey {
        case id, type, chip, title, body, metas, reasons
        case isRemote = "is_remote"
        case isNational = "is_national"
        case authorName = "author_name"
        case mediaEmoji = "media_emoji"
        case ctaOverride = "cta"
    }

    init(id: String,
         type: SuggestionType,
         isRemote: Bool = false,
         isNational: Bool = false,
         chip: String? = nil,
         authorName: String? = nil,
         title: String,
         body: String? = nil,
         metas: [SuggestionMeta] = [],
         mediaEmoji: String? = nil,
         ctaOverride: SuggestionCTA? = nil,
         reasons: [SuggestionReason] = [],
         destination: SuggestionDestination? = nil,
         nextStepId: Int? = nil,
         targetId: Int? = nil) {
        self.id = id
        self.type = type
        self.isRemote = isRemote
        self.isNational = isNational
        self.chip = chip
        self.authorName = authorName
        self.title = title
        self.body = body
        // Chaque ligne de méta est optionnelle ; 3 au maximum.
        self.metas = Array(metas.prefix(3))
        self.mediaEmoji = mediaEmoji
        self.ctaOverride = ctaOverride
        self.reasons = reasons
        self.destination = destination ?? .list(SuggestionCard.defaultList(for: type))
        self.nextStepId = nextStepId
        self.targetId = targetId
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let decodedType = try c.decode(SuggestionType.self, forKey: .type)
        self.init(
            id: try c.decode(String.self, forKey: .id),
            type: decodedType,
            isRemote: (try? c.decode(Bool.self, forKey: .isRemote)) ?? false,
            isNational: (try? c.decode(Bool.self, forKey: .isNational)) ?? false,
            chip: try? c.decode(String.self, forKey: .chip),
            authorName: try? c.decode(String.self, forKey: .authorName),
            title: try c.decode(String.self, forKey: .title),
            body: try? c.decode(String.self, forKey: .body),
            metas: (try? c.decode(LossyArray<SuggestionMeta>.self, forKey: .metas))?.elements ?? [],
            mediaEmoji: try? c.decode(String.self, forKey: .mediaEmoji),
            ctaOverride: try? c.decode(SuggestionCTA.self, forKey: .ctaOverride),
            reasons: (try? c.decode(LossyArray<SuggestionReason>.self, forKey: .reasons))?.elements ?? []
        )
    }

    var cta: SuggestionCTA {
        if let override = ctaOverride { return override }
        switch type {
        case .action: return .answer
        case .contentPath: return .read
        case .outing: return isRemote ? .register : .participate
        case .neighborhood: return .join
        case .smalltalk: return .smallTalk
        case .poi: return .seePlace
        case .postMessage: return .writeMessage
        case .becomeAmbassador: return .becomeAmbassador
        case .connexion: return .sayHello
        }
    }

    /// Liste ouverte quand le fournisseur ne donne pas de cible précise (fournisseur factice).
    static func defaultList(for type: SuggestionType) -> SuggestionTarget {
        switch type {
        case .action: return .demands
        case .contentPath: return .resources
        case .outing: return .events
        case .neighborhood, .postMessage, .connexion: return .groups
        case .poi: return .places
        case .smalltalk, .becomeAmbassador: return .events
        }
    }
}

struct ExplorerAccess: Decodable {
    let id: String
    let type: SuggestionType
    let label: String
    let context: String?
    let destination: SuggestionDestination
    /// Pour la mesure (`placement` others) : `item_kind` est le `type`, `target_id` celui-ci.
    let targetId: Int?

    enum CodingKeys: String, CodingKey {
        case id, type, label, context, target
    }

    init(id: String, type: SuggestionType, label: String, context: String?, destination: SuggestionDestination, targetId: Int? = nil) {
        self.id = id
        self.type = type
        self.label = label
        self.context = context
        self.destination = destination
        self.targetId = targetId
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(SuggestionType.self, forKey: .type)
        let list = (try? c.decode(SuggestionTarget.self, forKey: .target)) ?? SuggestionCard.defaultList(for: type)
        self.init(id: try c.decode(String.self, forKey: .id),
                  type: type,
                  label: try c.decode(String.self, forKey: .label),
                  context: try? c.decode(String.self, forKey: .context),
                  destination: .list(list))
    }
}

struct SuggestionPayload: Decodable {
    var hero: SuggestionCard?
    let explorer: [ExplorerAccess]

    enum CodingKeys: String, CodingKey {
        case hero, explorer
    }

    init(hero: SuggestionCard?, explorer: [ExplorerAccess]) {
        self.hero = hero
        self.explorer = Array(explorer.prefix(4))
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let all = (try? c.decode(LossyArray<ExplorerAccess>.self, forKey: .explorer))?.elements ?? []
        self.init(hero: try? c.decode(SuggestionCard.self, forKey: .hero), explorer: all)
    }

    var isEmpty: Bool { hero == nil && explorer.isEmpty }
}
