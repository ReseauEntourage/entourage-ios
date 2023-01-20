//
//  ActionCreatePageViewController.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit

class ActionCreatePageViewController: UIPageViewController {
    
    
    var createPhase1VC:ActionCreatePhase1ViewController? = nil
    var createPhase2VC:ActionCreatePhase2ViewController? = nil
    var createPhase3VC:ActionCreatePhase3ViewController? = nil
    
    weak var parentDelegate:ActionCreateMainDelegate? = nil
    
    var currentPhasePosition = 1
    
    var isContrib = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRadiusBottomOnly(radius: ApplicationTheme.bigCornerRadius)
        
        self.isPagingEnabled = false
        
        createPhase1VC = viewController(phase: currentPhasePosition) as? ActionCreatePhase1ViewController
        
        guard let createPhase1VC = createPhase1VC else {
            return
        }
        
        setViewControllers([createPhase1VC], direction: .forward, animated: true)
    }
    
    func viewController(phase:Int) -> UIViewController? {
        
        switch phase {
        case 1:
            if createPhase1VC == nil {
                createPhase1VC = storyboard?.instantiateViewController(withIdentifier: "createPhase1") as? ActionCreatePhase1ViewController
                createPhase1VC?.pageDelegate = parentDelegate
            }
            if isContrib {
                AnalyticsLoggerManager.logEvent(name: Help_create_contrib_1)
            }
            else {
                AnalyticsLoggerManager.logEvent(name: Help_create_demand_1)
            }
            return createPhase1VC
        case 2:
            if createPhase2VC == nil {
                createPhase2VC = storyboard?.instantiateViewController(withIdentifier: "createPhase2") as? ActionCreatePhase2ViewController
                createPhase2VC?.pageDelegate = parentDelegate
            }
            if isContrib {
                AnalyticsLoggerManager.logEvent(name: Help_create_contrib_2)
            }
            else {
                AnalyticsLoggerManager.logEvent(name: Help_create_demand_2)
            }
            return createPhase2VC
        case 3:
            if isContrib {
                AnalyticsLoggerManager.logEvent(name: Help_create_contrib_3)
            }
            else {
                AnalyticsLoggerManager.logEvent(name: Help_create_demand_3)
            }
            if createPhase3VC == nil {
                createPhase3VC = storyboard?.instantiateViewController(withIdentifier: "createPhase3") as? ActionCreatePhase3ViewController
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

