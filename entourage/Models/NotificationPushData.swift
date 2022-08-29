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
        case "users": return .users
        case "neighborhoods": return .neighborhoods
        case "resources": return .resources
        case "outings": return .outings
        case "contributions": return .contributions
        case "solicitations": return .solicitations
        case "conversations": return .conversations
        case "partners": return .partners
        default: return .none
        }
    }
    
}
