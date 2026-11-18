import XCTest
@testable import entourage

/// « Votre prochain pas » (EN-9473) : décodage du contrat du moteur par type, adaptation vers la home,
/// et enchaînement « Plus tard » (le moteur n'est prévenu qu'après la fin du message « Annuler »).
/// Les JSON reprennent la forme des sérialiseurs du back (`design.md`, décision 12).
final class NextStepSuggestionTests: XCTestCase {

    // MARK: - Aides

    private func item(_ json: String) throws -> NextStepItem {
        try JSONDecoder().decode(NextStepItem.self, from: Data(json.utf8))
    }

    private func card(_ json: String) throws -> SuggestionCard {
        let decoded = try item(json)
        return try XCTUnwrap(NextStepAdapter.card(from: decoded), "la suggestion devrait s'afficher")
    }

    private let reasons = #""reasons":[{"code":"near_you","text":"C'est à 800 m de chez vous."},{"code":"shared_interests","text":"On y parle de sport."}]"#

    // MARK: - Un test par type

    func testOutingInPerson() throws {
        let card = try self.card("""
        {"id":12,"kind":"outing","mode":"segment","placement":"hero","link":null,"targets":null,
         "target":{"id":42,"title":"Café solidaire du 11e","online":false,"distance":0.8,
                   "metadata":{"starts_at":"2026-11-20T14:00:00.000Z","display_address":"Ménilmontant, Paris"}},
         \(reasons),"expires_at":"2026-11-20T00:00:00Z"}
        """)
        XCTAssertEqual(card.type, .outing)
        XCTAssertEqual(card.id, "12")
        XCTAssertEqual(card.nextStepId, 12)
        XCTAssertEqual(card.destination, .outing(id: 42))
        XCTAssertFalse(card.isRemote)
        XCTAssertEqual(card.cta, .participate)
        XCTAssertEqual(card.title, "Café solidaire du 11e")
        XCTAssertTrue(card.metas.contains { $0.text == "Ménilmontant, Paris" })
        XCTAssertTrue(card.metas.contains { $0.text == String(format: "suggestion_meta_distance_m".localized, 800) })
    }

    /// Un papotage est un événement en visio : même variant, pas de distance.
    func testPapotageIsAnOnlineOuting() throws {
        let card = try self.card("""
        {"id":13,"kind":"outing","placement":"hero",
         "target":{"id":43,"title":"Papotage solidaire","online":true,"distance":5.0,
                   "metadata":{"starts_at":"2026-11-19T20:00:00.000Z","display_address":null}},
         "reasons":[{"code":"online_event","text":"C'est en visio."}]}
        """)
        XCTAssertTrue(card.isRemote)
        XCTAssertEqual(card.cta, .register)
        XCTAssertEqual(card.destination, .outing(id: 43))
        XCTAssertTrue(card.metas.contains { $0.text == "suggestion_meta_remote".localized })
        XCTAssertFalse(card.metas.contains { $0.text.contains("km") }, "pas de distance pour une visio")
    }

