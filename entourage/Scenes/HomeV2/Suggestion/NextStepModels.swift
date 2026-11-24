//
//  NextStepModels.swift
//  entourage
//
//  Contrat du moteur « Votre prochain pas » (`/api/v1/next_steps`, EN-9473, design.md décision 12)
//  et adaptateur vers les modèles d'affichage de la home (`{ hero, explorer[] }`).
//
//  Le décodage est tolérant : un élément illisible ou d'un `kind` inconnu de cette version
//  de l'app est écarté, jamais bloquant.
//

import Foundation

// MARK: - Réponses du moteur

/// Cible d'une suggestion, sérialisée par le sérialiseur v1 de son type (événement, groupe,
/// entraide, lieu, ressource). Seuls les champs affichés sont lus ; tous sont optionnels.
struct NextStepTarget: Decodable {
    let id: Int?
    let title: String?
    let description: String?
    let isOnline: Bool
    let isNational: Bool
    /// Distance en kilomètres, quand le moteur la connaît.
    let distanceKm: Double?
    let startsAt: String?
    /// Adresse affichable : jamais vide (un texte vide est ramené à `nil`).
    let address: String?
    /// L'adresse à afficher : `nil` si elle est absente ou vide (le moteur renvoie parfois `display_address: ""`).
    var visibleAddress: String? {
        guard let trimmed = address?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
        return trimmed
    }
    let authorName: String?
    /// Photo de profil de l'auteur d'une entraide (`author.avatar_url`, miniature 300×300) : `nil` quand
    /// la personne n'a pas de photo ou que l'adresse n'est pas exploitable. On ne lit jamais `image_url`
    /// (l'image jointe à une proposition d'aide) : le média de la card est le portrait de la personne.
    let authorAvatarURL: URL?
    /// `solicitation` (demande) ou `contribution` (proposition d'aide), pour une entraide.
    let actionType: String?
    /// Durée en minutes, pour une ressource.
    let durationMinutes: Int?
    /// Une ressource déjà lue par l'utilisateur (mini-parcours : on ouvre la première non lue).
    let isWatched: Bool
    /// Zone d'un groupe : absente pour un groupe thématique national.
    let zone: String?
    /// Horaires d'un lieu solidaire (texte brut, parfois sur plusieurs lignes).
    let hours: String?
    /// Les horaires à afficher : `nil` s'ils sont absents ou vides.
    var visibleHours: String? {
        guard let trimmed = hours?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
        return trimmed
    }

    enum CodingKeys: String, CodingKey {
        case id, title, name, description, online, national, distance, metadata, author, adress, address, duration, watched, zone, hours
        case actionType = "action_type"
    }

    enum MetadataKeys: String, CodingKey {
        case startsAt = "starts_at"
        case displayAddress = "display_address"
    }

    /// Adresse d'un groupe : un objet `{ latitude, longitude, display_address }`.
    enum AddressKeys: String, CodingKey {
        case displayAddress = "display_address"
    }

    enum AuthorKeys: String, CodingKey {
        case displayName = "display_name"
        case avatarURL = "avatar_url"
    }

    /// Adresse d'image affichable : `http(s)` seulement. Vide, absente ou illisible (`null`, `""`, `n/a`) : `nil`.
    static func imageURL(from text: String?) -> URL? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty,
              let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else { return nil }
        return url
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(Int.self, forKey: .id)
        // Un événement ou une entraide a un `title`, un groupe, un lieu ou une ressource un `name`.
        title = (try? c.decode(String.self, forKey: .title)) ?? (try? c.decode(String.self, forKey: .name))
        description = try? c.decode(String.self, forKey: .description)
        isOnline = (try? c.decode(Bool.self, forKey: .online)) ?? false
        isNational = (try? c.decode(Bool.self, forKey: .national)) ?? false
        if let value = try? c.decode(Double.self, forKey: .distance) {
            distanceKm = value
        } else if let text = try? c.decode(String.self, forKey: .distance), let value = Double(text) {
            distanceKm = value
        } else {
            distanceKm = nil
        }
        if let meta = try? c.nestedContainer(keyedBy: MetadataKeys.self, forKey: .metadata) {
            startsAt = try? meta.decode(String.self, forKey: .startsAt)
            address = try? meta.decode(String.self, forKey: .displayAddress)
        } else {
            startsAt = nil
            // Un lieu donne `adress` en texte ; un groupe donne `address` en objet (ou, ailleurs, en texte).
            if let text = (try? c.decode(String.self, forKey: .adress)) ?? (try? c.decode(String.self, forKey: .address)) {
                address = text
            } else if let object = try? c.nestedContainer(keyedBy: AddressKeys.self, forKey: .address) {
                address = try? object.decode(String.self, forKey: .displayAddress)
            } else {
                address = nil
            }
        }
        if let author = try? c.nestedContainer(keyedBy: AuthorKeys.self, forKey: .author) {
            authorName = try? author.decode(String.self, forKey: .displayName)
            authorAvatarURL = NextStepTarget.imageURL(from: try? author.decode(String.self, forKey: .avatarURL))
        } else {
            authorName = nil
            authorAvatarURL = nil
        }
        actionType = try? c.decode(String.self, forKey: .actionType)
        durationMinutes = try? c.decode(Int.self, forKey: .duration)
        isWatched = (try? c.decode(Bool.self, forKey: .watched)) ?? false
        zone = try? c.decode(String.self, forKey: .zone)
        hours = try? c.decode(String.self, forKey: .hours)
    }
}

