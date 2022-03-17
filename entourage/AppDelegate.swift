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


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var environmentConfigManager:EnvironmentConfigurationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        UNUserNotificationCenter.current().delegate = self
        
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
    }
    
    @objc func goLogin() {
        DispatchQueue.main.async {
            AppState.clearDatas()
            AppState.navigateToStartupScreen()
        }
    }
    
    func handleAppLaunchFromNotificationCenter(userInfos:[String:Any]) {
        //TODO: parse notif - redirect vers le bon endroit ?
        AppState.checkNotifcationsAndGoMainScreen()
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}

//MARK: - Notifications - A faire
extension AppDelegate: UNUserNotificationCenterDelegate {
    //MARK: - Push -
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.didRegisterForRemoteNotificationsWithDeviceToken(token: deviceToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //TODO: à faire
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //TODO: à faire
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Logger.print("***** Messaging receive messaging token ? \(messaging) - \(fcmToken)")
    }
}
