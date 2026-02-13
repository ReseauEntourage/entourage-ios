//
//  UniversalLinkManager.swift
//  entourage
//
//  Created by Clement entourage on 03/04/2023.
//

import Foundation
import UIKit

struct UniversalLinkManager {
    static let prodURL = "app.entourage.social"
    static let prodURL2 = "www.entourage.social"
    static let stagingURL = "entourage-webapp-preprod.herokuapp.com"
    static let stagingURL2 = "preprod.entourage.social"

    static func handleUniversalLink(components: URLComponents) {
        // 1. Validation de l'hôte
        let validHosts = [stagingURL, stagingURL2, prodURL, prodURL2]
        guard let host = components.host, validHosts.contains(host) else { return }

        // 2. Nettoyage du path (Équivalent du uri.pathSegments d'Android)
        var pathElements = components.path.components(separatedBy: "/").filter { !$0.isEmpty }
        
        // On enlève "app" si c'est le premier élément pour stabiliser les index
        // (Ça évite les crashs que tu pourrais avoir sur Android si le lien n'a pas "/app/")
        if pathElements.first == "app" {
            pathElements.removeFirst()
        }

        if pathElements.isEmpty {
            DeepLinkManager.showHomeUniversalLink()
            return
        }

        let mainEntity = pathElements[0]

        switch mainEntity {
        
        // --- 1. Bonnes ondes ---
        case "good-waves":
            // Android: SmallTalkIntroActivity
            DeepLinkManager.showSmallTalkIntro()
            
        // --- 2. Charte éthique ---
        case "charte-ethique-entourage":
            // Android: Intent.ACTION_VIEW disclaimer_link_public
            if let url = URL(string: "https://www.entourage.social/charte-ethique-grand-public") {
                UIApplication.shared.open(url)
            }
            
        // --- 3. Outings (Événements) ---
        case "outings":
            if pathElements.count > 1 {
                let subEntity = pathElements[1]
                
                switch subEntity {
                case "papotages":
                    // Android: presenter.getEventSmallTalk()
                    DeepLinkManager.showSuggestedSmallTalkEvent()
                    
                case "new", "create":
                    // Android: CreateEventActivity
                    DeepLinkManager.showEventCreation()
                    
                case "webinar":
                    // Android: presenter.getEventSensibilisation()
                    DeepLinkManager.showWelcomeWebinar()
                    
                case "chat_messages": // Format: /app/outings/chat_messages/ID_EVENT/ID_POST
                    if pathElements.count > 3 {
                        let eventId = pathElements[2]
                        let postId = pathElements[3]
                        DeepLinkManager.showEventDetailMessageUniversalLink(instanceId: eventId, postId: postId)
                    }
                    
                default:
                    // Si size > 3 sur Android = Agenda à true
                    if pathElements.count > 2 {
                        DeepLinkManager.showOutingUniversalLinkWithAgenda(id: subEntity)
                    } else {
                        DeepLinkManager.showOutingUniversalLink(id: subEntity)
                    }
                }
            } else {
                DeepLinkManager.showOutingListUniversalLink()
            }
            
        // --- Actions ---
        case "actions":
            if let url = components.url {
                WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: AppState.getTopViewController())
            }
            
        // --- Créations génériques ---
        case "create-outing":
            DeepLinkManager.showEventCreation()
            
        case "smalltalk":
            DeepLinkManager.showSmallTalkIntro()
            
        // --- Groupes & Voisinages ---
        case "neighborhoods", "groups":
            if pathElements.count > 1 {
                let subEntity = pathElements[1]
                
                if subEntity == "chat_messages" && pathElements.count > 3 {
                    DeepLinkManager.showNeighborhoodDetailMessageUniversalLink(instanceId: pathElements[2], postId: pathElements[3])
                } else {
                    DeepLinkManager.showNeighborhoodDetailUniversalLink(id: subEntity)
                }
            } else {
                DeepLinkManager.showNeiborhoodListUniversalLink()
            }
            
        // --- Conversations ---
        case "conversations", "messages":
            if pathElements.count > 1 {
                DeepLinkManager.showConversationUniversalLink(conversationId: pathElements[1])
            } else {
                DeepLinkManager.showConversationUniversalLink(conversationId: "AAAAA")
            }
            
        // --- Solicitations & Contributions ---
        case "solicitations":
            handleContributionOrSolicitation(elements: pathElements, isContrib: false)
            
        case "contributions":
            handleContributionOrSolicitation(elements: pathElements, isContrib: true)
            
        // --- Ressources ---
        case "resources":
            if pathElements.count > 1 {
                DeepLinkManager.showResourceUniversalLink(id: pathElements[1])
            } else {
                DeepLinkManager.showRessourceListUniversalLink()
            }
            
        // --- Map ---
        case "map":
            DeepLinkManager.showMap()
            
        // --- Utilisateurs ---
        case "users", "user":
            if pathElements.count > 1, let userIdInt = Int(pathElements[1]) {
                DeepLinkManager.showUser(userId: userIdInt)
            }
            
        // --- CGU / Charte ---
        case "chart-event":
            DeepLinkManager.showCGU()
            
        // --- Fallback ---
        default:
            DeepLinkManager.showHomeUniversalLink()
        }
    }
    
    // MARK: - Helpers
    
    private static func handleContributionOrSolicitation(elements: [String], isContrib: Bool) {
        if elements.count > 1 {
            let subEntity = elements[1]
            if subEntity == "new" {
                DeepLinkManager.showActionNewUniversalLink(isContrib: isContrib)
            } else {
                DeepLinkManager.showActionUniversalLink(id: subEntity, isContrib: isContrib)
            }
        } else {
            if isContrib {
                DeepLinkManager.showContribListUniversalLink()
            } else {
                DeepLinkManager.showSolicitationListUniversalLink()
            }
        }
    }
}
