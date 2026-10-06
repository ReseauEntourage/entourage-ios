import XCTest
@testable import entourage

/// EN-8022 : détection d'un numéro de téléphone français dans un message.
final class PhoneNumberDetectorTests: XCTestCase {

    func testDetectsSupportedFormats() {
        let numbers = [
            "06 12 34 56 78",
            "0612345678",
            "06.12.34.56.78",
            "06-12-34-56-78",
            "+33 6 12 34 56 78",
            "+33612345678",
            "0033612345678",
            "0033 6 12 34 56 78",
            "+33 (0)6 12 34 56 78",
            "01 23 45 67 89"
        ]
        for number in numbers {
            XCTAssertTrue(PhoneNumberDetector.containsPhoneNumber(number), number)
            XCTAssertTrue(PhoneNumberDetector.containsPhoneNumber("Appelle-moi au \(number) ce soir"), number)
        }
    }

    func testIgnoresTextWithoutPhoneNumber() {
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber(nil))
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber(""))
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber("Bonjour, on se voit à 18h30 ?"))
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber("J'ai 12 34 56 ans"))
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber("Code postal 75011"))
    }

    func testIgnoresNumbersThatAreTooLongOrNotFrench() {
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber("061234567890"))
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber("+44 7911 123456"))
        XCTAssertFalse(PhoneNumberDetector.containsPhoneNumber("00 12 34 56 78"))
    }

    func testFindFrenchPhoneNumbersReturnsRanges() {
        let text = "Appelle le 06 12 34 56 78 ou le +33 7 98 76 54 32 !"
        let found = PhoneNumberDetector.findFrenchPhoneNumbers(in: text).map { (text as NSString).substring(with: $0) }
        XCTAssertEqual(found, ["06 12 34 56 78", "+33 7 98 76 54 32"])
        XCTAssertEqual(PhoneNumberDetector.findFrenchPhoneNumbers(in: "0612345678").first, NSRange(location: 0, length: 10))
        XCTAssertTrue(PhoneNumberDetector.findFrenchPhoneNumbers(in: "rien à signaler").isEmpty)
        XCTAssertTrue(PhoneNumberDetector.findFrenchPhoneNumbers(in: nil).isEmpty)
    }
}
