//
//  Messaging.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//

import Foundation


struct MessagingMessage:Codable {
    var uid:Int = 0
    var type:String? = nil
    var title:String? = nil
    private var lastMessage:LastMessage? = nil
    var numberUnreadMessages:Int? = 0
    var section:String? = nil
    var user:MemberMessaging? = nil
    
    func isOneToOne() -> Bool {
        return type == "private"
    }
    
    func getPictoTypeFromSection() -> String {
        switch section {
        case "social":
            return "ic_action_social"
        case "clothes":
            return "ic_action_clothes"
        case "equipment":
            return "ic_action_equipment"
        case "hygiene":
            return "ic_action_hygiene"
        case "services":
            return "ic_action_services"
        default:
            return "ic_action_other"
        }
    }
    
    var createdDate:Date? {
        get {
            guard let dateStr = lastMessage?.dateStr else {return nil}
            return Utils.getDateFromWSDateString(dateStr)
        }
    }
    var createdDateFormatted:String {
        get {
            return Utils.formatMessageListDateName(date:createdDate)
        }
    }
    var getLastMessage:String? {
        get {
            return lastMessage?.text
        }
    }
    
    var hasUnread:Bool {
        get {
            return numberUnreadMessages ?? 0 > 0
        }
    }
    
    func getRolesWithPartnerFormated() -> String? {
        if let communityRoles = user?.roles {
            
            var roleStr = ""
            
            for role in communityRoles {
                if roleStr.count > 0 {
                    roleStr = "\(roleStr) • \(role)"
                }
                else {
                    roleStr = role
                }
                
                break
            }
            if let name = user?.partner?.name {
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
    
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case title = "name"
        case type
        case lastMessage = "last_message"
        case numberUnreadMessages = "number_of_unread_messages"
        case section
        case user
        
    }
}

struct LastMessage:Codable {
    var text:String? = nil
    var dateStr:String? = nil
    enum CodingKeys: String, CodingKey {
        case text
        case dateStr = "date"
    }
}

struct MemberMessaging:Codable {
    var uid:Int
    var displayName:String?
    var imageUrl:String?
    var partner:Partner? = nil
    var partnerRoleTitle:String? = nil
    var roles:[String]? = nil
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case displayName = "display_name"
        case imageUrl = "avatar_url"
        case roles
        case partnerRoleTitle = "partner_role_title"
        case partner
    }
}
