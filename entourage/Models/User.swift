//
//  OTUser.swift
//  entourage
//
//  Created by Jerome on 11/01/2022.
//

import CoreLocation

struct User: Codable {
    var goal:String? = nil
    var addressPrimary:Address? = nil
    var addressSecondary:Address? = nil
    private var _firstname:String? = nil
    private var _lastname:String? = nil
    var sid:Int = 0
    var uuid:String? = nil
    var type:String = ""
    var email:String? = nil
    private var _displayName:String? = nil
    var phone:String? = nil
    var password:String? = nil
    var avatarURL:String? = nil
    var avatarKey:String? = nil
    var token:String? = ""
    var stats:UserStats? = UserStats()
    var about:String? = nil
    var organization:Organization? = nil
    var partner:Partner? = nil
   // var conversation:Conversation? = nil
    var roles:[String]? = nil
    var memberships:[String]? = nil
    
    var firebaseProperties:[String:String]? = [String:String]()
    var interests:[String]? = nil
    var unreadCount:Int = 0
    var permissions:UserPermissions? = UserPermissions()
    
    var birthday:String? = nil
    var radiusDistance:Int? = 0
    
    var isEngaged:Bool = false
    
    var hasConsent:Bool? = nil
    
    private var creationDateString:String? = nil
    
    var creationDate: Date? {
        get {
            return Utils.getDateFromWSDateString(creationDateString)
        }
    }
    
    var firstname:String {
        get {
            return _firstname ?? "-"
        }
        set(newName) {
            _firstname = newName
        }
    }
    
    var lastname:String {
        get {
            return _lastname ?? "-"
        }
        set(newName) {
            _lastname = newName
        }
    }
    
    var displayName:String {
        get {
            return _displayName ?? "-"
        }
        set(newName) {
            _displayName = newName
        }
    }
    
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
        //case conversation
        case roles
        case memberships
        case interests
        
        case _firstname = "first_name"
        case _lastname = "last_name"
        case sid = "id"
        
        case type = "user_type"
        case _displayName = "display_name"
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
        case creationDateString = "created_at"
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
        
        if let hasConsent = hasConsent {
            dict["newsletter_subscription"] = hasConsent
        }
        return dict
    }
    
    func dictionaryUserUpdateForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if firstname.count > 0 {
            dict["first_name"] = firstname
        }
        if lastname.count > 0 {
            dict["last_name"] = lastname
        }
        if let about = about, about.count >= 0 {
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
        if let birthday = birthday, birthday.count >= 0 {
            dict["birthday"] = birthday
        }
        if radiusDistance ?? 0 >= 0 {
            dict["travel_distance"] = radiusDistance
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

struct UserLightNeighborhood: Codable {
    var sid:Int = 0
    private var _displayName:String? = nil
    var avatarURL:String? = nil
    var partner:Partner? = nil
    var partnerRoleTitle:String? = nil
    var role:String? = nil
    var groupRole:String? = nil
    var communityRoles:[String]? = nil
    var status:String? = nil
    var message:String? = nil
    
    var displayName:String {
        get {
            return _displayName ?? "-"
        }
        set(newName) {
            _displayName = newName
        }
    }
    
    enum CodingKeys: String, CodingKey {
       
        case partnerRoleTitle = "partner_role_title"
        case status
        case message
        case partner
        case role
        case groupRole = "group_role"
        case sid = "id"
        case communityRoles = "community_roles"
        
        case _displayName = "display_name"
        case avatarURL = "avatar_url"
    }
    
    func getCommunityRolesFormated() -> String? {
        if let communityRoles = communityRoles {
            var pos = 0
            var roleStr = ""
            for role in communityRoles {
                roleStr = pos == 0 ? role : "\(roleStr) • \(role)"
                pos = pos + 1
            }
            return roleStr
        }
        
        return nil
    }
    
    func getCommunityRoleWithPartnerFormated() -> String? {
        if let communityRoles = communityRoles {
            
            var roleStr = ""
            
            if isAdmin() {
                roleStr = "Admin".localized
            }
            
            for role in communityRoles {
                if roleStr.count > 0 {
                    roleStr = "\(roleStr) • \(role)"
                }
                else {
                    roleStr = role
                }
                
                break
            }
            if let name = partner?.name {
                if roleStr.count > 0 {
                    roleStr = "\(roleStr) • \(name)"
                }
                else {
                    roleStr = name
                }
            }
            return roleStr
        }
        
        return nil
    }
    
    func isAdmin() -> Bool {
        //TODO: a ajouter d'autre checks ?
        if groupRole == "creator" {
            return true
        }
        return false
    }
    func isAmbassador() -> Bool {
        guard let role = role else {
            return false
        }
        return role.contains("ambassador")
    }
}

//MARK: - Organization -
struct Organization:Codable {
    var name:String
    var description:String? = nil
    var phone:String? = nil
    var address:String? = nil
    var logo_url:String? = nil
}

//MARK: - UserPermissions -
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

//MARK: - UserStats -
struct UserStats:Codable {
    var entourageCount:Int = 0
    var actionsCount:Int = 0
    var eventsCount:Int = 0
    var contribCreationCount:Int = 0
    var askCreactionCount:Int = 0
    var neighborhoodsCount:Int = 0
    var outingsCount:Int? = 0
    
    enum CodingKeys: String, CodingKey {
        case entourageCount = "entourage_count"
        case actionsCount = "actions_count"
        case eventsCount = "events_count"
        case contribCreationCount = "contribution_creation_count"
        case askCreactionCount = "ask_for_help_creation_count"
        case neighborhoodsCount = "neighborhoods_count"
        case outingsCount = "outings_count"
    }
}
