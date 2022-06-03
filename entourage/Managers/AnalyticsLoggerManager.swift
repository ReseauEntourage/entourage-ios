//
//  AnalyticsManager.swift
//  entourage
//
//  Created by Jerome on 01/06/2022.
//

import Foundation
import FirebaseAnalytics

struct AnalyticsLoggerManager {
    
    static func logEvent(name:String, parameters:[String : Any]? = nil) {
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
