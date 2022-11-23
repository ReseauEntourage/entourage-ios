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
    
    init(instanceName:String, instanceId:Int) {
        self.instanceType = InstanceType.getFromString(key: instanceName)
        self.instanceId = instanceId
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
    case none
    
    static func getFromString(key:String) -> InstanceType {
        switch key {
        case "pois": return .pois
        case "users","user": return .users
        case "neighborhoods","neighborhood": return .neighborhoods
        case "resources": return .resources
        case "outings","outing": return .outings
        case "contributions","contribution": return .contributions
        case "solicitations", "solicitation": return .solicitations
        case "conversations","conversation": return .conversations
        case "partners": return .partners
        default: return .none
        }
    }
    
}
