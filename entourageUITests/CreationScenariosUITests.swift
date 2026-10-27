import XCTest

/// Scénarios de création et de conversation (équivalents iOS de `CreateGroupScenarioTest`,
/// `CreationEvenementScenarioTest`, `CreateActionFullFlowScenarioTest` et `ConversationScenarioTest` côté Android) : on remplit le parcours comme un utilisateur, on publie, puis on
/// vérifie le corps réellement envoyé au faux backend et l'écran de confirmation. Une capture par étape.
///
/// Position : `LocationManger` renvoie Paris en mode `-UITestMode` (équivalent du `adb emu geo fix` d'Android).
final class CreationScenariosUITests: UITestCase {

    // MARK: - Helpers

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }

    private func tab(_ index: Int) {
        let button = app.tabBars.buttons.element(boundBy: index)
        XCTAssertTrue(button.waitForExistence(timeout: 20), "Onglet \(index) introuvable")
        button.tap()
    }

    /// Attend un élément puis le touche.
    private func tap(_ identifier: String, timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) {
        let target = element(identifier)
        XCTAssertTrue(target.waitForExistence(timeout: timeout), "\(identifier) introuvable", file: file, line: line)
        target.tap()
    }

    private func type(_ text: String, into identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        let field = element(identifier)
        XCTAssertTrue(field.waitForExistence(timeout: 10), "\(identifier) introuvable", file: file, line: line)
        field.tap()
        field.typeText(text)
    }

    private func next() { tap("form_flow_next") }

    /// Referme le clavier en touchant le fond de l'écran (les parcours SwiftUI le referment au toucher).
    private func dismissKeyboard() {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.2)).tap()
    }

    /// Choisit « Ma position » dans le sélecteur de lieu (Paris en mode test), puis valide.
    private func pickCurrentPlace(from field: String) {
        tap(field)
        tap("place_use_my_position")
        // La position arrive via une notification : on laisse l'écran s'actualiser avant de valider.
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        tap("place_validate")
    }

    // MARK: - Groupe

    func testCreateGroup() throws {
        launchApp()
        step("Onglet Groupes") { tab(3) }

        step("Ouvrir la création") {
            let button = element("groups_create")
            if button.waitForExistence(timeout: 10), button.isHittable { button.tap() } else { tap("groups_create_expanded") }
        }

        step("Étape 1 : nom, description, lieu") {
            type("Unit test group 1", into: "group_form_name")
            type("Groupe créé automatiquement par le test E2E.", into: "group_form_description")
            dismissKeyboard()
        }
        step("Lieu : ma position") { pickCurrentPlace(from: "group_form_place") }
        step("Continuer") { next() }

        step("Étape 2 : centre d'intérêt") { tap("group_form_interest_activites") }
        step("Continuer vers la photo") { next() }

        step("Étape 3 : photo de la galerie") {
            tap("group_form_photo")
            let list = element("photo_gallery_list")
            XCTAssertTrue(list.waitForExistence(timeout: 10))
            let firstImage = app.collectionViews["photo_gallery_list"].cells.firstMatch
            XCTAssertTrue(firstImage.waitForExistence(timeout: 10), "La galerie doit proposer une image")
            firstImage.tap()
            tap("photo_gallery_validate")
        }
        step("Continuer vers l'aperçu") { next() }
        step("Publier") { next() }

        let request = waitForRequest("POST neighborhoods")
        let group = request?.body["neighborhood"] as? [String: Any]
        XCTAssertEqual(group?["name"] as? String, "Unit test group 1")
        XCTAssertEqual(group?["interests"] as? [String], ["activites"])
        XCTAssertEqual(group?["neighborhood_image_id"] as? Int, 15)
        XCTAssertEqual(group?["latitude"] as? Double ?? 0, 48.8566, accuracy: 0.001)

        XCTAssertTrue(element("creation_end_title").waitForExistence(timeout: 10), "L'écran de confirmation doit s'afficher")
        screenshot("Confirmation")
    }

    // MARK: - Entraide

    /// Parcours commun : charte, rubrique, titre et description, lieu, aperçu, publication.
    private func createAction(isContrib: Bool, title: String) throws {
        launchApp()
        step("Onglet Entraide") { tab(1) }

        step("Ouvrir le menu de création") { tap("actions_create_fab") }
        step("Choisir \(isContrib ? "contribution" : "demande")") {
            tap(isContrib ? "actions_create_contribution" : "actions_create_demand")
        }

        step("Accepter la charte") { tap("action_charter_accept") }
        step("Rubrique") { tap("action_form_section_social") }
        step("Continuer vers le détail") { next() }

        step("Titre et description") {
            type(title, into: "action_form_title")
            type("Action créée automatiquement par le test E2E.", into: "action_form_description")
            dismissKeyboard()
        }
        step("Continuer vers le lieu") { next() }

        step("Lieu : ma position") { pickCurrentPlace(from: "action_form_place") }
        step("Continuer") { next() }

        // Étape de partage dans le groupe : proposée selon le groupe par défaut de l'utilisateur.
        let shareNo = app.buttons["Non"].firstMatch
        if shareNo.waitForExistence(timeout: 3) {
            step("Partage dans le groupe : non") { shareNo.tap() }
            step("Continuer vers l'aperçu") { next() }
        }
        step("Publier") { next() }

        let key = isContrib ? "contribution" : "solicitation"
        let request = waitForRequest(isContrib ? "POST contributions" : "POST solicitations")
        let action = request?.body[key] as? [String: Any]
        XCTAssertEqual(action?["title"] as? String, title)
        XCTAssertEqual(action?["section"] as? String, "social")
        XCTAssertEqual(action?["recipient_consent_obtained"] as? Bool, true)
        XCTAssertEqual((action?["location"] as? [String: Any])?["latitude"] as? Double ?? 0, 48.8566, accuracy: 0.001)

        // Après la création d'une entraide, l'app ouvre directement son détail.
        XCTAssertTrue(app.staticTexts[title].firstMatch.waitForExistence(timeout: 10), "Le détail de l'entraide créée doit s'afficher")
        screenshot("Détail de l'entraide")
    }

    func testCreateContribution() throws { try createAction(isContrib: true, title: "Unit test Contribution 1") }

    func testCreateDemand() throws { try createAction(isContrib: false, title: "Unit test Demande 1") }

    // MARK: - Événement

    /// Valide la roue de sélection ouverte (date ou heure) avec sa valeur par défaut.
    private func commitPicker(_ identifier: String) {
        tap(identifier)
        tap("form_flow_picker_validate")
    }

    func testCreateOnlineEvent() throws {
        launchApp()
        step("Onglet Événements") { tab(4) }
        step("Ouvrir la création") {
            let button = element("events_create")
            if button.waitForExistence(timeout: 10), button.isHittable { button.tap() } else { tap("events_create_expanded") }
        }

        step("Étape 1 : nom, description, photo") {
            type("Unit test Event 1", into: "event_form_title")
            type("Evenement créé automatiquement par le test E2E.", into: "event_form_description")
            dismissKeyboard()
            tap("event_form_photo")
            let firstImage = app.collectionViews.cells.firstMatch
            XCTAssertTrue(firstImage.waitForExistence(timeout: 10), "La galerie doit proposer une image")
            firstImage.tap()
        }
        screenshot("Photo choisie")
        step("Valider la photo") { tap("event_gallery_validate") }
        step("Continuer") { next() }

        // Demain : évite qu'une heure de début déjà passée aujourd'hui rende le test dépendant de l'heure.
        step("Étape 2 : date et heures") {
            tap("event_form_date")
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            setDateWheels(to: tomorrow)
            tap("form_flow_picker_validate")
            commitPicker("event_form_time_start")
            commitPicker("event_form_time_end")
        }
        step("Continuer") { next() }

        step("Étape 3 : en ligne") {
            tap("event_form_mode_online")
            type("https://www.entourage.social/", into: "event_form_online_url")
            dismissKeyboard()
        }
        step("Continuer") { next() }

        step("Étape 4 : centre d'intérêt") { tap("event_form_interest_activites") }
        step("Continuer") { next() }

        // Étape « groupes » : seulement si l'utilisateur en a (aucun sur le faux backend).
        if element("form_flow_next").label.lowercased().contains("continuer") { step("Continuer") { next() } }
        step("Publier") { next() }

        let request = waitForRequest("POST outings")
        let event = request?.body["outing"] as? [String: Any]
        XCTAssertEqual(event?["title"] as? String, "Unit test Event 1")
        XCTAssertEqual(event?["online"] as? Bool, true)
        XCTAssertEqual(event?["event_url"] as? String, "https://www.entourage.social/")
        XCTAssertEqual(event?["interests"] as? [String], ["activites"])
        XCTAssertEqual(event?["entourage_image_id"] as? Int, 32)
        let metadata = event?["metadata"] as? [String: Any]
        XCTAssertNotNil(metadata?["starts_at"], "La date de début doit être envoyée")
        XCTAssertNotNil(metadata?["ends_at"], "La date de fin doit être envoyée")

        XCTAssertTrue(element("creation_end_title").waitForExistence(timeout: 10), "L'écran de confirmation doit s'afficher")
        screenshot("Confirmation")
    }

    /// Règle les roues jour / mois / année de la roue de date ouverte (ordre local : jour, mois, année).
    private func setDateWheels(to date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d"
        let day = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: date).capitalized(with: formatter.locale)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)

        let wheels = app.pickerWheels
        XCTAssertTrue(wheels.firstMatch.waitForExistence(timeout: 5), "La roue de date doit s'afficher")
        XCTAssertEqual(wheels.count, 3, "Jour, mois et année attendus")
        wheels.element(boundBy: 0).adjust(toPickerWheelValue: day)
        wheels.element(boundBy: 1).adjust(toPickerWheelValue: month)
        wheels.element(boundBy: 2).adjust(toPickerWheelValue: year)
    }

    // MARK: - Conversation

    /// Équivalent iOS de `ConversationScenarioTest.envoiDunMessage` : ouvrir la discussion, écrire, envoyer.
    func testSendMessageInConversation() throws {
        launchApp()
        step("Onglet Discussions") { tab(2) }

        step("Ouvrir la conversation") {
            let row = app.staticTexts["Jean M."].firstMatch
            XCTAssertTrue(row.waitForExistence(timeout: 15), "La conversation de test doit être listée")
            row.tap()
        }
        XCTAssertTrue(app.staticTexts["Bonjour, comment ça va ?"].firstMatch.waitForExistence(timeout: 10),
                      "Le message reçu doit être affiché")

        step("Écrire un message") { type("Unit test message 1", into: "conversation_input") }
        step("Envoyer") { tap("conversation_send") }

        let request = waitForRequest("POST conversations/301/chat_messages")
        let content = (request?.body["chat_message"] as? [String: Any])?["content"] as? String ?? ""
        XCTAssertTrue(content.contains("Unit test message 1"), "Le corps envoyé doit contenir le message, reçu : \(content)")

        XCTAssertTrue(app.staticTexts["Unit test message 1"].firstMatch.waitForExistence(timeout: 10), "Le message envoyé doit apparaître")
        screenshot("Message affiché")
    }
}