    func testLocalAndNationalNeighborhood() throws {
        let local = try self.card(#"{"id":14,"kind":"neighborhood","placement":"hero","target":{"id":7,"name":"Voisins Ménilmontant","national":false,"description":"Un groupe de voisins"},"reasons":[]}"#)
        XCTAssertEqual(local.destination, .neighborhood(id: 7))
        XCTAssertFalse(local.isNational)
        XCTAssertEqual(local.chip, "suggestion_chip_local".localized)
        XCTAssertEqual(local.cta, .join)

        let national = try self.card(#"{"id":15,"kind":"neighborhood","placement":"hero","target":{"id":8,"name":"Cuisine et partage","national":true},"reasons":[]}"#)
        XCTAssertTrue(national.isNational)
        XCTAssertEqual(national.chip, "suggestion_chip_national".localized)
    }

    /// Forme réelle d'un groupe (préprod, 16/11) : `address` est un objet, `display_address` peut être vide.
    func testNeighborhoodAddressIsAnObjectWithEmptyDisplayAddress() throws {
        let card = try self.card("""
        {"id":29,"kind":"neighborhood","placement":"hero","target":{"id":522,"name":"Voisins du 11e","zone":null,"national":false,
         "address":{"latitude":48.8566,"longitude":2.3522,"display_address":""}},"reasons":[]}
        """)
        XCTAssertEqual(card.destination, .neighborhood(id: 522))
        XCTAssertFalse(card.isNational)
        XCTAssertFalse(card.metas.contains { $0.icon == "📍" }, "pas de ligne d'adresse quand elle est vide")
    }

    func testNeighborhoodAddressIsShownWhenFilled() throws {
        let card = try self.card("""
        {"id":30,"kind":"neighborhood","placement":"hero","target":{"id":522,"name":"Voisins du 11e","zone":null,"national":false,
         "address":{"latitude":48.8566,"longitude":2.3522,"display_address":"Paris 11e"}},"reasons":[]}
        """)
        XCTAssertEqual(card.metas.first?.text, "Paris 11e")
        XCTAssertEqual(card.metas.first?.icon, "📍")
    }

    func testActionDemandKeepsUserTextAsIs() throws {
        let card = try self.card("""
        {"id":16,"kind":"action","placement":"hero",
         "target":{"id":99,"title":"Besoin d'un téléphone","description":"Bonjour à tous, je cherche un télé…","action_type":"solicitation","distance":0.1,
                   "author":{"id":5,"display_name":"Nino D."}},\(reasons)}
        """)
        XCTAssertEqual(card.destination, .action(id: 99, isContrib: false))
        XCTAssertEqual(card.title, "Besoin d'un téléphone")
        XCTAssertEqual(card.body, "Bonjour à tous, je cherche un télé…")
        XCTAssertEqual(card.authorName, "Nino D.")
        XCTAssertEqual(card.cta, .answer)
    }

    func testActionContributionOpensAsContribution() throws {
        let card = try self.card(#"{"id":17,"kind":"action","placement":"hero","target":{"id":100,"title":"Je prête une perceuse","action_type":"contribution"},"reasons":[]}"#)
        XCTAssertEqual(card.destination, .action(id: 100, isContrib: true))
    }

    func testContentPathShowsThreeResourcesAndOpensTheFirst() throws {
        let card = try self.card("""
        {"id":18,"kind":"content_path","placement":"hero","target":null,
         "targets":[{"id":31,"name":"Comprendre l'isolement","duration":2},{"id":32,"name":"Un geste simple","duration":3},{"id":33,"name":"Aller vers l'autre","duration":2}],
         "reasons":[{"code":"content_path","text":"Trois lectures courtes pour découvrir Entourage."}]}
        """)
        XCTAssertEqual(card.destination, .resource(id: 31))
        XCTAssertEqual(card.metas.count, 3)
        XCTAssertEqual(card.cta, .read)
    }

    func testSmallTalk() throws {
        let card = try self.card(#"{"id":19,"kind":"smalltalk","placement":"hero","target":null,"reasons":[{"code":"smalltalk","text":"Les Bonnes ondes vous mettent en relation."}]}"#)
        XCTAssertEqual(card.destination, .smallTalk)
        XCTAssertEqual(card.cta, .smallTalk)
    }

    func testPoi() throws {
        let card = try self.card(#"{"id":20,"kind":"poi","placement":"hero","target":{"id":55,"name":"Bagagerie solidaire du 20e","adress":"12 rue X, Paris"},"reasons":[]}"#)
        XCTAssertEqual(card.destination, .poi(id: 55))
        XCTAssertEqual(card.title, "Bagagerie solidaire du 20e")
        XCTAssertEqual(card.cta, .seePlace)
    }

    /// Badges de groupe (mêmes mots qu'Android) : groupe de voisins, groupe thématique rejoint, groupe à découvrir.
    func testGroupBadgesAndEngineSentenceAsText() throws {
        let neighbors = try self.card(#"{"id":40,"kind":"post_message","placement":"hero","target":{"id":522,"name":"Voisins","national":false,"zone":null},"reasons":[{"code":"member_group","text":"Vous êtes membre de ce groupe."}]}"#)
        XCTAssertEqual(neighbors.badgeKey, "suggestion_badge_post_message")
        XCTAssertEqual(neighbors.body, "Vous êtes membre de ce groupe.")

        let thematic = try self.card(#"{"id":41,"kind":"post_message","placement":"hero","target":{"id":5,"name":"Cuisine et partage","national":true},"reasons":[]}"#)
        XCTAssertEqual(thematic.badgeKey, "suggestion_badge_post_message_group")

        let discovered = try self.card(#"{"id":42,"kind":"neighborhood","placement":"hero","target":{"id":6,"name":"Cuisine","national":true},"reasons":[]}"#)
        XCTAssertEqual(discovered.badgeKey, "suggestion_badge_neighborhood")

        XCTAssertEqual("suggestion_badge_post_message".localized, "✉️ Discuter avec vos voisins")
        XCTAssertEqual("suggestion_badge_post_message_group".localized, "✉️ Discuter dans votre groupe")
        XCTAssertEqual("suggestion_badge_neighborhood".localized, "👥 Un groupe qui pourrait vous plaire")
    }

    /// Réponse réelle de préprod (artifact du 16/11) : cible `action` sans clé racine, `metadata` vide.
    func testRealPreprodActionTarget() throws {
        let card = try self.card("""
        {"id":null,"kind":"action","mode":"segment","placement":"others",
         "target":{"id":149820,"uuid":"eWaSLFcwbiFk","uuid_v2":"eWaSLFcwbiFk","status":"open","section":"clothes",
                   "title":"Je cherche chaussure d'hiver homme 42","title_translations":null,
                   "description":"Je cherche chaussure d'hiver homme 42","description_translations":null,"image_url":null,
                   "action_type":"solicitation",
                   "author":{"id":5100,"display_name":"Clem T.","avatar_url":null,"created_at":"2025-11-05T16:45:40.360+01:00"},
                   "metadata":{},"member":false,"members":[{"id":1,"lang":"fr","avatar_url":"n/a","display_name":"n/a"}],
                   "members_count":1,"created_at":"2026-10-01T16:38:03.150+02:00","updated_at":"2026-10-15T16:14:58.639+02:00",
                   "status_changed_at":null,"distance":2.5,"location":{"latitude":48.85298008272297,"longitude":2.415879454243083}},
         "targets":null,"link":null,"reasons":[{"code":"neighbor_needs_help","text":"Une personne près de chez vous a besoin d'un coup de pouce."}],"expires_at":null}
        """)
        XCTAssertEqual(card.destination, .action(id: 149820, isContrib: false))
        XCTAssertEqual(card.title, "Je cherche chaussure d'hiver homme 42")
        XCTAssertEqual(card.authorName, "Clem T.")
    }

    /// Réponse réelle de préprod (artifact du 16/11) : cible `poi`, `address` en texte, `category_ids`, `partner_id` nul.
    func testRealPreprodPoiTarget() throws {
        let card = try self.card("""
        {"id":null,"kind":"poi","mode":"need","placement":"others",
         "target":{"id":145042,"name":"Maison Béthanie - Secours Catholique","description":"Accueil de jour",
                   "longitude":5.371295,"latitude":43.304681,"phone":"488087670","website":null,
                   "email":"accueildejour.131@secours-catholique.org","audience":"Accueil inconditionnel","partner_id":null,
                   "address":"11 Rue malaval, 13002 Marseille","hours":"lun : 8h30 à 11h00\\nmar : Fermé","languages":"",
                   "air_conditioned":false,"source_url":"https://soliguide.fr/fiche/13977","uuid":"s13977","source":"soliguide",
                   "category_ids":[6,41,42,43,3,1,7,5]},
         "targets":null,"link":null,"reasons":[{"code":"poi_for_need","text":"Ce lieu peut vous aider."}],"expires_at":null}
        """)
        XCTAssertEqual(card.destination, .poi(id: 145042))
        XCTAssertEqual(card.title, "Maison Béthanie - Secours Catholique")
        XCTAssertTrue(card.metas.contains { $0.text == "11 Rue malaval, 13002 Marseille" })
    }

    func testPostMessageOpensTheGroup() throws {
        let card = try self.card(#"{"id":21,"kind":"post_message","placement":"hero","target":{"id":7,"name":"Voisins Ménilmontant"},"reasons":[{"code":"group_member_message","text":"Un petit message suffit."}]}"#)
        XCTAssertEqual(card.destination, .neighborhoodPost(id: 7, name: "Voisins Ménilmontant", zone: nil, isNational: false))
        XCTAssertEqual(card.cta, .writeMessage)
    }

    /// Un groupe thématique national n'a pas de zone : l'écran d'écriture le traite comme tel.
    func testPostMessageKeepsTheGroupZone() throws {
        let card = try self.card(#"{"id":26,"kind":"post_message","placement":"hero","target":{"id":9,"name":"Quartier Nord","zone":"paris","national":false},"reasons":[]}"#)
        XCTAssertEqual(card.destination, .neighborhoodPost(id: 9, name: "Quartier Nord", zone: "paris", isNational: false))
    }

    func testContentPathOpensTheFirstUnreadResource() throws {
        let card = try self.card("""
        {"id":27,"kind":"content_path","placement":"hero","target":null,
         "targets":[{"id":31,"name":"A","duration":2,"watched":true},{"id":32,"name":"B","duration":3,"watched":false},{"id":33,"name":"C","duration":2,"watched":false}],
         "reasons":[]}
        """)
        XCTAssertEqual(card.destination, .resource(id: 32))
        XCTAssertEqual(card.metas.count, 3)
    }

    func testContentPathWithAllResourcesReadOpensTheFirst() throws {
        let card = try self.card("""
        {"id":28,"kind":"content_path","placement":"hero","target":null,
         "targets":[{"id":31,"name":"A","watched":true},{"id":32,"name":"B","watched":true},{"id":33,"name":"C","watched":true}],
         "reasons":[]}
        """)
        XCTAssertEqual(card.destination, .resource(id: 31))
    }

    func testBecomeAmbassadorOpensTheLink() throws {
        let card = try self.card(#"{"id":22,"kind":"become_ambassador","placement":"hero","target":null,"link":"https://forms.example.com/devenir-animateur-entourage","reasons":[]}"#)
        XCTAssertEqual(card.destination, .link(URL(string: "https://forms.example.com/devenir-animateur-entourage")!))
        XCTAssertEqual(card.cta, .becomeAmbassador)
    }

    func testBecomeAmbassadorWithoutLinkIsDropped() throws {
        let decoded = try item(#"{"id":23,"kind":"become_ambassador","placement":"hero","target":null,"link":null,"reasons":[]}"#)
        XCTAssertNil(NextStepAdapter.card(from: decoded))
    }

    // MARK: - Raisons, type inconnu, autres pistes

    /// Les phrases du moteur sont gardées telles quelles ; l'app ne filtre aucune raison selon le profil.
    func testReasonsKeepTheEnginePhrases() throws {
        let card = try self.card(#"{"id":24,"kind":"smalltalk","placement":"hero","target":null,"reasons":[{"code":"popular","text":"D'autres personnes y participent déjà."},{"code":"code_futur","text":"Une raison inconnue."}]}"#)
        XCTAssertEqual(card.reasons.map { $0.code }, ["popular", "code_futur"])
        XCTAssertEqual(card.reasons.first?.text, "D'autres personnes y participent déjà.")
        XCTAssertEqual(SuggestionWhyViewController.displayedReasons(for: card).count, 2)
        XCTAssertEqual(card.reasons.last?.icon, "✅", "un code inconnu prend l'icône par défaut")
    }

    func testUnknownKindIsDropped() throws {
        let decoded = try item(#"{"id":25,"kind":"type_futur","placement":"hero","target":{"id":1,"title":"?"},"reasons":[]}"#)
        XCTAssertNil(NextStepAdapter.card(from: decoded))
    }

    func testUnreadableOtherIsDroppedWithoutBreakingTheOthers() throws {
        let data = Data(#"{"next_steps":[{"kind":"outing","placement":"others","target":{"id":1,"title":"A"}},{"placement":"others"},{"kind":"smalltalk","placement":"others","target":null}]}"#.utf8)
        let response = try JSONDecoder().decode(NextStepOthersResponse.self, from: data)
        XCTAssertEqual(response.items.map { $0.kind }, ["outing", "smalltalk"])
    }

    func testOthersBecomeAtMostThreeAccesses() throws {
        let others = try (1...5).map { i in
            try item(#"{"id":null,"kind":"neighborhood","placement":"others","target":{"id":\#(i),"name":"Groupe \#(i)"},"reasons":[]}"#)
        }
        let payload = NextStepAdapter.payload(current: nil, others: others)
        XCTAssertNil(payload.hero)
        XCTAssertEqual(payload.explorer.count, 3)
        XCTAssertEqual(payload.explorer.first?.label, "Groupe 1")
        XCTAssertEqual(payload.explorer.first?.destination, .neighborhood(id: 1))
        XCTAssertEqual(payload.explorer.first?.targetId, 1)
    }

    func testNoSuggestionLeavesAnEmptyPayload() throws {
        let response = try JSONDecoder().decode(NextStepSingleResponse.self, from: Data(#"{"next_step":null}"#.utf8))
        XCTAssertNil(response.item)
        XCTAssertTrue(NextStepAdapter.payload(current: response.item, others: []).isEmpty)
    }

    // MARK: - Mesure

    func testInteractionBodies() throws {
        let hero = NextStepInteraction(placement: .hero, kind: .whyOpened, nextStepId: 12, itemKind: nil, targetId: nil)
        let heroFields = try XCTUnwrap(hero.body["interaction"] as? [String: Any])
        XCTAssertEqual(heroFields["placement"] as? String, "hero")
        XCTAssertEqual(heroFields["kind"] as? String, "why_opened")
        XCTAssertEqual(heroFields["next_step_id"] as? Int, 12)
        XCTAssertNil(heroFields["item_kind"])

        let other = NextStepInteraction(placement: .others, kind: .tapped, nextStepId: nil, itemKind: "outing", targetId: 42)
        let otherFields = try XCTUnwrap(other.body["interaction"] as? [String: Any])
        XCTAssertEqual(otherFields["placement"] as? String, "others")
        XCTAssertEqual(otherFields["item_kind"] as? String, "outing")
        XCTAssertEqual(otherFields["target_id"] as? Int, 42)
        XCTAssertNil(otherFields["next_step_id"])
    }

    // MARK: - « Plus tard »

    private final class FakeProvider: SuggestionProviding {
        var payload = SuggestionPayload(hero: nil, explorer: [])
        var next: SuggestionCard?
        var dismissed = [SuggestionCard]()
        var fetchCount = 0
        var interactions = [NextStepInteraction]()

        func fetch(completion: @escaping (Swift.Result<SuggestionPayload, Error>) -> Void) {
            fetchCount += 1
            completion(.success(payload))
        }
        func dismiss(_ card: SuggestionCard, completion: @escaping (Swift.Result<SuggestionCard?, Error>) -> Void) {
            dismissed.append(card)
            completion(.success(next))
        }
        func record(_ interaction: NextStepInteraction) { interactions.append(interaction) }
    }

    private struct Harness {
        let provider: FakeProvider
        let coordinator: SuggestionCoordinator
        let snackbar: SnackbarSpy
    }

    private final class SnackbarSpy {
        var undo: (() -> Void)?
        var expire: (() -> Void)?
        var shown = 0
    }

    private func makeHarness(hero: SuggestionCard, next: SuggestionCard?) -> Harness {
        let provider = FakeProvider()
        provider.payload = SuggestionPayload(hero: hero, explorer: [])
        provider.next = next
        let spy = SnackbarSpy()
        let coordinator = SuggestionCoordinator(provider: provider,
                                                presentSnackbar: { _, _, undo, expire in spy.shown += 1; spy.undo = undo; spy.expire = expire },
                                                navigator: { _ in })
        coordinator.refresh()
        return Harness(provider: provider, coordinator: coordinator, snackbar: spy)
    }

    private func hero(_ id: Int) -> SuggestionCard {
        SuggestionCard(id: "\(id)", type: .smalltalk, title: "Hero \(id)", nextStepId: id)
    }

    func testLaterIsSentOnlyAfterTheMessageDisappears() throws {
        let h = makeHarness(hero: hero(1), next: hero(2))
        XCTAssertEqual(h.coordinator.payload?.hero?.id, "1")

        h.coordinator.laterTapped(hero(1))
        XCTAssertNil(h.coordinator.payload?.hero, "la card est retirée tout de suite")
        XCTAssertTrue(h.provider.dismissed.isEmpty, "le moteur n'est pas prévenu pendant le message")

        h.snackbar.expire?()
        XCTAssertEqual(h.provider.dismissed.map { $0.id }, ["1"])
        XCTAssertEqual(h.coordinator.payload?.hero?.id, "2", "la suivante donnée par le moteur remplace la card")
    }

    func testUndoRestoresTheCardWithoutWarningTheEngine() throws {
        let h = makeHarness(hero: hero(1), next: hero(2))

        h.coordinator.laterTapped(hero(1))
        h.snackbar.undo?()

        XCTAssertEqual(h.coordinator.payload?.hero?.id, "1")
        XCTAssertTrue(h.provider.dismissed.isEmpty)

        // Un message déjà annulé ne peut plus acter « Plus tard ».
        h.snackbar.expire?()
        XCTAssertTrue(h.provider.dismissed.isEmpty)
    }

    func testRefreshDoesNotBringBackTheCardDuringTheMessage() throws {
        let h = makeHarness(hero: hero(1), next: nil)
        let fetchesBefore = h.provider.fetchCount

        h.coordinator.laterTapped(hero(1))
        h.coordinator.refresh()

        XCTAssertEqual(h.provider.fetchCount, fetchesBefore)
        XCTAssertNil(h.coordinator.payload?.hero)
    }

    func testNoNextSuggestionEmptiesTheZone() throws {
        let h = makeHarness(hero: hero(1), next: nil)
        h.coordinator.laterTapped(hero(1))
        h.snackbar.expire?()

        if case .empty = h.coordinator.state {} else { XCTFail("sans suggestion suivante ni autre piste, la zone est vide") }
        XCTAssertFalse(h.coordinator.isShowingSuggestions, "la home retrouve ses sections d'origine")
    }

    /// Les autres pistes sans cible (mini-parcours, Bonnes ondes, Animateur) n'envoient pas de `target_id`.
    func testOthersWithoutTargetOmitTargetId() throws {
        let h = makeHarness(hero: hero(1), next: nil)
        let noTarget: [SuggestionType] = [.contentPath, .smalltalk, .becomeAmbassador]
        for (index, type) in noTarget.enumerated() {
            h.coordinator.explorerTapped(ExplorerAccess(id: "o\(index)", type: type, label: "x", context: nil, destination: .smallTalk, targetId: 5))
        }
        h.coordinator.explorerTapped(ExplorerAccess(id: "o9", type: .outing, label: "x", context: nil, destination: .outing(id: 5), targetId: 5))

        let sent = h.provider.interactions
        XCTAssertEqual(sent.map { $0.itemKind }, ["content_path", "smalltalk", "become_ambassador", "outing"])
        XCTAssertEqual(sent.map { $0.targetId }, [nil, nil, nil, 5])
        for interaction in sent.prefix(3) {
            let fields = try XCTUnwrap(interaction.body["interaction"] as? [String: Any])
            XCTAssertNil(fields["target_id"])
        }
    }

    /// `displayed` part une fois par affichage de la home : ni à chaque rafraîchissement, ni jamais.
    func testDisplayedIsSentOncePerHomeDisplay() throws {
        let h = makeHarness(hero: hero(1), next: nil)
        let card = hero(1)
        func displayedCount() -> Int { h.provider.interactions.filter { $0.kind == .displayed }.count }

        h.coordinator.homeWillAppear()
        h.coordinator.heroDidDisplay(card)
        XCTAssertEqual(displayedCount(), 1)

        // Reconstruction de la table et rafraîchissement du moteur pendant le même affichage.
        h.coordinator.heroDidDisplay(card)
        h.coordinator.refresh()
        h.coordinator.heroDidDisplay(card)
        XCTAssertEqual(displayedCount(), 1)

        // La home revient à l'écran : le prochain pas est de nouveau affiché.
        h.coordinator.homeWillAppear()
        h.coordinator.refresh()
        h.coordinator.heroDidDisplay(card)
        XCTAssertEqual(displayedCount(), 2)

        // Un autre prochain pas affiché pendant le même affichage est un nouvel affichage.
        h.coordinator.heroDidDisplay(hero(2))
        XCTAssertEqual(displayedCount(), 3)
    }

    func testDisplayAndTapAreReportedToTheEngine() throws {
        let h = makeHarness(hero: hero(1), next: nil)
        let card = hero(1)
        h.coordinator.heroDidDisplay(card)
        h.coordinator.heroDidDisplay(card)   // une seule fois par suggestion
        h.coordinator.primaryTapped(card)

        XCTAssertEqual(h.provider.interactions.map { $0.kind }, [.displayed, .tapped])
        XCTAssertTrue(h.provider.interactions.allSatisfy { $0.placement == .hero && $0.nextStepId == 1 })
    }
}
