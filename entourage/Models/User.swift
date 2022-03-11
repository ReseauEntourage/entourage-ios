//
//  OTUser.swift
//  entourage
//
//  Created by Jerome on 11/01/2022.
//

import CoreLocation

struct User: Codable {
    var goal:String? = nil
    var addressPrimary:UserAddress? = nil
    var addressSecondary:UserAddress? = nil
    var firstname:String = ""
    var lastname:String = ""
    var sid:Int = 0
    var uuid:String = ""
    var type:String = ""
    var email:String? = nil
    var displayName:String = ""
    var phone:String? = nil
    var password:String? = nil
    var avatarURL:String? = nil
    var avatarKey:String? = nil
    var token:String = ""
    var stats:UserStats = UserStats()
    var about:String? = nil
    var organization:Organization? = nil
    var partner:Association? = nil
    var conversation:Conversation? = nil
    var roles:[String]? = nil
    var memberships:[String]? = nil
    
    var firebaseProperties = [String:String]()
    var interests:[String]? = nil
    var unreadCount:Int = 0
    var permissions:UserPermissions = UserPermissions()
    
    var birthday:String? = nil
    var radiusDistance:Int = 0
    
    var isEngaged:Bool = false

    enum CodingKeys: String, CodingKey {
        case uuid
        case email
        case phone
        case token
        case stats
        case about
        case permissions
        case goal
        
        case organization
        case partner
        case conversation
        case roles
        case memberships
        case interests
        
        case firstname = "first_name"
        case lastname = "last_name"
        case sid = "id"
        
        case type = "user_type"
        case displayName = "display_name"
        case password = "sms_code"
        case avatarURL = "avatar_url"
        case avatarKey = "avatar_key"
        case addressPrimary = "address"
        case addressSecondary = "address_2"
        case firebaseProperties = "firebase_properties"
        case isEngaged = "engaged"
        case unreadCount = "unread_count"
        case radiusDistance = "travel_distance"
        case birthday
    }
    
    func dictionaryForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if firstname.count > 0 {
            dict["first_name"] = firstname
        }
        if lastname.count > 0 {
            dict["last_name"] = lastname
        }
        if let about = about, about.count > 0 {
            dict["about"] = about
        }
        if let email = email, email.count > 0 {
            dict["email"] = email
        }
        if let password = password, password.count > 0 {
            dict["sms_code"] = password
        }
        if let avatarKey = avatarKey, avatarKey.count > 0 {
            dict["avatar_key"] = avatarKey
        }
        if let goal = goal, goal.count > 0 {
            dict["goal"] = goal
        }
        return dict
    }
    
    func hasActionZoneDefined() -> Bool {
        if let _ = addressPrimary {
            return true
        }
        return false
    }
    
    func isAmbassador() -> Bool {
        guard let roles = roles else {
            return false
        }
        return roles.contains("ambassador")
    }
}


struct UserAddress:Codable {
    var displayAddress:String
    var location:CLLocation? = nil
    
    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
}

struct Organization:Codable {
    var name:String
    var description:String
    var phone:String
    var address:String
    var logo_url:String
}

struct Conversation:Codable {
}

struct UserPermissions:Codable {
    var isEventCreationActive = false
    
    enum CodingKeys: String, CodingKey {
        case outing = "outing"
        enum ActionsKeys: String, CodingKey {
            case creation = "creation"
        }
    }
    
    init() {
        isEventCreationActive = false
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let siteContainer = try container.nestedContainer(keyedBy: CodingKeys.ActionsKeys.self, forKey: .outing)
        isEventCreationActive = try siteContainer.decode(Bool.self, forKey: .creation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var siteContainer = container.nestedContainer(keyedBy: CodingKeys.ActionsKeys.self, forKey: .outing)
        try siteContainer.encode(isEventCreationActive,forKey: .creation)
    }
}

struct UserStats:Codable {
    var tourCount:Int = 0
    var entourageCount:Int = 0
    var encounterCount:Int = 0
    var actionsCount:Int = 0
    var eventsCount:Int = 0
    var contribCreationCount:Int = 0
    var askCreactionCount:Int = 0
    var isGoodWavesValidated:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case tourCount = "tour_count"
        case entourageCount = "entourage_count"
        case encounterCount = "encounter_count"
        case actionsCount = "actions_count"
        case eventsCount = "events_count"
        case contribCreationCount = "contribution_creation_count"
        case askCreactionCount = "ask_for_help_creation_count"
        case isGoodWavesValidated = "good_waves_participation"
    }
}
