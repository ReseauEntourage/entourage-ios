//
//  AppDelegate.swift
//  entourageios
//
//  Created by Jerome on 11/01/2022.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import GooglePlaces
import Firebase
import FirebaseMessaging
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var environmentConfigManager:EnvironmentConfigurationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        UNUserNotificationCenter.current().delegate = self
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        initEnvironmentConfigManager()
        configureGooglePlace()
        configureFirebase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(goLogin), name: NSNotification.Name(notificationLoginError), object: nil)
        
        if UserDefaults.currentUser == nil {
            AppState.navigateToStartupScreen()
            return true
        }
        
        if let datas = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String:Any] {
            /*
             [[OTLocationManager sharedInstance] startLocationUpdates];
             */
            Logger.print("***** recup notif from launch : \(datas)")
            handleAppLaunchFromNotificationCenter(userInfos: datas)
        }
        else {
            AppState.checkNotifcationsAndGoMainScreen()
        }
        return true
    }
    
    private func initEnvironmentConfigManager() {
        environmentConfigManager = EnvironmentConfigurationManager.sharedInstance
    }
    
    private func configureGooglePlace() {
        guard let environmentConfigManager = environmentConfigManager else { return }
        GMSPlacesClient.provideAPIKey(environmentConfigManager.GooglePlaceApiKey as String)
    }
    
    private func configureFirebase() {
        guard let environmentConfigManager = environmentConfigManager else { return }
        let firebasePlistName = environmentConfigManager.runsOnStaging ? "GoogleService-Info-social.entourage.ios.beta" : "GoogleService-Info"
        
        guard let filePath = Bundle.main.path(forResource: firebasePlistName, ofType: "plist"), let firebaseOptions = FirebaseOptions(contentsOfFile: filePath) else { return  }
        
        FirebaseConfiguration.init().setLoggerLevel(.min)
        FirebaseApp.configure(options: firebaseOptions)
        Analytics.setUserProperty(kUserAuthenticationLevelAuthenticated, forName: "AuthenticationLevel")
        
        FirebaseMessaging.Messaging.messaging().delegate = self
        
        AnalyticsLoggerManager.updateAnalyticsWitUser()
    }
    
    @objc func goLogin() {
        DispatchQueue.main.async {
            AppState.clearDatas()
            AppState.navigateToStartupScreen()
        }
    }
    
    func handleAppLaunchFromNotificationCenter(userInfos:[String:Any]) {
        self.handleNotification(userInfos: userInfos, isFromBackground: true, isFromStart: true)
        
        AppState.checkNotifcationsAndGoMainScreen()
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func handleNotification(userInfos:[String:Any]?, isFromBackground:Bool, isFromStart:Bool) {
        Logger.print("***** handle notifs \(userInfos)")
        Logger.print("***** isFrom BG : \(isFromBackground)")
        Logger.print("***** isFrom Start : \(isFromStart)")
        
        guard let userInfos = userInfos,let content = userInfos["content"] as? [String:Any], let extras = content["extra"] as? [String:Any],let instance = extras["instance"] as? String, let instanceId = extras["id"] as? Int else {
            return
        }
        Logger.print("***** extras : \(extras) ")
        Logger.print("***** Instance : \(instance) - id : \(instanceId)")
        
        let notifData = NotificationPushData(instanceName: instance, instanceId: instanceId)
        
        if isFromBackground {
            //TODO: go Page
            Logger.print("***** NotifData : \(notifData) ")
            
            DeepLinkManager.presentAction(notification: notifData)
        }
        else if isFromStart {
            //TODO: Go page ?
        }
        else {
            Logger.print("***** \(userInfos["aps"])")
            //TODO: update count tabbar
            if let _aps = userInfos["aps"] as? [String:Any], let _badge = _aps["badge"] as? Int {
                Logger.print("***** Show Badge count : \(_badge)")
            }
        }
    }
}

//MARK: - Notifications - A faire
extension AppDelegate: UNUserNotificationCenterDelegate {
    //MARK: - Push -
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.didRegisterForRemoteNotificationsWithDeviceToken(token: deviceToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let dictNotif = response.notification.request.content.userInfo as? [String:Any]
        self.handleNotification(userInfos: dictNotif, isFromBackground: true,isFromStart: false)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let dictNotif = notification.request.content.userInfo as? [String:Any]
        self.handleNotification(userInfos: dictNotif, isFromBackground: false,isFromStart: false)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Logger.print("***** Messaging receive messaging token ? \(messaging) - \(fcmToken)")
    }
}
