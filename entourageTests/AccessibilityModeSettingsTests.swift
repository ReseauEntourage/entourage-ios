import XCTest
@testable import entourage

/// Règles du réglage « Contraste amélioré » (mêmes cas que `AccessibilityModeSettings` côté Android) :
/// tri-état par compte, activation automatique avec VoiceOver, choix de l'utilisateur prioritaire.
final class AccessibilityModeSettingsTests: XCTestCase {

    private var suiteName: String!
    private var store: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "tests.accessibility.\(UUID().uuidString)"
        store = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        store.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func settings(user: Int = 1, voiceOver: Bool = false) -> AccessibilityModeSettings {
        AccessibilityModeSettings(userId: user, store: store, screenReaderActive: { voiceOver })
    }

    func testNoChoiceByDefault() {
        let settings = settings()
        XCTAssertEqual(settings.choice, .unset)
        XCTAssertFalse(settings.isHighContrastEnabled)
    }

    func testExplicitChoicesArePersisted() {
        settings().setHighContrast(true)
        XCTAssertEqual(settings().choice, .enabled)
        XCTAssertTrue(settings().isHighContrastEnabled)

        settings().setHighContrast(false)
        XCTAssertEqual(settings().choice, .disabled)
        XCTAssertFalse(settings().isHighContrastEnabled)
    }

    func testChoiceIsPerAccount() {
        settings(user: 1).setHighContrast(true)
        XCTAssertEqual(settings(user: 2).choice, .unset)
        XCTAssertFalse(settings(user: 2).isHighContrastEnabled)
        settings(user: 2).setHighContrast(false)
        XCTAssertTrue(settings(user: 1).isHighContrastEnabled)
    }

    func testVoiceOverActivatesTheModeWhenNoChoiceIsStored() {
        let enabled = settings(voiceOver: true).refresh(available: true)
        XCTAssertTrue(enabled)
        XCTAssertEqual(settings().choice, .enabled, "l'activation automatique est enregistrée pour le compte")
    }

    func testVoiceOverNeverReactivatesAModeTheUserDisabled() {
        settings().setHighContrast(false)
        XCTAssertFalse(settings(voiceOver: true).refresh(available: true))
        XCTAssertEqual(settings().choice, .disabled)
    }

    func testNoVoiceOverNeverDisablesAnEnabledMode() {
        settings().setHighContrast(true)
        XCTAssertTrue(settings(voiceOver: false).refresh(available: true))
        XCTAssertEqual(settings().choice, .enabled)
    }

    func testWithoutVoiceOverNoChoiceStaysUnset() {
        XCTAssertFalse(settings(voiceOver: false).refresh(available: true))
        XCTAssertEqual(settings().choice, .unset)
    }

    func testRefreshIsIdempotent() {
        let settings = settings(voiceOver: true)
        settings.refresh(available: true)
        settings.refresh(available: true)
        XCTAssertEqual(settings.choice, .enabled)
    }

    func testNothingIsWrittenWhileTheModeIsNotAvailable() {
        XCTAssertFalse(settings(voiceOver: true).refresh(available: false))
        XCTAssertEqual(settings().choice, .unset, "aucune activation automatique tant que le moteur de palette n'est pas livré")
    }

    func testTheModeIsOffUntilTheContrastEngineShips() {
        XCTAssertFalse(AccessibilityModeSettings.isContrastModeAvailable)
    }
}
