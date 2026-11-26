//
//  AnalyticsManager.swift
//  entourage
//
//  Created by Jerome on 01/06/2022.
//

import Foundation
import FirebaseAnalytics

struct AnalyticsLoggerManager {
    
    /// Couture de test : quand elle est posée, les événements lui sont remis au lieu de partir vers Firebase.
    static var eventSink: ((_ name: String, _ parameters: [String: Any]?) -> Void)?

    static func logEvent(name:String, parameters:[String : Any]? = nil) {
        if let sink = eventSink { return sink(name, parameters) }
        Analytics.logEvent(name, parameters: parameters)
    }
 
    static func updateAnalyticsWitUser() {
        if let user = UserDefaults.currentUser {
            Analytics.setUserID("\(user.sid)")
            if let name = user.partner?.name {
                Analytics.setUserProperty(name, forName: "EntouragePartner")
            }
            
            if !user.type.isEmpty {
                Analytics.setUserProperty(user.type, forName: "EntourageUserType")
            }
            
            if let lang = Locale.preferredLanguages.first {
                Analytics.setUserProperty(lang, forName: "Language")
            }
        }
    }
}
