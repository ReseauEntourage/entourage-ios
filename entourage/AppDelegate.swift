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
    var environmentConfigManager: EnvironmentConfigurationManager?

    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        // Notifications: mettre le delegate AVANT la demande d’autorisation
        UNUserNotificationCenter.current().delegate = self

        // Clavier
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false

        // Environnement / Services
        initEnvironmentConfigManager()
        configureGooglePlace()
        configureFirebase()

        // Push (autorisation + inscription APNs)
        setupPushNotifications(application: application)

        // Observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goLogin),
                                               name: NSNotification.Name(notificationLoginError),
                                               object: nil)

        // Routage initial selon session
        if UserDefaults.currentUser == nil || A0SimpleKeychain().string(forKey: kKeychainPassword) == nil {
            AppState.navigateToStartupScreen()
            return true
        }

        // Lancement via notification
        if let datas = launchOptions?[.remoteNotification] as? [String: Any] {
            Logger.print("***** recup notif from launch : \(datas)")
            handleAppLaunchFromNotificationCenter(userInfos: datas)
        } else {
            AppState.checkNotifcationsAndGoMainScreen()
        }

        incrementConnectionCount()
        return true
    }

    // MARK: - Push setup
    private func setupPushNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            print("Notifications granted? \(granted)")
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
                print("isRegisteredForRemoteNotifications? \(UIApplication.shared.isRegisteredForRemoteNotifications)")
            }
        }
    }

    // MARK: - Env/Services
    private func initEnvironmentConfigManager() {
        environmentConfigManager = EnvironmentConfigurationManager.sharedInstance
    }

    private func configureGooglePlace() {
        guard let environmentConfigManager = environmentConfigManager else { return }
        GMSPlacesClient.provideAPIKey(environmentConfigManager.GooglePlaceApiKey as String)
    }

    private func configureFirebase() {
        guard let environmentConfigManager = environmentConfigManager else { return }
        let firebasePlistName = environmentConfigManager.runsOnStaging
            ? "GoogleService-Info-social.entourage.ios.beta"
            : "GoogleService-Info"

        guard let filePath = Bundle.main.path(forResource: firebasePlistName, ofType: "plist"),
              let firebaseOptions = FirebaseOptions(contentsOfFile: filePath) else { return }

        FirebaseConfiguration.init().setLoggerLevel(.min)
        FirebaseApp.configure(options: firebaseOptions)

        // Analytics
        Analytics.setUserProperty(kUserAuthenticationLevelAuthenticated, forName: "AuthenticationLevel")
        AnalyticsLoggerManager.updateAnalyticsWitUser()

        // Firebase Messaging
        Messaging.messaging().delegate = self

        // Optionnel : fetch explicite du token FCM (utile en debug)
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
            } else {
                print("FCM token: \(token ?? "nil")")
                // → Envoie-le à ton backend si nécessaire
            }
        }
    }

    // MARK: - Session / Login
    @objc func goLogin() {
        DispatchQueue.main.async {
            AppState.clearDatas(withKeychain: true)
            AppState.navigateToStartupScreen()
        }
    }

    // MARK: - Compteur de connexions (tel quel)
    func incrementConnectionCount() {
        let defaults = UserDefaults.standard
        let currentCount = defaults.integer(forKey: "connectionCount")
        let newCount = currentCount + 1
        defaults.set(newCount, forKey: "connectionCount")
    }

    // MARK: - Lancement via notif
    func handleAppLaunchFromNotificationCenter(userInfos: [String: Any]) {
        self.handleNotification(userInfos: userInfos, isFromBackground: true, isFromStart: true)
        AppState.checkNotifcationsAndGoMainScreen()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // laissé vide comme dans ta version
    }

    // MARK: - Universal links
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard let incomingURL = userActivity.webpageURL else { return false }
        guard let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: false) else { return false }
        UniversalLinkManager.handleUniversalLink(components: components)
        return true
    }

    // MARK: - Deeplinks (URL Schemes)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
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
                _ = pathIterator.next() // outingUUID
            case "neighborhoods":
                _ = pathIterator.next() // neighborhoodUUID
            case "conversations":
                _ = pathIterator.next() // conversationUUID
            case "solicitations":
                _ = pathIterator.next() // solicitationUUID
            case "contributions":
                _ = pathIterator.next() // contributionUUID
            case "resources":
                _ = pathIterator.next() // resourceUUID
            default:
                break
            }
        }
    }

    // MARK: - Utilitaires UI
    func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    // MARK: - Parsing / Routage de notifications
    func handleNotification(userInfos: [String: Any]?, isFromBackground: Bool, isFromStart: Bool) {
        Logger.print("***** handle notifs \(userInfos)")
        Logger.print("***** isFrom BG : \(isFromBackground)")
        Logger.print("***** isFrom Start : \(isFromStart)")

        if let userInfos = userInfos,
           let content = userInfos["content"] as? [String: Any],
           let extras = content["extra"] as? [String: Any],
           let stage = extras["stage"] as? String {

            if let popup = extras["popup"] as? String, popup == "outing_on_day_before" {
                if let instanceId = extras["instance_id"] as? Int {
                    DeepLinkManager.showHomeUniversalLinkWithParam(instanceId)
                }
            }

            if stage == "h1" { DeepLinkManager.showWelcomeOne();   return }
            if stage == "j2" { DeepLinkManager.showWelcomeTwo();   return }
            if stage == "j5" { DeepLinkManager.showWelcomeThree(); return }
            if stage == "j8" { DeepLinkManager.showWelcomeFour();  return }
            if stage == "j11"{ DeepLinkManager.showWelcomeFive();  return }
        }

        guard let userInfos = userInfos,
              let content = userInfos["content"] as? [String: Any],
              let extras = content["extra"] as? [String: Any],
              let instance = extras["instance"] as? String,
              let instanceId = extras["instance_id"] as? Int
        else {
            return
        }

        Logger.print("***** extras : \(extras) ")
        Logger.print("***** Instance : \(instance) - id : \(instanceId)")
        let postId = extras["post_id"] as? Int
        Logger.print("***** post id : \(String(describing: postId)) ")
        let notifData = NotificationPushData(instanceName: instance, instanceId: instanceId, postId: postId)

        if isFromBackground {
            DeepLinkManager.presentAction(notification: notifData)
        } else if isFromStart {
            DeepLinkManager.presentAction(notification: notifData)
        }

        // Update badge count
        if let _aps = userInfos["aps"] as? [String: Any], let _badge = _aps["badge"] as? Int {
            UserDefaults.badgeCount = _badge
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateCount), object: nil)
        }
    }
}

// MARK: - Notifications (APNs + UNUserNotificationCenter)
extension AppDelegate: UNUserNotificationCenterDelegate {

    // APNs OK -> on transmet le token à Firebase
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.didRegisterForRemoteNotificationsWithDeviceToken(token: deviceToken)
        Messaging.messaging().apnsToken = deviceToken
    }

    // APNs KO
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    // Touche une notification (app fg/bg)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let dictNotif = response.notification.request.content.userInfo as? [String: Any]
        self.handleNotification(userInfos: dictNotif, isFromBackground: true, isFromStart: false)
        completionHandler() // important
    }

    // Réception en foreground (affichage contrôlé)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let dictNotif = notification.request.content.userInfo as? [String: Any]
        self.handleNotification(userInfos: dictNotif, isFromBackground: false, isFromStart: false)

        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
}

// MARK: - Firebase Messaging
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Logger.print("***** Messaging receive messaging token ? \(messaging) - \(String(describing: fcmToken))")
        // Option: envoyer au backend ici
    }
}
