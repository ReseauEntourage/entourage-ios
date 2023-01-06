//
//  AppState.swift
//  entourage
//
//  Created by Jerome on 12/01/2022.
//

import Foundation
import SimpleKeychain

struct AppState {
    
    static func checkNotifcationsAndGoMainScreen() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            var status = settings.authorizationStatus
            
            if #available(iOS 12.0, *) {
                if status == UNAuthorizationStatus.provisional {
                    status = UNAuthorizationStatus.notDetermined
                }
            }
            
            DispatchQueue.main.async {
                if status == UNAuthorizationStatus.notDetermined {
                    self.showPopNotification { isAccept in}
                }
                else {
                    NotificationManager.promptUserForAuthorizations()
                }
            }
        }
        AppState.navigateToMainApp()
    }
    
    static func showPopNotification(completion: @escaping (_ isAccept:Bool) -> Void){
        let alertVC = UIAlertController.init(title:  "pop_notification_title".localized, message:  "pop_notification_description".localized, preferredStyle: .alert)
        
        let actionValidate = UIAlertAction.init(title: "pop_notification_bt_activate".localized, style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
            completion(true)
            NotificationManager.promptUserForAuthorizations()
        }
        
        let actionCancel = UIAlertAction.init(title: "pop_notification_bt_cancel".localized, style: .cancel) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
            completion(false)
        }
        alertVC.addAction(actionCancel)
        alertVC.addAction(actionValidate)
        
        DispatchQueue.main.async {
            AppState.getTopViewController()?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    static func navigateToStartupScreen() {
        clearDatas()
        let sb = UIStoryboard.init(name: StoryboardName.intro, bundle: nil)
        let vc = sb.instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    static func navigateToMainApp() {
        let tabbar = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateInitialViewController() as! MainTabbarViewController // MainTabbarViewController()
        tabbar.selectedIndex = 0
        tabbar.boldSelectedItem()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabbar
        appDelegate.window?.makeKeyAndVisible()
    }
    
    static func getTopViewController() -> UIViewController? {
        return UIApplication.shared.topFrontViewController
    }
    
    static func continueFromLoginVC() {
        DispatchQueue.main.async {
            self.checkNotifcationsAndGoMainScreen()
        }
    }
    
    static func navigateToLoginScreen(deeplink:NSURL, senderController:UIViewController) {
        
        let loginVc = UIStoryboard.init(name: StoryboardName.intro, bundle: nil).instantiateViewController(withIdentifier: "LoginV2VC") as! OTLoginV2ViewController
        loginVc.deeplink = deeplink as URL;
        
        getTopViewController()?.show(loginVc, sender: self)
    }
    
    static func clearDatas() {
        
        UserDefaults.currentUser = nil
        UserDefaults.temporaryUser = nil
        UserDefaults.pushToken = nil
        
        SimpleKeychain.A0SimpleKeychain().deleteEntry(forKey: kKeychainPhone)
        SimpleKeychain.A0SimpleKeychain().deleteEntry(forKey: kKeychainPassword)
    }
}
