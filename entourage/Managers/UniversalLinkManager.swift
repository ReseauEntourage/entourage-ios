//
//  UniversalLinkManager.swift
//  entourage
//
//  Created by Clement entourage on 03/04/2023.
//

import Foundation

struct UniversalLinkManager {
    static let prodURL = "app.entourage.social"
    static let stagingURL = "entourage-webapp-preprod.herokuapp.com"
    
    
    static func handleUniversalLink(components:URLComponents){
        
        let pathComponents = components.path.components(separatedBy: "/")
        if let queryItems = components.queryItems {
               for queryItem in queryItems {
                   print("eho" + "\(queryItem.name): \(queryItem.value ?? "")")
               }
           }
        
        // check if the incoming URL matches any of the URLs you want to handle
        if components.host == stagingURL || components.host == prodURL {
            print("eho pathComponents " , pathComponents)
            
            if pathComponents.contains("outings") && pathComponents.contains("chat_messages"){
                if pathComponents.count > 3 , let _eventhashId = pathComponents[2] as? String, let _posthashId = pathComponents[3] as? String {
                    DeepLinkManager.showEventDetailMessageUniversalLink(instanceId: _eventhashId, postId: _posthashId)
                }
            }else if pathComponents.contains("neighborhoods") && pathComponents.contains("chat_messages"){
                DeepLinkManager.showNeighborhoodDetailMessageUniversalLink(instanceId: "AAAAA", postId: "AAAAA")

            }else if pathComponents.contains("conversations") && pathComponents.contains("chat_messages"){
                DeepLinkManager.showConversationUniversalLink(conversationId: "AAAAA")

            }else if pathComponents.contains("outings") {
                if pathComponents.count > 2 , let _hashId = pathComponents[2] as? String{
                    DeepLinkManager.showOutingUniversalLink(id: _hashId)
                }else{
                    DeepLinkManager.showOutingListUniversalLink()
                }
            }else if pathComponents.contains("neighborhoods") || pathComponents.contains("groups") {
                if pathComponents.count > 2 , let _hashId = pathComponents[2] as? String{
                    DeepLinkManager.showNeighborhoodDetailUniversalLink(id: _hashId)
                }

            }else if pathComponents.contains("conversations") || pathComponents.contains("messages") {
                DeepLinkManager.showConversationUniversalLink(conversationId: "AAAAA")

            }else if pathComponents.contains("solicitations") {
                if pathComponents.contains("new"){
                    DeepLinkManager.showActionNewUniversalLink(isContrib: false)
                }else{
                    DeepLinkManager.showActionUniversalLink(id: "AAAAA", isContrib: false)

                }
                
            }else if pathComponents.contains("contributions") {
                if pathComponents.contains("new"){
                    DeepLinkManager.showActionNewUniversalLink(isContrib: true)
                }else{
                    DeepLinkManager.showActionUniversalLink(id: "AAAAA", isContrib: true)
                }
            }else if pathComponents.contains("resources") {
                DeepLinkManager.showResourceUniversalLink(id: "AAAAA")

            }
            
        }
    }
}


