//
//  OTMainTabbarViewController.swift
//  entourage
//
//  Created by Jr on 06/07/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTMainTabbarViewController: UITabBarController {

    var homeVC:UINavigationController!
    var guideVC:UINavigationController!
    let plusVC = UIViewController()
    var messagesVC:UINavigationController!
    var menuVC:UINavigationController!
    
    var temporaryNavPop:UIViewController? = nil
    
    var isAskForHelp = false
    var addEditEvent = false
    
    var tooltipView:UIView? = nil
    
    var oldItemSelected = 0
    var currentItemSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor.appOrange()
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        
        delegate = self
        
       setupVCs()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTooltip), name: NSNotification.Name(rawValue: "showToolTip"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTooltip), name: NSNotification.Name(rawValue: "hideToolTip"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showActions), name: NSNotification.Name(rawValue: "showAlls"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEvents), name: NSNotification.Name(rawValue: "showEvents"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tapProfilTab), name: NSNotification.Name(rawValue: "tapProfilTab"), object: nil)
    }
    
    @objc func showTooltip() {
        //TODO: a remettre ou pas ?
//        tooltipView = OTHomeTooltipView.init(frame: view.frame)
//
//        view.addSubview(tooltipView!)
//        view.bringSubviewToFront(tooltipView!)
    }
    
    @objc func hideTooltip() {
        if let tooltipView = tooltipView {
            tooltipView.removeFromSuperview()
            self.tooltipView = nil
            NotificationCenter.default.removeObserver(self)
        }
    }
    @objc func switchToHomeTab() {
        showHomeVC()
    }
    
    @objc func tapProfilTab() {
        DispatchQueue.main.async {
            self.selectedIndex = 4
            self.boldSelectedItem()
        }
    }
    
    func setupVCs() {
        let  _homeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OTMain") as! OTHomeMainViewController//OTMainViewController
        
        homeVC = UINavigationController.init(rootViewController: _homeVC)
        homeVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"tabbar_home")
        homeVC.tabBarItem.image = UIImage.init(named: "ic_tab_home")?.withRenderingMode(.alwaysOriginal)
        homeVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_home_selected")
        homeVC.tabBarItem.tag = 0
        
        let _guideVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuideHub") as! OTMainGuideHubViewController
        guideVC = UINavigationController.init(rootViewController: _guideVC)
        guideVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"tabbar_guide")
        guideVC.tabBarItem.image = UIImage.init(named: "ic_tab_guide")?.withRenderingMode(.alwaysOriginal)
        guideVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_guide_selected")
        guideVC.tabBarItem.tag = 1
        
        plusVC.tabBarItem.title = ""
        plusVC.tabBarItem.tag = 2
        plusVC.tabBarItem.image = UIImage.init(named: "ic_tab_plus_selected")?.withRenderingMode(.alwaysOriginal)
        plusVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_plus_selected")
        
        let _messagesVC = UIStoryboard.myEntourages()?.instantiateViewController(withIdentifier: "OTMyEntouragesViewController") as! OTMyEntouragesViewController
        messagesVC = UINavigationController.init(rootViewController: _messagesVC)
        messagesVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"tabbar_message")
        messagesVC.tabBarItem.image = UIImage.init(named: "ic_tab_message")?.withRenderingMode(.alwaysOriginal)
        messagesVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_message_selected")
        messagesVC.tabBarItem.tag = 3
        
        let _menuVC = UIStoryboard.init(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "MenuProfileVC") as! OTMenuProfileViewController
        menuVC = UINavigationController.init(rootViewController: _menuVC)
        menuVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"tabbar_profil")
        menuVC.tabBarItem.image = UIImage.init(named: "ic_tab_menu")?.withRenderingMode(.alwaysTemplate)
        menuVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_menu_selected")
        menuVC.tabBarItem.tag = 4
        viewControllers = [homeVC,guideVC,plusVC,messagesVC,menuVC]
        
        boldSelectedItem()
    }
    
    @objc func boldSelectedItem() {
        let regularFont = UIFont.init(name: "SFUIText-Regular", size: 13)
        let regularTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.darkGray,NSAttributedString.Key.font:regularFont!]
        
        for item in tabBar.items! {
            item.setTitleTextAttributes(regularTextAttr as [NSAttributedString.Key : Any], for: .normal)
        }
        
        let selectedFont = UIFont.init(name: "SFUIText-Bold", size: 13)
               let selectionTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.appOrange()!,NSAttributedString.Key.font:selectedFont!]
        
         tabBar.selectedItem?.setTitleTextAttributes(selectionTextAttr as [NSAttributedString.Key : Any], for: .normal)
       
       
        //Analytics
        if oldItemSelected == currentItemSelected {
            return
        }
        
        switch currentItemSelected {
        case 0:
            OTLogger.logEvent(Action_Tab_Feeds)
        case 1:
            OTLogger.logEvent(Action_Tab_Gds)
        case 2:
            OTLogger.logEvent(Action_Tab_Plus)
        case 3:
            OTLogger.logEvent(Action_Tab_Messages)
        case 4:
            OTLogger.logEvent(Action_Tab_Profil)
        default:
            break
        }
    }
    
   @objc func showMapOption() {
        //Check if Encounter if not show regular menu
        let isOngoingTou = UserDefaults.standard.currentOngoingTour
        
        OTLogger.logEvent(Action_Tab_Plus)
        
        if (OTOngoingTourService.sharedInstance()?.isOngoing ?? false || isOngoingTou != nil) {
            self.createEncounter()
            return
        }
        
        OTLogger.logEvent(Action_Plus_Agir)
        let storyb = UIStoryboard.init(name: "MapOptions", bundle: nil)
        if let vc = storyb.instantiateViewController(withIdentifier: "MapOptions") as? OTMapOptionsViewController {
            vc.optionsDelegate = self
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func showEvents() {
        self.showHomeVC()
        if let _vc = homeVC.topViewController as? OTHomeMainViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.showAllEvents()
            }
        }
    }
    @objc func showActions() {
        self.showHomeVC()
        if let _vc = homeVC.topViewController as? OTHomeMainViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.showAllActions()
            }
        }
    }
}

