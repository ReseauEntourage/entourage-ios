//
//  OnboardingPageViewController.swift
//  entourage
//

import UIKit
import GooglePlaces
import CoreLocation

final class OnboardingPageViewController: UIPageViewController {

    // MARK: - Child controllers
    var createPhase1VC: OnboardingPhase1ViewController? = nil
    var createPhase2VC: OnboardingPhase2ViewController? = nil
    var createPhase3VC: OnboardingPhase3ViewController? = nil

    // ⚠️ Quand parentDelegate est assigné APRÈS la création de phase 1,
    // on le propage immédiatement aux enfants déjà créés.
    weak var parentDelegate: OnboardingDelegate? = nil {
        didSet { propagateDelegateToChildren() }
    }

    var currentPhasePosition = 1

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRadiusBottomOnly(radius: ApplicationTheme.bigCornerRadius)

        // Phase 1 en full code (SwiftUI hosté)
        if createPhase1VC == nil {
            let vc = OnboardingPhase1ViewController()
            vc.pageDelegate = parentDelegate // peut être nil ici si pas encore injecté
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
                // Au cas où le délégué arrive tard
                createPhase1VC?.pageDelegate = parentDelegate
            }
            AnalyticsLoggerManager.logEvent(name: Onboard_name)
            return createPhase1VC

        case 2:
            if createPhase2VC == nil {
                createPhase2VC = storyboard?
                    .instantiateViewController(withIdentifier: "onboardPhase2")
                    as? OnboardingPhase2ViewController
                createPhase2VC?.pageDelegate = parentDelegate
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

// ⚠️ Si tu as déjà `defaultCountryCode` défini avec la nouvelle vue SwiftUI,
// enlève la redéclaration suivante pour éviter un conflit de symboles.
// let defaultCountryCode = CountryCode(country: "France", code: "+33", flag: "🇫🇷")

protocol OnboardingDelegate: AnyObject {
    func addUserInfos(
        firstname: String?,
        lastname: String?,
        countryCode: CountryCode,
        phone: String?,
        email: String?,
        consentEmail: Bool,
        gender: String?,
        howWeMet: String?,
        birthdate: String?,
        company: String?,
        event: String?
    )
    func sendCode(code: String)
    func addInfos(userType: UserType)
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    func goMain()
    func requestNewcode()
}
