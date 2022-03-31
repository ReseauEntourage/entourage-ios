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
    var guideVC:UINavigationController!
    var plusVC:UINavigationController!
    var messagesVC:UINavigationController!
    var menuVC:UINavigationController!
    
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
        
//        NotificationCenter.default.addObserver(self, selector: #selector(hidePopInfo), name: NSNotification.Name(rawValue: "hidePopView"), object: nil)//TODO: a faire ?
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showActions), name: NSNotification.Name(rawValue: "showAlls"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(showEvents), name: NSNotification.Name(rawValue: "showEvents"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tapProfilTab), name: NSNotification.Name(rawValue: "tapProfilTab"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showHome), name: NSNotification.Name(rawValue: "showHome"), object: nil)
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
    
  
    @objc func switchToHomeTab() {
        showHomeVC()
    }
    
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
        let  _homeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainHomeVC")
        
        homeVC = UINavigationController.init(rootViewController: _homeVC)
        homeVC.tabBarItem.title = "Users".localized
        homeVC.tabBarItem.image = UIImage.init(named: "ic_tab_users")?.withRenderingMode(.alwaysOriginal)
        homeVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_users")
        homeVC.tabBarItem.tag = 0
        
        let _guideVC = UIStoryboard.init(name: "GuideSolidarity", bundle: nil).instantiateViewController(withIdentifier: "MainGuide")
        guideVC = UINavigationController.init(rootViewController: _guideVC)
        guideVC.tabBarItem.title = "guide".localized
        guideVC.tabBarItem.image = UIImage.init(named: "ic_tab_guide")?.withRenderingMode(.alwaysOriginal)
        guideVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_guide")
        guideVC.tabBarItem.tag = 1
        
        let _plusVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main2VC")

        plusVC = UINavigationController.init(rootViewController: _plusVC)
        plusVC.tabBarItem.title = "Tab+".localized
        plusVC.tabBarItem.accessibilityLabel = "Action +"
        plusVC.tabBarItem.tag = 2
        plusVC.tabBarItem.image = UIImage.init(named: "ic_tab_plus_selected")?.withRenderingMode(.alwaysOriginal)
        plusVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_plus_selected")
        

        let _messagesVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main3VC")

        messagesVC = UINavigationController.init(rootViewController: _messagesVC)
        messagesVC.tabBarItem.title = "message".localized
        messagesVC.tabBarItem.image = UIImage.init(named: "ic_tab_message")?.withRenderingMode(.alwaysOriginal)
        messagesVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_message_selected")
        messagesVC.tabBarItem.tag = 3
        
        let _menuVC = UIStoryboard.init(name: "ProfileParams", bundle: nil).instantiateViewController(withIdentifier: "mainProfileParamsVC")
        menuVC = UINavigationController.init(rootViewController: _menuVC)
        menuVC.isNavigationBarHidden = true
        menuVC.tabBarItem.title = "profil".localized
        menuVC.tabBarItem.image = UIImage.init(named: "ic_tab_profile")?.withRenderingMode(.alwaysTemplate)
        menuVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_profile")
        menuVC.tabBarItem.tag = 4
        viewControllers = [menuVC,homeVC,guideVC,plusVC,messagesVC]
        
        boldSelectedItem()
    }
    
    @objc func boldSelectedItem() {
        let regularFont = UIFont.systemFont(ofSize: 13, weight: .regular)
       // let regularFont = UIFont.init(name: "SFUIText-Regular", size: 13)
        let regularTextAttr:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.darkGray,NSAttributedString.Key.font:regularFont]
        
        for item in tabBar.items! {
            item.setTitleTextAttributes(regularTextAttr as [NSAttributedString.Key : Any], for: .normal)
        }
        let selectedFont = UIFont.systemFont(ofSize: 13, weight: .bold)
       // let selectedFont = UIFont.init(name: "SFUIText-Bold", size: 13)
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
        
        if item.tag == 3 {
//                if let nav = messagesVC, let vc = nav.viewControllers[0] as? OTMyEntourageMainViewController {
//                    vc.setupVcsAfterTapTabbar()
//                }
        }
    }

    func showHomeVC(isEditor:Bool = false) {
        if self.selectedIndex != 0 {
            self.selectedIndex = 0
        }
        
//        if !isEditor {
//            homeVC.popToRootViewController(animated: false)
//            (homeVC.topViewController as? OTHomeMainViewController)?.isFromProfile = true
//        }
        //homeVC.popToRootViewController(animated: false)
        boldSelectedItem()
    }
}
