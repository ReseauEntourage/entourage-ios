//
//  EventCreatePageViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit

/// Page des étapes (une étape = un contrôleur SwiftUI), suivie de l'aperçu.
/// Les pages sont dérivées de `EventFormPage.all`.
class EventCreatePageViewController: UIPageViewController {

    weak var parentDelegate: EventCreateMainDelegate? = nil

    var isCreating = false

    private(set) var currentPage: EventFormPage = .step(EventCreateStep.all[0])
    private var cache = [Int: UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        isPagingEnabled = false

        if let vc = viewController(for: currentPage) {
            setViewControllers([vc], direction: .forward, animated: false)
        }
    }

    func viewController(for page: EventFormPage) -> UIViewController? {
        guard let delegate = parentDelegate else { return nil }
        if let cached = cache[page.index] { return cached }

        let vc: UIViewController
        switch page {
        case .preview:
            vc = EventPreviewViewController(store: delegate.formStore, delegate: delegate)
        case .step(let step):
            switch step {
            case .presentation:
                let phase = EventCreatePhase1ViewController()
                phase.pageDelegate = delegate
                vc = phase
            case .schedule:
                let phase = EventCreatePhase2ViewController()
                phase.pageDelegate = delegate
                vc = phase
            case .location:
                let phase = EventCreatePhase3ViewController()
                phase.pageDelegate = delegate
                vc = phase
            case .categories:
                let phase = EventCreatePhase4ViewController()
                phase.pageDelegate = delegate
                vc = phase
            case .groups:
                let phase = EventCreatePhase5ViewController()
                phase.pageDelegate = delegate
                vc = phase
            }
        }
        cache[page.index] = vc
        return vc
    }

    func goPage(_ page: EventFormPage, animated: Bool) {
        loadViewIfNeeded()
        let direction: UIPageViewController.NavigationDirection = currentPage.index > page.index ? .reverse : .forward
        currentPage = page
        logAnalytics(for: page)
        guard let vc = viewController(for: page) else { return }
        setViewControllers([vc], direction: direction, animated: animated)
    }

    private func logAnalytics(for page: EventFormPage) {
        guard isCreating, case .step(let step) = page else { return }
        switch step {
        case .presentation: AnalyticsLoggerManager.logEvent(name: Event_create_1)
        case .schedule: AnalyticsLoggerManager.logEvent(name: Event_create_2)
        case .location: AnalyticsLoggerManager.logEvent(name: Event_create_3)
        case .categories: AnalyticsLoggerManager.logEvent(name: Event_create_4)
        case .groups: AnalyticsLoggerManager.logEvent(name: Event_create_5)
        }
    }
}
