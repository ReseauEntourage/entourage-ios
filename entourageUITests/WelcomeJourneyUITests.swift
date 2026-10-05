import XCTest

/// Scénarios end-to-end du parcours de bienvenue (EN-9653).
///
/// Chaque scénario part d'un `home/summary` en fake data, clique comme un utilisateur, vérifie
/// ce qui est affiché ET ce qui est réellement envoyé au backend (faux), et laisse une capture par étape
/// dans `test-screenshots/<scénario>/`.
final class WelcomeJourneyUITests: UITestCase {

    private var journey: WelcomeJourneyScreen { WelcomeJourneyScreen(app: app) }

    private let skipRoute = "POST users/onboarding_step_skipped"

    // Contrat backend, écrit en dur : `step` attendu pour chaque étape.
    private let skipApiStep: [WelcomeJourneyScreen.Step: String] = [
        .video: "welcome_watched",
        .national: "neighborhood_national",
        .webinar: "webinar_or_first_steps",
        .papotages: "papotages"
    ]

    // Contrat : l'ouverture d'une étape doit appeler ce endpoint.
    private let routeOpenedByStep: [WelcomeJourneyScreen.Step: String] = [
        .video: "GET resources/welcome",
        .national: "GET neighborhoods/national",
        .webinar: "GET outings/firsts_steps",
        .papotages: "GET outings/papotages"
    ]

    // MARK: - Affichage

    func testFirstDisplayEverythingIsAccessible() {
        launchApp(events: [])
        XCTAssertTrue(journey.waitUntilVisible(), "Le parcours de bienvenue doit s'afficher")
        screenshot("Accueil – parcours au premier affichage")

        for step in WelcomeJourneyScreen.Step.allCases {
            XCTAssertEqual(journey.state(of: step), .todo, "\(step) doit être à faire")
            journey.scrollTo(journey.ctaButton(step))
            XCTAssertTrue(journey.ctaButton(step).isHittable, "\(step) : bouton principal inaccessible (étape verrouillée ?)")
            XCTAssertTrue(journey.skipButton(step).exists, "\(step) : « Passer cette étape » manquant")
        }
        screenshot("Dernière étape accessible sans avoir fait les précédentes")
    }

    func testResumeFromSummaryShowsDoneSkippedAndTodo() {
        launchApp(events: [
            "onboarding.resource.welcome_watched",
            "onboarding.neighborhood.national_skipped"
        ])
        XCTAssertTrue(journey.waitUntilVisible())

        XCTAssertEqual(journey.state(of: .video), .done)
        XCTAssertEqual(journey.state(of: .national), .skipped)
        XCTAssertEqual(journey.state(of: .webinar), .todo)
        XCTAssertEqual(journey.state(of: .papotages), .todo)
        XCTAssertEqual(journey.counter.label, "1/4", "Seule l'étape réellement faite compte dans la progression")
        XCTAssertTrue(journey.redoButton(.national).exists, "« Découvrir cette étape » attendu sur l'étape passée")
        XCTAssertFalse(journey.skipButton(.video).exists, "Pas de « Passer » sur une étape terminée")
        screenshot("Une étape faite, une passée")
    }

    // MARK: - « Passer cette étape » : une étape = un scénario

    func testSkipVideoStep() { assertSkipping(.video) }
    func testSkipNationalGroupsStep() { assertSkipping(.national) }
    func testSkipWebinarStep() { assertSkipping(.webinar) }
    func testSkipPapotagesStep() { assertSkipping(.papotages) }

