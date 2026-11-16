//
//  SuggestionProvider.swift
//  entourage
//
//  Source de données de la suggestion. L'app passe par ce protocole : `NextStepSuggestionProvider`
//  appelle le moteur (EN-9473) ; `MockSuggestionProvider` ne sert plus qu'aux tests et aux prévisualisations.
//

import Foundation

enum SuggestionLoadState {
    case loading
    case loaded(SuggestionPayload)
    case empty
    case failed
}

protocol SuggestionProviding: AnyObject {
    /// Le prochain pas et les autres pistes. Une erreur laisse la home sur sa dernière suggestion connue.
    func fetch(completion: @escaping (Swift.Result<SuggestionPayload, Error>) -> Void)
    /// « Plus tard » confirmé (le message « Annuler » a disparu) : le moteur ne re-propose pas la
    /// suggestion avant 30 jours et renvoie la suivante, ou `nil`.
    func dismiss(_ card: SuggestionCard, completion: @escaping (Swift.Result<SuggestionCard?, Error>) -> Void)
    /// Geste transmis au moteur pour la mesure. Silencieux, ne bloque jamais le parcours.
    func record(_ interaction: NextStepInteraction)
}

/// Fournisseur de l'app : le moteur. Pendant les tests d'interface (`-UITestMode`), aucune suggestion,
/// la home garde ses sections d'origine.
enum SuggestionProviderFactory {
    static func make() -> SuggestionProviding {
        if ProcessInfo.processInfo.arguments.contains("-UITestMode") { return EmptySuggestionProvider() }
        return NextStepSuggestionProvider()
    }
}

// MARK: - Moteur

final class NextStepSuggestionProvider: SuggestionProviding {

    func fetch(completion: @escaping (Swift.Result<SuggestionPayload, Error>) -> Void) {
        var currentResult: Swift.Result<NextStepItem?, Error>?
        var othersResult: Swift.Result<[NextStepItem], Error>?
        let group = DispatchGroup()

        group.enter()
        NextStepService.current { result in currentResult = result; group.leave() }
        group.enter()
        NextStepService.others { result in othersResult = result; group.leave() }

        group.notify(queue: .main) {
            switch currentResult {
            case .success(let current)?:
                // Les autres pistes en erreur n'empêchent pas d'afficher le prochain pas.
                var others = [NextStepItem]()
                if case .success(let items)? = othersResult { others = items }
                completion(.success(NextStepAdapter.payload(current: current, others: others)))
            case .failure(let error)?:
                completion(.failure(error))
            case nil:
                completion(.failure(NextStepError.failed))
            }
        }
    }

