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
    
    var isAskForHelp = false
    var addEditEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor.appOrange()
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        
        delegate = self
        
       setupVCs()
    }
    
    func setupVCs() {
        let  _homeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OTMain") as! OTMainViewController
        
        homeVC = UINavigationController.init(rootViewController: _homeVC)
        homeVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"à proximité")
        homeVC.tabBarItem.image = UIImage.init(named: "ic_tab_home")?.withRenderingMode(.alwaysOriginal)
        homeVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_home_selected")
        
        let _guideVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OTMain") as! OTMainViewController
        _guideVC.isSolidarityGuide = true
        guideVC = UINavigationController.init(rootViewController: _guideVC)
        guideVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"annuaire")
        guideVC.tabBarItem.image = UIImage.init(named: "ic_tab_guide")?.withRenderingMode(.alwaysOriginal)
        guideVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_guide_selected")
        
        plusVC.tabBarItem.title = ""
        plusVC.tabBarItem.tag = 2
        plusVC.tabBarItem.image = UIImage.init(named: "ic_tab_plus_selected")?.withRenderingMode(.alwaysOriginal)
        plusVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_plus_selected")
        
        let _messagesVC = UIStoryboard.myEntourages()?.instantiateViewController(withIdentifier: "OTMyEntouragesViewController") as! OTMyEntouragesViewController
        messagesVC = UINavigationController.init(rootViewController: _messagesVC)
        messagesVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"messagerie")
        messagesVC.tabBarItem.image = UIImage.init(named: "ic_tab_message")?.withRenderingMode(.alwaysOriginal)
        messagesVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_message_selected")
        
        let _menuVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OTMenuViewControllerIdentifier") as! OTMenuViewController
        menuVC = UINavigationController.init(rootViewController: _menuVC)
        menuVC.tabBarItem.title = OTLocalisationService.getLocalizedValue(forKey:"menu")
        menuVC.tabBarItem.image = UIImage.init(named: "ic_tab_menu")?.withRenderingMode(.alwaysTemplate)
        //  menuVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_menu_selected")
        
        viewControllers = [homeVC,guideVC,plusVC,messagesVC,menuVC]
        
        boldSelectedItem()
    }
    
    func boldSelectedItem() {
        let regularFont = UIFont.init(name: "SFUIText-Regular", size: 13)
        let regularTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.darkGray,NSAttributedString.Key.font:regularFont!]
        
        for item in tabBar.items! {
            item.setTitleTextAttributes(regularTextAttr as [NSAttributedString.Key : Any], for: .normal)
        }
        
        let selectedFont = UIFont.init(name: "SFUIText-Bold", size: 13)
               let selectionTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.appOrange()!,NSAttributedString.Key.font:selectedFont!]
        
         tabBar.selectedItem?.setTitleTextAttributes(selectionTextAttr as [NSAttributedString.Key : Any], for: .normal)
    }
    
    func showMapOption() {
        OTLogger.logEvent(Action_Plus_Agir)
        let storyb = UIStoryboard.init(name: "MapOptions", bundle: nil)
        if let vc = storyb.instantiateViewController(withIdentifier: "MapOptions") as? OTMapOptionsViewController {
            vc.optionsDelegate = self
            
            self.present(vc, animated: true, completion: nil)
        }
    }
}

//MARK: - OTOptionsDelegate -
extension OTMainTabbarViewController: OTOptionsDelegate {
    
    func createTour() {
        self.showHomeVC()
        if let _vc = homeVC.topViewController as? OTMainViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.createTourFromNav()
            }
        }
    }
    
    func createEncounter() {
        self.showHomeVC()
        if let _vc = homeVC.topViewController as? OTMainViewController {
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                _vc.createEncounterFromNav()
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
            if let vc = navController.children[0] as? OTEntourageEditorViewController {
                let location = OTLocationManager.sharedInstance()?.defaultLocationForNewActions()
                vc.location = location
                vc.entourageEditorDelegate = self
                vc.isAskForHelp = self.isAskForHelp
                vc.isEditingEvent = self.addEditEvent
                vc.type = nil
                
                self.show(navController, sender: nil)
                self.showHomeVC()
            }
        }
    }
}

//MARK: - EntourageEditorDelegate -
extension OTMainTabbarViewController: EntourageEditorDelegate {
    func didEdit(_ entourage: OTEntourage!) {
        (self.homeVC.children[0] as! OTMainViewController).didEdit(entourage)
    }
}

//MARK: - UITabBarControllerDelegate -
extension OTMainTabbarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        Logger.print("***** Should select tab : \(viewController.tabBarItem.tag) selected : \(tabBarController.selectedIndex)")
        if viewController.tabBarItem.tag == 2 {
            self.showMapOption()
            
            return false
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag != 2 {
            boldSelectedItem()
        }
    }

    func showHomeVC() {
        if self.selectedIndex != 0 {
            self.selectedIndex = 0
        }
        boldSelectedItem()
    }
}
