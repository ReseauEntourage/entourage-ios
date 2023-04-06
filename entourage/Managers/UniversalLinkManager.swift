//
//  UniversalLinkManager.swift
//  entourage
//
//  Created by Clement entourage on 03/04/2023.
//

import Foundation

struct UniversalLinkManager {
    static func handleUniversalLink(components:URLComponents){
        
        let pathComponents = components.path.components(separatedBy: "/")
        if let queryItems = components.queryItems {
               for queryItem in queryItems {
                   print("eho" + "\(queryItem.name): \(queryItem.value ?? "")")
               }
           }
        
        // check if the incoming URL matches any of the URLs you want to handle
        if components.host == "entourage-webapp-preprod.herokuapp.com" {
            print("eho pathComponents " , pathComponents)
            
            if pathComponents.contains("outings") && pathComponents.contains("chat_messages"){
                DeepLinkManager.showEventDetailMessageUniversalLink(instanceId: "AAAAA", postId: "AAAAA")
            }
            if pathComponents.contains("neighborhoods") && pathComponents.contains("chat_messages"){
                DeepLinkManager.showNeighborhoodDetailMessageUniversalLink(instanceId: "AAAAA", postId: "AAAAA")

            }
            if pathComponents.contains("conversations") && pathComponents.contains("chat_messages"){
                DeepLinkManager.showConversationUniversalLink(conversationId: "AAAAA")

            }
            if pathComponents.contains("outings") {
                DeepLinkManager.showOutingUniversalLink(id: "AAAAA")

            }
            if pathComponents.contains("neighborhoods") {
                DeepLinkManager.showNeighborhoodDetailUniversalLink(id: "AAAAA")

            }
            if pathComponents.contains("conversations") {
                DeepLinkManager.showConversationUniversalLink(conversationId: "AAAAA")

            }
            if pathComponents.contains("solicitations") {
                DeepLinkManager.showActionUniversalLink(id: "AAAAA", isContrib: false)

            }
            if pathComponents.contains("contributions") {
                DeepLinkManager.showActionUniversalLink(id: "AAAAA", isContrib: true)

            }
            if pathComponents.contains("resources") {
                DeepLinkManager.showResourceUniversalLink(id: "AAAAA")

            }
            
        }
    }
}


