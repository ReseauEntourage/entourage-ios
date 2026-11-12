import XCTest
@testable import entourage

/// Les liens de visio (Google Meet…) sont confiés au système (app Meet, sinon Safari),
/// jamais au navigateur embarqué (SFSafariViewController).
final class SystemOpenedLinksTests: XCTestCase {

    // MARK: - Liens Meet : ouverts par le système

    func testMeetLinksAreSystemOpened() {
        let links = [
            "https://meet.google.com/rzs-igyt-zpe",
            "https://meet.google.com/meet/rzs-igyt-zpe?authuser=0",
            "meet.google.com/rzs-igyt-zpe",
            "http://meet.google.com/rzs-igyt-zpe",
            "HTTPS://MEET.GOOGLE.COM/rzs-igyt-zpe",
            "  https://meet.google.com/rzs-igyt-zpe\n",
            "https://meet.google.com:443/rzs-igyt-zpe"
        ]
        for link in links {
            XCTAssertTrue(WebLinkManager.isSystemOpenedLink(link), link)
        }
    }

    func testURLOverloadMatchesStringOverload() {
        let url = URL(string: "https://meet.google.com/meet/rzs-igyt-zpe?authuser=0")!
        XCTAssertTrue(WebLinkManager.isSystemOpenedLink(url: url))
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink(url: URL(string: "https://example.org/page")!))
    }

    // MARK: - Hôtes qui ressemblent à Meet : jamais ouverts par le système

    func testLookalikeHostsAreNotSystemOpened() {
        let links = [
            "https://meet.google.com.evil.tld/rzs-igyt-zpe",
            "https://notmeet.google.com/rzs-igyt-zpe",
            "https://www.google.com/rzs-igyt-zpe",
            "https://docs.google.com/document/d/1",
            "https://meet.google.com@evil.tld/rzs-igyt-zpe",
            "https://evil.tld/meet.google.com/rzs-igyt-zpe",
            "https://evil.tld/?u=https://meet.google.com/rzs-igyt-zpe"
        ]
        for link in links {
            XCTAssertFalse(WebLinkManager.isSystemOpenedLink(link), link)
        }
    }

    func testNonHttpSchemesAreNotSystemOpened() {
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink("javascript://meet.google.com/%0Aalert(1)"))
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink("ftp://meet.google.com/rzs-igyt-zpe"))
    }

    // MARK: - Autres liens et entrées invalides

    func testOtherWebLinksAreNotSystemOpened() {
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink("https://www.entourage.social/app/actions/123"))
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink("https://example.org/page"))
    }

    func testNilEmptyOrInvalidInputIsNotSystemOpened() {
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink(nil))
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink(""))
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink("   "))
        XCTAssertFalse(WebLinkManager.isSystemOpenedLink("not a url"))
    }
}
