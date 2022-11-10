//
//  HomeMainViewModel.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import Foundation


class HomeViewModel {
    
    private var delegate:HomeMainViewsActionsDelegate?
    
    var _userHome:UserHome = UserHome()
    
    private var notificationCount = 0
    
    init(delegate:HomeMainViewsActionsDelegate) {
        self.delegate = delegate
        self.loadMetadatas()
    }
    
    var moderatorName:String {
        get {
            return _userHome.moderator?.displayName ?? "-"
        }
    }
    var moderatorId:Int {
        get {
            return _userHome.moderator?.id ?? 0
        }
    }
    
    var userHome:UserHome {
        get {
            return _userHome
        }
    }
    
    var notifCount:Int {
        get {
            return notificationCount
        }
    }
    
    var actions:HomeActions {
        get {
            return _userHome.actions
        }
    }
    
    func getHomeDetail(completion: @escaping (_ isOk:Bool) -> Void) {
        HomeService.getUserHome { [weak self] userHome, error in
            if let userHome = userHome {
                self?._userHome = userHome
                
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func getEventFromAction(_ action:HomeAction) {
        switch action.type {
        case .user:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showUserProfile(id: id)
                }
            default:
                break
            }
        case .profile:
            switch action.action {
            case .show:
                delegate?.editMyProfile()
            default:
                break
            }
        case .neighborhood:
            switch action.action {
            case .create:
                delegate?.createNeighborhood()
            case .show:
                if let id = action.params.id {
                    delegate?.showNeighborhoodDetail(id: id)
                }
            case .index:
                delegate?.showAllNeighborhoods()
            default:
                break
            }
        case .contribution:
            switch action.action {
            case .create:
                delegate?.createContribution()
            case .show:
                if let id = action.params.id {
                    delegate?.showContribution(id: id)
                }
            case .index:
                delegate?.showAllContributions()
            default:
                break
            }
        case .conversation:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showConversation(conversationId: id)
                }
            default:
                break
            }
        case .webview:
            switch action.action {
            case .show:
                if let url = action.params.url {
                    delegate?.showWebview(url: url)
                }
            default:
                break
            }
        case .poi:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showPoi(id: id)
                }
            case .index:
                delegate?.showAllPois()
            default:
                break
            }
        case .solicitation:
            switch action.action {
            case .create:
                delegate?.createSolicitation()
            case .show:
                if let id = action.params.id {
                    delegate?.showSolicitationDetail(id: id)
                }
            case .index:
                delegate?.showAllSolicitations()
            default:
                break
            }
        case .outing:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showOuting(id: id)
                }
            case .index:
                delegate?.showAllOutings()
            case .create:
                delegate?.createOuting()
            default:
                break
            }
        case .resource:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showResource(id: id)
                }
            case .index:
                delegate?.showResources()
            default:
                break
            }
        default:
            break
        }
    }
    
    
    private func loadMetadatas() {
        MetadatasService.getMetadatas { error in
            Logger.print("***** return get metadats ? \(error)")
        }
    }
    
}
