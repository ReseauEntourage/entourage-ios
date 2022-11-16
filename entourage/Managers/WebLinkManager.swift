//
//  WebLinkManager.swift
//  entourage
//
//  Created by Jerome on 16/03/2022.
//

import Foundation
import SafariServices

struct WebLinkManager {
    
    static func openUrl(url:URL?, openInApp:Bool, presenterViewController:UIViewController?, safariDelegate:SFSafariViewControllerDelegate? = nil) {
        if openInApp {
            openUrlInApp(url: url?.checkAndAddScheme, presenterViewController: presenterViewController,safariDelegate: safariDelegate)
        }
        else {
            openUrl(url: url?.checkAndAddScheme)
        }
    }

    private static func openUrlInApp(url:URL?, presenterViewController:UIViewController?, safariDelegate:SFSafariViewControllerDelegate? = nil) {
        guard let url = url else {
            return
        }
        SafariWebManager.launchUrlInApp(url: url, viewController: presenterViewController,safariDelegate: safariDelegate)
    }
    
    private static func openUrl(url:URL?) {
        guard let url = url else { return }
        
        UIApplication.shared.open(url)
    }
}
