//
//  DeeplinkManager.swift
//  entourage
//
//  Created by Jerome on 29/08/2022.
//

import Foundation


struct DeepLinkManager {
    
    static func presentAction(notification:NotificationPushData) {
        
     //   print("notification" , notification)
        if notification.context == "outing_on_day_before"{
            showHomeUniversalLinkWithParam(notification.instanceId)
            return
        }
        if notification.stage != nil && !notification.stage!.isEmpty{
            if notification.stage == "h1" {
                DeepLinkManager.showWelcomeOne()
                return
            }
            if notification.stage == "j2" {
                DeepLinkManager.showWelcomeTwo()
                return
            }
            if notification.stage == "j5" {
                DeepLinkManager.showWelcomeThree()
                return
            }
            if notification.stage == "j8" {
                DeepLinkManager.showWelcomeFour()
                return
            }
            if notification.stage == "j11" {
                DeepLinkManager.showWelcomeFive()
                return
            }
            
        }
        if notification.context != nil && !notification.context!.isEmpty{
            if notification.context == "h1" {
                print("condition " , notification.context == "h1")
                DeepLinkManager.showWelcomeOne()
                return
            }
            if notification.context == "j2" {
                DeepLinkManager.showWelcomeTwo()
                return
            }
            if notification.stage == "j5" {
                DeepLinkManager.showWelcomeThree()
                return
            }
            if notification.context == "j8" {
                DeepLinkManager.showWelcomeFour()
                return
            }
            if notification.context == "j11" {
                DeepLinkManager.showWelcomeFive()
                return
            }
            
        }
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
        case .neighborhood_post:
            if let _postId = notification.postId{
                showNeighborhoodDetailMessage(instanceId: notification.instanceId, postId: _postId)
            }else{
                showNeighborhoodDetail(id: notification.instanceId)
            }
        case .outing_post:
            if let _postId = notification.postId{
                showEventDetailMessage(instanceId: notification.instanceId, postId: _postId)
            }else{
                showOuting(id: notification.instanceId)
            }
        case .none:
            break
        }
    }
    
    static func presentActionFromDeeplink(notification:NotificationPushData) {
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
        case .neighborhood_post:
            if let _postId = notification.postId{
                showNeighborhoodDetailMessage(instanceId: notification.instanceId, postId: _postId)
            }else{
                showNeighborhoodDetail(id: notification.instanceId)
            }
        case .outing_post:
            if let _postId = notification.postId{
                showEventDetailMessage(instanceId: notification.instanceId, postId: _postId)
            }else{
                showOuting(id: notification.instanceId)
            }
        case .none:
            break
        }
    }
    
    static func setImage(notificationInstanceType:InstanceType) -> String {
        switch notificationInstanceType {
        case .users:
            return "placeholder_user"
        case .pois:
            return "ic_notif_placeholder"
        case .conversations:
            return "placeholder_user"
        case .neighborhoods:
            return "placeholder_user"
        case .outings:
            return "placeholder_user"
        case .partners:
            return "ic_notif_placeholder"
        case .resources:
            return "placeholder_user"
        case .contributions:
            return "ic_notif_placeholder"
        case .solicitations:
            return "ic_notif_placeholder"
        case .neighborhood_post:
            return "placeholder_user"
        case .outing_post:
            return "placeholder_user"
        case .none:
            return "ic_notif_placeholder"
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
    
    static func showNeighborhoodDetailWithCreatePost(id:Int,group:Neighborhood) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let navVC = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodDetailViewController {
            vc.isAfterCreation = false
            vc.neighborhoodId = id
            vc.isShowCreatePost = true
            vc.neighborhood = group
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
    
    static func showWelcomeOne(){
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "welcomeonevc") as? WelcomeViewController {
                if let currentVc = AppState.getTopViewController() as? HomeV2ViewController{
                    vc.delegate = currentVc.self
                    currentVc.present(vc, animated: true)
                }
                
            }
        }
    }
    static func showWelcomeTwo(){
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "welcometwovc") as? WelcmeTwoViewController {
                if let currentVc = AppState.getTopViewController() as? HomeV2ViewController{
                    vc.delegate = currentVc.self
                    currentVc.present(vc, animated: true)
                }
                
            }
        }
    }
    static func showWelcomeThree(){
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "welcomethreevc") as? WelcomeThreeViewController {
                if let currentVc = AppState.getTopViewController() as? HomeV2ViewController{
                    vc.delegate = currentVc.self
                    currentVc.present(vc, animated: true)
                }
                
            }
        }
    }
    static func showWelcomeFour(){
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "welcomefourvc") as? WelcomeFourViewController {
                if let currentVc = AppState.getTopViewController() as? HomeV2ViewController{
                    currentVc.present(vc, animated: true)
                }
            }
        }
        
    }
    static func showWelcomeFive(){
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "welcomefivevc") as? WelcomeFiveViewController {
                if let currentVc = AppState.getTopViewController() as? HomeV2ViewController{
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }

    
    //TODO : display message from group
    static func showNeighborhoodDetailMessage(instanceId:Int, postId:Int) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhoodMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? NeighborhoodDetailMessagesViewController {
            vc.parentCommentId = postId
            vc.neighborhoodId = instanceId
            vc.isStartEditing = false
            vc.isGroupMember = true
        AppState.getTopViewController()?.present(vc, animated: true)
        
        }
    }
    
    static func showEventDetailMessage(instanceId:Int, postId:Int) {
        let sb = UIStoryboard.init(name: StoryboardName.eventMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? EventDetailMessagesViewController {
            vc.parentCommentId = postId
            vc.eventId = instanceId
            vc.isStartEditing = false
            vc.isGroupMember = true
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    

    
    //MARK: UNIVERSAL LINK REDIRECTION
    
    
    static func showEventDetailMessageUniversalLink(instanceId:String, postId:String) {
        let sb = UIStoryboard.init(name: StoryboardName.eventMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? EventDetailMessagesViewController {
            vc.hashedEventId = postId
            vc.hashedEventId = instanceId
            vc.isStartEditing = false
            vc.isGroupMember = true
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    static func showNeighborhoodDetailMessageUniversalLink(instanceId:String, postId:String) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhoodMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? NeighborhoodDetailMessagesViewController {
            vc.hashedParentCommentId = postId
            vc.hashedNeighborhoodId = instanceId
            vc.isStartEditing = false
            vc.isGroupMember = true
        AppState.getTopViewController()?.present(vc, animated: true)
        
        }
    }
    
    static func showActionUniversalLink(id:String,isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actions, bundle: nil)
        if let navVc = sb.instantiateViewController(withIdentifier: "actionDetailFullNav") as? UINavigationController, let vc = navVc.topViewController as? ActionDetailFullViewController {
            vc.hashedActionId = id
            vc.action = nil
            vc.isContrib = isContrib
            AppState.getTopViewController()?.present(navVc, animated: true)
        }
    }
    static func showActionNewUniversalLink(isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actionCreate, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "actionCreateVCMain") as? ActionCreateMainViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isContrib = isContrib
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    static func showActionListUniversalLink(id:String,isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actions, bundle: nil)
        if let navVc = sb.instantiateViewController(withIdentifier: "actionDetailFullNav") as? UINavigationController, let vc = navVc.topViewController as? ActionDetailFullViewController {
            vc.hashedActionId = id
            vc.action = nil
            vc.isContrib = isContrib
            AppState.getTopViewController()?.present(navVc, animated: true)
        }
    }
    
    static func showHomeUniversalLink() {
        if let vc = AppState.getTopViewController() {
            if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                _tabbar.showHome()
            }
        }
    }
    static func showHomeUniversalLinkWithParam(_ eventId: Int) {
        DispatchQueue.main.async {
            if let vc = AppState.getTopViewController() {
                if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                    if let homeVC = vc as? HomeV2ViewController {
                        homeVC.shouldLaunchEventPopup = eventId
                        _tabbar.showHome()
                    }
                }
                else{
                    vc.dismiss(animated: true) {
                        let _currentVc = AppState.getTopViewController()
                        if let _home = _currentVc as? HomeV2ViewController{
                            _home.shouldLaunchEventPopup = eventId

                        }
                    }
                }
            }
        }

    }
    
    static func showContribListUniversalLink() {
        if let vc = AppState.getTopViewController() {
            // Verifier si le viewController est présenté comme modal
            if vc.isModal {
                // Fermer le modal avant de lancer la commande
                vc.dismiss(animated: true) {
                    if let _vc = AppState.getTopViewController() {
                        if let _tabbar = _vc.tabBarController as? MainTabbarViewController {
                            _tabbar.showActionsContrib()
                        }
                    }
                }
            } else {
                if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                    _tabbar.showActionsContrib()
                }
            }
        }
    }
    static func showDemandListUniversalLink() {
        if let vc = AppState.getTopViewController() {
            // Verifier si le viewController est présenté comme modal
            if vc.isModal {
                // Fermer le modal avant de lancer la commande
                vc.dismiss(animated: true) {
                    if let _vc = AppState.getTopViewController() {
                        if let _tabbar = _vc.tabBarController as? MainTabbarViewController {
                            _tabbar.showActionsDemand()
                        }
                    }
                }
            } else {
                if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                    _tabbar.showActionsDemand()
                }
            }
        }
    }
    static func showSolicitationListUniversalLink() {
        if let vc = AppState.getTopViewController(){
            if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                _tabbar.showActionsSolicitations()
            }
        }
    }
    
    static func showOutingListUniversalLink() {
        if let vc = AppState.getTopViewController(){
            if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                _tabbar.showMyEvents()
            }
        }
    }
    static func showDiscoverOutingListUniversalLink() {
        if let vc = AppState.getTopViewController(){
            if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                _tabbar.showDiscoverEvents()
            }
        }
    }
    
    static func showOutingUniversalLink(id:String) {
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController  {
            vc.hashedEventId = id
            vc.event = nil
            vc.isAfterCreation = false
            vc.modalPresentationStyle = .fullScreen
            AppState.getTopViewController()?.present(navVc, animated: true)
        }
    }
    static func showNeighborhoodDetailUniversalLink(id:String) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let navVC = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodDetailViewController {
            vc.isAfterCreation = false
            vc.hashedNeighborhoodId = id
            vc.isShowCreatePost = false
            vc.neighborhood = nil
            AppState.getTopViewController()?.present(navVC, animated: true)
        }
    }
    static func showNeiborhoodListUniversalLink() {
        if let vc = AppState.getTopViewController() as? HomeV2ViewController{
            if let _tabbar = vc.tabBarController as? MainTabbarViewController {
                _tabbar.showMyNeighborhoods()
            }
        }
    }
    
    
    static func showResourceUniversalLink(id:String) {
        if let vc = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "pedagoDetailVC") as? PedagogicDetailViewController {
            vc.hashdResourceId = id
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    
    static func showRessourceListUniversalLink() {
         let vc = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "listPedagoNav")
            AppState.getTopViewController()?.present(vc, animated: true)
    }
    
    static func showConversationUniversalLink(conversationId: String) {
        // Supposons que vous avez récupéré l'ID de l'utilisateur d'une manière ou d'une autre, peut-être stocké dans UserDefaults ou via un gestionnaire d'authentification
        guard let userId = UserDefaults.currentUser?.sid else {
            print("L'ID de l'utilisateur n'est pas disponible.")
            return
        }

        // Ajouter l'utilisateur à la conversation avant de naviguer
        MessagingService.addUserToConversation(conversationId: conversationId) { success, error in
            guard success else {
                if let error = error {
                    print("Erreur lors de l'ajout à la conversation: \(error)")
                } else {
                    print("Erreur inconnue lors de l'ajout à la conversation.")
                }
                return
            }

            
            DispatchQueue.main.async {
                if let vc = UIStoryboard.init(name: StoryboardName.messages, bundle: nil).instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.setupFromOtherVCWithHash(conversationId: conversationId, title: nil, isOneToOne: true)
                    AppState.getTopViewController()?.present(vc, animated: true)
                }
            }
        }
    }
    
}

enum RedirectionType {
    case outingsChatMessage(chatMessageId:Int, outingsId:Int)
    case outings(outingsId:Int)
    case neighborhoodsChatMessage(chatMessageId:Int, groupId:Int)
    case neighborhood(groupId:Int)
    case solicitation(id:Int)
    case contributions(id:Int)
    case conversation(id:Int)
}
