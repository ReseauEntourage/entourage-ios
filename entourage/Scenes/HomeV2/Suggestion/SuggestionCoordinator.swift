//
//  SuggestionCoordinator.swift
//  entourage
//
//  Porte l'état de la suggestion sur la home (chargement, erreur, vide, chargé),
//  l'instrumentation et la navigation. La home ne fait que l'afficher.
//

import UIKit

final class SuggestionCoordinator {

    private let provider: SuggestionProviding
    private(set) var state: SuggestionLoadState = .loading
    /// Appelé quand l'état change : la home reconstruit ses lignes.
    var onStateChanged: (() -> Void)?

    private var hasLoggedHeroView = false
    private var hasLoggedExplorerView = false
    private var isFetching = false

    init(provider: SuggestionProviding = MockSuggestionProvider.shared) {
        self.provider = provider
    }

    var payload: SuggestionPayload? {
        if case .loaded(let payload) = state { return payload }
        return nil
    }

    /// Chargement à l'ouverture et au retour sur la home. Garde la dernière suggestion affichée
    /// pendant le rafraîchissement pour ne pas faire clignoter la zone.
    func refresh() {
        guard SuggestionFeature.isEnabled, !isFetching else { return }
        isFetching = true
        provider.fetch { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            switch result {
            case .success(let payload):
                self.state = payload.isEmpty ? .empty : .loaded(payload)
            case .failure:
                // Erreur réseau : on garde ce qui est affiché, sinon la zone est masquée.
                if self.payload == nil { self.state = .failed }
            }
            self.onStateChanged?()
        }
    }

    // MARK: Affichage (instrumentation)

    func heroDidDisplay(_ card: SuggestionCard) {
        guard !hasLoggedHeroView else { return }
        hasLoggedHeroView = true
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_View, parameters: ["type": card.type.rawValue, "id": card.id])
    }

    // MARK: Actions de la card

    func primaryTapped(_ card: SuggestionCard) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Cta, parameters: ["type": card.type.rawValue, "id": card.id])
        navigate(to: card.target)
    }

    func bodyTapped(_ card: SuggestionCard) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Body, parameters: ["type": card.type.rawValue, "id": card.id])
        navigate(to: card.target)
    }

    func infoTapped(_ card: SuggestionCard, from presenter: UIViewController) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Why, parameters: ["type": card.type.rawValue, "id": card.id])
    }

    /// « Plus tard » : retire la suggestion (le moteur la remplace) avec possibilité d'annuler.
    func laterTapped(_ card: SuggestionCard) {
        AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Click_Later, parameters: ["type": card.type.rawValue, "id": card.id])
        provider.dismiss(suggestionId: card.id)
        hasLoggedHeroView = false
        refresh()
        SuggestionSnackbar.show(message: "suggestion_later_toast".localized, actionTitle: "suggestion_undo".localized) { [weak self] in
            guard let self = self else { return }
            AnalyticsLoggerManager.logEvent(name: Suggestion_Hero_Undo_Later, parameters: ["type": card.type.rawValue, "id": card.id])
            self.provider.undoDismiss(suggestionId: card.id)
            self.hasLoggedHeroView = false
            self.refresh()
        }
    }

    // MARK: Navigation

    func navigate(to target: SuggestionTarget) {
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
