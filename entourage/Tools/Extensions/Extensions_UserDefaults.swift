//
//  Extensions_UserDefault.swift
//  entourage
//
//  Created by Jerome on 21/01/2022.
//

import Foundation

//MARK: - UserDEfault with user -
extension UserDefaults {
    
    func decode<T: Decodable>(_ type: T.Type, forKey defaultName: String) throws -> T {
        try JSONDecoder().decode(T.self, from: data(forKey: defaultName) ?? .init())
    }
    func encode<T: Encodable>(_ value: T, forKey defaultName: String) throws {
        try set(JSONEncoder().encode(value), forKey: defaultName)
    }
    
    private enum Keys {
        static let tempUser = "tempUser"
        static let currentUser = "currentUser"
        static let pushToken = "pushToken"
    }
    
    class var temporaryUser: User? {
        get {
            return try? UserDefaults.standard.decode(User.self, forKey: Keys.tempUser)
        }
        set {
            if let newvalue = newValue {
               try? UserDefaults.standard.encode(newvalue, forKey: Keys.tempUser)
            }
            else {
                UserDefaults.standard.removeObject(forKey: Keys.tempUser)
            }
        }
    }
    class var currentUser: User? {
        get {
            return try? UserDefaults.standard.decode(User.self,forKey: Keys.currentUser)
        }
        set {
            if let newvalue = newValue {
                try? UserDefaults.standard.encode(newvalue, forKey: Keys.currentUser)
            }
            else {
                UserDefaults.standard.removeObject(forKey: Keys.currentUser)
            }
        }
    }
    
    class func updateCurrentUser(newUser:User) {
        var _newUser = newUser
        let user = UserDefaults.currentUser
        _newUser.phone = user?.phone
        UserDefaults.currentUser = _newUser
    }
    
    class var pushToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.pushToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.pushToken)
        }
    }
    class var token: String? {
        get {
            return try? UserDefaults.standard.decode(User.self,forKey: Keys.currentUser).token
        }
    }
}
