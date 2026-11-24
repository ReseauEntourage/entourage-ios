//
//  NextStepService.swift
//  entourage
//
//  Appels du moteur « Votre prochain pas » (EN-9473, `/api/v1/next_steps`).
//  Ces appels sont silencieux : une erreur ne déclenche pas la feuille d'erreur globale
//  (`reportsErrors: false`), la home garde simplement ce qu'elle affiche.
//

import Foundation

enum NextStepError: Error {
    case notAuthenticated
    case failed
}

/// Gestes de l'utilisateur transmis au moteur pour la mesure (`POST /next_steps/interactions`).
struct NextStepInteraction: Equatable {
    enum Placement: String { case hero, others }
    enum Kind: String { case displayed, whyOpened = "why_opened", tapped }

    let placement: Placement
    let kind: Kind
    /// Prochain pas (`placement` hero).
    let nextStepId: Int?
    /// Autre piste (`placement` others) : `kind` du moteur et identifiant de la cible, s'il y en a un.
    let itemKind: String?
    let targetId: Int?

    /// Corps attendu par le moteur : `{ "interaction": { placement, kind, next_step_id | item_kind + target_id } }`.
    var body: [String: Any] {
        var fields: [String: Any] = ["placement": placement.rawValue, "kind": kind.rawValue]
        if let nextStepId = nextStepId { fields["next_step_id"] = nextStepId }
        if let itemKind = itemKind { fields["item_kind"] = itemKind }
        if let targetId = targetId { fields["target_id"] = targetId }
        return ["interaction": fields]
    }
}

struct NextStepService {

    typealias Completion<T> = (Swift.Result<T, Error>) -> Void

    /// Délai des appels au moteur : 15 s, comme Android. Le délai de lecture par défaut d'iOS (120 s) laisserait
    /// la home en squelette pendant deux minutes sur un mauvais réseau, alors qu'elle n'a plus d'autres sections.
    static let timeout: TimeInterval = 15

    /// `GET /next_steps/current` : le prochain pas, ou `nil` (parcours de bienvenue, moteur coupé).
    static func current(completion: @escaping Completion<NextStepItem?>) {
        get(kAPINextStepsCurrent) { data in
            completion(.success((try? JSONDecoder().decode(NextStepSingleResponse.self, from: data))?.item))
        } failure: { completion(.failure($0)) }
    }

    /// `GET /next_steps/others` : jusqu'à trois autres pistes.
    static func others(completion: @escaping Completion<[NextStepItem]>) {
        get(kAPINextStepsOthers) { data in
            completion(.success((try? JSONDecoder().decode(NextStepOthersResponse.self, from: data))?.items ?? []))
        } failure: { completion(.failure($0)) }
    }

    /// `POST /next_steps/:id/ignore` : ignore le prochain pas et renvoie le suivant (ou `nil`).
    static func ignore(nextStepId: Int, completion: @escaping Completion<NextStepItem?>) {
        guard let token = UserDefaults.token else { return completion(.failure(NextStepError.notAuthenticated)) }
        let endpoint = String(format: kAPINextStepsIgnore, nextStepId, token)
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil, reportsErrors: false, timeout: timeout) { data, resp, _ in
            guard let data = data, let http = resp as? HTTPURLResponse, http.statusCode < 300 else {
                DispatchQueue.main.async { completion(.failure(NextStepError.failed)) }
                return
            }
            let item = (try? JSONDecoder().decode(NextStepSingleResponse.self, from: data))?.item
            DispatchQueue.main.async { completion(.success(item)) }
        }
    }

    /// `POST /next_steps/interactions` : n'attend aucune réponse et n'échoue jamais visiblement.
    static func record(_ interaction: NextStepInteraction) {
        guard let token = UserDefaults.token,
              let body = try? JSONSerialization.data(withJSONObject: interaction.body) else { return }
        let endpoint = String(format: kAPINextStepsInteractions, token)
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: body, reportsErrors: false, timeout: timeout) { _, _, _ in }
    }

    // MARK: - Privé

    private static func get(_ route: String, success: @escaping (Data) -> Void, failure: @escaping (Error) -> Void) {
        guard let token = UserDefaults.token else { return failure(NextStepError.notAuthenticated) }
        let endpoint = String(format: route, token)
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil, reportsErrors: false, timeout: timeout) { data, resp, _ in
            guard let data = data, let http = resp as? HTTPURLResponse, http.statusCode < 300 else {
                DispatchQueue.main.async { failure(NextStepError.failed) }
                return
            }
            DispatchQueue.main.async { success(data) }
        }
    }
}
