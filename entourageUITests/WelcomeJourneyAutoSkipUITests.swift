import XCTest

/// Règles automatiques du parcours de bienvenue (100 % front) :
/// - J14 : 14 jours sans connexion ;
/// - J30 : compte créé il y a 30 jours.
/// Dans les deux cas l'app envoie un skip par étape encore à faire, puis le parcours disparaît.
final class WelcomeJourneyAutoSkipUITests: UITestCase {

    private var journey: WelcomeJourneyScreen { WelcomeJourneyScreen(app: app) }

    private let skipRoute = "POST users/onboarding_step_skipped"
    private let allSteps = ["welcome_watched", "neighborhood_national", "webinar_or_first_steps", "papotages"]

    private func skippedSteps() -> [String] {
        requests(matching: skipRoute).compactMap { $0.body["step"] as? String }
    }

    /// Attend que `count` skips soient partis, puis que la home ait rechargé le summary.
    private func waitForSkips(count: Int, timeout: TimeInterval = 20,
                              file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        while skippedSteps().count < count && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        XCTAssertEqual(skippedSteps().count, count, "Nombre de skips envoyés", file: file, line: line)
        while requests(matching: "GET home/summary").count < 2 && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        XCTAssertGreaterThanOrEqual(requests(matching: "GET home/summary").count, 2, "La home doit se recharger après les skips",
                                    file: file, line: line)
    }

    /// Laisse à la home le temps de finir de charger (le summary est le dernier appel de la chaîne d'accueil).
    private func waitForHomeLoaded() {
        waitForRequest("GET home/summary")
        RunLoop.current.run(until: Date().addingTimeInterval(2))
    }

    // MARK: - J14

    func testReturningAfter14DaysSkipsEveryStep() {
        launchApp(events: [], lastConnectionDaysAgo: 14)

        waitForSkips(count: 4)
        XCTAssertEqual(skippedSteps().sorted(), allSteps.sorted())
        XCTAssertFalse(journey.card(.video).exists, "Le parcours doit disparaître une fois tout passé")
        XCTAssertFalse(journey.successBanner.exists, "Pas de message de réussite : l'utilisateur n'a rien fait")
        screenshot("Après 14 jours : parcours masqué")
    }

    func testReturningAfter13DaysChangesNothing() {
        launchApp(events: [], lastConnectionDaysAgo: 13)

        XCTAssertTrue(journey.waitUntilVisible())
        waitForHomeLoaded()
        XCTAssertTrue(skippedSteps().isEmpty, "13 jours : rien ne doit être passé")
        XCTAssertEqual(journey.state(of: .video), .todo)
        screenshot("Après 13 jours : parcours intact")
    }

    func testFirstConnectionChangesNothing() {
        launchApp(events: [])

        XCTAssertTrue(journey.waitUntilVisible())
        waitForHomeLoaded()
        XCTAssertTrue(skippedSteps().isEmpty)
    }

    func testOnlyPendingStepsAreSkippedAfter14Days() {
        launchApp(events: ["onboarding.resource.welcome_watched", "onboarding.neighborhood.national_skipped"],
                  lastConnectionDaysAgo: 14)

        waitForSkips(count: 2)
        XCTAssertEqual(skippedSteps().sorted(), ["papotages", "webinar_or_first_steps"])
        XCTAssertFalse(journey.card(.video).exists)
        screenshot("Seules les étapes restantes sont passées")
    }

    // MARK: - J30

    func testAccountOf30DaysSkipsEveryStep() {
        launchApp(events: [], accountAgeDays: 30)

        waitForSkips(count: 4)
        XCTAssertEqual(skippedSteps().sorted(), allSteps.sorted())
        XCTAssertFalse(journey.card(.video).exists)
        screenshot("Compte de 30 jours : parcours masqué")
    }

    func testAccountOf29DaysChangesNothing() {
        launchApp(events: [], accountAgeDays: 29)

        XCTAssertTrue(journey.waitUntilVisible())
        waitForHomeLoaded()
        XCTAssertTrue(skippedSteps().isEmpty, "29 jours : rien ne doit être passé")
        screenshot("Compte de 29 jours : parcours intact")
    }
}
