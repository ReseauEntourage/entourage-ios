//
//  HomeMainViewModel.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import Foundation


class HomeViewModel {
    
    private var delegate:HomeMainViewsActionsDelegate?
    
    private var _userHome:UserHome = UserHome()
    
    private var notificationCount = 0
    
    init(delegate:HomeMainViewsActionsDelegate) {
        self.delegate = delegate
    }
    
    var moderator:User {
        get {
            return _userHome.moderator
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
        Logger.print("***** get event from action type : \(action.type)")
        Logger.print("***** get event from action action : \(action.action)")
        switch action.type {
        case .profile:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showUserProfile(id: id)
                }
                else {
                    delegate?.editMyProfile()
                }
                break
            default:
                break
            }
        case .neighborhood:
            switch action.action {
            case .new:
                delegate?.createNeighborhood()
                break
            case .show:
                if let id = action.params.id {
                    delegate?.showNeighborhoodDetail(id: id)
                }
                break
            case .index:
                delegate?.showAllNeighborhoods()
                break
            default:
                break
            }
        case .contribution:
            switch action.action {
            case .new:
                delegate?.createContribution()
                break
            case .show:
                if let id = action.params.id {
                    delegate?.showContribution(id: id)
                }
                break
            case .index:
                delegate?.showAllContributions()
                break
            default:
                break
            }
        case .conversation:
            switch action.action {
            case .show:
                if let uid = action.params.uuid {
                    delegate?.showConversation(uuid: uid)
                }
                break
            default:
                break
            }
        case .webview:
            switch action.action {
            case .show:
                if let url = action.params.url {
                    delegate?.showWebview(url: url)
                }
                break
            default:
                break
            }
        case .poi:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showPoi(id: id)
                }
                break
            case .index:
                delegate?.showAllPois()
                break
            default:
                break
            }
        case .ask_for_help:
            switch action.action {
            case .new:
                delegate?.createAskForHelp()
                break
            case .show:
                if let id = action.params.id {
                    delegate?.showAskForHelpDetail(id: id)
                }
                break
            case .index:
                delegate?.showAllAskForHelp()
                break
            default:
                break
            }
        case .outing:
            switch action.action {
            case .show:
                if let id = action.params.id {
                    delegate?.showOuting(id: id)
                }
                break
            case .index:
                delegate?.showAllOutings()
                break
            default:
                break
            }
        case .resource:
            switch action.action {
            case .new:
                break
            case .show:
                if let id = action.params.id {
                    delegate?.showResource(id: id)
                }
                break
            case .index:
                delegate?.showResources()
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    
}