    private func assertSkipping(_ step: WelcomeJourneyScreen.Step, file: StaticString = #filePath, line: UInt = #line) {
        launchApp(events: [])
        XCTAssertTrue(journey.waitUntilVisible(), file: file, line: line)
        screenshot("Avant de passer \(step.rawValue)")

        self.step("Tap sur Passer cette étape (\(step.rawValue))") {
            journey.skip(step)
            XCTAssertTrue(journey.waitForState(.skipped, of: step), "\(step) doit passer en « Passée »", file: file, line: line)
        }

        // Ce qui est parti au backend
        let sent = requests(matching: skipRoute)
        XCTAssertEqual(sent.count, 1, "Un seul appel de skip attendu", file: file, line: line)
        XCTAssertEqual(sent.first?.body["step"] as? String, skipApiStep[step], file: file, line: line)

        // Ce qui est affiché
        XCTAssertTrue(journey.redoButton(step).exists, file: file, line: line)
        XCTAssertFalse(journey.skipButton(step).exists, "Plus de « Passer » une fois l'étape passée", file: file, line: line)
        XCTAssertEqual(journey.counter.label, "0/4", "Passer une étape ne la compte pas comme terminée", file: file, line: line)
        for other in WelcomeJourneyScreen.Step.allCases where other != step {
            XCTAssertEqual(journey.state(of: other), .todo, "\(other) ne doit pas être impactée", file: file, line: line)
        }
    }

    /// Régression : le « Passer » doit s'afficher immédiatement, même si le serveur met 5 s à répondre.
    func testSkipIsInstantEvenWhenTheServerIsSlow() {
        launchApp(events: [], skipDelayMs: 5_000)
        XCTAssertTrue(journey.waitUntilVisible())

        let tapDate = Date()
        step("Passer l'étape vidéo avec un serveur lent") {
            journey.skip(.video)
            XCTAssertTrue(journey.waitForState(.skipped, of: .video, timeout: 1.5),
                          "L'étape doit passer en « Passée » sans attendre la réponse du serveur")
        }
        XCTAssertLessThan(Date().timeIntervalSince(tapDate), 4, "Le basculement ne doit pas dépendre du serveur")

        // La requête est bien partie, et l'état reste « Passée » quand le serveur finit par répondre.
        XCTAssertEqual(requests(matching: skipRoute).first?.body["step"] as? String, "welcome_watched")
        RunLoop.current.run(until: Date().addingTimeInterval(6))
        XCTAssertEqual(journey.state(of: .video), .skipped)
        XCTAssertEqual(requests(matching: skipRoute).count, 1)
    }

    func testSkippingEveryStepEndsTheJourney() {
        launchApp(events: [])
        XCTAssertTrue(journey.waitUntilVisible())

        for step in WelcomeJourneyScreen.Step.allCases {
            self.step("Passer \(step.rawValue)") {
                journey.skip(step)
                if step != .papotages {
                    XCTAssertTrue(journey.waitForState(.skipped, of: step))
                }
            }
        }

        // Tout a été passé : plus d'étapes et pas d'encart vert de réussite.
        let gone = NSPredicate(format: "exists == false")
        wait(for: [expectation(for: gone, evaluatedWith: journey.card(.video))], timeout: 10)
        XCTAssertFalse(journey.successBanner.exists, "Pas d'encart de réussite quand les étapes ont été passées")
        XCTAssertEqual(requests(matching: skipRoute).compactMap { $0.body["step"] as? String },
                       ["welcome_watched", "neighborhood_national", "webinar_or_first_steps", "papotages"])
        screenshot("Parcours terminé")
    }

    // MARK: - Clics et vues : chaque étape ouvre le bon écran / appelle le bon endpoint

    func testTapVideoStepOpensWelcomeVideo() { assertOpening(.video) }
    func testTapNationalGroupsStepOpensGroupsList() { assertOpening(.national) }
    func testTapWebinarStepOpensFirstStepsEvents() { assertOpening(.webinar) }
    func testTapPapotagesStepOpensPapotagesEvents() { assertOpening(.papotages) }

