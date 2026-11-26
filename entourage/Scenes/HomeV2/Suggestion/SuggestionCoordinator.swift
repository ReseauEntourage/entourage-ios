//
//  SuggestionCoordinator.swift
//  entourage
//
//  Porte l'état de la suggestion sur la home (chargement, erreur, vide, chargé),
//  l'instrumentation, la mesure auprès du moteur et la navigation. La home ne fait que l'afficher.
//

import UIKit

final class SuggestionCoordinator {

    /// Affiche le message « Plus tard » avec son action « Annuler » ; `onExpire` est appelé quand il disparaît sans annulation.
    typealias SnackbarPresenter = (_ message: String, _ actionTitle: String,
                                   _ onUndo: @escaping () -> Void, _ onExpire: @escaping () -> Void) -> Void

    private let provider: SuggestionProviding
    private let presentSnackbar: SnackbarPresenter
    private let navigator: (SuggestionDestination) -> Void

    private(set) var state: SuggestionLoadState = .loading

    /// Comme Android : le moteur est appelé au premier affichage et après un geste sur une suggestion,
    /// pas à chaque retour sur la home.
    private var started = false
    private var needsRefresh = false
    /// Le parcours de bienvenue est affiché : la card ne l'est pas, le moteur n'est donc pas appelé.
    /// La home démarre retenue (`startsSuppressed`) : tant que son résumé n'a pas dit si le parcours est
    /// affiché, le moteur n'est pas appelé, comme sur Android.
    private var isSuppressed: Bool
    /// Appelé quand l'état change : la home reconstruit ses lignes.
    var onStateChanged: (() -> Void)?

    private var loggedHeroId: String?
    private var loggedAccessIds = Set<String>()
    private var hasLoggedExplorerView = false
    private var isFetching = false
    /// Suggestion retirée par « Plus tard », en attendant la fin du message « Annuler ».
    private var pendingLater: SuggestionCard?

    init(provider: SuggestionProviding = SuggestionProviderFactory.make(),
         presentSnackbar: @escaping SnackbarPresenter = SuggestionCoordinator.defaultSnackbar,
         navigator: @escaping (SuggestionDestination) -> Void = SuggestionCoordinator.open,
         startsSuppressed: Bool = false) {
        self.provider = provider
        self.presentSnackbar = presentSnackbar
        self.navigator = navigator
        self.isSuppressed = startsSuppressed
    }

    var payload: SuggestionPayload? {
        if case .loaded(let payload) = state { return payload }
        return nil
    }

    /// Retour sur la home, comme Android : appel au premier affichage et après un geste sur une suggestion
    /// (une suggestion réalisée est alors remplacée par le moteur, sans que l'app le signale). Aucun appel
    /// tant que le parcours de bienvenue masque la card.
    func refreshIfNeeded() {
        guard !isSuppressed, !started || needsRefresh else { return }
        started = true
        needsRefresh = false
        refresh()
    }

    /// Le parcours de bienvenue est affiché ou non. Quand il se termine ou se masque, la card devient
    /// visible : le moteur est appelé à ce moment.
    func setSuppressed(_ value: Bool) {
        let wasSuppressed = isSuppressed
        isSuppressed = value
        if wasSuppressed && !value {
            started = true
            needsRefresh = false
            refresh()
        }
    }

    /// Chargement depuis le moteur. Garde la dernière suggestion affichée pendant le rafraîchissement,
    /// pour ne pas faire clignoter la zone.
    func refresh() {
        // Pendant le message « Annuler », la suggestion retirée ne doit pas revenir.
        guard !isFetching, pendingLater == nil else { return }
        isFetching = true
        provider.fetch { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            switch result {
            case .success(let payload):
                self.state = payload.isEmpty ? .empty : .loaded(payload)
                // `current` a renvoyé `null`. Le back ne distingue pas « tout exclu » de « aucun candidat » dans sa réponse.
                if payload.hero == nil { self.logNextStepNull(reason: "no_candidates") }
            case .failure:
                self.logNextStepNull(reason: "error")
                // Erreur : on garde ce qui est affiché, sinon la zone est masquée.
                if self.payload == nil { self.state = .failed }
            }
            self.onStateChanged?()
        }
    }

    // MARK: Affichage (instrumentation et mesure)

