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
import SimpleKeychain

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
        
        if UserDefaults.currentUser == nil || A0SimpleKeychain().string(forKey:kKeychainPassword) == nil {
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
            AppState.clearDatas(withKeychain: true)
            AppState.navigateToStartupScreen()
        }
    }
    
    func handleAppLaunchFromNotificationCenter(userInfos:[String:Any]) {
        self.handleNotification(userInfos: userInfos, isFromBackground: true, isFromStart: true)
        AppState.checkNotifcationsAndGoMainScreen()
        
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    //Universal links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard let incomingURL = userActivity.webpageURL else { return false }
        print("eho incoming url " , incomingURL)
        guard let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: false) else { return false }
        UniversalLinkManager.handleUniversalLink(components:components)
        return true
    }
    
    //Deeplinks
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        handleDeepLink(url: url)
        return true
    }

    private func handleDeepLink(url: URL) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let pathComponents = components.path?.split(separator: "/") else { return }
        
        var pathIterator = pathComponents.makeIterator()
        
        while let pathComponent = pathIterator.next() {
            switch pathComponent {
            case "outings":
                guard let outingUUID = pathIterator.next() else { break }
                // Handle outings
            case "neighborhoods":
                guard let neighborhoodUUID = pathIterator.next() else { break }
                // Handle neighborhoods
            case "conversations":
                guard let conversationUUID = pathIterator.next() else { break }
                // Handle conversations
            case "solicitations":
                guard let solicitationUUID = pathIterator.next() else { break }
                // Handle solicitations
            case "contributions":
                guard let contributionUUID = pathIterator.next() else { break }
                // Handle contributions
            case "resources":
                guard let resourceUUID = pathIterator.next() else { break }
                // Handle resources
            default:
                break
            }
        }
    }
    
    func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    
    func handleNotification(userInfos:[String:Any]?, isFromBackground:Bool, isFromStart:Bool) {
        Logger.print("***** handle notifs \(userInfos)")
        Logger.print("***** isFrom BG : \(isFromBackground)")
        Logger.print("***** isFrom Start : \(isFromStart)")
        
        if let userInfos = userInfos, let content = userInfos["content"] as? [String:Any],let extras = content["extra"] as? [String:Any], let stage = extras["stage"] as? String {
            if stage == "h1" {
                DeepLinkManager.showWelcomeOne()
                return
            }
            if stage == "j2" {
                DeepLinkManager.showWelcomeTwo()
                return
            }
            if stage == "j5" {
                DeepLinkManager.showWelcomeThree()
                return
            }
            if stage == "j8" {
                DeepLinkManager.showWelcomeFour()
                return
            }
            if stage == "j11" {
                DeepLinkManager.showWelcomeFive()
                return
            }
            
        }
        
        guard let userInfos = userInfos,let content = userInfos["content"] as? [String:Any], let extras = content["extra"] as? [String:Any],let instance = extras["instance"] as? String, let instanceId = extras["instance_id"] as? Int  else {
            return
        }
        
        
        Logger.print("***** extras : \(extras) ")
        Logger.print("***** Instance : \(instance) - id : \(instanceId)")
        let postId = extras["post_id"] as? Int
        Logger.print("***** post id : \(postId) ")
        let notifData = NotificationPushData(instanceName: instance, instanceId: instanceId, postId: postId)
        
        if isFromBackground {
            DeepLinkManager.presentAction(notification: notifData)
        }
        else if isFromStart {
            DeepLinkManager.presentAction(notification: notifData)
        }
        //Update badge count
        
        if let _aps = userInfos["aps"] as? [String:Any], let _badge = _aps["badge"] as? Int {
            UserDefaults.badgeCount = _badge
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateCount), object: nil)
        }
    }
}

//MARK: - Notifications
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
