//
//  OTHomeMainViewController.swift
//  entourage
//
//  Created by Jr on 09/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeMainViewController: UIViewController {
    
    var homeNeoVC:OTHomeNeoViewController? = nil
    var homeExpertVC:OTHomeExpertViewController? = nil
    
    @IBOutlet weak var ui_view_container: UIView!
    
    var isExpertMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatTotalUnreadCountBadge), name: NSNotification.Name.updateTotalUnreadCount, object: nil)
        setupVcs()
        
       changeVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        changeVC()
        
        if isExpertMode {
            homeExpertVC?.view.frame = self.view.frame
        }
        else {
            homeNeoVC?.view.frame = self.view.frame
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func setVCMode() {
        
        if let isExpertSettings = UserDefaults.standard.object(forKey: "isExpertMode") as? Bool {
            isExpertMode = isExpertSettings
        }
        else {
            if let currentUser = UserDefaults.standard.currentUser {
                isExpertMode = false
                let isNeighbour = currentUser.isUserTypeNeighbour()
                if isNeighbour {
                    if currentUser.isEngaged {
                        isExpertMode = true
                    }
                }
                
                UserDefaults.standard.setValue(isExpertMode, forKey: "isExpertMode")
            }
        }
        
        if let currentUser = UserDefaults.standard.currentUser {
            if !currentUser.isUserTypeNeighbour() {
                isExpertMode = true
            }
        }
    }
    
    func changeVC() {
        setVCMode()
        if isExpertMode {
            if let _ = homeNeoVC {
                homeNeoVC?.willMove(toParent: nil)
                homeNeoVC?.view.removeFromSuperview()
                homeNeoVC?.removeFromParent()
            }
            
            if let _ = homeExpertVC {
                addChild(homeExpertVC!)
                homeExpertVC?.view.frame = self.view.frame
                ui_view_container.addSubview(homeExpertVC!.view)
                homeExpertVC!.didMove(toParent: self)
            }
        }
        else {
            if let _ = homeExpertVC {
                homeExpertVC?.willMove(toParent: nil)
                homeExpertVC?.view.removeFromSuperview()
                homeExpertVC?.removeFromParent()
            }
            
            if let _ = homeNeoVC {
                addChild(homeNeoVC!)
                homeNeoVC?.view.frame = self.view.frame
                ui_view_container.addSubview(homeNeoVC!.view)
                homeNeoVC!.didMove(toParent: self)
            }
        }
    }
    
    func setupVcs() {
        homeExpertVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeExpert") as? OTHomeExpertViewController
        
        homeNeoVC = UIStoryboard.init(name: "MainNeo", bundle: nil).instantiateViewController(withIdentifier: "HomeNeo") as? OTHomeNeoViewController
    }
    
    @objc func updatTotalUnreadCountBadge(notification: NSNotification) {
        if let _dict = notification.object as? NSDictionary, let totalUnreadCountBadge = _dict[kNotificationTotalUnreadCountKey] as? NSNumber {
            OTAppState.updateMessagesTabBadge(withValue: totalUnreadCountBadge.stringValue)
        }
    }
    
    func showAllEvents() {
        homeExpertVC?.showAllEvents()
    }
    
    func showAllActions() {
        homeExpertVC?.showAllActions()
    }
    
    func createEncounterFromNav() {
        homeExpertVC?.createEncounterFromNav()
    }
    
    func createTourFromNav() {
        homeExpertVC?.createTourFromNav()
    }
    
    //MARK: - Methods called from deeplink manager
    @objc func action_show_events() {
        self.showAllEvents()
     }
     
     @objc func action_show_feeds() {
        self.showAllActions()
     }
}
