//
//  SafariWebManager.swift
//  entourage
//
//  Created by Jerome on 28/01/2022.
//

import Foundation
import SafariServices

struct SafariWebManager {
    static func launchUrlInApp(url:URL, viewController:UIViewController?, safariDelegate:SFSafariViewControllerDelegate? = nil) {
        
        let set = NSCharacterSet(charactersIn: "/")
        var urlParh = url.absoluteString.trimmingCharacters(in: set as CharacterSet)
        
        if !urlParh.contains("http") {
            urlParh = String.init(format: "http://%@", urlParh)
        }
        
        guard let launchUrl = URL(string: urlParh) else { return }
        
        if !UIApplication.shared.canOpenURL(launchUrl) {
            return
        }
        
        let safariVC = SafariWebManager.getSafariViewController(url:launchUrl,safariDelegate: safariDelegate)
        
        if let vc = viewController {
            vc.present(safariVC, animated: true, completion: nil)
        }
        else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootVC = appDelegate.window?.rootViewController
            
            if let _vc = rootVC as? UITabBarController {
                let navController = _vc.viewControllers?.first
                
                if let _nav = navController as? UINavigationController, let _nav2 = _nav.topViewController {
                    _nav2.present(safariVC, animated: true, completion: nil)
                }
            } else if let _nav = rootVC as? UINavigationController {
                _nav.present(safariVC, animated: true, completion: nil)
            }
        }
    }
    
    private static func getSafariViewController(url:URL,safariDelegate:SFSafariViewControllerDelegate?) -> SFSafariViewController {
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let safariController = SFSafariViewController(url: url,configuration: config)
        
        if #available(iOS 13.0, *) {
            safariController.modalPresentationStyle = .automatic
        } else {
            safariController.modalPresentationStyle = .fullScreen
        }
        safariController.modalTransitionStyle = .coverVertical
        
        safariController.preferredBarTintColor = ApplicationTheme.getDefaultBackgroundBarColor()
        safariController.preferredControlTintColor = ApplicationTheme.getDefaultTintBarColor()
        
        safariController.delegate = safariDelegate
        return safariController
    }
}
