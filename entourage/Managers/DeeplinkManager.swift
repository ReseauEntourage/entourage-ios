//
//  DeeplinkManager.swift
//  entourage
//
//  Created by Jerome on 29/08/2022.
//

import Foundation


struct DeepLinkManager {
    
    static func presentAction(notification:NotificationPushData) {
        switch notification.instanceType {
        case .users:
            showUser(userId: notification.instanceId)
        case .pois:
            showPoi(id: notification.instanceId)
        case .conversations:
            showConversation(conversationId: notification.instanceId)
        case .neighborhoods:
            showNeighborhoodDetail(id: notification.instanceId)
        case .outings:
            showOuting(id: notification.instanceId)
        case .partners:
            showPartner(partnerId: notification.instanceId)
        case .resources:
            showResource(id: notification.instanceId)
        case .contributions:
            showAction(id: notification.instanceId, isContrib: true)
        case .solicitations:
            showAction(id: notification.instanceId, isContrib: false)
        case .none:
            break
        }
    }
    
    
    //MARK: - Navigation Actions -
    static func showUser(userId:Int) {
        if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(userId)"
                
                AppState.getTopViewController()?.present(navVC, animated: true)
            }
        }
    }
    
    static func showPoi(id:Int) {
        if  let navVc = UIStoryboard.init(name: StoryboardName.solidarity, bundle: nil).instantiateInitialViewController() as? UINavigationController, let _controller = navVc.topViewController as? GuideDetailPoiViewController {
            var poi = MapPoi()
            poi.uuid = "\(id)"
            _controller.poi = poi
            
            AppState.getTopViewController()?.present(navVc, animated: true)
        }
    }
    
    static func showConversation(conversationId:Int) {
        if let vc = UIStoryboard.init(name: StoryboardName.messages, bundle: nil).instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
            vc.setupFromOtherVC(conversationId: conversationId, title: nil, isOneToOne: true)
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    
    static func showResource(id:Int) {
        if let vc = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "pedagoDetailVC") as? PedagogicDetailViewController {
            vc.resourceId = id
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    
    static func showPartner(partnerId:Int) {
        if let navVc = UIStoryboard.init(name:StoryboardName.partnerDetails, bundle: nil).instantiateInitialViewController() as? UINavigationController, let vc = navVc.topViewController as? PartnerDetailViewController {
            vc.partnerId = partnerId
            
            AppState.getTopViewController()?.present(navVc, animated: true)
        }
    }
    
    static func showNeighborhoodDetail(id:Int) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let navVC = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodDetailViewController {
            vc.isAfterCreation = false
            vc.neighborhoodId = id
            vc.isShowCreatePost = false
            vc.neighborhood = nil
            AppState.getTopViewController()?.present(navVC, animated: true)
        }
    }
    
    static func showOuting(id:Int) {
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController  {
            vc.eventId = id
            vc.event = nil
            vc.isAfterCreation = false
            vc.modalPresentationStyle = .fullScreen
            AppState.getTopViewController()?.present(navVc, animated: true)
        }
    }
    
    static func showAction(id:Int,isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actions, bundle: nil)
        if let navVc = sb.instantiateViewController(withIdentifier: "actionDetailFullNav") as? UINavigationController, let vc = navVc.topViewController as? ActionDetailFullViewController {
            vc.actionId = id
            vc.action = nil
            vc.isContrib = isContrib
            AppState.getTopViewController()?.present(navVc, animated: true)
        }
    }
}
