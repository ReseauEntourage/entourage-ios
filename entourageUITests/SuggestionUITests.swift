import XCTest

/// Zone « Votre prochain pas » de la home (EN-9473) sur le faux moteur du `StubBackend` : card hero, zone Autres,
/// « Pourquoi », « Plus tard » / « Annuler », enchaînement avec le moteur. Une capture par étape.
///
/// Le parcours de bienvenue masque la zone : on le fait disparaître avec les quatre étapes déjà passées.
final class SuggestionUITests: UITestCase {

    private let welcomeDone = [
        "onboarding.resource.welcome_watched_skipped", "onboarding.neighborhood.national_skipped",
        "onboarding.outing.webinar_or_first_steps_skipped", "onboarding.outing.papotages_skipped"
    ]
    private let firstTitle = "Café solidaire du 11e"
    private let secondTitle = "Papotage du jeudi"
    private let otherOutingRow = "suggestion_explorer_others-outing-701"
    private let otherGroupRow = "suggestion_explorer_others-neighborhood-702"

    private func launch(_ scenario: String) {
        launchApp(events: welcomeDone, suggestions: scenario)
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 20), "La barre d'onglets doit s'afficher")
    }

    private var zoneTitle: XCUIElement { app.staticTexts["Une idée de rencontre pour vous"] }
    private var explorerTitle: XCUIElement { app.staticTexts["D'autres occasions de se retrouver"] }
    private var primary: XCUIElement { app.buttons["suggestion_primary_button"] }
    private var later: XCUIElement { app.buttons["suggestion_later_button"] }
    private var info: XCUIElement { app.buttons["suggestion_info_button"] }
    private var undo: XCUIElement { app.buttons["suggestion_undo_button"] }

    private func anyElement(_ id: String) -> XCUIElement { app.descendants(matching: .any)[id].firstMatch }

    private func cardTitle(_ title: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", title)).firstMatch
    }

    /// Fait défiler la home jusqu'à ce que l'élément soit à l'écran.
    private func scrollToVisible(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        var tries = 0
        while !(element.exists && element.isHittable) && tries < 6 {
            app.swipeUp()
            tries += 1
        }
        XCTAssertTrue(element.exists && element.isHittable, "Élément hors écran : \(element)", file: file, line: line)
    }

    private func waitUntilGone(_ element: XCUIElement, timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: timeout), .completed, "Toujours affiché : \(element)", file: file, line: line)
    }

    private func waitForCount(_ signature: String, _ count: Int, timeout: TimeInterval = 15,
                              file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        while requests(matching: signature).count < count && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        XCTAssertGreaterThanOrEqual(requests(matching: signature).count, count, "\(signature) attendu \(count) fois. Envoyées : \(sentRequests.map(\.signature))",
                                    file: file, line: line)
    }

    // MARK: - Affichage

    func testHeroCardAndExplorerAreDisplayed() {
        launch("full")

        XCTAssertTrue(zoneTitle.waitForExistence(timeout: 20), "Titre de la zone")
        XCTAssertTrue(cardTitle(firstTitle).waitForExistence(timeout: 5), "Titre de la card")
        XCTAssertTrue(primary.exists, "Bouton d'action")
        XCTAssertTrue(later.exists, "Bouton « Plus tard »")
        XCTAssertTrue(info.exists, "Bouton « Pourquoi »")
        screenshot("Card hero")
        XCTAssertEqual(requests(matching: "GET next_steps/current").count, 1)
        XCTAssertEqual(requests(matching: "GET next_steps/others").count, 1)

        scrollToVisible(anyElement(otherOutingRow))
        XCTAssertTrue(explorerTitle.exists, "Titre de la zone Autres")
        XCTAssertTrue(anyElement(otherGroupRow).exists, "Seconde ligne de la zone Autres")
        screenshot("Zone Autres")
        // La mesure « affiché » part vers le moteur.
        waitForRequest("POST next_steps/interactions")
    }

    func testTapOnAnExplorerRowOpensTheTrack() {
        launch("full")
        let row = anyElement(otherOutingRow)
        XCTAssertTrue(zoneTitle.waitForExistence(timeout: 20))
        scrollToVisible(row)
        screenshot("Avant le tap")

        row.tap()
        waitForRequest("GET outings/701")
        screenshot("Événement ouvert")
        let tapped = requests(matching: "POST next_steps/interactions").contains {
            ($0.body["interaction"] as? [String: Any])?["kind"] as? String == "tapped"
        }
        XCTAssertTrue(tapped, "Le tap est transmis au moteur")
    }

    func testWhyButtonOpensTheExplanationSheet() {
        launch("full")
        XCTAssertTrue(info.waitForExistence(timeout: 20))

        info.tap()
        XCTAssertTrue(app.staticTexts["Pourquoi cet événement ?"].waitForExistence(timeout: 5), "Titre de la feuille")
        XCTAssertTrue(app.staticTexts["C'est près de chez vous."].exists, "Phrase du moteur")
        screenshot("Feuille Pourquoi")

        app.buttons["suggestion_why_close_button"].tap()
        waitUntilGone(app.buttons["suggestion_why_close_button"])
        XCTAssertTrue(primary.waitForExistence(timeout: 5), "On revient à la home")
        screenshot("Feuille fermée")
    }

    // MARK: - « Plus tard »

    func testLaterRemovesTheCardAndUndoBringsItBack() {
        launch("full")
        XCTAssertTrue(later.waitForExistence(timeout: 20))

        later.tap()
        XCTAssertTrue(undo.waitForExistence(timeout: 5), "Message avec « Annuler »")
        XCTAssertEqual(app.staticTexts["Suggestion mise de côté. Nous ne vous la proposerons pas tout de suite."].exists, true)
        XCTAssertFalse(primary.exists, "La card est retirée tout de suite")
        screenshot("Plus tard")

        undo.tap()
        XCTAssertTrue(cardTitle(firstTitle).waitForExistence(timeout: 5), "La card revient")
        XCTAssertTrue(primary.exists)
        screenshot("Après annulation")

        // Le message est parti : on laisse passer son délai, le moteur ne doit jamais être prévenu.
        RunLoop.current.run(until: Date().addingTimeInterval(7))
        XCTAssertTrue(requests(matching: "POST next_steps/11/ignore").isEmpty, "Annulé : aucun ignore")
        XCTAssertTrue(cardTitle(firstTitle).exists)
    }

    func testLaterWithoutUndoIgnoresAndShowsTheNextCard() {
        launch("full")
        XCTAssertTrue(later.waitForExistence(timeout: 20))

        later.tap()
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        XCTAssertTrue(requests(matching: "POST next_steps/11/ignore").isEmpty, "Pas d'ignore pendant le message")

        waitForRequest("POST next_steps/11/ignore", timeout: 15)
        XCTAssertTrue(cardTitle(secondTitle).waitForExistence(timeout: 10), "La suivante remplace la card")
        XCTAssertFalse(cardTitle(firstTitle).exists)
        XCTAssertEqual(requests(matching: "GET next_steps/current").count, 1, "La réponse portait la suivante : pas de relecture")
        screenshot("Suivante affichée")
    }

    func testIgnoreWithoutNextRereadsTheEngine() {
        launch("ignore_without_next")
        XCTAssertTrue(later.waitForExistence(timeout: 20))
        XCTAssertEqual(requests(matching: "GET next_steps/current").count, 1)

        later.tap()
        screenshot("Plus tard")
        waitForRequest("POST next_steps/11/ignore", timeout: 15)
        waitForCount("GET next_steps/current", 2)
        XCTAssertTrue(cardTitle(secondTitle).waitForExistence(timeout: 10), "La carte relue remplace l'ancienne")
        screenshot("Carte relue")
    }

    // MARK: - Moteur sans prochain pas, ou sans rien

    func testNoNextStepShowsTheExplorerAlone() {
        launch("explorer_only")

        let row = anyElement(otherOutingRow)
        XCTAssertTrue(row.waitForExistence(timeout: 20))
        scrollToVisible(row)
        XCTAssertTrue(explorerTitle.exists)
        XCTAssertFalse(zoneTitle.exists, "Pas de titre de card sans prochain pas")
        XCTAssertFalse(primary.exists)
        XCTAssertFalse(later.exists)
        screenshot("Zone Autres seule")
    }

    func testNoSuggestionShowsNothing() {
        launch("none")
        waitForRequest("GET next_steps/others")
        waitForRequest("GET next_steps/current")
        RunLoop.current.run(until: Date().addingTimeInterval(1))

        XCTAssertFalse(zoneTitle.exists)
        XCTAssertFalse(explorerTitle.exists)
        XCTAssertFalse(primary.exists)
        screenshot("Aucune suggestion")
    }
}
