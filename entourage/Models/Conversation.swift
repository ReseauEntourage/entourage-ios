//
//  Conversation.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//

import Foundation


struct Conversation:Codable {
    var uid:Int = 0
    var uuid:String? = nil
    var type:String? = nil
    var title:String? = nil
    var imageUrl:String? = nil
    private var lastMessage:LastMessage? = nil
    var numberUnreadMessages:Int? = 0
    var section:String? = nil
    var user:MemberConversation? = nil
    var members:[MemberLight]? = nil
    var members_count:Int? = 0
    var isCreator:Bool? = nil
    private var blockers:[String]? = nil
    
    var messages:[PostMessage]? = nil
    private var hasPersonalPost:Bool? = nil
    
    var author:ConversationAuthor? = nil
    
    func isOneToOne() -> Bool {
        return type == "private"
    }
    
    func hasToShowFirstMessage() -> Bool {
        return numberUnreadMessages ?? 0 > 0 && !(hasPersonalPost ?? true)
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
    
    func imBlocker() -> Bool {
        let _return = blockers?.contains(where: {$0 == "me"})
                                         
        return _return ?? false
    }
    
    func isTheBlocker() -> Bool {
        let _return = blockers?.contains(where: {$0 == "participant"})
                                         
        return _return ?? false
    }
    
    func hasBlocker() -> Bool {
        return blockers?.count ?? 0 > 0
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
        case uuid
        case title = "name"
        case imageUrl = "image_url"
        case type
        case lastMessage = "last_message"
        case numberUnreadMessages = "number_of_unread_messages"
        case section
        case user
        case messages = "chat_messages"
        case hasPersonalPost = "has_personal_post"
        case members
        case members_count
        case isCreator = "creator"
        case blockers
        case author
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

struct MemberConversation:Codable {
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

struct UserBlocked:Codable {
    var blockedUser:BlockedUser
    var user:BlockedUser
    
    var isChecked = false
    
    enum CodingKeys: String, CodingKey {
        case user = "user"
        case blockedUser = "blocked_user"
    }
    
    func imBlocker() -> Bool {
        return user.uid == UserDefaults.currentUser?.sid
    }
}
struct BlockedUser:Codable {
    var uid:Int
    var displayName:String?
    var avatarUrl:String?
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
    }
}

struct ConversationAuthor:Codable {
    var id = 0
    var username:String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case username = "display_name"
    }
}
