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
    let address: String?
    let authorName: String?
    /// `solicitation` (demande) ou `contribution` (proposition d'aide), pour une entraide.
    let actionType: String?
    /// Durée en minutes, pour une ressource.
    let durationMinutes: Int?
    /// Une ressource déjà lue par l'utilisateur (mini-parcours : on ouvre la première non lue).
    let isWatched: Bool
    /// Zone d'un groupe : absente pour un groupe thématique national.
    let zone: String?

    enum CodingKeys: String, CodingKey {
        case id, title, name, description, online, national, distance, metadata, author, adress, address, duration, watched, zone
        case actionType = "action_type"
    }

    enum MetadataKeys: String, CodingKey {
        case startsAt = "starts_at"
        case displayAddress = "display_address"
    }

    enum AuthorKeys: String, CodingKey {
        case displayName = "display_name"
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
            address = (try? c.decode(String.self, forKey: .adress)) ?? (try? c.decode(String.self, forKey: .address))
        }
        if let author = try? c.nestedContainer(keyedBy: AuthorKeys.self, forKey: .author) {
            authorName = try? author.decode(String.self, forKey: .displayName)
        } else {
            authorName = nil
        }
        actionType = try? c.decode(String.self, forKey: .actionType)
        durationMinutes = try? c.decode(Int.self, forKey: .duration)
        isWatched = (try? c.decode(Bool.self, forKey: .watched)) ?? false
        zone = try? c.decode(String.self, forKey: .zone)
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
                  author: String? = nil, body: String? = nil, metas: [SuggestionMeta] = [],
                  destination: SuggestionDestination) -> SuggestionCard {
            return SuggestionCard(id: cardId, type: type, isRemote: isRemote, isNational: isNational, chip: chip,
                                  authorName: author, title: title, body: body, metas: metas,
                                  reasons: reasons, destination: destination,
                                  nextStepId: isHero ? item.id : nil, targetId: id)
        }

        switch type {
        case .outing:
            guard let target = target, let id = id, let title = target.title else { return nil }
            var metas = [SuggestionMeta]()
            if let date = Utils.getDateFromWSDateString(target.startsAt) {
                metas.append(SuggestionMeta(icon: "🗓", text: Utils.formatEventDateTimeFull(date: date)))
            }
            if target.isOnline {
                metas.append(SuggestionMeta(icon: "💻", text: "suggestion_meta_remote".localized))
            } else {
                if let address = target.address, !address.isEmpty { metas.append(SuggestionMeta(icon: "📍", text: address)) }
                if let distance = distanceText(target.distanceKm) { metas.append(SuggestionMeta(icon: nil, text: distance)) }
            }
            return make(title: title, isRemote: target.isOnline, metas: metas, destination: .outing(id: id))

        case .neighborhood:
            guard let target = target, let id = id, let title = target.title else { return nil }
            let chip = target.isNational ? "suggestion_chip_national".localized : "suggestion_chip_local".localized
            var metas = [SuggestionMeta]()
            if let description = target.description, !description.isEmpty { metas.append(SuggestionMeta(icon: nil, text: description)) }
            return make(title: title, isNational: target.isNational, chip: chip, metas: metas, destination: .neighborhood(id: id))

        case .action:
            guard let target = target, let id = id, let title = target.title else { return nil }
            var metas = [SuggestionMeta]()
            if let distance = distanceText(target.distanceKm) { metas.append(SuggestionMeta(icon: "📍", text: distance)) }
            let isContrib = target.actionType == "contribution"
            return make(title: title, author: target.authorName, body: target.description, metas: metas,
                        destination: .action(id: id, isContrib: isContrib))

        case .contentPath:
            // On ouvre le premier contenu non lu ; si tous sont lus, le premier.
            guard let opened = item.targets.first(where: { !$0.isWatched && $0.id != nil }) ?? item.targets.first,
                  let openedId = opened.id else { return nil }
            let metas = item.targets.prefix(3).compactMap { resource -> SuggestionMeta? in
                guard let title = resource.title else { return nil }
                let duration = resource.durationMinutes.map { " · " + String(format: "suggestion_meta_minutes".localized, $0) } ?? ""
                return SuggestionMeta(icon: "📘", text: title + duration)
            }
            return make(title: "suggestion_content_path_title".localized, metas: metas, destination: .resource(id: openedId))

        case .smalltalk:
            return make(title: "suggestion_smalltalk_title".localized, body: "suggestion_smalltalk_body".localized, destination: .smallTalk)

        case .poi:
            guard let target = target, let id = id, let title = target.title else { return nil }
            var metas = [SuggestionMeta]()
            if let address = target.address, !address.isEmpty { metas.append(SuggestionMeta(icon: "📍", text: address)) }
            if let distance = distanceText(target.distanceKm) { metas.append(SuggestionMeta(icon: nil, text: distance)) }
            return make(title: title, metas: metas, destination: .poi(id: id))

        case .postMessage:
            guard let target = target, let id = id, let title = target.title else { return nil }
            return make(title: title, destination: .neighborhoodPost(id: id, name: title, zone: target.zone, isNational: target.isNational))

        case .becomeAmbassador:
            guard let link = item.link, let url = URL(string: link), url.scheme?.hasPrefix("http") == true else { return nil }
            return make(title: "suggestion_ambassador_title".localized, body: "suggestion_ambassador_body".localized, destination: .link(url))

        case .connexion:
            return nil
        }
    }

    /// Une autre piste devient une ligne de la zone : son titre, une ligne de contexte tirée de ses
    /// informations (la première), et un tap qui ouvre la piste elle-même.
    static func access(from item: NextStepItem) -> ExplorerAccess? {
        guard let card = card(from: item) else { return nil }
        return ExplorerAccess(id: card.id, type: card.type, label: card.title,
                              context: card.metas.first?.text, destination: card.destination, targetId: card.targetId)
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
