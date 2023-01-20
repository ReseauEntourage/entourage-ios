//
//  NeighborhoodCreatePageViewController.swift
//  entourage
//
//  Created by Jerome on 06/04/2022.
//

import UIKit

class NeighborhoodCreatePageViewController: UIPageViewController {
    
    var createPhase1VC:NeighborhoodCreatePhase1ViewController? = nil
    var createPhase2VC:NeighborhoodCreatePhase2ViewController? = nil
    var createPhase3VC:NeighborhoodCreatePhase3ViewController? = nil
    
    weak var parentDelegate:NeighborhoodCreateMainDelegate? = nil
    
    var currentPhasePosition = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRadiusBottomOnly(radius: ApplicationTheme.bigCornerRadius)
        
        self.isPagingEnabled = false
        
        createPhase1VC = viewController(phase: currentPhasePosition) as? NeighborhoodCreatePhase1ViewController
        
        guard let createPhase1VC = createPhase1VC else {
            return
        }
        
        setViewControllers([createPhase1VC], direction: .forward, animated: true)
    }
    
    func viewController(phase:Int) -> UIViewController? {
        
        switch phase {
        case 1:
            if createPhase1VC == nil {
                createPhase1VC = storyboard?.instantiateViewController(withIdentifier: "createPhase1") as? NeighborhoodCreatePhase1ViewController
                createPhase1VC?.pageDelegate = parentDelegate
            }
            return createPhase1VC
        case 2:
            if createPhase2VC == nil {
                createPhase2VC = storyboard?.instantiateViewController(withIdentifier: "createPhase2") as? NeighborhoodCreatePhase2ViewController
                createPhase2VC?.pageDelegate = parentDelegate
            }
            return createPhase2VC
        case 3:
            if createPhase3VC == nil {
                createPhase3VC = storyboard?.instantiateViewController(withIdentifier: "createPhase3") as? NeighborhoodCreatePhase3ViewController
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
