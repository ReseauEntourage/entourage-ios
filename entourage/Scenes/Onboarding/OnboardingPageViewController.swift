//
//  OnboardingPageViewController.swift
//  entourage
//
//  Created by You on 30/11/2022.
//

import UIKit
import GooglePlaces
import CoreLocation

class OnboardingPageViewController: UIPageViewController {
    
    var createPhase1VC:OnboardingPhase1ViewController? = nil
    var createPhase2VC:OnboardingPhase2ViewController? = nil
    var createPhase3VC:OnboardingPhase3ViewController? = nil
    
    weak var parentDelegate:OnboardingDelegate? = nil
    
    var currentPhasePosition = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRadiusBottomOnly(radius: ApplicationTheme.bigCornerRadius)
        
        createPhase1VC = viewController(phase: currentPhasePosition) as? OnboardingPhase1ViewController
        
        guard let createPhase1VC = createPhase1VC else {
            return
        }
        
        setViewControllers([createPhase1VC], direction: .forward, animated: true)
    }
    
    func viewController(phase:Int) -> UIViewController? {
        
        switch phase {
        case 1:
            if createPhase1VC == nil {
                createPhase1VC = storyboard?.instantiateViewController(withIdentifier: "onboardPhase1") as? OnboardingPhase1ViewController
                createPhase1VC?.pageDelegate = parentDelegate
            }
            return createPhase1VC
        case 2:
            if createPhase2VC == nil {
                createPhase2VC = storyboard?.instantiateViewController(withIdentifier: "onboardPhase2") as? OnboardingPhase2ViewController
                createPhase2VC?.pageDelegate = parentDelegate
            }
            return createPhase2VC
        case 3:
            if createPhase3VC == nil {
                createPhase3VC = storyboard?.instantiateViewController(withIdentifier: "onboardPhase3") as? OnboardingPhase3ViewController
                createPhase3VC?.pageDelegate = parentDelegate
            }
            return createPhase3VC
            
        default:
            return nil
        }
    }
    
    func goPagePosition(position:Int) {
        
        let direction = currentPhasePosition > position ? UIPageViewController.NavigationDirection.reverse : UIPageViewController.NavigationDirection.forward
        
        currentPhasePosition = position
        guard let vc = viewController(phase: currentPhasePosition) else { return }
        
        setViewControllers([vc], direction: direction, animated: true)
    }
}

let defaultCountryCode = CountryCode(country: "France",code: "+33",flag: "🇫🇷")

protocol OnboardingDelegate:AnyObject {
    func addUserInfos(firstname:String?, lastname:String?,countryCode:CountryCode, phone:String?, email:String?, consentEmail:Bool)
    func sendCode(code:String)
    func addInfos(userType:UserType)
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    func goMain()
    func requestNewcode()
}
