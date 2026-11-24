import XCTest
@testable import entourage

/// Contrat de l'annonceur d'erreurs VoiceOver : annonce seulement si VoiceOver tourne et si le message n'est pas vide.
final class AccessibilityAnnouncerTests: XCTestCase {

    private var posted: [(UIAccessibility.Notification, String)] = []
    private var savedActive: (() -> Bool)!
    private var savedPost: ((UIAccessibility.Notification, Any?) -> Void)!

    override func setUp() {
        super.setUp()
        savedActive = AccessibilityAnnouncer.isVoiceOverActive
        savedPost = AccessibilityAnnouncer.post
        posted = []
        AccessibilityAnnouncer.post = { [unowned self] notification, argument in
            self.posted.append((notification, argument as? String ?? ""))
        }
    }

    override func tearDown() {
        AccessibilityAnnouncer.isVoiceOverActive = savedActive
        AccessibilityAnnouncer.post = savedPost
        super.tearDown()
    }

    func testAnnouncesTheMessageWhenVoiceOverIsRunning() {
        AccessibilityAnnouncer.isVoiceOverActive = { true }
        AccessibilityAnnouncer.announce("Le nom est obligatoire")
        XCTAssertEqual(posted.count, 1)
        XCTAssertEqual(posted.first?.0, .announcement)
        XCTAssertEqual(posted.first?.1, "Le nom est obligatoire")
    }

    func testAnnouncesNothingWhenVoiceOverIsOff() {
        AccessibilityAnnouncer.isVoiceOverActive = { false }
        AccessibilityAnnouncer.announce("Le nom est obligatoire")
        XCTAssertTrue(posted.isEmpty)
    }

    func testAnnouncesNothingForAnEmptyOrBlankMessage() {
        AccessibilityAnnouncer.isVoiceOverActive = { true }
        AccessibilityAnnouncer.announce(nil)
        AccessibilityAnnouncer.announce("")
        AccessibilityAnnouncer.announce("   \n ")
        XCTAssertTrue(posted.isEmpty)
    }

    func testTrimsTheMessage() {
        AccessibilityAnnouncer.isVoiceOverActive = { true }
        AccessibilityAnnouncer.announce("  Erreur réseau \n")
        XCTAssertEqual(posted.first?.1, "Erreur réseau")
    }

    func testAnnouncesOnTheMainThreadFromABackgroundThread() {
        AccessibilityAnnouncer.isVoiceOverActive = { true }
        let done = expectation(description: "annonce postée")
        AccessibilityAnnouncer.post = { _, _ in
            XCTAssertTrue(Thread.isMainThread)
            done.fulfill()
        }
        DispatchQueue.global().async { AccessibilityAnnouncer.announce("Erreur") }
        wait(for: [done], timeout: 2)
    }
}
