//
//  NotificationPushData.swift
//  entourage
//
//  Created by Jerome on 29/08/2022.
//

import Foundation


struct NotificationPushData {
    var instanceId:Int = 0
    var instanceType:InstanceType = .none
    var postId:Int? = nil
    var welcome: Bool? = false
    //value = h1, j2, j8, j11
    var stage: String? = nil
    var url: String? = nil
    
    
    init(instanceName:String, instanceId:Int, postId:Int?) {
        self.instanceType = InstanceType.getFromString(key: instanceName)
        self.instanceId = instanceId
        self.postId = postId
    }
}

enum InstanceType:String {
    case pois
    case users
    case neighborhoods
    case resources
    case outings
    case contributions
    case solicitations
    case conversations
    case partners
    case neighborhood_post
    case outing_post
    case none

    
    static func getFromString(key:String) -> InstanceType {
        switch key {
        case "pois": return .pois
        case "users","user": return .users
        case "neighborhoods","neighborhood": return .neighborhoods
        case "neighborhood_post": return .neighborhood_post
        case "resources": return .resources
        case "outings","outing": return .outings
        case "outing_post": return .outing_post
        case "contributions","contribution": return .contributions
        case "solicitations", "solicitation": return .solicitations
        case "conversations","conversation": return .conversations
        case "partners": return .partners
        default: return .none
        }
    }
    
}
