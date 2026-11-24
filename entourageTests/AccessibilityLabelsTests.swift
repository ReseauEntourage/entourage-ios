import XCTest
@testable import entourage

/// Noms vocaux (VoiceOver) : `String.a11y` ne lit jamais une clé brute, et `UIView.a11yKey`
/// (attribut d'exécution posé dans les xib/storyboards) pose bien le libellé.
final class AccessibilityLabelsTests: XCTestCase {

    func testKnownKeyIsLocalizedAndNotTheRawKey() {
        let label = "a11y_close".a11y
        XCTAssertFalse(label.isEmpty)
        XCTAssertNotEqual(label, "a11y_close", "la clé brute ne doit jamais être lue à voix haute")
    }

    func testMissingKeyNeverReturnsTheRawKey() {
        XCTAssertEqual("a11y_unknown_key_for_test".a11y, "")
    }

    func testA11yKeySetsLabelAndMakesTheViewAnAccessibilityElement() {
        let button = UIButton(type: .custom)
        button.setValue("a11y_close", forKeyPath: "a11yKey")   // ce que fait Interface Builder au chargement
        XCTAssertTrue(button.isAccessibilityElement)
        XCTAssertEqual(button.accessibilityLabel, "a11y_close".a11y)
        XCTAssertFalse((button.accessibilityLabel ?? "").isEmpty)
    }

    func testEmptyA11yKeyLeavesTheViewUntouched() {
        let view = UIView()
        view.setValue("", forKeyPath: "a11yKey")
        XCTAssertNil(view.accessibilityLabel)
        XCTAssertFalse(view.isAccessibilityElement)
    }
}
