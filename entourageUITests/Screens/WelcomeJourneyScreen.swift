import XCTest

/// Page object du parcours de bienvenue sur l'accueil.
/// Les identifiants viennent de `HomeWelcomeJourneyView` (`welcome_step_<id>`, `_cta`, `_skip`, `_redo`).
struct WelcomeJourneyScreen {

    enum Step: String, CaseIterable {
        case video, national, webinar, papotages
    }

    /// État exposé par chaque carte (accessibilityValue) : todo / done / skipped.
    enum State: String {
        case todo, done, skipped
    }

    let app: XCUIApplication

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }

    // MARK: - Éléments

    func card(_ step: Step) -> XCUIElement { element("welcome_step_\(step.rawValue)") }
    func ctaButton(_ step: Step) -> XCUIElement { app.buttons["welcome_step_\(step.rawValue)_cta"] }
    func skipButton(_ step: Step) -> XCUIElement { app.buttons["welcome_step_\(step.rawValue)_skip"] }
    func redoButton(_ step: Step) -> XCUIElement { app.buttons["welcome_step_\(step.rawValue)_redo"] }

    var counter: XCUIElement { element("welcome_journey_counter") }
    var successBanner: XCUIElement { element("welcome_journey_success") }

    // MARK: - Lecture

    func state(of step: Step) -> State? {
        (card(step).value as? String).flatMap(State.init(rawValue:))
    }

    // MARK: - Actions

    /// Attend l'affichage du parcours (le summary fake data doit être chargé).
    @discardableResult
    func waitUntilVisible(timeout: TimeInterval = 20) -> Bool {
        card(.video).waitForExistence(timeout: timeout) || successBanner.waitForExistence(timeout: 1)
    }

    /// Fait défiler l'accueil jusqu'à ce que l'élément soit touchable.
    func scrollTo(_ target: XCUIElement, maxSwipes: Int = 8) {
        var swipes = 0
        while !(target.exists && target.isHittable) && swipes < maxSwipes {
            app.swipeUp()
            swipes += 1
        }
    }

    /// Attend qu'une carte atteigne l'état attendu.
    @discardableResult
    func waitForState(_ expected: State, of step: Step, timeout: TimeInterval = 10) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if state(of: step) == expected { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline
        return state(of: step) == expected
    }

    func skip(_ step: Step) {
        let button = skipButton(step)
        scrollTo(button)
        button.tap()
    }

    func tapCTA(_ step: Step) {
        let button = ctaButton(step)
        scrollTo(button)
        button.tap()
    }

    // MARK: - Tableau debug (long click sur le logo)

    var logo: XCUIElement { element("home_logo") }

    func toggleDebugPanel() {
        logo.press(forDuration: 1.2)
    }

    func debugRow(_ step: Step) -> XCUIElement { element("welcome_debug_row_\(step.rawValue)") }
}
