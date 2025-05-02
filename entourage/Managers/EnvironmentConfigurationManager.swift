//
//  EnvironmentConfigurationManager.swift
//  entourage
//
//  Use this manager to get private informations like keys and token for differents API services.
//
//  Mod by Jerome on 2022.
//

import Foundation


struct UserStorageKey {
    static let environment = "environment"
    static let APIHostURL = "ApiBaseUrl"
    
    static let APIKey = "ApiKey"
    static let amazonPictureFolder = "AmazonPictureFolder"
    static let amazonAccessKey = "AmazonAccessKey"
    static let amazonSecretKey = "AmazonSecretKey"
    static let mixpanelToken = "MixpanelToken"
    static let awsPictureBucket = "AwsPictureBucket"
    static let environmentTypeKey = "EnvironmentType"
    static let googlePlaceApiKey = "GooglePlaceApiKey"
}

class EnvironmentConfigurationManager {
    
    static let sharedInstance = EnvironmentConfigurationManager()
    
    private init() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        self.config = EnvironmentConfigurationManager.plist(name: "AppConfigurations", bundleId: bundleId)
        self.apiKeys = EnvironmentConfigurationManager.plist(name: "ApiKeys", bundleId: bundleId)
        self.communityConfig = EnvironmentConfigurationManager.communityPlist()
    }
    
    private var config: NSDictionary?
    private var apiKeys: NSDictionary?
    private var communityConfig: NSDictionary?
    private let stagingEnvironmentName: String = "staging"
    private let prodEnvironmentName: String = "prod"
    
    var baseURL: String {
        if runsOnProduction {
            return "https://www.entourage.social"
        } else {
            return "https://preprod.entourage.social"
        }
    }
    
    var configCopy: NSDictionary? {
        get { return config }
    }
    
    var community: NSDictionary {
        return self.communityConfig!
    }
    
    var amazonAccessKey: NSString {
        return configuration(forKey: UserStorageKey.amazonAccessKey)
    }
    
    var amazonSecretKey: NSString {
        return configuration(forKey: UserStorageKey.amazonSecretKey)
    }
    
    var amazonPictureFolder: NSString {
        return configuration(forKey: UserStorageKey.amazonPictureFolder)
    }
    
    var APIHostURL: NSString {
        return configuration(forKey: UserStorageKey.APIHostURL)
    }
    
    var APIKey: NSString {
        return apiKeysConfiguration(forKey: UserStorageKey.APIKey)
    }
    
    var MixpanelToken : NSString {
        return configuration(forKey: UserStorageKey.mixpanelToken)
    }
    
    var AwsPictureBucket : NSString {
        return configuration(forKey: UserStorageKey.awsPictureBucket)
    }
    
    var GooglePlaceApiKey : NSString {
        return configuration(forKey: UserStorageKey.googlePlaceApiKey)
    }
    
    var environmentName : String {
        return configuration(forKey: UserStorageKey.environmentTypeKey) as String
    }
    
   var runsOnProduction: Bool {
        return self.environmentName == prodEnvironmentName
    }
    
    var runsOnStaging: Bool {
        return self.environmentName == stagingEnvironmentName
    }
    
    private func configuration(forKey: String) -> NSString {
        return self.config![forKey] as! NSString
    }
    
    private func apiKeysConfiguration(forKey: String) -> NSString {
        return self.apiKeys![forKey] as! NSString
    }
    
    private static func plist(name: String, bundleId:String) -> NSDictionary? {
        guard let plistFile = Bundle.main.path(forResource: name, ofType: "plist"),
            let config:NSDictionary = NSDictionary(contentsOfFile: plistFile) else {
                return nil
        }
        
        if let plist:NSDictionary = config.object(forKey: bundleId) as? NSDictionary {
            return plist
        }
        
        return nil
    }

    private static func communityPlist() -> NSDictionary? {
        guard let plistFile = Bundle.main.path(forResource: "CommunityConfig", ofType: "plist"),
            let config:NSDictionary = NSDictionary(contentsOfFile: plistFile) else {
                return nil
        }
        
        return config
    }
}
