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
    var giftsVC:UINavigationController!
    var messagesVC:UINavigationController!
    var groupVC:UINavigationController!
    var eventsVC:UINavigationController!
    
    var temporaryNavPop:UIViewController? = nil
    
    var isAskForHelp = false
    var addEditEvent = false
    
//    var popview:OTPopInfoCustom? = nil//TODO: a faire ?
    
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
        
//        NotificationCenter.default.addObserver(self, selector: #selector(hidePopInfo), name: NSNotification.Name(rawValue: "hidePopView"), object: nil)//TODO: a faire ?
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showActions), name: NSNotification.Name(rawValue: "showAlls"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(showEvents), name: NSNotification.Name(rawValue: "showEvents"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tapProfilTab), name: NSNotification.Name(rawValue: "tapProfilTab"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showHome), name: NSNotification.Name(rawValue: "showHome"), object: nil)
        //Notif for changing neighborhood list to discover and select tab
        NotificationCenter.default.addObserver(self, selector: #selector(showDiscoverNeighborhoods), name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowDiscover), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMyNeighborhoods), name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowMy), object: nil)
        
        //Show Events from home tab clicks
        NotificationCenter.default.addObserver(self, selector: #selector(showDiscoverEvents), name: NSNotification.Name(rawValue: kNotificationEventShowDiscover), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMyEvents), name: NSNotification.Name(rawValue: kNotificationEventShowMy), object: nil)
    }
    
    @objc func showDiscoverNeighborhoods() {
        if let vc = groupVC.topViewController as? NeighborhoodHomeViewController {
            vc.setDiscoverFirst()
        }
        self.selectedIndex = 3
        Logger.print("***** discover group : \(groupVC.topViewController)")
    }
    @objc func showMyNeighborhoods() {
        if let vc = groupVC.topViewController as? NeighborhoodHomeViewController {
            vc.setMyFirst()
        }
        self.selectedIndex = 3
        Logger.print("***** My group : \(groupVC.topViewController)")
    }
    
    @objc func showDiscoverEvents() {
        if let vc = eventsVC.topViewController as? EventMainHomeViewController {
            vc.setDiscoverFirst()
        }
        self.selectedIndex = 4
        Logger.print("***** discover Events ")
    }
    
    @objc func showMyEvents() {
        if let vc = eventsVC.topViewController as? EventMainHomeViewController {
            vc.setMyFirst()
        }
        self.selectedIndex = 4
        Logger.print("***** My Events ")
    }
    
//    func showPopInfo(delegate:OTPopInfoDelegate,title:String,message:String,buttonOkStr:String,buttonCancelStr:String) {
//        popview = OTPopInfoCustom.init(frame: view.frame,delegate: delegate,title: title,message: message,buttonOkStr: buttonOkStr,buttonCancelStr: buttonCancelStr)
//
//        view.addSubview(popview!)
//        view.bringSubviewToFront(popview!)
//    }
    
//    @objc func hidePopInfo() {
//        if let popview = popview {
//            popview.removeFromSuperview()
//            self.popview = nil
//        }
//    }
    
//
//    @objc func switchToHomeTab() {
//        showHomeVC()
//    }
    
    @objc func tapProfilTab() {
        DispatchQueue.main.async {
            self.selectedIndex = 4
            self.boldSelectedItem()
            //TO force scrolltoTop
            //TODO: a faire ?
//            if let vc = self.menuVC.topViewController as? OTMenuProfileViewController {
//                vc.gotoTop()
//            }
        }
    }
    
    func setupVCs() {
        
        let _homeVC = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "homeVC")
        homeVC = UINavigationController.init(rootViewController: _homeVC)
        homeVC.isNavigationBarHidden = true
        homeVC.tabBarItem.title = "tabbar_home".localized
        homeVC.tabBarItem.accessibilityLabel = "Home"
        homeVC.tabBarItem.tag = 0 //
        homeVC.tabBarItem.image = UIImage.init(named: "ic_home_off")?.withRenderingMode(.alwaysOriginal)
        homeVC.tabBarItem.selectedImage = UIImage.init(named: "ic_home_on")
        
        
        let _giftsVC = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "home_gift_vc")
        giftsVC = UINavigationController.init(rootViewController: _giftsVC)
        giftsVC.isNavigationBarHidden = true
        giftsVC.tabBarItem.title = "tabbar_gifts".localized
        giftsVC.tabBarItem.image = UIImage.init(named: "ic_gifts_off")?.withRenderingMode(.alwaysOriginal)
        giftsVC.tabBarItem.selectedImage = UIImage.init(named: "ic_gifts_on")
        giftsVC.tabBarItem.tag = 1
        
        
        let  _msgVC = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "home_messanger_vc")
        messagesVC = UINavigationController.init(rootViewController: _msgVC)
        messagesVC.isNavigationBarHidden = true
        messagesVC.tabBarItem.title = "tabbar_messages".localized
        messagesVC.tabBarItem.image = UIImage.init(named: "ic_message_off")?.withRenderingMode(.alwaysOriginal)
        messagesVC.tabBarItem.selectedImage = UIImage.init(named: "ic_message_on")
        messagesVC.tabBarItem.tag = 2
        
        
        let _groupVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "home")
        groupVC = UINavigationController.init(rootViewController: _groupVC)
        groupVC.isNavigationBarHidden = true
        groupVC.tabBarItem.title = "tabbar_groups".localized
        groupVC.tabBarItem.image = UIImage.init(named: "ic_group_off")?.withRenderingMode(.alwaysOriginal)
        groupVC.tabBarItem.selectedImage = UIImage.init(named: "ic_group_on")
        groupVC.tabBarItem.tag = 3
        
        
        let _eventsVC = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "home_events_vc")
        eventsVC = UINavigationController.init(rootViewController: _eventsVC)
        eventsVC.isNavigationBarHidden = true
        eventsVC.tabBarItem.title = "tabbar_events".localized
        eventsVC.tabBarItem.image = UIImage.init(named: "ic_event_off")?.withRenderingMode(.alwaysOriginal)
        eventsVC.tabBarItem.selectedImage = UIImage.init(named: "ic_event_on")
        eventsVC.tabBarItem.tag = 4
        viewControllers = [homeVC,giftsVC,messagesVC,groupVC,eventsVC]
        boldSelectedItem()
    }
    
    @objc func boldSelectedItem() {
        let regularFont = ApplicationTheme.getFontNunitoLight(size: 13)
        let regularTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.appOrangeLight,NSAttributedString.Key.font:regularFont]
        
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
        
        //TODO: a faire Analytics
