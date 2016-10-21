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
  static let amazonAccessKey = "AmazonAccessKey"
  static let amazonSecretKey = "AmazonSecretKey"
  static let flurryAPIKey = "FlurryApiKey"
  static let nuanceHostAddress = "NuanceHostAddress"
  static let nuanceAppId = "NuanceAPIKey"
}

@objc class ConfigurationManager: NSObject {

  static let shared = ConfigurationManager()
  private var plist: NSDictionary?
  private var prodPlist: NSDictionary

  private override init() {
    guard let prodPlist = ConfigurationManager.plist(name: "prod") else {
      fatalError("prod plist option not found")
    }
    self.plist = ConfigurationManager.plist(name: UserStorageKey.environment.userPreferences)
    self.prodPlist = prodPlist
  }

  var amazonAccessKey: NSString {
    return configuration(forKey: UserStorageKey.amazonAccessKey)
  }

  var amazonSecretKey: NSString {
    return configuration(forKey: UserStorageKey.amazonSecretKey)
  }

  var APIHostURL: NSString {
    return configuration(forKey: UserStorageKey.APIHostURL)
  }

  var APIKey: NSString {
    return configuration(forKey: UserStorageKey.APIKey)
  }

  var flurryAPIKey: NSString {
    return configuration(forKey: UserStorageKey.flurryAPIKey)
  }

  var nuanceHostAddress: NSString {
    return configuration(forKey: UserStorageKey.nuanceHostAddress)
  }

  var nuanceAppId: NSString {
    return configuration(forKey: UserStorageKey.nuanceAppId)
  }

  private func configuration(forKey: String) -> NSString {
    guard let api = plist?[forKey] as? NSString else {
      return prodPlist[forKey] as! NSString
    }
    return api
  }

  private static func plist(name: String) -> NSDictionary? {
    guard let plistFile = Bundle.main.path(forResource: name, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: plistFile) else {
      return nil
    }
    return plist
  }
}
