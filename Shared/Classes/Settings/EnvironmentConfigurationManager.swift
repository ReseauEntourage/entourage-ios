import Foundation

extension String {
    var userPreferences: String {
        // swiftlint:disable:next force_cast
        return UserDefaults.standard.string(forKey: self)!
    }
}

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

@objc enum ApplicationType:Int {
    case entourage = 0
    case voisinAge = 1
}

@objc class EnvironmentConfigurationManager: NSObject {
    
    private var config: NSDictionary?
    private var apiKeys: NSDictionary?
    private let stagingEnvironmentName: String = "staging"
    private let prodEnvironmentName: String = "prod"
    
    @objc var applicationType: ApplicationType = ApplicationType.entourage
    
    @objc convenience init(bundleId:String) {
        self.init()
        self.config = EnvironmentConfigurationManager.plist(name: "AppConfigurations", bundleId: bundleId)
        self.apiKeys = EnvironmentConfigurationManager.plist(name: "ApiKeys", bundleId: bundleId)
        
    #if PFP
        self.applicationType = ApplicationType.voisinAge
    #endif
        
    }
    
    @objc var amazonAccessKey: NSString {
        return configuration(forKey: UserStorageKey.amazonAccessKey)
    }
    
    @objc var amazonSecretKey: NSString {
        return configuration(forKey: UserStorageKey.amazonSecretKey)
    }
    
    @objc var amazonPictureFolder: NSString {
        return configuration(forKey: UserStorageKey.amazonPictureFolder)
    }
    
    @objc var APIHostURL: NSString {
        return configuration(forKey: UserStorageKey.APIHostURL)
    }
    
    @objc var APIKey: NSString {
        return apiKeysConfiguration(forKey: UserStorageKey.APIKey)
    }
    
    @objc var MixpanelToken : NSString {
        return configuration(forKey: UserStorageKey.mixpanelToken)
    }
    
    @objc var AwsPictureBucket : NSString {
        return configuration(forKey: UserStorageKey.awsPictureBucket)
    }
    
    @objc var GooglePlaceApiKey : NSString {
        return configuration(forKey: UserStorageKey.googlePlaceApiKey)
    }
    
    @objc var environmentName : NSString {
        return configuration(forKey: UserStorageKey.environmentTypeKey)
    }
    
    @objc var runsOnProduction: Bool {
        return self.environmentName as String == prodEnvironmentName
    }
    
    @objc var runsOnStaging: Bool {
        return self.runsOnProduction == false
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
}
