//
//  OnboardingPageViewController.swift
//  entourage
//

import UIKit
import GooglePlaces
import CoreLocation

class OnboardingPageViewController: UIPageViewController {
    
    var createPhase1VC: OnboardingPhase1ViewController? = nil
    var createPhase2VC: OnboardingPhase2ViewController? = nil
    var createPhase3VC: OnboardingPhase3ViewController? = nil
    
    weak var parentDelegate: OnboardingDelegate? = nil
    
    var currentPhasePosition = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRadiusBottomOnly(radius: ApplicationTheme.bigCornerRadius)
        
        // Phase 1 en full code (SwiftUI hosté)
        if createPhase1VC == nil {
            let vc = OnboardingPhase1ViewController()
            vc.pageDelegate = parentDelegate            // compat API inchangée
            // Si tu as des valeurs déjà connues, tu peux les pousser ici :
            // vc.userFirstname = ...
            // vc.userLastname  = ...
            // vc.countryCode   = defaultCountryCode
            // vc.phone         = ...
            // vc.email         = ...
            // vc.hasConsent    = ...
            createPhase1VC = vc
        }
        
        guard let first = createPhase1VC else { return }
        setViewControllers([first], direction: .forward, animated: true)
    }
    
    func viewController(phase: Int) -> UIViewController? {
        switch phase {
        case 1:
            // PLUS de storyboard ici : on réutilise l’instance programmatique
            if createPhase1VC == nil {
                let vc = OnboardingPhase1ViewController()
                vc.pageDelegate = parentDelegate
                createPhase1VC = vc
            }
            AnalyticsLoggerManager.logEvent(name: Onboard_name)
            return createPhase1VC
            
        case 2:
            // Tu peux garder storyboard pour la phase 2 pour l’instant
            if createPhase2VC == nil {
                createPhase2VC = storyboard?.instantiateViewController(withIdentifier: "onboardPhase2") as? OnboardingPhase2ViewController
                createPhase2VC?.pageDelegate = parentDelegate
            }
            AnalyticsLoggerManager.logEvent(name: Onboard_code)
            return createPhase2VC
            
        case 3:
            if createPhase3VC == nil {
                createPhase3VC = storyboard?.instantiateViewController(withIdentifier: "onboardPhase3") as? OnboardingPhase3ViewController
                createPhase3VC?.pageDelegate = parentDelegate
            }
            AnalyticsLoggerManager.logEvent(name: Onboard_profile)
            return createPhase3VC
            
        default:
            return nil
        }
    }
    
    func goPagePosition(position: Int) {
        let direction: UIPageViewController.NavigationDirection = (currentPhasePosition > position) ? .reverse : .forward
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
        company: String?,
        event: String?
    )
    func sendCode(code: String)
    func addInfos(userType: UserType)
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    func goMain()
    func requestNewcode()
}