    func dismiss(_ card: SuggestionCard, completion: @escaping (Swift.Result<SuggestionCard?, Error>) -> Void) {
        guard let nextStepId = card.nextStepId else { return completion(.failure(NextStepError.failed)) }
        NextStepService.ignore(nextStepId: nextStepId) { result in
            switch result {
            case .success(let item): completion(.success(item.flatMap { NextStepAdapter.card(from: $0) }))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func record(_ interaction: NextStepInteraction) {
        NextStepService.record(interaction)
    }
}

/// Aucune suggestion : sert aux tests d'interface.
final class EmptySuggestionProvider: SuggestionProviding {
    func fetch(completion: @escaping (Swift.Result<SuggestionPayload, Error>) -> Void) {
        completion(.success(SuggestionPayload(hero: nil, explorer: [])))
    }
    func dismiss(_ card: SuggestionCard, completion: @escaping (Swift.Result<SuggestionCard?, Error>) -> Void) {
        completion(.success(nil))
    }
    func record(_ interaction: NextStepInteraction) {}
}

// MARK: - Mock (tests et prévisualisations)

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

    func dismiss(_ card: SuggestionCard, completion: @escaping (Swift.Result<SuggestionCard?, Error>) -> Void) {
        heroIndex = (heroIndex + 1) % Self.heroes.count
        do {
            let data = Data(Self.heroes[heroIndex].utf8)
            completion(.success(try JSONDecoder().decode(SuggestionCard.self, from: data)))
        } catch {
            completion(.failure(error))
        }
    }

    func record(_ interaction: NextStepInteraction) {}

    // MARK: Données

    private static let heroes: [String] = [
        // 1 · Entraide (champs saisis par l'utilisateur, affichés bruts)
        """
        {"id":"h1","type":"action","chip":"Équipement","author_name":"Nino D.","title":"Besoin d'un téléphone",
         "body":"Bonjour à tous, je suis actuellement à la recherche d'un télé…",
         "metas":[{"icon":"📍","text":"À moins de 100 m de vous"}],
         "reasons":[{"code":"near_you","text":"C'est à moins de 100 m de chez vous."},
                    {"code":"shared_interests","text":"Vous avez indiqué aimer rendre service."},
                    {"code":"popular","text":"Des voisins ont déjà répondu à des demandes proches."}]}
        """,
        // 2 · Contenu pédagogique
        """
        {"id":"h2","type":"content_path","chip":"Comprendre","title":"Femmes isolées en précarité : fiche profil",
         "metas":[{"icon":"⏱","text":"2 min de lecture"}],
         "reasons":[{"code":"popular","text":"Vous avez participé à un moment similaire en avril."},
                    {"code":"shared_interests","text":"Vous avez indiqué aimer comprendre avant d'agir."}]}
        """,
        // 3a · Événement présentiel
        """
        {"id":"h3","type":"outing","title":"Café solidaire du 11e","media_emoji":"🎉",
         "metas":[{"icon":"🗓","text":"Samedi 14 juin, 14h00"},{"icon":"📍","text":"Ménilmontant, à 1,2 km"}],
         "reasons":[{"code":"upcoming_event","text":"C'est ce samedi, l'occasion est proche."},
                    {"code":"near_you","text":"C'est à 1,2 km de chez vous."},
                    {"code":"online_event","text":"C'est gratuit et sans rendez-vous."}]}
        """,
        // 3b · Événement visio (pas de distance)
        """
        {"id":"h4","type":"outing","is_remote":true,"title":"Papotage solidaire","media_emoji":"💻",
         "metas":[{"icon":"🗓","text":"Jeudi 19 juin, 20h00"},{"icon":"💻","text":"En visio, depuis chez vous"}],
         "reasons":[{"code":"upcoming_event","text":"C'est jeudi soir, depuis votre canapé."},
                    {"code":"online_event","text":"Vous n'avez pas besoin de vous déplacer."}]}
        """,
        // 4a · Groupe local (pas de nombre de membres)
        """
        {"id":"h5","type":"neighborhood","chip":"Quartier","title":"Voisins Ménilmontant","media_emoji":"🏘️",
         "metas":[{"text":"Un groupe de voisins près de chez vous"}],
         "reasons":[{"code":"near_you","text":"Ce groupe est dans votre quartier."},
                    {"code":"popular","text":"Des voisins y échangent déjà."}]}
        """,
        // 4b · Groupe national thématique (pas de distance)
        """
        {"id":"h6","type":"neighborhood","is_national":true,"chip":"National","title":"Cuisine et partage","media_emoji":"🍳",
         "metas":[{"text":"Un groupe pour échanger autour de la cuisine, partout en France"}],
         "reasons":[{"code":"shared_interests","text":"Vous avez indiqué aimer cuisiner."}]}
        """,
        // 5 · Connexion
        """
        {"id":"h7","type":"connexion","author_name":"Karim G.","title":"Souhaitez la bienvenue à Karim",
         "metas":[{"text":"Nouveau voisin dans votre quartier"}],
         "reasons":[{"code":"near_you","text":"Karim habite près de chez vous."},
                    {"code":"shared_interests","text":"Vous partagez des centres d'intérêt."}]}
        """,
        // 6 · Lieu solidaire
        """
        {"id":"h8","type":"poi","title":"Bagagerie solidaire du 20e","media_emoji":"🗺️",
         "metas":[{"text":"Consigne gratuite, sans rendez-vous"},{"icon":"📍","text":"À 600 m, ouvert jusqu'à 18h"}],
         "reasons":[{"code":"answers_your_need","text":"Vous cherchiez où déposer vos affaires."},
                    {"code":"online_event","text":"C'est gratuit et sans rendez-vous."}]}
        """,
        // 7 · Bonnes ondes
        """
        {"id":"h9","type":"smalltalk","title":"Les Bonnes ondes","body":"Échangez avec quelques personnes, sans engagement.",
         "reasons":[{"code":"smalltalk","text":"Les Bonnes ondes vous mettent en relation avec quelques personnes pour discuter."}]}
        """,
        // 8 · Mini-parcours de contenus
        """
        {"id":"h10","type":"content_path","title":"Trois lectures pour bien démarrer",
         "metas":[{"icon":"📘","text":"Comprendre l'isolement · 2 min"},{"icon":"📘","text":"Un geste simple · 3 min"},{"icon":"📘","text":"Aller vers l'autre · 2 min"}],
         "reasons":[{"code":"content_path","text":"Trois lectures courtes pour découvrir Entourage."}]}
        """,
        // 9 · Poster un message
        """
        {"id":"h11","type":"post_message","title":"Voisins Ménilmontant",
         "reasons":[{"code":"group_member_message","text":"Vous faites partie de ce groupe : un petit message suffit pour faire connaissance."}]}
        """,
        // 10 · Devenir Animateur
        """
        {"id":"h12","type":"become_ambassador","title":"Devenir Animateur Entourage","body":"Animez des rencontres près de chez vous.",
         "reasons":[{"code":"become_ambassador","text":"Envie d'animer des rencontres près de chez vous ?"}]}
        """
    ]

    /// Payload complet, avec volontairement des entrées d'un type inconnu pour exercer le décodage tolérant.
    private static func json(heroIndex: Int) -> String {
        """
        {"hero":\(heroes[heroIndex]),
         "explorer":[
           {"id":"e1","type":"action","label":"2 voisins ont besoin d'un coup de pouce","context":"à moins de 2 km de vous","target":"demands"},
           {"id":"e2","type":"content_path","label":"Un contenu pour bien démarrer","context":"2 min de lecture","target":"resources"},
           {"id":"e0","type":"type_futur_inconnu","label":"Ignoré","target":"events"},
           {"id":"e3","type":"neighborhood","label":"Un groupe de voisins près de chez vous","context":"Voisins Ménilmontant","target":"groups"}
         ]}
        """
    }
}
