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

    // MARK: - Photo de l'auteur d'une entraide (design.md, décision 13)

    private let avatar = "https://example.org/avatars/5100-300x300.jpg"

    private func actionCard(author: String?, imageUrl: String = "null", type: String = "solicitation") throws -> SuggestionCard {
        let authorJson = author.map { #","author":\#($0)"# } ?? ""
        return try self.card("""
        {"id":50,"kind":"action","placement":"hero",
         "target":{"id":101,"title":"Besoin d'un téléphone","action_type":"\(type)","image_url":\(imageUrl)\(authorJson)},
         "reasons":[]}
        """)
    }

    /// Scénario « Auteur avec photo » : `target.author.avatar_url` est décodé puis porté par la card.
    func testActionAuthorAvatarIsDecodedAndCarriedByTheCard() throws {
        let json = """
        {"id":50,"kind":"action","placement":"hero",
         "target":{"id":101,"title":"Besoin d'un téléphone","action_type":"solicitation",
                   "author":{"id":5100,"display_name":"Clem T.","avatar_url":"\(avatar)"}},
         "reasons":[]}
        """
        let decoded = try item(json)
        XCTAssertEqual(decoded.target?.authorAvatarURL?.absoluteString, avatar)

        let card = try XCTUnwrap(NextStepAdapter.card(from: decoded))
        XCTAssertEqual(card.authorAvatarURL?.absoluteString, avatar)
        XCTAssertEqual(card.authorName, "Clem T.", "les initiales restent le repli")
    }

    /// Scénario « Proposition d'aide avec une image jointe » : on affiche la photo de l'auteur, jamais `image_url`.
    func testContributionWithAttachedImageKeepsTheAuthorPhoto() throws {
        let card = try actionCard(author: #"{"id":5100,"display_name":"Clem T.","avatar_url":"\#(avatar)"}"#,
                                  imageUrl: #""https://example.org/images/jointe.jpg""#, type: "contribution")
        XCTAssertEqual(card.destination, .action(id: 101, isContrib: true))
        XCTAssertEqual(card.authorAvatarURL?.absoluteString, avatar)

        // Sans photo d'auteur, l'image jointe ne la remplace pas.
        let withoutPhoto = try actionCard(author: #"{"id":5100,"display_name":"Clem T.","avatar_url":null}"#,
                                          imageUrl: #""https://example.org/images/jointe.jpg""#, type: "contribution")
        XCTAssertNil(withoutPhoto.authorAvatarURL)
    }

    /// Scénario « Auteur sans photo » : pas d'URL, le nom reste pour les initiales.
    func testActionAuthorWithoutAvatarHasNoPhotoURL() throws {
        let withNull = try actionCard(author: #"{"id":5100,"display_name":"Clem T.","avatar_url":null}"#)
        XCTAssertNil(withNull.authorAvatarURL)
        XCTAssertEqual(withNull.authorName, "Clem T.")

        let keyAbsent = try actionCard(author: #"{"id":5100,"display_name":"Clem T."}"#)
        XCTAssertNil(keyAbsent.authorAvatarURL)
        XCTAssertEqual(keyAbsent.authorName, "Clem T.")

        // Une adresse vide ou inexploitable vaut « pas de photo ».
        for unusable in [#""""#, #""   ""#, #""n/a""#, #""ftp://example.org/a.jpg""#, "12"] {
            let card = try actionCard(author: #"{"id":5100,"display_name":"Clem T.","avatar_url":\#(unusable)}"#)
            XCTAssertNil(card.authorAvatarURL, "avatar_url \(unusable) ne doit pas donner de photo")
            XCTAssertEqual(card.authorName, "Clem T.")
        }
    }

    /// Scénario « Ni photo ni nom » : ni URL ni nom, la card retombe sur l'emoji du type.
    func testActionWithoutNameNorPhoto() throws {
        let authors: [String?] = [#"{"id":5100}"#, #"{"id":5100,"display_name":null,"avatar_url":null}"#, nil]
        for author in authors {
            let card = try actionCard(author: author)
            XCTAssertNil(card.authorName)
            XCTAssertNil(card.authorAvatarURL)
        }
    }

    // MARK: Rendu du média de la card (sans attendre le réseau)

    private func descendants(of view: UIView, identifier: String) -> [UIView] {
        view.subviews.flatMap { sub -> [UIView] in
            (sub.accessibilityIdentifier == identifier ? [sub] : []) + descendants(of: sub, identifier: identifier)
        }
    }

    private func media(of view: SuggestionCardView) throws -> (photo: UIImageView, label: UILabel) {
        let photo = try XCTUnwrap(descendants(of: view, identifier: "suggestion_media_photo").first as? UIImageView)
        let label = try XCTUnwrap(descendants(of: view, identifier: "suggestion_media_label").first as? UILabel)
        return (photo, label)
    }

    /// Adresse qui ne se résout jamais : le chargement échoue, sans dépendre d'un serveur.
    private let unreachableAvatar = "https://avatar.invalid/5100.jpg"

    func testCardWithPhotoShowsItOverTheInitialsAndStaysDecorative() throws {
        let view = SuggestionCardView()
        view.configure(card: try actionCard(author: #"{"id":5100,"display_name":"Clem T.","avatar_url":"\#(unreachableAvatar)"}"#))
        let (photo, label) = try media(of: view)

        XCTAssertFalse(photo.isHidden, "la photo est demandée")
        XCTAssertNil(photo.image, "pas encore chargée : les initiales servent de placeholder")
        XCTAssertFalse(label.isHidden)
        XCTAssertEqual(label.text, "CT")
        XCTAssertFalse(photo.isAccessibilityElement, "l'image est décorative : le nom de l'auteur est déjà lu")
    }

    func testCardWithoutPhotoShowsInitialsOnly() throws {
        let view = SuggestionCardView()
        view.configure(card: try actionCard(author: #"{"id":5100,"display_name":"Clem T.","avatar_url":null}"#))
        let (photo, label) = try media(of: view)

        XCTAssertTrue(photo.isHidden)
        XCTAssertFalse(label.isHidden)
        XCTAssertEqual(label.text, "CT")
    }

    func testCardWithoutNameNorPhotoShowsTheTypeEmoji() throws {
        let view = SuggestionCardView()
        view.configure(card: try actionCard(author: nil))
        let (photo, label) = try media(of: view)

        XCTAssertTrue(photo.isHidden)
        XCTAssertFalse(label.isHidden)
        XCTAssertEqual(label.text, SuggestionType.action.fallbackEmoji)
    }

    /// Une photo ne doit pas rester sur la card suivante (réutilisation de la cellule de la home).
    func testPhotoDoesNotStayOnTheNextCard() throws {
        let view = SuggestionCardView()
        view.configure(card: try actionCard(author: #"{"id":5100,"display_name":"Clem T.","avatar_url":"\#(unreachableAvatar)"}"#))
        let (photo, label) = try media(of: view)
        // Simule une photo chargée : la photo masque les initiales.
        photo.image = UIImage()
        label.isHidden = true

        view.prepareForReuse()
        XCTAssertNil(photo.image)
        XCTAssertTrue(photo.isHidden)
        XCTAssertFalse(label.isHidden)

        // Reconfiguration directe, sans prepareForReuse, avec une card d'un autre type.
        photo.isHidden = false
        photo.image = UIImage()
        label.isHidden = true
        view.configure(card: try self.card(#"{"id":51,"kind":"smalltalk","placement":"hero","target":null,"reasons":[]}"#))
        XCTAssertNil(photo.image)
        XCTAssertTrue(photo.isHidden)
        XCTAssertFalse(label.isHidden)
        XCTAssertEqual(label.text, SuggestionType.smalltalk.fallbackEmoji)
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
        /// Ce que le moteur renvoie à la lecture suivante un « Plus tard » confirmé (par défaut : `payload`).
        var payloadAfterDismiss: SuggestionPayload?
        /// Le moteur répond en erreur à `ignore`.
        var dismissFails = false
        /// `GET current` échoue (réseau, API).
        var fetchFails = false

        func fetch(completion: @escaping (Swift.Result<SuggestionPayload, Error>) -> Void) {
            fetchCount += 1
            if fetchFails { return completion(.failure(NextStepError.failed)) }
            completion(.success(dismissed.isEmpty ? payload : (payloadAfterDismiss ?? payload)))
        }
        func dismiss(_ card: SuggestionCard, completion: @escaping (Swift.Result<SuggestionCard?, Error>) -> Void) {
            dismissed.append(card)
            completion(dismissFails ? .failure(NextStepError.failed) : .success(next))
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
        h.provider.payloadAfterDismiss = SuggestionPayload(hero: nil, explorer: [])
        h.coordinator.laterTapped(hero(1))
        h.snackbar.expire?()

        if case .empty = h.coordinator.state {} else { XCTFail("sans suggestion suivante ni autre piste, la zone est vide") }
    }

    /// Correctif `confirmLater` : sans suivante dans la réponse de `ignore`, l'app relit le moteur (`current`).
    func testIgnoreWithoutNextRereadsTheEngine() throws {
        let h = makeHarness(hero: hero(1), next: nil)
        h.provider.payloadAfterDismiss = SuggestionPayload(hero: hero(2), explorer: [])
        let fetchesBefore = h.provider.fetchCount

        h.coordinator.laterTapped(hero(1))
        h.snackbar.expire?()

        XCTAssertEqual(h.provider.dismissed.map { $0.id }, ["1"])
        XCTAssertEqual(h.provider.fetchCount, fetchesBefore + 1, "le moteur est relu une fois")
        XCTAssertEqual(h.coordinator.payload?.hero?.id, "2", "la carte relue remplace l'ancienne")
    }

    /// Une suivante donnée par `ignore` suffit : pas de relecture.
    func testIgnoreWithNextDoesNotRereadTheEngine() throws {
        let h = makeHarness(hero: hero(1), next: hero(2))
        let fetchesBefore = h.provider.fetchCount

        h.coordinator.laterTapped(hero(1))
        h.snackbar.expire?()

        XCTAssertEqual(h.provider.fetchCount, fetchesBefore)
        XCTAssertEqual(h.coordinator.payload?.hero?.id, "2")
    }

    /// Un `ignore` en erreur : l'app se recale sur le moteur au lieu de laisser la zone sans card.
    func testFailedIgnoreRereadsTheEngine() throws {
        let h = makeHarness(hero: hero(1), next: nil)
        h.provider.dismissFails = true
        let fetchesBefore = h.provider.fetchCount

        h.coordinator.laterTapped(hero(1))
        h.snackbar.expire?()

        XCTAssertEqual(h.provider.fetchCount, fetchesBefore + 1)
        XCTAssertEqual(h.coordinator.payload?.hero?.id, "1")
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

    // MARK: - Parité avec Android

    /// Mêmes icônes qu'Android pour chaque code de raison du moteur.
    func testReasonIconsMatchAndroid() {
        let expected: [String: String] = [
            "near_you": "📍", "shared_interests": "✨", "popular": "👥", "upcoming_event": "🗓️",
            "online_event": "💻", "papotage": "💻", "answers_your_need": "🔎", "poi_for_need": "🔎",
            "local_group": "👥", "national_group": "👥", "neighbor_needs_help": "🤝", "help_offered": "🤝",
            "content_path": "📘", "group_member_message": "💬", "smalltalk": "💬", "become_ambassador": "🌟"
        ]
        for (code, icon) in expected {
            XCTAssertEqual(SuggestionReason(code: code, text: "x").icon, icon, code)
        }
    }

    /// Une card sans phrase du moteur n'ouvre pas de feuille vide : pas de bouton « ? ».
    func testWhyButtonIsHiddenWithoutReasons() throws {
        let view = SuggestionCardView()
        view.configure(card: try card(#"{"id":50,"kind":"smalltalk","placement":"hero","target":null,"reasons":[]}"#))
        XCTAssertTrue(view.isWhyButtonHidden)
        view.configure(card: try card(#"{"id":51,"kind":"smalltalk","placement":"hero","target":null,"reasons":[{"code":"smalltalk","text":"Les Bonnes ondes."},{"code":"x","text":"  "}]}"#))
        XCTAssertFalse(view.isWhyButtonHidden)
    }

    /// Toutes les clés de suggestion du français existent en anglais : sinon un iPhone en anglais afficherait les clés brutes.
    func testSuggestionStringsAreTranslatedToEnglish() throws {
        func keys(_ language: String) throws -> Set<String> {
            let path = try XCTUnwrap(Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language))
            let dictionary = try XCTUnwrap(NSDictionary(contentsOfFile: path) as? [String: String])
            return Set(dictionary.keys.filter { $0.hasPrefix("suggestion_") })
        }
        let missing = try keys("fr").subtracting(keys("en"))
        XCTAssertTrue(missing.isEmpty, "clés sans traduction anglaise : \(missing.sorted())")
    }

    // MARK: - Alignement sur Android

    /// Un groupe local montre son adresse, un groupe national rien, et aucune description de groupe.
    func testGroupCardsShowTheAddressOnlyForALocalGroup() throws {
        let local = try card(#"{"id":60,"kind":"neighborhood","placement":"hero","target":{"id":7,"name":"Voisins","national":false,"description":"Un groupe de voisins","address":{"display_address":"Paris 11e"}},"reasons":[]}"#)
        XCTAssertEqual(local.metas.map { $0.text }, ["Paris 11e"], "pas de description de groupe sur la card")
        let national = try card(#"{"id":61,"kind":"neighborhood","placement":"hero","target":{"id":8,"name":"Cuisine","national":true,"description":"Un groupe","address":{"display_address":"Paris"}},"reasons":[]}"#)
        XCTAssertTrue(national.metas.isEmpty)
        let post = try card(#"{"id":62,"kind":"post_message","placement":"hero","target":{"id":9,"name":"Voisins","national":false,"address":{"display_address":"Paris 11e"}},"reasons":[]}"#)
        XCTAssertEqual(post.metas.map { $0.text }, ["Paris 11e"])
    }

    /// Comme Android : seule une adresse https ouvre le formulaire « devenir Animateur ».
    func testAmbassadorLinkMustBeHttps() throws {
        let http = try item(#"{"id":63,"kind":"become_ambassador","placement":"hero","target":null,"link":"http://forms.example.com/x","reasons":[]}"#)
        XCTAssertNil(NextStepAdapter.card(from: http))
    }

    /// Une autre piste sans information affiche la phrase du moteur comme ligne de contexte.
    func testExplorerContextFallsBackToTheEngineSentence() throws {
        let other = try item(#"{"id":null,"kind":"smalltalk","placement":"others","target":null,"reasons":[{"code":"smalltalk","text":"Les Bonnes ondes vous mettent en relation."}]}"#)
        let access = try XCTUnwrap(NextStepAdapter.access(from: other))
        XCTAssertEqual(access.context, "Les Bonnes ondes vous mettent en relation.")
    }

    /// Comme Android : le contexte d'une ligne Explorer est la première information venue de la cible, jamais
    /// la distance calculée par l'app. Une entraide affiche donc sa description, pas « À 800 m de vous ».
    func testExplorerContextOfAnActionIsItsDescriptionNotTheDistance() throws {
        let other = try item("""
        {"id":null,"kind":"action","placement":"others",
         "target":{"id":99,"title":"Besoin d'un téléphone","description":"Bonjour à tous, je cherche un télé…","action_type":"solicitation","distance":0.8,
                   "author":{"id":5,"display_name":"Nino D."}},"reasons":[]}
        """)
        let access = try XCTUnwrap(NextStepAdapter.access(from: other))
        XCTAssertEqual(access.context, "Bonjour à tous, je cherche un télé…")
        // La card, elle, garde la distance.
        let card = try XCTUnwrap(NextStepAdapter.card(from: other))
        XCTAssertEqual(card.metas.first?.text, String(format: "suggestion_meta_distance_m".localized, 800))
    }

    /// Une entraide sans description n'a pas de ligne de contexte : la distance n'en tient pas lieu.
    func testExplorerContextOfAnActionWithoutDescriptionIsEmpty() throws {
        let other = try item(#"{"id":null,"kind":"action","placement":"others","target":{"id":100,"title":"Je prête une perceuse","action_type":"contribution","distance":2.0},"reasons":[]}"#)
        let access = try XCTUnwrap(NextStepAdapter.access(from: other))
        XCTAssertNil(access.context)
    }

    /// Un mini-parcours : le contexte est le titre du premier contenu, sans la durée (qui reste sur la card).
    func testExplorerContextOfAContentPathIsTheFirstTitleWithoutTheDuration() throws {
        let other = try item("""
        {"id":null,"kind":"content_path","placement":"others","target":null,
         "targets":[{"id":31,"name":"Comprendre l'isolement","duration":2},{"id":32,"name":"Un geste simple","duration":3}],"reasons":[]}
        """)
        let access = try XCTUnwrap(NextStepAdapter.access(from: other))
        XCTAssertEqual(access.context, "Comprendre l'isolement")
        let card = try XCTUnwrap(NextStepAdapter.card(from: other))
        XCTAssertEqual(card.metas.first?.text, "Comprendre l'isolement · " + String(format: "suggestion_meta_minutes".localized, 2))
    }

    /// Un événement en visio sans date : « En visio, depuis chez vous » est calculé par l'app, il ne sert pas de contexte.
    func testExplorerContextOfAnOnlineOutingWithoutDateIsEmpty() throws {
        let other = try item(#"{"id":null,"kind":"outing","placement":"others","target":{"id":43,"title":"Papotage solidaire","online":true,"distance":5.0,"metadata":{"starts_at":null,"display_address":null}},"reasons":[]}"#)
        let access = try XCTUnwrap(NextStepAdapter.access(from: other))
        XCTAssertNil(access.context)
        let card = try XCTUnwrap(NextStepAdapter.card(from: other))
        XCTAssertTrue(card.metas.contains { $0.text == "suggestion_meta_remote".localized }, "la card garde la mention visio")
    }

    /// Un événement sans date : l'adresse, avant la distance. Un lieu : son adresse, pas ses horaires.
    func testExplorerContextIsTheAddressBeforeTheDistance() throws {
        let outing = try item(#"{"id":null,"kind":"outing","placement":"others","target":{"id":42,"title":"Café solidaire","online":false,"distance":0.8,"metadata":{"display_address":"Ménilmontant, Paris"}},"reasons":[]}"#)
        XCTAssertEqual(try XCTUnwrap(NextStepAdapter.access(from: outing)).context, "Ménilmontant, Paris")
        let poi = try item(#"{"id":null,"kind":"poi","placement":"others","target":{"id":55,"name":"Bagagerie solidaire du 20e","adress":"12 rue X, Paris","hours":"lun : 8h30 à 11h00","distance":1.2},"reasons":[]}"#)
        XCTAssertEqual(try XCTUnwrap(NextStepAdapter.access(from: poi)).context, "12 rue X, Paris")
    }

    /// Comme Android : un lieu solidaire affiche son adresse puis ses horaires, jamais de distance (décision 14).
    func testPoiShowsAddressThenOpeningHoursAndNoDistance() throws {
        let card = try self.card(#"{"id":20,"kind":"poi","placement":"hero","target":{"id":55,"name":"Bagagerie solidaire du 20e","adress":"12 rue X, Paris","hours":"lun : 8h30 à 11h00\nmar : Fermé","distance":1.2},"reasons":[]}"#)
        XCTAssertEqual(card.metas.map { $0.icon }, ["📍", "🕒"])
        XCTAssertEqual(card.metas.map { $0.text }, ["12 rue X, Paris", "lun : 8h30 à 11h00\nmar : Fermé"])
        // Des horaires vides ne font pas de ligne.
        let noHours = try self.card(#"{"id":21,"kind":"poi","placement":"hero","target":{"id":56,"name":"Accueil de jour","adress":"3 rue Y, Lyon","hours":"  "},"reasons":[]}"#)
        XCTAssertEqual(noHours.metas.map { $0.text }, ["3 rue Y, Lyon"])
    }

    /// Comme Android : le texte lu par VoiceOver suit l'ordre type, puces, auteur, titre, texte, informations.
    func testHeroReadoutFollowsTheAndroidOrder() throws {
        let action = try self.card(#"{"id":16,"kind":"action","placement":"hero","target":{"id":99,"title":"Besoin d'un téléphone","description":"Bonjour à tous","action_type":"solicitation","distance":0.8,"author":{"id":5,"display_name":"Nino D."}},"reasons":[]}"#)
        XCTAssertEqual(action.accessibilityReadout,
                       ["suggestion_badge_action".localized, "Nino D.", "Besoin d'un téléphone", "Bonjour à tous",
                        String(format: "suggestion_meta_distance_m".localized, 800)].joined(separator: ". "))
        let group = try self.card(#"{"id":14,"kind":"neighborhood","placement":"hero","target":{"id":7,"name":"Voisins Ménilmontant","national":false,"address":{"display_address":"Paris 11e"}},"reasons":[]}"#)
        XCTAssertEqual(group.accessibilityReadout,
                       ["suggestion_badge_neighborhood".localized, "suggestion_chip_local".localized, "Voisins Ménilmontant", "Paris 11e"]
                        .joined(separator: ". "))
        let online = try self.card(#"{"id":13,"kind":"outing","placement":"hero","target":{"id":43,"title":"Papotage solidaire","online":true,"metadata":{"starts_at":null,"display_address":null}},"reasons":[]}"#)
        XCTAssertEqual(online.accessibilityReadout,
                       ["suggestion_badge_outing".localized, "suggestion_chip_remote".localized, "Papotage solidaire",
                        "suggestion_meta_remote".localized].joined(separator: ". "))
    }

    /// Comme Android : appel au premier affichage et après un geste sur une suggestion, pas à chaque retour.
    func testEngineIsCalledOnFirstDisplayAndAfterATapOnly() throws {
        let provider = FakeProvider()
        provider.payload = SuggestionPayload(hero: hero(1), explorer: [])
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in })
        coordinator.refreshIfNeeded()
        XCTAssertEqual(provider.fetchCount, 1)
        coordinator.refreshIfNeeded()   // retour sur la home sans geste
        XCTAssertEqual(provider.fetchCount, 1)
        coordinator.primaryTapped(hero(1))
        coordinator.refreshIfNeeded()   // retour après un tap sur la card
        XCTAssertEqual(provider.fetchCount, 2)
        coordinator.refreshIfNeeded()
        XCTAssertEqual(provider.fetchCount, 2)
    }

    /// Le parcours de bienvenue masque la card : pas d'appel, puis un appel dès qu'il se termine.
    func testNoCallWhileTheWelcomeJourneyIsDisplayed() throws {
        let provider = FakeProvider()
        provider.payload = SuggestionPayload(hero: hero(1), explorer: [])
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in })
        coordinator.setSuppressed(true)
        coordinator.refreshIfNeeded()
        XCTAssertEqual(provider.fetchCount, 0)
        coordinator.setSuppressed(false)
        XCTAssertEqual(provider.fetchCount, 1)
    }

    /// Comme Android : la home démarre retenue. `viewWillAppear` tourne avant la réponse du résumé de la home ;
    /// le moteur n'est appelé qu'une fois le parcours de bienvenue connu, et une seule fois.
    func testNoCallBeforeTheHomeKnowsTheWelcomeJourney() throws {
        let provider = FakeProvider()
        provider.payload = SuggestionPayload(hero: hero(1), explorer: [])
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in },
                                                startsSuppressed: true)
        coordinator.homeWillAppear()
        coordinator.refreshIfNeeded()    // viewWillAppear, avant la réponse du résumé
        XCTAssertEqual(provider.fetchCount, 0)
        coordinator.setSuppressed(false) // le résumé dit : pas de parcours de bienvenue
        XCTAssertEqual(provider.fetchCount, 1)
        coordinator.refreshIfNeeded()    // retour sur la home sans geste
        XCTAssertEqual(provider.fetchCount, 1)
    }

    /// Le résumé montre le parcours de bienvenue : toujours aucun appel, puis un appel dès qu'il se termine.
    func testNoCallWhenTheSummaryShowsTheWelcomeJourney() throws {
        let provider = FakeProvider()
        provider.payload = SuggestionPayload(hero: hero(1), explorer: [])
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in },
                                                startsSuppressed: true)
        coordinator.refreshIfNeeded()
        coordinator.setSuppressed(true)  // le résumé dit : parcours de bienvenue affiché
        coordinator.refreshIfNeeded()
        XCTAssertEqual(provider.fetchCount, 0)
        coordinator.setSuppressed(false) // le parcours se termine
        XCTAssertEqual(provider.fetchCount, 1)
    }

    // MARK: - Événements Firebase « Prochain Pas » (EN-9892)

    private typealias LoggedEvent = (name: String, parameters: [String: Any])

    /// Capte les événements envoyés pendant `body` (les nouveaux noms du ticket seulement).
    private func capturingEvents(_ body: () -> Void) -> [LoggedEvent] {
        var events = [LoggedEvent]()
        AnalyticsLoggerManager.eventSink = { name, parameters in events.append((name, parameters ?? [:])) }
        defer { AnalyticsLoggerManager.eventSink = nil }
        body()
        return events.filter { $0.name.hasPrefix("next_step_") }
    }

    private func typedHero(_ id: Int, _ type: SuggestionType, targetId: Int?) -> SuggestionCard {
        SuggestionCard(id: "\(id)", type: type, title: "Hero \(id)", nextStepId: id, targetId: targetId)
    }

    func testLaterTappedEvent() throws {
        let card = typedHero(1, .outing, targetId: 501)
        let h = makeHarness(hero: card, next: nil)
        let events = capturingEvents { h.coordinator.laterTapped(card) }
        XCTAssertEqual(events.map { $0.name }, ["next_step_later_tapped"])
        XCTAssertEqual(events.first?.parameters["kind"] as? String, "outing")
        XCTAssertEqual(events.first?.parameters["target_id"] as? Int, 501)
        XCTAssertEqual(events.first?.parameters.count, 2)
    }

    func testLaterCancelledEvent() throws {
        let card = typedHero(1, .outing, targetId: 501)
        let h = makeHarness(hero: card, next: nil)
        h.coordinator.laterTapped(card)
        let events = capturingEvents { h.snackbar.undo?() }
        XCTAssertEqual(events.map { $0.name }, ["next_step_later_cancelled"])
        XCTAssertEqual(events.first?.parameters["kind"] as? String, "outing")
        XCTAssertEqual(events.first?.parameters["target_id"] as? Int, 501)
    }

    func testIgnoredEventIsLoggedAfterTheEngineAnswered() throws {
        let card = typedHero(1, .outing, targetId: 501)
        let h = makeHarness(hero: card, next: nil)
        h.provider.payloadAfterDismiss = SuggestionPayload(hero: nil, explorer: [])
        h.coordinator.laterTapped(card)
        var before = [LoggedEvent]()
        let events = capturingEvents { before = []; h.snackbar.expire?() }
        XCTAssertTrue(before.isEmpty)
        XCTAssertEqual(events.filter { $0.name == "next_step_ignored" }.count, 1)
        let ignored = try XCTUnwrap(events.first { $0.name == "next_step_ignored" })
        XCTAssertEqual(ignored.parameters["kind"] as? String, "outing")
        XCTAssertEqual(ignored.parameters["target_id"] as? Int, 501)
        XCTAssertNil(ignored.parameters["days_active"], "le contrat du moteur n'expose pas created_at")
    }

    func testIgnoredEventIsNotLoggedWhenTheEngineFails() throws {
        let card = typedHero(1, .outing, targetId: 501)
        let h = makeHarness(hero: card, next: nil)
        h.provider.dismissFails = true
        h.coordinator.laterTapped(card)
        let events = capturingEvents { h.snackbar.expire?() }
        XCTAssertFalse(events.contains { $0.name == "next_step_ignored" })
    }

    func testIgnoredEventIsNotLoggedWhenCancelled() throws {
        let card = typedHero(1, .outing, targetId: 501)
        let h = makeHarness(hero: card, next: nil)
        h.coordinator.laterTapped(card)
        let events = capturingEvents { h.snackbar.undo?(); h.snackbar.expire?() }
        XCTAssertEqual(events.map { $0.name }, ["next_step_later_cancelled"])
    }

    func testRealisedEventOnTapForPoiAndAmbassador() throws {
        for (type, targetId) in [(SuggestionType.poi, Optional(77)), (.becomeAmbassador, nil)] {
            let card = typedHero(1, type, targetId: targetId)
            let h = makeHarness(hero: card, next: nil)
            let events = capturingEvents { h.coordinator.primaryTapped(card) }
            XCTAssertEqual(events.map { $0.name }, ["next_step_realised"], "\(type)")
            XCTAssertEqual(events.first?.parameters["kind"] as? String, type.rawValue)
            XCTAssertEqual(events.first?.parameters["target_id"] as? Int, targetId)
            XCTAssertEqual(events.first?.parameters["realisation_trigger"] as? String, "tap")
        }
    }

    func testRealisedEventIsNotLoggedForOtherKinds() throws {
        let card = typedHero(1, .outing, targetId: 501)
        let h = makeHarness(hero: card, next: nil)
        let events = capturingEvents { h.coordinator.primaryTapped(card) }
        XCTAssertTrue(events.isEmpty, "les autres kinds sont réalisés côté back, sans signal vers l'app")
    }

    func testExplorerTappedEvent() throws {
        let card = typedHero(1, .outing, targetId: 501)
        let accesses = [
            ExplorerAccess(id: "others-outing-701", type: .outing, label: "A", context: nil, destination: .outing(id: 701), targetId: 701),
            ExplorerAccess(id: "others-neighborhood-702", type: .neighborhood, label: "B", context: nil, destination: .neighborhood(id: 702), targetId: 702)
        ]
        let provider = FakeProvider()
        provider.payload = SuggestionPayload(hero: card, explorer: accesses)
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in })
        coordinator.refresh()

        let events = capturingEvents { coordinator.explorerTapped(accesses[1]) }
        XCTAssertEqual(events.map { $0.name }, ["next_step_explorer_tapped"])
        let p = try XCTUnwrap(events.first?.parameters)
        XCTAssertEqual(p["kind"] as? String, "outing")
        XCTAssertEqual(p["target_id"] as? Int, 501)
        XCTAssertEqual(p["position"] as? Int, 2)
        XCTAssertEqual(p["explorer_kind"] as? String, "neighborhood")
        XCTAssertEqual(p["explorer_target_id"] as? Int, 702)
    }

    func testExplorerTappedEventWithoutMainSuggestion() throws {
        let access = ExplorerAccess(id: "others-outing-701", type: .outing, label: "A", context: nil, destination: .outing(id: 701), targetId: 701)
        let provider = FakeProvider()
        provider.payload = SuggestionPayload(hero: nil, explorer: [access])
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in })
        coordinator.refresh()

        let events = capturingEvents { coordinator.explorerTapped(access) }
        let p = try XCTUnwrap(events.first?.parameters)
        XCTAssertNil(p["kind"])
        XCTAssertNil(p["target_id"])
        XCTAssertEqual(p["position"] as? Int, 1)
    }

    func testNullEventWhenCurrentIsNull() throws {
        let provider = FakeProvider()
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in })
        let events = capturingEvents { coordinator.refresh() }
        XCTAssertEqual(events.map { $0.name }, ["next_step_null"])
        XCTAssertEqual(events.first?.parameters["reason"] as? String, "no_candidates")
    }

    func testNullEventOnError() throws {
        let provider = FakeProvider()
        provider.fetchFails = true
        let coordinator = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in })
        let events = capturingEvents { coordinator.refresh() }
        XCTAssertEqual(events.map { $0.name }, ["next_step_null"])
        XCTAssertEqual(events.first?.parameters["reason"] as? String, "error")
    }

    func testNullEventIsNotLoggedDuringWelcomeJourneyOrWithAHero() throws {
        let provider = FakeProvider()
        let suppressed = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in }, startsSuppressed: true)
        XCTAssertTrue(capturingEvents { suppressed.refreshIfNeeded() }.isEmpty)

        provider.payload = SuggestionPayload(hero: hero(1), explorer: [])
        let active = SuggestionCoordinator(provider: provider, presentSnackbar: { _, _, _, _ in }, navigator: { _ in })
        XCTAssertTrue(capturingEvents { active.refresh() }.isEmpty)
    }
}
