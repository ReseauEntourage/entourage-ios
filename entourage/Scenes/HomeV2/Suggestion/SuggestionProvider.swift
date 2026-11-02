//
//  SuggestionProvider.swift
//  entourage
//
//  Source de données de la suggestion. Le moteur (EN-9473) n'est pas livré :
//  l'app passe par ce protocole, aujourd'hui servi par MockSuggestionProvider.
//  Brancher l'API = écrire un second SuggestionProviding, sans toucher aux vues.
//

import Foundation

enum SuggestionLoadState {
    case loading
    case loaded(SuggestionPayload)
    case empty
    case failed
}

protocol SuggestionProviding: AnyObject {
    func fetch(completion: @escaping (Swift.Result<SuggestionPayload, Error>) -> Void)
    /// « Plus tard » : le moteur retire la suggestion (et ne la re-propose pas avant 30 jours).
    func dismiss(suggestionId: String)
    /// Annule le retrait (toast « Annuler »).
    func undoDismiss(suggestionId: String)
}

/// Flag simple : actif par défaut en DEBUG hors tests UI, activable ailleurs
/// via UserDefaults `suggestion_mock_enabled` ou l'argument de lancement `-suggestion_mock_enabled YES`.
enum SuggestionFeature {
    static let defaultsKey = "suggestion_mock_enabled"

    static var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: defaultsKey) != nil {
            return UserDefaults.standard.bool(forKey: defaultsKey)
        }
        #if DEBUG
        return !ProcessInfo.processInfo.arguments.contains("-UITestMode")
        #else
        return false
        #endif
    }
}

// MARK: - Mock

final class MockSuggestionProvider: SuggestionProviding {

    static let shared = MockSuggestionProvider()

    private var heroIndex = 0
    private var fetchCount = 0

    func fetch(completion: @escaping (Swift.Result<SuggestionPayload, Error>) -> Void) {
        fetchCount += 1
        // Simule la latence réseau pour exercer l'état « chargement ».
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            do {
                let data = Data(Self.json(heroIndex: self.heroIndex).utf8)
                completion(.success(try JSONDecoder().decode(SuggestionPayload.self, from: data)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func dismiss(suggestionId: String) {
        heroIndex = (heroIndex + 1) % Self.heroes.count
    }

    func undoDismiss(suggestionId: String) {
        heroIndex = (heroIndex - 1 + Self.heroes.count) % Self.heroes.count
    }

    // MARK: Données

    private static let heroes: [String] = [
        // 1 · Entraide (champs saisis par l'utilisateur, affichés bruts)
        """
        {"id":"h1","type":"entraide","chip":"Équipement","author_name":"Nino D.","title":"Besoin d'un téléphone",
         "body":"Bonjour à tous, je suis actuellement à la recherche d'un télé…",
         "metas":[{"icon":"📍","text":"À moins de 100 m de vous"}],
         "reasons":[{"kind":"proximity","text":"C'est à moins de 100 m de chez vous."},
                    {"kind":"interests","text":"Vous avez indiqué aimer rendre service."},
                    {"kind":"social_proof","text":"Des voisins ont déjà répondu à des demandes proches."}]}
        """,
        // 2 · Contenu pédagogique
        """
        {"id":"h2","type":"contenu","chip":"Comprendre","title":"Femmes isolées en précarité : fiche profil",
         "metas":[{"icon":"⏱","text":"2 min de lecture"}],
         "reasons":[{"kind":"history","text":"Vous avez participé à un moment similaire en avril."},
                    {"kind":"interests","text":"Vous avez indiqué aimer comprendre avant d'agir."}]}
        """,
        // 3a · Événement présentiel
        """
        {"id":"h3","type":"evenement","title":"Café solidaire du 11e","media_emoji":"🎉",
         "metas":[{"icon":"🗓","text":"Samedi 14 juin, 14h00"},{"icon":"📍","text":"Ménilmontant, à 1,2 km"}],
         "reasons":[{"kind":"moment","text":"C'est ce samedi, l'occasion est proche."},
                    {"kind":"proximity","text":"C'est à 1,2 km de chez vous."},
                    {"kind":"accessibility","text":"C'est gratuit et sans rendez-vous."}]}
        """,
        // 3b · Événement visio (pas de distance)
        """
        {"id":"h4","type":"evenement","is_remote":true,"title":"Papotage solidaire","media_emoji":"💻",
         "metas":[{"icon":"🗓","text":"Jeudi 19 juin, 20h00"},{"icon":"💻","text":"En visio, depuis chez vous"}],
         "reasons":[{"kind":"moment","text":"C'est jeudi soir, depuis votre canapé."},
                    {"kind":"accessibility","text":"Vous n'avez pas besoin de vous déplacer."}]}
        """,
        // 4a · Groupe local (pas de nombre de membres)
        """
        {"id":"h5","type":"groupe","chip":"Quartier","title":"Voisins Ménilmontant","media_emoji":"🏘️",
         "metas":[{"text":"Un groupe de voisins près de chez vous"}],
         "reasons":[{"kind":"proximity","text":"Ce groupe est dans votre quartier."},
                    {"kind":"social_proof","text":"Des voisins y échangent déjà."}]}
        """,
        // 4b · Groupe national thématique (pas de distance)
        """
        {"id":"h6","type":"groupe","is_national":true,"chip":"National","title":"Cuisine et partage","media_emoji":"🍳",
         "metas":[{"text":"Un groupe pour échanger autour de la cuisine, partout en France"}],
         "reasons":[{"kind":"interests","text":"Vous avez indiqué aimer cuisiner."}]}
        """,
        // 5 · Connexion
        """
        {"id":"h7","type":"connexion","author_name":"Karim G.","title":"Souhaitez la bienvenue à Karim",
         "metas":[{"text":"Nouveau voisin dans votre quartier"}],
         "reasons":[{"kind":"proximity","text":"Karim habite près de chez vous."},
                    {"kind":"interests","text":"Vous partagez des centres d'intérêt."}]}
        """,
        // 6 · Lieu solidaire
        """
        {"id":"h8","type":"lieu","title":"Bagagerie solidaire du 20e","media_emoji":"🗺️",
         "metas":[{"text":"Consigne gratuite, sans rendez-vous"},{"icon":"📍","text":"À 600 m, ouvert jusqu'à 18h"}],
         "reasons":[{"kind":"need","text":"Vous cherchiez où déposer vos affaires."},
                    {"kind":"accessibility","text":"C'est gratuit et sans rendez-vous."}]}
        """
    ]

    /// Payload complet, avec volontairement des entrées d'un type inconnu pour exercer le décodage tolérant.
    private static func json(heroIndex: Int) -> String {
        """
        {"is_isolated_profile":false,
         "hero":\(heroes[heroIndex]),
         "explorer":[
           {"id":"e1","type":"entraide","label":"2 voisins ont besoin d'un coup de pouce","context":"à moins de 2 km de vous","target":"demands"},
           {"id":"e2","type":"contenu","label":"Un contenu pour bien démarrer","context":"2 min de lecture","target":"resources"},
           {"id":"e0","type":"type_futur_inconnu","label":"Ignoré","target":"events"},
           {"id":"e3","type":"groupe","label":"Un groupe de voisins près de chez vous","context":"Voisins Ménilmontant","target":"groups"}
         ]}
        """
    }
}
