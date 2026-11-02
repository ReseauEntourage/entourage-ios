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

    func testJourneyDisappearsWithoutSuccessBannerWhenResolvedWithASkippedStep() {
        let viewModel = makeViewModel(events: [
            Event.video,
            "onboarding.neighborhood.national_skipped",
            Event.webinar,
            "onboarding.outing.papotages_skipped"
        ], initiallyAllResolved: false)

        XCTAssertTrue(viewModel.hideEntirely, "Une étape passée : tout le bloc doit disparaître")
        XCTAssertFalse(viewModel.isFullyCompleted, "Pas d'encart vert de réussite")
    }

    func testSuccessBannerIsShownOnlyWhenEveryStepWasReallyDone() {
        let viewModel = makeViewModel(events: [Event.video, Event.national, Event.webinar, Event.papotages],
                                      initiallyAllResolved: false)

        XCTAssertFalse(viewModel.hideEntirely)
        XCTAssertTrue(viewModel.isFullyCompleted)
        XCTAssertEqual(viewModel.completedCount, 4)
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

    func testSkippingTheLastStepHidesTheJourneyImmediately() {
        let viewModel = makeViewModel(events: [
            Event.video, Event.national, Event.webinar, "onboarding.outing.papotages_skipped"
        ], initiallyAllResolved: false)

        XCTAssertTrue(viewModel.hideEntirely)
    }

    // MARK: - Parcours porté par le backend (`user.onboarding_journey`)

    private func makeViewModel(events: [String]?, journey: OnboardingJourney?, initiallyAllResolved: Bool? = nil) -> WelcomeJourneyViewModel {
        var initial = initiallyAllResolved
        let viewModel = WelcomeJourneyViewModel()
        viewModel.update(with: events, groupCount: 0, hasInitiallyCompletedAll: &initial, journey: journey)
        return viewModel
    }

    private func journey(removed: Bool = false, reason: String? = nil, steps: [String: String]? = nil) -> OnboardingJourney {
        OnboardingJourney(removed: removed, removedReason: reason, steps: steps, doneStepsCount: nil)
    }

    private let allTodo = [
        "welcome_watched": "todo", "neighborhood_national": "todo",
        "webinar_or_first_steps": "todo", "papotages": "todo"
    ]

    func testJourneyDecodesFromSummaryJSON() throws {
        let json = """
        {"removed": true, "removed_reason": "inactivity", "done_steps_count": 1,
         "steps": {"welcome_watched": "done", "papotages": "skipped"}}
        """
        let decoded = try JSONDecoder().decode(OnboardingJourney.self, from: Data(json.utf8))

        XCTAssertTrue(decoded.isRemoved)
        XCTAssertEqual(decoded.removedReason, "inactivity")
        XCTAssertEqual(decoded.doneStepsCount, 1)
        XCTAssertEqual(decoded.steps?["papotages"], "skipped")
    }

    func testJourneyDecodesWithNullReasonAndMissingFields() throws {
        let decoded = try JSONDecoder().decode(OnboardingJourney.self, from: Data(#"{"removed": false, "removed_reason": null}"#.utf8))

        XCTAssertFalse(decoded.isRemoved)
        XCTAssertNil(decoded.removedReason)
        XCTAssertNil(decoded.steps)
    }

    func testStepsFromBackendOverrideEvents() {
        var steps = allTodo
        steps["welcome_watched"] = "done"
        steps["papotages"] = "skipped"
        // Les events disent l'inverse : c'est `steps` qui fait foi.
        let viewModel = makeViewModel(events: [Event.webinar], journey: journey(steps: steps))

        XCTAssertEqual(states(viewModel), [
            .video: .completed, .nationalGroups: .active, .webinar: .active, .papotages: .skipped
        ])
    }

    func testMissingStepKeyFallsBackOnEvents() {
        let viewModel = makeViewModel(events: [Event.national], journey: journey(steps: ["welcome_watched": "todo"]))

        XCTAssertEqual(states(viewModel)[.nationalGroups], .completed)
        XCTAssertEqual(states(viewModel)[.video], .active)
    }

    func testJourneyWithoutStepsFallsBackOnEvents() {
        let viewModel = makeViewModel(events: [Event.video], journey: journey())

        XCTAssertEqual(states(viewModel)[.video], .completed)
        XCTAssertFalse(viewModel.hideEntirely)
    }

    func testBackendRemovedJourneyIsHiddenAtLaunchWhateverTheSteps() {
        var initial: Bool? = nil
        let viewModel = WelcomeJourneyViewModel()
        viewModel.update(with: [], groupCount: 0, hasInitiallyCompletedAll: &initial,
                         journey: journey(removed: true, reason: "ceiling", steps: allTodo))

        XCTAssertTrue(viewModel.hideEntirely)
        XCTAssertFalse(viewModel.isFullyCompleted)
        XCTAssertEqual(initial, true)
    }

    func testBackendRemovalForInactivityOrHiddenHidesAJourneyDisplayedEarlier() {
        for reason in ["inactivity", "ceiling", "hidden"] {
            let viewModel = makeViewModel(events: [], journey: journey(removed: true, reason: reason, steps: allTodo),
                                          initiallyAllResolved: false)
            XCTAssertTrue(viewModel.hideEntirely, reason)
        }
    }

    func testNotRemovedJourneyStaysVisible() {
        let viewModel = makeViewModel(events: [], journey: journey(removed: false, steps: allTodo))

        XCTAssertFalse(viewModel.hideEntirely)
        XCTAssertEqual(viewModel.steps.count, 4)
    }

    func testJourneyCompletedDuringTheSessionStillShowsTheSuccessBanner() {
        let done = ["welcome_watched": "done", "neighborhood_national": "done",
                    "webinar_or_first_steps": "done", "papotages": "done"]
        let viewModel = makeViewModel(events: [], journey: journey(removed: true, reason: "completed", steps: done),
                                      initiallyAllResolved: false)

        XCTAssertFalse(viewModel.hideEntirely)
        XCTAssertTrue(viewModel.isFullyCompleted)
    }

    func testJourneyCompletedWithASkippedStepShowsNoSuccessBanner() {
        let steps = ["welcome_watched": "done", "neighborhood_national": "done",
                     "webinar_or_first_steps": "skipped", "papotages": "done"]
        let viewModel = makeViewModel(events: [], journey: journey(removed: true, reason: "completed", steps: steps),
                                      initiallyAllResolved: false)

        XCTAssertTrue(viewModel.hideEntirely)
        XCTAssertFalse(viewModel.isFullyCompleted)
    }

    func testAbsentJourneyKeepsTheLocalBehavior() {
        let viewModel = makeViewModel(events: [Event.video], journey: nil)

        XCTAssertFalse(viewModel.hideEntirely)
        XCTAssertEqual(states(viewModel)[.video], .completed)
        XCTAssertEqual(states(viewModel)[.nationalGroups], .active)
    }

    func testMarkingAStepSkippedNeverDowngradesADoneStep() {
        let current = journey(steps: ["welcome_watched": "done", "papotages": "todo"])

        XCTAssertEqual(current.markingSkipped(step: "welcome_watched").steps?["welcome_watched"], "done")
        XCTAssertEqual(current.markingSkipped(step: "papotages").steps?["papotages"], "skipped")
        XCTAssertNil(journey().markingSkipped(step: "papotages").steps)
    }
}
