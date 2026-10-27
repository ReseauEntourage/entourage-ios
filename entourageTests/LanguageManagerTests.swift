import XCTest
@testable import entourage

/// Équivalent iOS de `LanguageManagerTest` (Android) : correspondance nom de langue → code et préférences persistées.
final class LanguageManagerTests: XCTestCase {

    private let languageKey = "selected_language"
    private let translatedKey = "isTranslatedByDefault"
    private var savedLanguage: Any?
    private var savedTranslated: Any?

    override func setUp() {
        super.setUp()
        let defaults = UserDefaults.standard
        savedLanguage = defaults.object(forKey: languageKey)
        savedTranslated = defaults.object(forKey: translatedKey)
        defaults.removeObject(forKey: languageKey)
        defaults.removeObject(forKey: translatedKey)
    }

    override func tearDown() {
        let defaults = UserDefaults.standard
        defaults.set(savedLanguage, forKey: languageKey)
        defaults.set(savedTranslated, forKey: translatedKey)
        super.tearDown()
    }

    func testMapLanguageToCodeCoversEverySupportedLanguage() {
        let expected = ["Français": "fr", "English": "en", "Deutsch": "de", "Español": "es",
                        "Polski": "pl", "Українська": "uk", "Română": "ro", "العربية": "ar"]
        for (name, code) in expected {
            XCTAssertEqual(LanguageManager.mapLanguageToCode(language: name), code, "\(name) devrait donner \(code)")
        }
    }

    func testMapLanguageToCodeFallsBackToFrenchForUnknownLanguage() {
        XCTAssertEqual(LanguageManager.mapLanguageToCode(language: "Unknown"), "fr")
        XCTAssertEqual(LanguageManager.mapLanguageToCode(language: ""), "fr")
    }

    func testLoadDefaultsToEnglishWhenNothingWasSaved() {
        XCTAssertEqual(LanguageManager.loadLanguageFromPreferences(), "en")
    }

    func testSaveThenLoadReturnsTheSavedCode() {
        LanguageManager.saveLanguageToPreferences(languageCode: "pl")
        XCTAssertEqual(LanguageManager.loadLanguageFromPreferences(), "pl")
    }

    func testTranslationIsEnabledByDefaultAndTheDefaultIsPersisted() {
        XCTAssertNil(UserDefaults.standard.object(forKey: translatedKey))
        XCTAssertTrue(LanguageManager.getTranslatedByDefaultValue())
        XCTAssertEqual(UserDefaults.standard.object(forKey: translatedKey) as? Bool, true)
    }

    func testTranslationChoiceIsKeptOnceSet() {
        UserDefaults.standard.set(false, forKey: translatedKey)
        XCTAssertFalse(LanguageManager.getTranslatedByDefaultValue())
    }
}