/// Une suggestion du moteur : le prochain pas (`placement` hero, avec `id`) ou une autre piste.
struct NextStepItem: Decodable {
    let id: Int?
    let kind: String
    let placement: String?
    let target: NextStepTarget?
    /// Les trois ressources d'un mini-parcours (`content_path`).
    let targets: [NextStepTarget]
    /// Adresse du formulaire « devenir Animateur » (`become_ambassador`).
    let link: String?
    let reasons: [SuggestionReason]

    enum CodingKeys: String, CodingKey {
        case id, kind, placement, target, targets, link, reasons
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(Int.self, forKey: .id)
        kind = try c.decode(String.self, forKey: .kind)
        placement = try? c.decode(String.self, forKey: .placement)
        target = try? c.decode(NextStepTarget.self, forKey: .target)
        targets = (try? c.decode(LossyArray<NextStepTarget>.self, forKey: .targets))?.elements ?? []
        link = try? c.decode(String.self, forKey: .link)
        reasons = (try? c.decode(LossyArray<SuggestionReason>.self, forKey: .reasons))?.elements ?? []
    }
}

/// Réponse de `GET /next_steps/current` et de `POST /next_steps/:id/ignore`.
struct NextStepSingleResponse: Decodable {
    let item: NextStepItem?

    enum CodingKeys: String, CodingKey { case item = "next_step" }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        item = try? c.decode(NextStepItem.self, forKey: .item)
    }
}

/// Réponse de `GET /next_steps/others`.
struct NextStepOthersResponse: Decodable {
    let items: [NextStepItem]

    enum CodingKeys: String, CodingKey { case items = "next_steps" }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        items = (try? c.decode(LossyArray<NextStepItem>.self, forKey: .items))?.elements ?? []
    }
}

// MARK: - Adaptateur vers les modèles d'affichage

enum NextStepAdapter {

    /// Nombre maximal d'autres pistes affichées dans la zone « Pour vous aujourd'hui ».
    static let maxOthers = 3

    static func payload(current: NextStepItem?, others: [NextStepItem]) -> SuggestionPayload {
        let hero = current.flatMap { card(from: $0) }
        let accesses = others.prefix(maxOthers).compactMap { access(from: $0) }
        return SuggestionPayload(hero: hero, explorer: accesses)
    }

