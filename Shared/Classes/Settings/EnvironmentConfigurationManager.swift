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
    static let mixpanelKey = "MixpanelKey"
    static let mixpanelSecretKey = "MixpanelSecretKey"
}

@objc enum ApplicationType:Int {
    case entourage = 0
    case voisinAge = 1
}

@objc class EnvironmentConfigurationManager: NSObject {
    
    private var plist: NSDictionary?
    private let stagingEnvironmentName: String = "staging"
    private let prodEnvironmentName: String = "prod"
    
    @objc var environmentName: String = ""
    @objc var awsPictureBucket: String = "entourage-avatars-production-thumb"
    @objc var applicationType: ApplicationType = ApplicationType.entourage
    
    @objc convenience init(bundleId:String) {
        self.init()
        self.environmentName = self.plistFileName(bundleId: bundleId)
        self.plist = EnvironmentConfigurationManager.plist(name: self.environmentName)
        
    #if PFP
        self.applicationType = ApplicationType.voisinAge
        self.awsPictureBucket = "entourage-avatars-production-thumb/pfp"
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
        return configuration(forKey: UserStorageKey.APIKey)
    }
    
    @objc var MixpanelToken : NSString {
        return configuration(forKey: UserStorageKey.mixpanelToken)
    }
    
    @objc var MixpanelKey: NSString {
        return configuration(forKey: UserStorageKey.mixpanelKey)
    }
    
    @objc var MixpanelSecretKey: NSString {
        return configuration(forKey: UserStorageKey.mixpanelSecretKey)
    }
    
    @objc var runsOnProduction: Bool {
        return self.environmentName == stagingEnvironmentName
    }
    
    @objc var runsOnStaging: Bool {
        return self.runsOnProduction == false
    }
    
    private func configuration(forKey: String) -> NSString {
        return plist![forKey] as! NSString
    }
    
    private static func plist(name: String) -> NSDictionary? {
        guard let plistFile = Bundle.main.path(forResource: name, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: plistFile) else {
                return nil
        }
        return plist
    }
    
    private func plistFileName (bundleId: String) -> String {
        #if BETA
            return "staging"
        #else
            return "prod"
        #endif
    }
}
