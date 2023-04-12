//
//  NotifInApp.swift
//  entourage
//
//  Created by - on 22/11/2022.
//

import Foundation

struct NotifInApp:Codable {
    var uid:Int = 0
    var instanceId:Int? = nil
    private var instanceString:String
    var content:String? = nil
    var title:String? = nil
    var imageUrl:String? = nil
    var postId:Int? = nil
    
    private var createdAt:String? = nil
    var completedAt:String? = nil
    
    let actionType = HomeAction_TypeAction.show
    
    var type: HomeActionType {
        get {
            return getTypeFromKey(instanceString)
        }
    }
    
    
    func getNotificationPushData() -> NotificationPushData {
        return NotificationPushData(instanceName: instanceString, instanceId: instanceId ?? 0, postId:postId)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case instanceId = "instance_id"
        case postId = "post_id"
        case instanceString = "instance"
        case content
        case title
        case createdAt = "created_at"
        case completedAt = "completed_at"
        case imageUrl = "image_url"
    }
    
    private func getTypeFromKey(_ key:String) -> HomeActionType {
        switch key {
        case "profile":
            return .profile
        case "neighborhood":
            return .neighborhood
        case "neighborhood_post":
            return .neighborhoodPost
        case "outing_post":
            return .outingPost
        case "outing":
            return .outing
        case "resource":
            return .resource
        case "conversation":
            return .conversation
        case "contribution":
            return .contribution
        case "solicitation":
            return .solicitation
        case "poi":
            return .poi
        case "webview":
            return .webview
        case "user":
            return .user
        default:
            return .none
        }
    }
    
    func isRead() -> Bool {
        return completedAt != nil
    }
    
    func getCreateDate() -> String {
        let createdDate = Utils.getDateFromWSDateString(createdAt)
        let dateStr = Utils.formatActionDateName(date: createdDate, capitalizeFirst: true)
        
        return (dateStr)
    }
    
    func getDurationFromNow() -> String {
        if let date = Utils.getDateFromWSDateString(createdAt) {
            return Utils.formatDateAgo(date: date)
        } else {
            return ""
        }
    }
}


struct NotifInAppPermission:Codable {
    var neighborhood = false
    var outing = false
    var chat_message = false
    var action = false
    
    enum CodingKeys: String, CodingKey {
        case neighborhood
        case outing
        case chat_message
        case action
        
    }
    
    func allNotifsOn() -> Bool {
        return chat_message && neighborhood && outing && action
    }
    
    func getDatasForWS() -> [String:Bool] {
        var datas = [String:Bool]()
        datas["neighborhood"] = neighborhood
        datas["outing"] = outing
        datas["chat_message"] = chat_message
        datas["action"] = action
        
        return datas
    }
}