    /// La home s'affiche (ou se réaffiche) : `displayed` repart une fois pour le prochain pas affiché,
    /// et pas à chaque rafraîchissement ni à chaque reconstruction de la table.
    func homeWillAppear() {
        loggedHeroId = nil
        loggedAccessIds.removeAll()
        hasLoggedExplorerView = false
    }

    func heroDidDisplay(_ card: SuggestionCard) {
        guard loggedHeroId != card.id else { return }
        loggedHeroId = card.id
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_View, parameters: ["type": card.type.rawValue, "id": card.id])
        record(.displayed, card: card)
    }

    func explorerDidDisplay(_ accesses: [ExplorerAccess]) {
        if !hasLoggedExplorerView {
            hasLoggedExplorerView = true
            AnalyticsLoggerManager.logEvent(name: Suggestion_Explorer_View, parameters: ["count": accesses.count])
        }
        for access in accesses where loggedAccessIds.insert(access.id).inserted {
            record(.displayed, access: access)
        }
    }

    // MARK: Actions de la card

    /// Mène à l'écran ou au flux existant de la suggestion.
    func explorerTapped(_ access: ExplorerAccess) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Explorer_Click, parameters: ["type": access.type.rawValue, "id": access.id])
        logNextStepExplorerTapped(access)
        record(.tapped, access: access)
        needsRefresh = true
        navigator(access.destination)
    }

    func primaryTapped(_ card: SuggestionCard) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Cta, parameters: ["type": card.type.rawValue, "id": card.id])
        logNextStepRealisedByTap(card)
        record(.tapped, card: card)
        needsRefresh = true
        navigator(card.destination)
    }

    func bodyTapped(_ card: SuggestionCard) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Body, parameters: ["type": card.type.rawValue, "id": card.id])
        logNextStepRealisedByTap(card)
        record(.tapped, card: card)
        needsRefresh = true
        navigator(card.destination)
    }

    func infoTapped(_ card: SuggestionCard, from presenter: UIViewController) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Why, parameters: ["type": card.type.rawValue, "id": card.id])
        record(.whyOpened, card: card)
        presenter.present(SuggestionWhyViewController(card: card), animated: true)
    }

    // MARK: « Plus tard »

    /// « Plus tard » retire la card et laisse le temps d'annuler. Le moteur n'est prévenu qu'à la fin
    /// du message, sans annulation : il n'a pas de route pour revenir en arrière.
    func laterTapped(_ card: SuggestionCard) {
        guard pendingLater == nil else { return }
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Later, parameters: ["type": card.type.rawValue, "id": card.id])
        logNextStep(Next_Step_Later_Tapped, card: card)
        pendingLater = card
        setHero(nil)
        presentSnackbar("suggestion_later_toast".localized, "suggestion_undo".localized,
                        { [weak self] in self?.undoLater(card) },
                        { [weak self] in self?.confirmLater(card) })
    }

    /// Annulation : la card revient telle quelle et le moteur n'est pas prévenu.
    private func undoLater(_ card: SuggestionCard) {
        guard pendingLater?.id == card.id else { return }
        pendingLater = nil
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Undo_Later, parameters: ["type": card.type.rawValue, "id": card.id])
        logNextStep(Next_Step_Later_Cancelled, card: card)
        setHero(card)
    }

    /// Le message a disparu sans annulation : le moteur ignore la suggestion et renvoie la suivante.
    private func confirmLater(_ card: SuggestionCard) {
        guard pendingLater?.id == card.id else { return }
        pendingLater = nil
        provider.dismiss(card) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let next):
                // Après la réponse 2xx. `days_active` : le contrat du moteur n'expose pas `created_at`, donc absent.
                self.logNextStep(Next_Step_Ignored, card: card)
                self.loggedHeroId = nil
                self.setHero(next)
                // Comme Android : sans suivante dans la réponse, on relit le moteur (`current`) avant de laisser la zone sans card.
                if next == nil { self.refresh() }
            case .failure:
                // Le moteur n'a pas pris en compte l'abandon : on se recale sur lui.
                self.refresh()
            }
        }
    }

    /// Remplace le prochain pas en gardant les autres pistes.
    private func setHero(_ hero: SuggestionCard?) {
        var current = payload ?? SuggestionPayload(hero: nil, explorer: [])
        current.hero = hero
        state = current.isEmpty ? .empty : .loaded(current)
        onStateChanged?()
    }

    // MARK: Événements « Prochain Pas » (EN-9892)

    /// `kind` (celui du moteur) et `target_id` de la suggestion, lus en mémoire ; `target_id` est omis sans cible.
    private func logNextStep(_ name: String, card: SuggestionCard, extra: [String: Any] = [:]) {
        var parameters: [String: Any] = ["kind": card.type.rawValue]
        if let targetId = card.targetId { parameters["target_id"] = targetId }
        parameters.merge(extra) { _, new in new }
        AnalyticsLoggerManager.logEvent(name: name, parameters: parameters)
    }

    /// `poi` et `become_ambassador` sont réalisés par le tap : le back n'a aucune trace à détecter.
    /// `days_to_realise` : le contrat n'expose pas `first_displayed_at`, donc absent. Les autres `kind` sont
    /// détectés par le back, qui ne le signale pas à l'app (il remplace la suggestion) : pas de `auto` possible.
    private func logNextStepRealisedByTap(_ card: SuggestionCard) {
        guard [SuggestionType.poi, .becomeAmbassador].contains(card.type) else { return }
        logNextStep(Next_Step_Realised, card: card, extra: ["realisation_trigger": "tap"])
    }

    private func logNextStepExplorerTapped(_ access: ExplorerAccess) {
        var parameters: [String: Any] = ["explorer_kind": access.type.rawValue]
        if let hero = payload?.hero {
            parameters["kind"] = hero.type.rawValue
            if let targetId = hero.targetId { parameters["target_id"] = targetId }
        }
        if let index = payload?.explorer.firstIndex(where: { $0.id == access.id }) { parameters["position"] = index + 1 }
        if let targetId = access.targetId { parameters["explorer_target_id"] = targetId }
        AnalyticsLoggerManager.logEvent(name: Next_Step_Explorer_Tapped, parameters: parameters)
    }

    private func logNextStepNull(reason: String) {
        AnalyticsLoggerManager.logEvent(name: Next_Step_Null, parameters: ["reason": reason])
    }

    // MARK: Mesure

    private func record(_ kind: NextStepInteraction.Kind, card: SuggestionCard) {
        guard let nextStepId = card.nextStepId else { return }
        provider.record(NextStepInteraction(placement: .hero, kind: kind, nextStepId: nextStepId, itemKind: nil, targetId: nil))
    }

    private func record(_ kind: NextStepInteraction.Kind, access: ExplorerAccess) {
        // Ces trois types n'ont pas de cible : le moteur n'attend pas de `target_id`.
        let hasNoTarget = [SuggestionType.contentPath, .smalltalk, .becomeAmbassador].contains(access.type)
        provider.record(NextStepInteraction(placement: .others, kind: kind, nextStepId: nil,
                                            itemKind: access.type.rawValue, targetId: hasNoTarget ? nil : access.targetId))
    }

    // MARK: Navigation

    static let defaultSnackbar: SnackbarPresenter = { message, actionTitle, onUndo, onExpire in
        SuggestionSnackbar.show(message: message, actionTitle: actionTitle, onAction: onUndo, onExpire: onExpire)
    }

    /// Ouvre l'écran ou le flux existant. Les onglets n'acceptent pas de filtre en argument.
    static func open(_ destination: SuggestionDestination) {
        switch destination {
        case .outing(let id): DeepLinkManager.showOuting(id: id)
        case .neighborhood(let id): DeepLinkManager.showNeighborhoodDetail(id: id)
        case .neighborhoodPost(let id, let name, let zone, let isNational):
            var group = Neighborhood()
            group.uid = id
            group.name = name
            group.zone = zone
            group.national = isNational
            DeepLinkManager.showNeighborhoodDetailWithCreatePost(id: id, group: group)
        case .action(let id, let isContrib): DeepLinkManager.showAction(id: id, isContrib: isContrib)
        case .resource(let id): DeepLinkManager.showResource(id: id)
        case .poi(let id): DeepLinkManager.showPoi(id: id)
        case .smallTalk: DeepLinkManager.showSmallTalkIntro()
        case .link(let url): WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: AppState.getTopViewController())
        case .list(let target):
            switch target {
            case .events: DeepLinkManager.showDiscoverOutingListUniversalLink()
            case .groups: DeepLinkManager.showNeiborhoodListUniversalLink()
            case .demands: DeepLinkManager.showDemandListUniversalLink()
            case .contributions: DeepLinkManager.showContribListUniversalLink()
            case .resources: DeepLinkManager.showRessourceListUniversalLink()
            case .places: DeepLinkManager.showMap()
            }
        }
    }
}
