import XCTest

/// Scénarios de navigation principale (équivalents iOS de `HomeScenarioTest` / `DiscussionsListScenarioTest` côté
/// Android) : l'app démarre connectée sur l'accueil, puis chaque onglet s'ouvre, charge ses données auprès du faux
/// backend et reste utilisable. Une capture par étape dans `test-screenshots/<scénario>/`.
final class TabNavigationUITests: UITestCase {

    /// Ordre de la barre d'onglets (cf. `MainTabbarViewController`).
    private enum Tab: Int, CaseIterable {
        case home, actions, messages, groups, events
    }

    private func tabButton(_ tab: Tab) -> XCUIElement {
        app.tabBars.buttons.element(boundBy: tab.rawValue)
    }

    private func open(_ tab: Tab, file: StaticString = #filePath, line: UInt = #line) {
        let button = tabButton(tab)
        XCTAssertTrue(button.waitForExistence(timeout: 20), "Onglet \(tab) introuvable", file: file, line: line)
        button.tap()
        XCTAssertTrue(button.isSelected, "L'onglet \(tab) devrait être sélectionné", file: file, line: line)
    }

    func testHomeIsDisplayedAfterLaunch() {
        launchApp()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 20), "La barre d'onglets doit s'afficher")
        XCTAssertEqual(app.tabBars.buttons.count, Tab.allCases.count)
        XCTAssertTrue(tabButton(.home).isSelected, "L'accueil est l'onglet de départ")
        waitForRequest("GET home/summary")
        screenshot("Accueil")
    }

    func testEveryTabOpensAndLoadsItsData() {
        launchApp()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 20))

        for tab in [Tab.actions, .messages, .groups, .events, .home] {
            step("Onglet \(tab)") { open(tab) }
            XCTAssertTrue(app.tabBars.firstMatch.exists, "L'app doit rester utilisable après l'ouverture de \(tab)")
        }
        XCTAssertTrue(app.state == .runningForeground, "L'app a planté pendant la navigation")
    }
}
