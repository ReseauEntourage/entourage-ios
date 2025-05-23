//
//  OTMainTabbarViewController.swift
//  entourage
//
//  Created by Jr on 06/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class MainTabbarViewController: UITabBarController {

    var homeVC:UINavigationController!
    var actionsVC:UINavigationController!
    var messagesVC:UINavigationController!
    var groupVC:UINavigationController!
    var eventsVC:UINavigationController!
    
    var temporaryNavPop:UIViewController? = nil
    
    var isAskForHelp = false
    var addEditEvent = false
    
    var oldItemSelected = 0
    var currentItemSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.appOrange
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        
        delegate = self
        
       setupVCs()
        
        AnalyticsLoggerManager.updateAnalyticsWitUser()
        
        //Notif for changing neighborhood list to discover and select tab
        NotificationCenter.default.addObserver(self, selector: #selector(showDiscoverNeighborhoods), name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowDiscover), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMyNeighborhoods), name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowMy), object: nil)
        
        //Show Events from home tab clicks
        NotificationCenter.default.addObserver(self, selector: #selector(showDiscoverEvents), name: NSNotification.Name(rawValue: kNotificationEventShowDiscover), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMyEvents), name: NSNotification.Name(rawValue: kNotificationEventShowMy), object: nil)
        
        //Notif for changing contrig / solicitation
        NotificationCenter.default.addObserver(self, selector: #selector(showActionsSolicitations), name: NSNotification.Name(rawValue: kNotificationActionShowSolicitation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showActionsContrib), name: NSNotification.Name(rawValue: kNotificationActionShowContrib), object: nil)
        
        //Update message badge count
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeCount(_:)), name: NSNotification.Name(rawValue: kNotificationMessagesUpdateCount), object: nil)
    }
    
    @objc func showDiscoverNeighborhoods() {
        if let vc = groupVC.topViewController as? NeighborhoodHomeViewController {
            vc.setDiscoverFirst()
        }
        self.selectedIndex = 3
        self.boldSelectedItem()
        Logger.print("***** discover group : \(groupVC.topViewController)")
    }
    @objc func showMyNeighborhoods() {
        if let vc = groupVC.topViewController as? NeighborhoodHomeViewController {
            vc.setDiscoverFirst()
        }
        self.selectedIndex = 3
        self.boldSelectedItem()
        Logger.print("***** My group : \(groupVC.topViewController)")
    }
    

    
    
    @objc func showDiscoverEvents() {
        if let vc = eventsVC.topViewController as? EventListMainV2ViewController {
        }
        self.selectedIndex = 4
        self.boldSelectedItem()
        Logger.print("***** discover Events ")
    }
    
    @objc func showMyEvents() {
        if let vc = eventsVC.topViewController as? EventListMainV2ViewController {
        }
        self.selectedIndex = 4
        self.boldSelectedItem()
        Logger.print("***** My Events ")
    }
    
    @objc func showActionsContrib() {
        if let vc = actionsVC.topViewController as? ActionsMainHomeViewController {
            vc.setContributionsFirst()
        }
        self.selectedIndex = 1
        self.boldSelectedItem()
    }
    @objc func showActionsDemand() {
        if let vc = actionsVC.topViewController as? ActionsMainHomeViewController {
            vc.setSolicitationsFirst()
        }
        self.selectedIndex = 1
        self.boldSelectedItem()
    }
    @objc func showHome() {
        self.selectedIndex = 0
        self.boldSelectedItem()
    }
    
    @objc func showActionsSolicitations() {
        if let vc = actionsVC.topViewController as? ActionsMainHomeViewController {
            vc.setSolicitationsFirst()
        }
        self.selectedIndex = 1
        self.boldSelectedItem()
    }
    
    @objc func updateBadgeCount(_ notification:Notification) {
        if let badge = UserDefaults.badgeCount, badge > 0 {
            let newValue = badge > 9 ? "9+" : "\(badge)"
            messagesVC.tabBarItem.badgeValue = newValue
            UIApplication.shared.applicationIconBadgeNumber = badge
        }
        else {
            messagesVC.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func setupVCs() {
        
        let _homeVC = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "homev2vc")
        homeVC = UINavigationController.init(rootViewController: _homeVC)
        homeVC.isNavigationBarHidden = true
        homeVC.tabBarItem.title = "tabbar_home".localized
        homeVC.tabBarItem.accessibilityLabel = "Home"
        homeVC.tabBarItem.tag = 0 //
        homeVC.tabBarItem.image = UIImage.init(named: "ic_home_off")?.withRenderingMode(.alwaysOriginal)
        homeVC.tabBarItem.selectedImage = UIImage.init(named: "ic_home_on")
        let _giftsVC = UIStoryboard.init(name: StoryboardName.actions, bundle: nil).instantiateViewController(withIdentifier: "home_actions_vc")
        actionsVC = UINavigationController.init(rootViewController: _giftsVC)
        actionsVC.isNavigationBarHidden = true
        actionsVC.tabBarItem.title = "tabbar_gifts".localized
        actionsVC.tabBarItem.image = UIImage.init(named: "ic_gifts_off")?.withRenderingMode(.alwaysOriginal)
        actionsVC.tabBarItem.selectedImage = UIImage.init(named: "ic_gifts_on")
        actionsVC.tabBarItem.tag = 1
        
        
        let  _msgVC = UIStoryboard.init(name: StoryboardName.messages, bundle: nil).instantiateViewController(withIdentifier: "home_messages_vc")
        messagesVC = UINavigationController.init(rootViewController: _msgVC)
        messagesVC.isNavigationBarHidden = true
        messagesVC.tabBarItem.title = "tabbar_messages".localized
        messagesVC.tabBarItem.image = UIImage.init(named: "ic_message_off")?.withRenderingMode(.alwaysOriginal)
        messagesVC.tabBarItem.selectedImage = UIImage.init(named: "ic_message_on")
        messagesVC.tabBarItem.tag = 2
        messagesVC.tabBarItem.badgeColor = .appOrangeLight
        
        
        let _groupVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "home_new_group_vc")
        groupVC = UINavigationController.init(rootViewController: _groupVC)
        groupVC.isNavigationBarHidden = true
        groupVC.tabBarItem.title = "tabbar_groups".localized
        groupVC.tabBarItem.image = UIImage.init(named: "ic_group_off")?.withRenderingMode(.alwaysOriginal)
        groupVC.tabBarItem.selectedImage = UIImage.init(named: "ic_group_on")
        groupVC.tabBarItem.tag = 3
        
        
        let _eventsVC = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "home_new_events_vc")
        eventsVC = UINavigationController.init(rootViewController: _eventsVC)
        eventsVC.isNavigationBarHidden = true
        eventsVC.tabBarItem.title = "tabbar_events".localized
        eventsVC.tabBarItem.image = UIImage.init(named: "ic_event_off")?.withRenderingMode(.alwaysOriginal)
        eventsVC.tabBarItem.selectedImage = UIImage.init(named: "ic_event_on")
        eventsVC.tabBarItem.tag = 4
        viewControllers = [homeVC,actionsVC,messagesVC,groupVC,eventsVC]
        boldSelectedItem()
    }
    
    @objc func boldSelectedItem() {
        let regularFont = ApplicationTheme.getFontNunitoLight(size: 13)
        let regularTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.appGris112,NSAttributedString.Key.font:regularFont]
        
        for item in tabBar.items! {
            item.setTitleTextAttributes(regularTextAttr as [NSAttributedString.Key : Any], for: .normal)
        }
        
        let selectedFont = ApplicationTheme.getFontNunitoLight(size: 13)
        let selectionTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.appOrange,NSAttributedString.Key.font:selectedFont]
        
        tabBar.selectedItem?.setTitleTextAttributes(selectionTextAttr as [NSAttributedString.Key : Any], for: .normal)
        
       
        //Analytics
        if oldItemSelected == currentItemSelected {
            return
        }
        
        switch currentItemSelected {
        case 0:
            AnalyticsLoggerManager.logEvent(name: Action_Tabbar_home)
        case 1:
            AnalyticsLoggerManager.logEvent(name: Action_Tabbar_help)
        case 2:
            AnalyticsLoggerManager.logEvent(name: Action_Tabbar_messages)
        case 3:
            AnalyticsLoggerManager.logEvent(name: Action_Tabbar_groups)
        case 4:
            AnalyticsLoggerManager.logEvent(name: Action_Tabbar_events)
        default:
            break
        }
    }
}


//MARK: - UITabBarControllerDelegate -
extension MainTabbarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        oldItemSelected = currentItemSelected
        currentItemSelected = item.tag
        boldSelectedItem()
        
        
        switch item.tag {
        case 0://Home
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationHomeUpdate), object: nil)
        case 1: //actions
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationActionsUpdate), object: nil)
        case 2://Messages
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdate), object: nil)
        case 3://Neighborhoods
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationNeighborhoodsUpdate), object: nil)
        case 4://events
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationEventsUpdate), object: nil)
        default:
            break
        }
    }
}

extension MainTabbarViewController {
    func setTabBar(hidden: Bool, animated: Bool, duration: TimeInterval) {
        let tabBarHeight = tabBar.frame.size.height
        let offsetY = hidden ? tabBarHeight : -tabBarHeight
        let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)

        UIView.animate(withDuration: animated ? duration : 0.0, animations: {
            self.tabBar.frame = endFrame
        }, completion: { finished in
            if finished {
                self.tabBar.isHidden = hidden
            }
        })
    }
}
