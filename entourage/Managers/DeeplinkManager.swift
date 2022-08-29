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
            if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
                if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                    _homeVC.currentUserId = "\(notification.instanceId)"
                    
                    AppState.getTopViewController()?.present(navVC, animated: true)
                }
            }
            break
            //TODO: alls ;)
        case .pois:
            break
        case .contributions:
            break
        case .conversations:
            break
        case .neighborhoods:
            break
        case .outings:
            break
        case .partners:
            break
        case .resources:
            break
        case .solicitations:
            break
        case .none:
            break
        }
    }
}
