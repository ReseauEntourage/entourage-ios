import XCTest
@testable import entourage

/// Logique pure du parcours de bienvenue : état de chaque étape selon les events de `home/summary`.
/// Les noms d'events sont écrits en dur (contrat backend) pour détecter toute régression de mapping.
final class WelcomeJourneyViewModelTests: XCTestCase {

    private enum Event {
        static let video = "onboarding.resource.welcome_watched"
        static let national = "onboarding.neighborhood.national"
        static let webinar = "onboarding.outing.webinar_or_first_steps"
        static let papotages = "onboarding.outing.papotages"
    }

    private func makeViewModel(events: [String]?, initiallyAllResolved: Bool? = nil) -> WelcomeJourneyViewModel {
        var initial = initiallyAllResolved
        let viewModel = WelcomeJourneyViewModel()
        viewModel.update(with: events, groupCount: 0, hasInitiallyCompletedAll: &initial)
        return viewModel
    }

    private func states(_ viewModel: WelcomeJourneyViewModel) -> [WelcomeJourneyStepType: WelcomeJourneyStepState] {
        Dictionary(uniqueKeysWithValues: viewModel.steps.map { ($0.type, $0.state) })
    }

    // MARK: - Contrat backend

    func testEventNamesMatchBackendContract() {
        XCTAssertEqual(WelcomeJourneyStepType.video.completedEvent, Event.video)
        XCTAssertEqual(WelcomeJourneyStepType.nationalGroups.completedEvent, Event.national)
        XCTAssertEqual(WelcomeJourneyStepType.webinar.completedEvent, Event.webinar)
        XCTAssertEqual(WelcomeJourneyStepType.papotages.completedEvent, Event.papotages)

        XCTAssertEqual(WelcomeJourneyStepType.video.skippedEvent, "onboarding.resource.welcome_watched_skipped")
        XCTAssertEqual(WelcomeJourneyStepType.nationalGroups.skippedEvent, "onboarding.neighborhood.national_skipped")
        XCTAssertEqual(WelcomeJourneyStepType.webinar.skippedEvent, "onboarding.outing.webinar_or_first_steps_skipped")
        XCTAssertEqual(WelcomeJourneyStepType.papotages.skippedEvent, "onboarding.outing.papotages_skipped")
    }

    func testSkipApiStepsMatchBackendContract() {
        XCTAssertEqual(WelcomeJourneyStepType.video.skipApiStep, "welcome_watched")
        XCTAssertEqual(WelcomeJourneyStepType.nationalGroups.skipApiStep, "neighborhood_national")
        XCTAssertEqual(WelcomeJourneyStepType.webinar.skipApiStep, "webinar_or_first_steps")
        XCTAssertEqual(WelcomeJourneyStepType.papotages.skipApiStep, "papotages")
    }

    // MARK: - États

    func testNoEventsMeansEveryStepIsActive() {
        let viewModel = makeViewModel(events: [])

        XCTAssertEqual(viewModel.steps.map(\.type), [.video, .nationalGroups, .webinar, .papotages])
        XCTAssertTrue(viewModel.steps.allSatisfy { $0.state == .active })
        XCTAssertEqual(viewModel.completedCount, 0)
        XCTAssertFalse(viewModel.isFullyCompleted)
    }

    func testNilEventsBehaveLikeEmpty() {
        let viewModel = makeViewModel(events: nil)
        XCTAssertTrue(viewModel.steps.allSatisfy { $0.state == .active })
    }

    func testStepsAreNotLockedByPreviousSteps() {
        // Seule la dernière étape est faite : les trois premières restent accessibles.
        let viewModel = makeViewModel(events: [Event.papotages])
        let result = states(viewModel)

        XCTAssertEqual(result[.video], .active)
        XCTAssertEqual(result[.nationalGroups], .active)
        XCTAssertEqual(result[.webinar], .active)
        XCTAssertEqual(result[.papotages], .completed)
    }

    func testEachSkippedEventMarksOnlyItsOwnStepAsSkipped() {
        let cases: [(skippedEvent: String, type: WelcomeJourneyStepType)] = [
            ("onboarding.resource.welcome_watched_skipped", .video),
            ("onboarding.neighborhood.national_skipped", .nationalGroups),
            ("onboarding.outing.webinar_or_first_steps_skipped", .webinar),
            ("onboarding.outing.papotages_skipped", .papotages)
        ]

        for testCase in cases {
            let result = states(makeViewModel(events: [testCase.skippedEvent]))
            for type in WelcomeJourneyStepType.allCases {
                let expected: WelcomeJourneyStepState = (type == testCase.type) ? .skipped : .active
                XCTAssertEqual(result[type], expected, "\(testCase.skippedEvent) → \(type)")
            }
        }
    }

    func testCompletedWinsOverSkipped() {
        let viewModel = makeViewModel(events: [Event.video, "onboarding.resource.welcome_watched_skipped"])
        XCTAssertEqual(states(viewModel)[.video], .completed)
    }

    func testSkippedStepsAreNotCountedAsCompleted() {
        let viewModel = makeViewModel(events: [Event.video, "onboarding.neighborhood.national_skipped"])

        XCTAssertEqual(viewModel.completedCount, 1)
        XCTAssertEqual(viewModel.skippedCount, 1)
        XCTAssertFalse(viewModel.isFullyCompleted)
    }

    // MARK: - Fin de parcours

    func testJourneyIsResolvedWhenEveryStepIsDoneOrSkipped() {
        let viewModel = makeViewModel(events: [
            Event.video,
            "onboarding.neighborhood.national_skipped",
            Event.webinar,
            "onboarding.outing.papotages_skipped"
        ], initiallyAllResolved: false)

        XCTAssertTrue(viewModel.isFullyCompleted)
        XCTAssertEqual(viewModel.completedCount, 2)
        XCTAssertFalse(viewModel.hideEntirely)
    }

    func testJourneyIsHiddenWhenAlreadyResolvedAtLaunch() {
        let viewModel = makeViewModel(events: [
            "onboarding.resource.welcome_watched_skipped",
            "onboarding.neighborhood.national_skipped",
            "onboarding.outing.webinar_or_first_steps_skipped",
            "onboarding.outing.papotages_skipped"
        ])

        XCTAssertTrue(viewModel.hideEntirely)
    }

    func testResolvingTheLastStepDuringSessionDoesNotHideTheJourney() {
        // hasInitiallyCompletedAll = false : l'utilisateur voit le message de réussite avant que le parcours disparaisse.
        let viewModel = makeViewModel(events: [
            Event.video, Event.national, Event.webinar, "onboarding.outing.papotages_skipped"
        ], initiallyAllResolved: false)

        XCTAssertFalse(viewModel.hideEntirely)
        XCTAssertTrue(viewModel.isFullyCompleted)
    }
}
