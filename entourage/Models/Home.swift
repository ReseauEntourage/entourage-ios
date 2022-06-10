//
//  Home.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import Foundation

struct UserHome:Codable {
    var id: Int = 0
    var displayName: String = ""
    var avatarURL: String = ""
    var meetingsCount = 0
    var chatMessagesCount: Int = 0
    var outingParticipationsCount: Int = 0
    var neighborhoodParticipationsCount: Int = 0
    var actions = HomeActions()
    var moderatorName:String = ""
    var moderatorId:Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case meetingsCount = "meetings_count"
        case chatMessagesCount = "chat_messages_count"
        case outingParticipationsCount = "outing_participations_count"
        case neighborhoodParticipationsCount = "neighborhood_participations_count"
        case actions = "recommandations"
    }
}

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
        case "ask_for_help":
            return .ask_for_help
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
        case "new":
            return .new
        case "index":
            return .index
        default:
            return .none
        }
    }
    
}
typealias HomeActions = [HomeAction]

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

enum HomeAction_TypeAction {
    case show
    case new
    case index
    case none
}

enum HomeActionType {
    case user
    case profile
    case neighborhood
    case outing
    case contribution
    case ask_for_help
    case conversation
    case resource
    case webview
    case poi
    case none
    //TODO: crea formulaire de création d’une publication, sur un groupe donné
    //TODO: share groupe/don/demande ????
}

