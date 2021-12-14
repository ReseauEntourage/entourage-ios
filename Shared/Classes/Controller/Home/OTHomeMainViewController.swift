//
//  OTHomeMainViewController.swift
//  entourage
//
//  Created by Jr on 09/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTHomeMainViewController: UIViewController {
    
    var homeNeoVC:OTHomeNeoViewController? = nil
    var homeExpertVC:OTHomeExpertViewController? = nil
    var selectedFeedItem:OTFeedItem? = nil
    
    @IBOutlet weak var ui_view_container: UIView!
    
    var isExpertMode = false
    var isFromProfile = false
    
    var timerClosePop:Timer?
    let timerCount = 5 //seconds
    var countdownClosePop = 5 //seconds
    var alertPopInfo:OTCustomInfoPop?
    
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
        
        //To update badge unread messages
        if let user = UserDefaults.standard.currentUser {
            if let unreadCount = user.unreadCount {
            let notifDict = [kNotificationTotalUnreadCountKey:unreadCount]
            let notif = Notification(name: NSNotification.Name.updateTotalUnreadCount, object: notifDict, userInfo: nil)
            NotificationCenter.default.post(notif)
            }
        }
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
        isFromProfile = false
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
                homeExpertVC?.isFromProfile = self.isFromProfile
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
        homeExpertVC?.showAllActions(subtype: .None)
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
    
    func showFeedInfo(feedItem:OTFeedItem) {
        self.selectedFeedItem = feedItem
        
        if OTFeedItemFactory.create(for: feedItem).getStateInfo?()?.isPublic() ?? false {
            OTLogger.logEvent("OpenEntouragePublicPage")
            
            if feedItem.isTour() {
                self.performSegue(withIdentifier: "PublicFeedItemDetailsSegue", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "pushDetailFeedNew", sender: self)
            }
        }
        else {
            OTLogger.logEvent("OpenEntourageActivePage")
            self.performSegue(withIdentifier: "ActiveFeedItemDetailsSegue", sender: self)
        }
    }
    
    func showFeedInfoDetail(feedItem:OTFeedItem) {
        SVProgressHUD.dismiss()
        if let tabvc = self.tabBarController {
            alertPopInfo = OTCustomInfoPop(frame: tabvc.view.frame)
            
            var message = ""
            var title = ""
            if feedItem.isOuting() {
                message = OTLocalisationService.getLocalizedValue(forKey: "infoPopCreateEvent")
                title = OTLocalisationService.getLocalizedValue(forKey: "infoPopCreateEventTitle")
            }
            else {
                if (feedItem as! OTEntourage).isAskForHelp() {
                    message = OTLocalisationService.getLocalizedValue(forKey: "infoPopCreateAsk")
                    title = OTLocalisationService.getLocalizedValue(forKey: "infoPopCreateAskTitle")
                }
                else {
                    message = OTLocalisationService.getLocalizedValue(forKey: "infoPopCreateContrib")
                    title = OTLocalisationService.getLocalizedValue(forKey: "infoPopCreateContribTitle")
                }
            }
            
            alertPopInfo?.setupTitle(title: title, subtitle: message)
            alertPopInfo?.delegate = self
            tabvc.view.addSubview(alertPopInfo!)
            tabvc.view.bringSubviewToFront(alertPopInfo!)
        }
       
        self.selectedFeedItem = feedItem
        
        countdownClosePop = timerCount
        timerClosePop = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        if countdownClosePop > 0 {
            countdownClosePop = countdownClosePop - 1
        }
        else {
            close()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ActiveFeedItemDetailsSegue" {
            if let vc = segue.destination as? OTActiveFeedItemViewController {
                vc.feedItem = self.selectedFeedItem
                vc.inviteBehaviorTriggered = false
            }
        }
        else if segue.identifier == "pushDetailFeedNew" {
            if let vc = segue.destination as? OTDetailActionEventViewController {
                if let _item = self.selectedFeedItem {
                    vc.feedItem = _item
                }
            }
        }
        else if segue.identifier == "PublicFeedItemDetailsSegue" {
            if let vc = segue.destination as? OTPublicFeedItemViewController {
                vc.feedItem = self.selectedFeedItem
            }
        }
    }
}

//MARK: -  ClosepopDelegate -
extension OTHomeMainViewController: ClosePopDelegate {
    func close() {
        alertPopInfo?.removeFromSuperview()
        alertPopInfo = nil
        timerClosePop?.invalidate()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "pushDetailFeedNew", sender: self)
        }
    }
}