    private func assertOpening(_ step: WelcomeJourneyScreen.Step, file: StaticString = #filePath, line: UInt = #line) {
        launchApp(events: [])
        XCTAssertTrue(journey.waitUntilVisible(), file: file, line: line)

        self.step("Tap sur le bouton principal (\(step.rawValue))") {
            journey.tapCTA(step)
            let route = routeOpenedByStep[step]!
            XCTAssertNotNil(waitForRequest(route), file: file, line: line)
        }

        // Ouvrir une étape ne la saute ni ne la termine.
        XCTAssertTrue(requests(matching: skipRoute).isEmpty, "Ouvrir une étape ne doit pas la passer", file: file, line: line)
        // Et un seul endpoint d'étape est appelé : pas de fuite vers une autre étape.
        let otherRoutes = routeOpenedByStep.filter { $0.key != step }.map(\.value)
        for route in otherRoutes {
            XCTAssertTrue(requests(matching: route).isEmpty, "\(route) ne devrait pas être appelé en ouvrant \(step)", file: file, line: line)
        }
    }

    func testWatchingTheVideoMarksTheStepDone() {
        launchApp(events: [])
        XCTAssertTrue(journey.waitUntilVisible())

        step("Ouvrir la vidéo") { journey.tapCTA(.video) }
        waitForRequest("GET resources/welcome")

        let continueButton = app.buttons["Continuer"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 10), "Bouton « Continuer » de la vidéo")
        step("Continuer après la vidéo") {
            // Le bouton peut être grisé quelques secondes tant que la vidéo n'est pas « vue ».
            let enabled = NSPredicate(format: "isEnabled == true")
            wait(for: [expectation(for: enabled, evaluatedWith: continueButton)], timeout: 15)
            continueButton.tap()
        }

        XCTAssertNotNil(waitForRequest("POST resources/4242/users"))
        XCTAssertTrue(journey.waitUntilVisible())
        XCTAssertTrue(journey.waitForState(.done, of: .video, timeout: 15))
        XCTAssertEqual(journey.counter.label, "1/4")
        XCTAssertTrue(requests(matching: skipRoute).isEmpty)
        screenshot("Vidéo terminée")
    }

    func testRediscoverASkippedStepOpensItWithoutChangingItsState() {
        launchApp(events: ["onboarding.outing.papotages_skipped"])
        XCTAssertTrue(journey.waitUntilVisible())
        journey.scrollTo(journey.redoButton(.papotages))

        step("Découvrir cette étape (papotages)") { journey.redoButton(.papotages).tap() }
        XCTAssertNotNil(waitForRequest("GET outings/papotages"))
        XCTAssertTrue(requests(matching: skipRoute).isEmpty)
    }

    // MARK: - Tableau debug (long click sur le logo)

    func testDebugPanelListsTheWholeJourneyAndFollowsEachClick() {
        launchApp(events: ["onboarding.resource.welcome_watched"])
        XCTAssertTrue(journey.waitUntilVisible())

        step("Long click sur le logo") { journey.toggleDebugPanel() }
        XCTAssertTrue(journey.debugRow(.video).waitForExistence(timeout: 5), "Le tableau debug doit s'afficher")
        for debugStep in WelcomeJourneyScreen.Step.allCases {
            XCTAssertTrue(journey.debugRow(debugStep).exists, "\(debugStep) absent du tableau debug")
        }
        XCTAssertTrue((journey.debugRow(.video).value as? String ?? "").contains("terminée"))
        XCTAssertTrue((journey.debugRow(.webinar).value as? String ?? "").contains("à faire"))

        // L'étape « groupes » reste visible au-dessus du tableau (qui recouvre le bas de l'écran).
        step("Passer l'étape groupes") {
            journey.skip(.national)
            XCTAssertTrue(journey.waitForState(.skipped, of: .national))
        }

        let row = journey.debugRow(.national)
        let updated = NSPredicate(format: "value CONTAINS 'passée'")
        wait(for: [expectation(for: updated, evaluatedWith: row)], timeout: 10)
    }
}
