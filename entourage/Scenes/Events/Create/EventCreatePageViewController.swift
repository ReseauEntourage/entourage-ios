//
//  EventCreatePageViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit

class EventCreatePageViewController: UIPageViewController {
    
    
    var createPhase1VC:EventCreatePhase1ViewController? = nil
    var createPhase2VC:EventCreatePhase2ViewController? = nil
    var createPhase3VC:EventCreatePhase3ViewController? = nil
    var createPhase4VC:EventCreatePhase4ViewController? = nil
    var createPhase5VC:EventCreatePhase5ViewController? = nil
    
    weak var parentDelegate:EventCreateMainDelegate? = nil
    
    var currentPhasePosition = 1
    
    var isCreating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRadiusBottomOnly(radius: ApplicationTheme.bigCornerRadius)
        
        self.isPagingEnabled = false
        
        createPhase1VC = viewController(phase: currentPhasePosition) as? EventCreatePhase1ViewController
        
        guard let createPhase1VC = createPhase1VC else {
            return
        }
        
        setViewControllers([createPhase1VC], direction: .forward, animated: true)
    }
    
    func viewController(phase:Int) -> UIViewController? {
        
        switch phase {
        case 1:
            if createPhase1VC == nil {
                createPhase1VC = storyboard?.instantiateViewController(withIdentifier: "createPhase1") as? EventCreatePhase1ViewController
                createPhase1VC?.pageDelegate = parentDelegate
            }
            if isCreating { AnalyticsLoggerManager.logEvent(name: Event_create_1)}
            return createPhase1VC
        case 2:
            if createPhase2VC == nil {
                createPhase2VC = storyboard?.instantiateViewController(withIdentifier: "createPhase2") as? EventCreatePhase2ViewController
                createPhase2VC?.pageDelegate = parentDelegate
            }
            if isCreating { AnalyticsLoggerManager.logEvent(name: Event_create_2)}
            return createPhase2VC
        case 3:
            if createPhase3VC == nil {
                createPhase3VC = storyboard?.instantiateViewController(withIdentifier: "createPhase3") as? EventCreatePhase3ViewController
                createPhase3VC?.pageDelegate = parentDelegate
            }
            if isCreating { AnalyticsLoggerManager.logEvent(name: Event_create_3)}
            return createPhase3VC
        case 4:
            if createPhase4VC == nil {
                createPhase4VC = storyboard?.instantiateViewController(withIdentifier: "createPhase4") as? EventCreatePhase4ViewController
                createPhase4VC?.pageDelegate = parentDelegate
            }
            if isCreating { AnalyticsLoggerManager.logEvent(name: Event_create_4)}
            return createPhase4VC
        case 5:
            if createPhase5VC == nil {
                createPhase5VC = storyboard?.instantiateViewController(withIdentifier: "createPhase5") as? EventCreatePhase5ViewController
                createPhase5VC?.pageDelegate = parentDelegate
            }
            if isCreating { AnalyticsLoggerManager.logEvent(name: Event_create_5)}
            return createPhase5VC
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