//        switch currentItemSelected {
//        case 0:
//            OTLogger.logEvent(Action_Tab_Feeds)
//        case 1:
//            OTLogger.logEvent(Action_Tab_Gds)
//        case 2:
//            OTLogger.logEvent(Action_Tab_Plus)
//        case 3:
//            OTLogger.logEvent(Action_Tab_Messages)
//        case 4:
//            OTLogger.logEvent(Action_Tab_Profil)
//        default:
//            break
//        }
    }
    
    
//    @objc func showEvents() {
//        self.showHomeVC()
//        if let _vc = homeVC.topViewController as? OTHomeMainViewController {
//            let delayInSeconds = 0.1
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
//                _vc.showAllEvents()
//            }
//        }
//    }
//    @objc func showActions() {
//        self.showHomeVC()
//        if let _vc = homeVC.topViewController as? OTHomeMainViewController {
//            let delayInSeconds = 0.1
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
//                _vc.showAllActions()
//            }
//        }
//    }
//
//    @objc func showHome() {
//        self.showHomeVC()
//    }
}


//MARK: - UITabBarControllerDelegate -
extension MainTabbarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController.tabBarItem.tag == 2 {
//            self.showMapOption()
//
//            return false
//        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        oldItemSelected = currentItemSelected
        currentItemSelected = item.tag
        boldSelectedItem()
        
        //TO force reload neighborhoods
        if item.tag == 3 {
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationNeighborhoodsUpdate), object: nil)
        }
        
        //To force reload events
        if item.tag == 4 {
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationEventsUpdate), object: nil)
        }
    }

//    func showHomeVC(isEditor:Bool = false) {
//        if self.selectedIndex != 0 {
//            self.selectedIndex = 0
//        }
//
////        if !isEditor {
////            homeVC.popToRootViewController(animated: false)
////            (homeVC.topViewController as? OTHomeMainViewController)?.isFromProfile = true
////        }
//        //homeVC.popToRootViewController(animated: false)
//        boldSelectedItem()
//    }
}
