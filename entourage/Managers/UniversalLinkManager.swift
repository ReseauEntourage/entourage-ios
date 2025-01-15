//
//  UniversalLinkManager.swift
//  entourage
//
//  Created by Clement entourage on 03/04/2023.
//

import Foundation

struct UniversalLinkManager {
    static let prodURL = "app.entourage.social"
    static let prodURL2 = "www.entourage.social"
    static let stagingURL = "entourage-webapp-preprod.herokuapp.com"
    static let stagingURL2 = "preprod.entourage.social"

    
    static func handleUniversalLink(components:URLComponents){
        let pathComponents = components.path.components(separatedBy: "/")
        // check if the incoming URL matches any of the URLs you want to handle
        if components.host == stagingURL || components.host == prodURL || components.host == prodURL2 || components.host == stagingURL2  {
            if pathComponents.count ==  1 {
                DeepLinkManager.showHomeUniversalLink()
                return
            }
            
            if pathComponents[0] == "" && pathComponents[1] == "" {
                DeepLinkManager.showHomeUniversalLink()
            }
            if pathComponents.count == 2 && pathComponents[1] == "app"{
                DeepLinkManager.showHomeUniversalLink()
            }
            
            var iterator = 0
            if components.host != stagingURL {
                iterator = 1
            }
            
            if pathComponents.contains("actions"){
                if let url = components.url {
                    WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: AppState.getTopViewController())
                }
            }
                
            if pathComponents.contains("outings") && pathComponents.contains("chat_messages"){
                if pathComponents.count > 3 + iterator , let _eventhashId = pathComponents[2+iterator] as? String, let _posthashId = pathComponents[3+iterator] as? String {
                    DeepLinkManager.showEventDetailMessageUniversalLink(instanceId: _eventhashId, postId: _posthashId)
                }
            }else if pathComponents.contains("neighborhoods") && pathComponents.contains("chat_messages"){
                if pathComponents.count > 3+iterator , let _grouphashId = pathComponents[2+iterator] as? String, let _posthashId = pathComponents[3+iterator] as? String {
                    DeepLinkManager.showNeighborhoodDetailMessageUniversalLink(instanceId: _grouphashId, postId: _posthashId)
                }

            }else if pathComponents.contains("conversations"){
                if let _convId = pathComponents[2+iterator] as? String {
                    DeepLinkManager.showConversationUniversalLink(conversationId: _convId)
                }

            }else if pathComponents.contains("outings") {
                if pathComponents.count > 3 + iterator, let _hashId = pathComponents[2+iterator] as? String {
                    DeepLinkManager.showOutingUniversalLinkWithAgenda(id: _hashId)
                } else if pathComponents.count > 2+iterator , let _hashId = pathComponents[2+iterator] as? String{
                    DeepLinkManager.showOutingUniversalLink(id: _hashId)
                }else{
                    DeepLinkManager.showOutingListUniversalLink()
                }
            }else if pathComponents.contains("neighborhoods") || pathComponents.contains("groups") {
                if pathComponents.count > 2+iterator , let _hashId = pathComponents[2+iterator] as? String{
                    DeepLinkManager.showNeighborhoodDetailUniversalLink(id: _hashId)
                }else{
                    DeepLinkManager.showNeiborhoodListUniversalLink()
                }

            }else if pathComponents.contains("conversations") || pathComponents.contains("messages") {
                DeepLinkManager.showConversationUniversalLink(conversationId: "AAAAA")

            }else if pathComponents.contains("solicitations") {
                if pathComponents.contains("new"){
                    DeepLinkManager.showActionNewUniversalLink(isContrib: false)
                }else  if pathComponents.count > 2+iterator , let _hashId = pathComponents[2+iterator] as? String{
                    DeepLinkManager.showActionUniversalLink(id: _hashId, isContrib: false)
                }else{
                    DeepLinkManager.showSolicitationListUniversalLink()
                }
                
            }else if pathComponents.contains("contributions") {
                if pathComponents.contains("new"){
                    DeepLinkManager.showActionNewUniversalLink(isContrib: true)
                }else  if pathComponents.count > 2+iterator , let _hashId = pathComponents[2+iterator] as? String{
                    DeepLinkManager.showActionUniversalLink(id: _hashId, isContrib: true)
                }else{
                    DeepLinkManager.showContribListUniversalLink()
                }
                
            }else if pathComponents.contains("resources") {
                if pathComponents.count > 2+iterator , let _hashId = pathComponents[2+iterator] as? String{
                    DeepLinkManager.showResourceUniversalLink(id: _hashId)
                }else{
                    DeepLinkManager.showRessourceListUniversalLink()
                }
            }else if pathComponents.contains("map") {
                DeepLinkManager.showMap()
            }
        }
    }
}


