import XCTest
@testable import entourage

/// Règles J14 (14 jours sans connexion) et J30 (compte de 30 jours) qui passent tout le parcours de bienvenue.
final class WelcomeJourneyAutoSkipTests: XCTestCase {

    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private let now = Date(timeIntervalSince1970: 1_790_000_000)

    private func daysAgo(_ days: Int, extraSeconds: TimeInterval = 0) -> Date {
        now.addingTimeInterval(-Double(days) * 86_400 - extraSeconds)
    }

    private func reason(lastConnection: Date? = nil, accountCreation: Date? = nil) -> WelcomeJourneyAutoSkip.Reason? {
        WelcomeJourneyAutoSkip.reason(now: now, lastConnection: lastConnection, accountCreation: accountCreation, calendar: calendar)
    }

    // MARK: - J14 : dernière connexion

    func testNothingToSkipOnFirstConnection() {
        XCTAssertNil(reason(lastConnection: nil, accountCreation: nil))
    }

    func testRecentConnectionDoesNotSkip() {
        XCTAssertNil(reason(lastConnection: daysAgo(1)))
        XCTAssertNil(reason(lastConnection: daysAgo(13, extraSeconds: 86_399)))
    }

    func testFourteenDaysWithoutConnectionSkips() {
        XCTAssertEqual(reason(lastConnection: daysAgo(14)), .inactiveFor14Days)
        XCTAssertEqual(reason(lastConnection: daysAgo(40)), .inactiveFor14Days)
    }

    // MARK: - J30 : ancienneté du compte

    func testYoungAccountDoesNotSkip() {
        XCTAssertNil(reason(accountCreation: daysAgo(3)))
        XCTAssertNil(reason(accountCreation: daysAgo(29, extraSeconds: 86_399)))
    }

    func testThirtyDayOldAccountSkips() {
        XCTAssertEqual(reason(accountCreation: daysAgo(30)), .accountOlderThan30Days)
        XCTAssertEqual(reason(accountCreation: daysAgo(400)), .accountOlderThan30Days)
    }

    func testAccountAgeAppliesEvenWithRecentConnection() {
        XCTAssertEqual(reason(lastConnection: daysAgo(1), accountCreation: daysAgo(45)), .accountOlderThan30Days)
    }

    func testInactivityAppliesEvenWithYoungAccount() {
        XCTAssertEqual(reason(lastConnection: daysAgo(15), accountCreation: daysAgo(20)), .inactiveFor14Days)
    }

    // MARK: - Stockage de la dernière connexion

    func testLastConnectionIsStoredAndRead() throws {
        let suiteName = "welcome-autoskip-tests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        XCTAssertNil(WelcomeJourneyAutoSkip.lastConnection(defaults: defaults))

        WelcomeJourneyAutoSkip.recordConnection(at: now, defaults: defaults)

        XCTAssertEqual(WelcomeJourneyAutoSkip.lastConnection(defaults: defaults), now)
    }
}