    /// `nil` pour un `kind` inconnu de cette version de l'app, ou une suggestion inutilisable
    /// (cible absente, formulaire sans adresse) : la card n'est alors pas affichée.
    static func card(from item: NextStepItem) -> SuggestionCard? {
        guard let type = SuggestionType(rawValue: item.kind), type != .connexion else { return nil }
        let isHero = item.id != nil
        let cardId = isHero ? "\(item.id!)" : "others-\(item.kind)-\(item.target?.id ?? 0)"
        let reasons = item.reasons
        let target = item.target
        let id = target?.id

        func make(title: String, isRemote: Bool = false, isNational: Bool = false, chip: String? = nil,
                  author: String? = nil, authorAvatarURL: URL? = nil, body: String? = nil, metas: [SuggestionMeta] = [],
                  destination: SuggestionDestination) -> SuggestionCard {
            return SuggestionCard(id: cardId, type: type, isRemote: isRemote, isNational: isNational, chip: chip,
                                  authorName: author, authorAvatarURL: authorAvatarURL, title: title, body: body, metas: metas,
                                  reasons: reasons, destination: destination,
                                  nextStepId: isHero ? item.id : nil, targetId: id)
        }

        switch type {
        case .outing:
            guard let target = target, let id = id, let title = target.title else { return nil }
            var metas = [SuggestionMeta]()
            if let date = Utils.getDateFromWSDateString(target.startsAt) {
                metas.append(SuggestionMeta(icon: "🗓", text: eventDateFormatter.string(from: date)))
            }
            if target.isOnline {
                metas.append(.computed(icon: "💻", text: "suggestion_meta_remote".localized))
            } else {
                if let address = target.visibleAddress { metas.append(SuggestionMeta(icon: "📍", text: address)) }
                if let distance = distanceText(target.distanceKm) { metas.append(.computed(icon: nil, text: distance)) }
            }
            return make(title: title, isRemote: target.isOnline, metas: metas, destination: .outing(id: id))

        case .neighborhood:
            guard let target = target, let id = id, let title = target.title else { return nil }
            let chip = target.isNational ? "suggestion_chip_national".localized : "suggestion_chip_local".localized
            return make(title: title, isNational: target.isNational, chip: chip, metas: groupMetas(target), destination: .neighborhood(id: id))

        case .action:
            guard let target = target, let id = id, let title = target.title else { return nil }
            var metas = [SuggestionMeta]()
            if let distance = distanceText(target.distanceKm) { metas.append(.computed(icon: "📍", text: distance)) }
            let isContrib = target.actionType == "contribution"
            return make(title: title, author: target.authorName, authorAvatarURL: target.authorAvatarURL,
                        body: target.description, metas: metas, destination: .action(id: id, isContrib: isContrib))

        case .contentPath:
            // On ouvre le premier contenu non lu ; si tous sont lus, le premier.
            guard let opened = item.targets.first(where: { !$0.isWatched && $0.id != nil }) ?? item.targets.first,
                  let openedId = opened.id else { return nil }
            let metas = item.targets.prefix(3).compactMap { resource -> SuggestionMeta? in
                guard let title = resource.title else { return nil }
                let duration = resource.durationMinutes.map { " · " + String(format: "suggestion_meta_minutes".localized, $0) } ?? ""
                // La durée s'affiche sur la card ; le contexte d'une ligne Explorer est le titre seul, comme sur Android.
                return SuggestionMeta(icon: "📘", text: title + duration, context: title)
            }
            return make(title: "suggestion_content_path_title".localized, metas: metas, destination: .resource(id: openedId))

        case .smalltalk:
            // Comme Android : la phrase du moteur sert de texte.
            return make(title: "suggestion_smalltalk_title".localized, body: reasons.first?.text, destination: .smallTalk)

        case .poi:
            guard let target = target, let id = id, let title = target.title else { return nil }
            var metas = [SuggestionMeta]()
            // Comme Android : l'adresse puis les horaires, jamais de distance (design.md, décision 14).
            if let address = target.visibleAddress { metas.append(SuggestionMeta(icon: "📍", text: address)) }
            if let hours = target.visibleHours { metas.append(SuggestionMeta(icon: "🕒", text: hours)) }
            return make(title: title, metas: metas, destination: .poi(id: id))

        case .postMessage:
            guard let target = target, let id = id, let title = target.title else { return nil }
            // Le badge distingue le groupe de voisins du groupe thématique (national) ; le texte est la phrase du moteur, comme Android.
            return make(title: title, isNational: target.isNational, body: reasons.first?.text, metas: groupMetas(target),
                        destination: .neighborhoodPost(id: id, name: title, zone: target.zone, isNational: target.isNational))

        case .becomeAmbassador:
            // Comme Android : seule une adresse https ouvre le formulaire, sinon pas de card.
            guard let link = item.link?.trimmingCharacters(in: .whitespacesAndNewlines), let url = URL(string: link),
                  url.scheme?.lowercased() == "https" else { return nil }
            return make(title: "suggestion_ambassador_title".localized, body: reasons.first?.text, destination: .link(url))

        case .connexion:
            return nil
        }
    }

    /// Une autre piste devient une ligne de la zone : son titre, une ligne de contexte, et un tap qui ouvre la piste
    /// elle-même. Le contexte est, comme sur Android, la première information venue de la cible (date, adresse,
    /// titre du contenu), jamais une information calculée par l'app (distance, « En visio ») ; sinon le texte
    /// de la card (description d'une entraide, phrase du moteur).
    static func access(from item: NextStepItem) -> ExplorerAccess? {
        guard let card = card(from: item) else { return nil }
        let context = card.metas.compactMap { $0.context }.first(where: { !$0.isEmpty }) ?? card.body
        return ExplorerAccess(id: card.id, type: card.type, label: card.title,
                              context: context, destination: card.destination, targetId: card.targetId,
                              badgeKey: card.badgeKey)
    }

    /// Date d'un événement, comme Android : date moyenne et heure courte, dans la langue de l'appareil.
    private static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    /// Un groupe : son adresse seulement quand il est local (comme Android), jamais sa description.
    private static func groupMetas(_ target: NextStepTarget) -> [SuggestionMeta] {
        guard !target.isNational, let address = target.visibleAddress else { return [] }
        return [SuggestionMeta(icon: "📍", text: address)]
    }

    /// « 800 m » sous 1 km, « 3 km » au-delà.
    static func distanceText(_ km: Double?) -> String? {
        guard let km = km, km >= 0 else { return nil }
        if km < 1 {
            let meters = max(Int((km * 10).rounded()) * 100, 100)
            return String(format: "suggestion_meta_distance_m".localized, meters)
        }
        return String(format: "suggestion_meta_distance_km".localized, Int(km.rounded()))
    }
}
