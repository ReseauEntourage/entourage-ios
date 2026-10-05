import XCTest
@testable import entourage

/// Vérifie, avec un faux backend (`StubBackend`), que les actions du parcours de bienvenue
/// envoient bien les bonnes requêtes et que le `home/summary` renvoyé repasse bien dans le view model.
final class WelcomeJourneyNetworkTests: XCTestCase {

    private var previousUser: User?

    override func setUp() {
        super.setUp()
        previousUser = UserDefaults.currentUser

        var user = User()
        user.sid = 1
        user.token = "unit-test-token"
        UserDefaults.currentUser = user

        StubBackend.shared.requestLogURL = nil
        StubBackend.shared.reset()
        NetworkManager.sharedInstance.setProtocolClasses([StubURLProtocol.self])
    }

    override func tearDown() {
        NetworkManager.sharedInstance.setProtocolClasses(nil)
        UserDefaults.currentUser = previousUser
        super.tearDown()
    }

    // MARK: - Helpers

    private func skip(step: String, file: StaticString = #filePath, line: UInt = #line) {
        let done = expectation(description: "skip \(step)")
        HomeService.postOnboardingStepSkipped(step: step) { error in
            XCTAssertNil(error, file: file, line: line)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    private func fetchSummary() -> UserHome? {
        let done = expectation(description: "summary")
        var result: UserHome?
        HomeService.getUserHome { userHome, _ in
            result = userHome
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        return result
    }

    // MARK: - "Passer cette étape"

    func testSkipSendsPostWithTheExpectedStepForEachStepType() {
        let expectedSteps: [(type: WelcomeJourneyStepType, step: String)] = [
            (.video, "welcome_watched"),
            (.nationalGroups, "neighborhood_national"),
            (.webinar, "webinar_or_first_steps"),
            (.papotages, "papotages")
        ]

        for expected in expectedSteps {
            StubBackend.shared.reset()
            skip(step: expected.type.skipApiStep)

            let requests = StubBackend.shared.requests
            XCTAssertEqual(requests.count, 1, "\(expected.type)")
            XCTAssertEqual(requests.first?.signature, "POST users/onboarding_step_skipped", "\(expected.type)")
            XCTAssertEqual(requests.first?.body["step"] as? String, expected.step, "\(expected.type)")
        }
    }

    func testSkippedStepComesBackAsSkippedInSummary() {
        skip(step: WelcomeJourneyStepType.webinar.skipApiStep)

        let summary = fetchSummary()
        XCTAssertEqual(summary?.events, ["onboarding.outing.webinar_or_first_steps_skipped"])

        var initial: Bool? = nil
        let viewModel = WelcomeJourneyViewModel()
        viewModel.update(with: summary?.events, groupCount: 0, hasInitiallyCompletedAll: &initial)

        let webinar = viewModel.steps.first { $0.type == .webinar }
        XCTAssertEqual(webinar?.state, .skipped)
        XCTAssertEqual(viewModel.completedCount, 0)
        XCTAssertEqual(viewModel.steps.filter { $0.state == .active }.count, 3)
    }

    func testSkippingEveryStepResolvesTheJourney() {
        for type in WelcomeJourneyStepType.allCases {
            skip(step: type.skipApiStep)
        }

        var initial: Bool? = false
        let viewModel = WelcomeJourneyViewModel()
        viewModel.update(with: fetchSummary()?.events, groupCount: 0, hasInitiallyCompletedAll: &initial)

        // Tout a été passé : le parcours disparaît, sans encart de réussite.
        XCTAssertTrue(viewModel.hideEntirely)
        XCTAssertFalse(viewModel.isFullyCompleted)
    }

    func testSkipIsReportedAsErrorWhenBackendRejectsTheStep() {
        let done = expectation(description: "invalid step")
        HomeService.postOnboardingStepSkipped(step: "not_a_real_step") { error in
            XCTAssertNotNil(error)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)

        XCTAssertTrue(StubBackend.shared.events.isEmpty)
    }

    // MARK: - Summary / fake data

    func testSummaryFakeDataIsParsedIntoEvents() {
        StubBackend.shared.reset(events: [
            "onboarding.resource.welcome_watched",
            "onboarding.neighborhood.national_skipped"
        ])

        let summary = fetchSummary()
        XCTAssertEqual(summary?.events, [
            "onboarding.resource.welcome_watched",
            "onboarding.neighborhood.national_skipped"
        ])
        XCTAssertEqual(StubBackend.shared.requests.map(\.signature), ["GET home/summary"])
    }

    func testWatchingTheWelcomeVideoPostsTheResourceRead() throws {
        let resource = expectation(description: "welcome resource")
        var resourceId: Int?
        HomeService.getWelcomeResource { pedago, _ in
            resourceId = pedago?.id
            resource.fulfill()
        }
        wait(for: [resource], timeout: 5)

        let id = try XCTUnwrap(resourceId)

        let read = expectation(description: "resource read")
        HomeService.postResourceRead(resourceId: id) { error in
            XCTAssertNil(error)
            read.fulfill()
        }
        wait(for: [read], timeout: 5)

        XCTAssertEqual(StubBackend.shared.requests.map(\.signature),
                       ["GET resources/welcome", "POST resources/\(id)/users"])
        XCTAssertEqual(fetchSummary()?.events, ["onboarding.resource.welcome_watched"])
    }
}
