//
//  NotificationManager.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation
import Firebase
import FirebaseMessaging

struct NotificationManager {
    static func promptUserForAuthorizations() {
        let notifCenter = UNUserNotificationCenter.current()
        notifCenter.requestAuthorization(options: self.getNotifsOptions()) { granted, error in
            if error == nil {
                self.refreshPushDemand()
            }
        }
    }
    
    private static func refreshPushDemand() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    static func didRegisterForRemoteNotificationsWithDeviceToken(token:Data) {
        let tokenStr = self.deviceTokenString(data: token)
        Logger.print("***** token str ? \(tokenStr)")
        print("eho token ", tokenStr)
        UserDefaults.pushToken = tokenStr
        if let _ = UserDefaults.currentUser {
            self.getAuthorizationStatusWithCompletionHandler { status in
                AuthService.sendPushTokenToAppInfo(pushToken: tokenStr, notifStatus: self.authorizationStatus(status: status)) { error in
                    //TODO: enregistrement dans plist ?
                }
            }
        }
    }
    
    private static func getAuthorizationStatusWithCompletionHandler(completion: @escaping (_ status:UNAuthorizationStatus) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    //MARK: - Convienent methods -
    private static func getNotifsOptions() -> UNAuthorizationOptions{
        return UNAuthorizationOptions(arrayLiteral: [UNAuthorizationOptions.badge,UNAuthorizationOptions.sound,UNAuthorizationOptions.alert])
    }
    
    private static func authorizationStatus(status:UNAuthorizationStatus) -> String {
        switch(status) {
        case .notDetermined:
            return "not_determined"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        default:
            if #available(iOS 12.0, *) {
                if status == .provisional {
                    return "provisional"
                }
            }
            return ""
        }
    }
    
    private static func deviceTokenString(data:Data) -> String {
        let tokenParts = data.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        return tokenParts.joined()
    }
}
