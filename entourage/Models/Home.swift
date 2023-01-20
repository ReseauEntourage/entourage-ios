//
//  Home.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import Foundation

struct UserHome:Codable {
    var id: Int = 0
    private var _displayName: String? = nil
    var avatarURL: String? = nil
    var meetingsCount = 0
    var chatMessagesCount: Int = 0
    var outingParticipationsCount: Int = 0
    var neighborhoodParticipationsCount: Int = 0
    var actions = HomeActions()
    var moderator:HomeModerator? = nil
    
    var congratulations = HomeActions()
    
    var displayName:String {
        get {
            return _displayName ?? "-"
        }
        set(newName) {
            _displayName = newName
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case _displayName = "display_name"
        case avatarURL = "avatar_url"
        case meetingsCount = "meetings_count"
        case chatMessagesCount = "chat_messages_count"
        case outingParticipationsCount = "outing_participations_count"
        case neighborhoodParticipationsCount = "neighborhood_participations_count"
        case actions = "recommandations"
        case moderator
        case congratulations
    }
}

typealias HomeActions = [HomeAction]
struct HomeAction:Codable {
    var name:String = ""
    var action_url:String? = nil
    
    private var typeString:String
    private var actionString:String
    
    var params:HomeActionParams
    
    enum CodingKeys: String, CodingKey {
        case name
        case actionString = "action"
        case action_url = "image_url"
        case params
        case typeString = "type"
    }
    
    var action: HomeAction_TypeAction {
        get {
            return getActionFromKey(actionString)
        }
    }
    var type: HomeActionType {
        get {
            return getTypeFromKey(typeString)
        }
    }
    
    private func getTypeFromKey(_ key:String) -> HomeActionType {
        switch key {
        case "profile":
            return .profile
        case "neighborhood":
            return .neighborhood
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
    
    private func getActionFromKey(_ key:String) -> HomeAction_TypeAction {
        switch key {
        case "show":
            return .show
        case "create":
            return .create
        case "index":
            return .index
        default:
            return .none
        }
    }
    
}

struct HomeActionParams:Codable {
    var id:Int?
    var uuid:String?
    var url:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case url
    }
}

struct HomeModerator:Codable {
    var id:Int?
    var displayName:String?
    var imgUrl:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case imgUrl = "avatar_url"
    }
}

enum HomeAction_TypeAction {
    case show
    case create
    case index
    case none
}

enum HomeActionType {
    case user
    case profile
    case neighborhood
    case neighborhoodPost
    case outing
    case outingPost
    case contribution
    case solicitation
    case conversation
    case resource
    case webview
    case poi
    case none

}

