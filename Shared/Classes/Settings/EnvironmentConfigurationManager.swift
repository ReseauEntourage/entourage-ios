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
}

@objc class EnvironmentConfigurationManager: NSObject {
    
    private var plist: NSDictionary?
    private let stagingEnvironmentName: String = "staging"
    private let prodEnvironmentName: String = "prod"
    
    @objc var environmentName: String = ""
    
    @objc convenience init(bundleId:String) {
        self.init()
        self.environmentName = self.plistFileName(bundleId: bundleId)
        self.plist = EnvironmentConfigurationManager.plist(name: self.environmentName)
    }
    
    @objc var amazonAccessKey: NSString {
        return AMAZON_ACCESS_KEY as NSString
    }
    
    @objc var amazonSecretKey: NSString {
        return AMAZON_SECRET_KEY as NSString
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
        return MIXPANEL_TOKEN as NSString;
    }
    
    @objc var MixpanelKey: NSString {
        return MIXPANEL_KEY as NSString;
    }
    
    @objc var MixpanelSecretKey: NSString {
        return MIXPANEL_SECRET_KEY as NSString;
    }
    
    @objc var runsOnProduction: Bool {
        return self.environmentName == stagingEnvironmentName
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