//MARK: - OTOptionsDelegate -
extension OTMainTabbarViewController: OTOptionsDelegate {
    
    func createTour() {
        if let _vc = homeVC.topViewController as? OTMainViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.createTourFromNav()
            }
            return
        }
        else if let _vc = homeVC.topViewController as? OTFeedToursViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.createTourFromNav()
            }
            return
        }
        else {
            self.showHomeVC()
            if let _vc = homeVC.topViewController as? OTHomeMainViewController {
                let delayInSeconds = 0.1
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    _vc.createTourFromNav()
                }
            }
        }
    }
    
    func createEncounter() {
        
        if let _vc = homeVC.topViewController as? OTMainViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.createEncounterFromNav()
            }
        }
        else if let _vc = homeVC.topViewController as? OTFeedToursViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.createEncounterFromNav()
            }
        }
        else {
            self.showHomeVC()
            if let _vc = homeVC.topViewController as? OTHomeMainViewController {
                let delayInSeconds = 0.1
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    _vc.createEncounterFromNav()
                }
            }
        }
    }
    
    func createAction() {
        self.addEditEvent = false
        showEntourageEditor()
    }
    
    func createEvent() {
        self.addEditEvent = true
        showEntourageEditor()
    }
    
    func createActionGift() {
         self.isAskForHelp = false;
         self.createAction()
    }
    
    func createActionHelp() {
        self.isAskForHelp = true;
        self.createAction()
    }
    
    func togglePOI() {
        if let _vc = homeVC.topViewController as? OTMainViewController {
            let delayInSeconds = 0.01
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.showProposeFromNav()
            }
        }
    }
    
    func dismissOptions() {
        self.addEditEvent = false;
        self.dismiss(animated: true, completion: nil)
    }
    
    func proposeStructure() {
        if let _vc = homeVC.topViewController as? OTMainViewController {
            let delayInSeconds = 0.01
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.showProposeFromNav()
            }
        }
    }
    
    func showEntourageEditor() {
        if let navController = UIStoryboard.init(name: "EntourageEditor", bundle: nil).instantiateViewController(withIdentifier: "navEntourageEditor") as? UINavigationController {
            temporaryNavPop = navController
            if let vc = navController.children[0] as? OTEntourageEditorViewController {
                let location = OTLocationManager.sharedInstance()?.defaultLocationForNewActions()
                vc.location = location
                vc.entourageEditorDelegate = self
                vc.isAskForHelp = self.isAskForHelp
                vc.isEditingEvent = self.addEditEvent
                vc.type = nil
                
                self.show(navController, sender: nil)
                self.showHomeVC(isEditor:true)
            }
        }
    }
}

//MARK: - EntourageEditorDelegate -
extension OTMainTabbarViewController: EntourageEditorDelegate {
    func didEdit(_ entourage: OTEntourage!) {
        if let _vc = self.homeVC.children[0] as? OTHomeMainViewController {
            plusVC.dismiss(animated: true) {
                _vc.showFeedInfo(feedItem: entourage)
            }
        }
        else {
            temporaryNavPop?.dismiss(animated: true, completion: nil)
            showHomeVC()
            plusVC.dismiss(animated: true) {
                if let _vc = self.homeVC.children[0] as? OTHomeMainViewController {
                    _vc.showFeedInfo(feedItem: entourage)
                }
            }
        }
    }
}

//MARK: - UITabBarControllerDelegate -
extension OTMainTabbarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 2 {
            self.showMapOption()
            
            return false
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag != 2 {
            oldItemSelected = currentItemSelected
            currentItemSelected = item.tag
            boldSelectedItem()
        }
    }

    func showHomeVC(isEditor:Bool = false) {
        if self.selectedIndex != 0 {
            self.selectedIndex = 0
        }
        
        if !isEditor {
            homeVC.popToRootViewController(animated: false)
        }
        //homeVC.popToRootViewController(animated: false)
        boldSelectedItem()
    }
}
