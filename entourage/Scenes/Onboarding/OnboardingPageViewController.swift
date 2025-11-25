//
//  OnboardingPageViewController.swift
//  entourage
//

import UIKit
import GooglePlaces
import CoreLocation
import SwiftUI

final class OnboardingPageViewController: UIPageViewController {

    // MARK: - Child controllers
    var createPhase1VC: OnboardingPhase1ViewController? = nil
    var createPhase2VC: OnboardingPhase2ViewController? = nil
    var createPhase3VC: OnboardingPhase3ViewController? = nil

    // Quand parentDelegate est assigné APRÈS la création des phases,
    // on le propage immédiatement aux enfants UIKit (1, 2 et 3).
    weak var parentDelegate: OnboardingDelegate? = nil {
        didSet { propagateDelegateToChildren() }
    }

    var currentPhasePosition = 1

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRadiusBottomOnly(radius: ApplicationTheme.bigCornerRadius)

        // Phase 1 en full code (UIViewController qui hoste déjà SwiftUI chez toi)
        if createPhase1VC == nil {
            let vc = OnboardingPhase1ViewController()
            vc.pageDelegate = parentDelegate
            createPhase1VC = vc
        }

        if let first = createPhase1VC {
            setViewControllers([first], direction: .forward, animated: true)
        }
    }

    // MARK: - Delegate propagation
    private func propagateDelegateToChildren() {
        createPhase1VC?.pageDelegate = parentDelegate
        createPhase2VC?.pageDelegate = parentDelegate
        createPhase3VC?.pageDelegate = parentDelegate
    }

    // MARK: - Factory
    func viewController(phase: Int) -> UIViewController? {
        switch phase {
        case 1:
            if createPhase1VC == nil {
                let vc = OnboardingPhase1ViewController()
                vc.pageDelegate = parentDelegate
                createPhase1VC = vc
            } else {
                createPhase1VC?.pageDelegate = parentDelegate
            }
            AnalyticsLoggerManager.logEvent(name: Onboard_name)
            return createPhase1VC

        case 2:
            if createPhase2VC == nil {
                let vc = OnboardingPhase2ViewController()
                vc.pageDelegate = parentDelegate
                createPhase2VC = vc
            } else {
                createPhase2VC?.pageDelegate = parentDelegate
            }
            AnalyticsLoggerManager.logEvent(name: Onboard_code)
            return createPhase2VC

        case 3:
            if createPhase3VC == nil {
                createPhase3VC = storyboard?
                    .instantiateViewController(withIdentifier: "onboardPhase3")
                    as? OnboardingPhase3ViewController
                createPhase3VC?.pageDelegate = parentDelegate
            } else {
                createPhase3VC?.pageDelegate = parentDelegate
            }
            AnalyticsLoggerManager.logEvent(name: Onboard_profile)
            return createPhase3VC

        default:
            return nil
        }
    }

    // MARK: - Public
    func goPagePosition(position: Int) {
        let direction: UIPageViewController.NavigationDirection =
            (currentPhasePosition > position) ? .reverse : .forward
        currentPhasePosition = position
        guard let vc = viewController(phase: currentPhasePosition) else { return }
        setViewControllers([vc], direction: direction, animated: true)
    }
}
