//
//  WebLinkManager.swift
//  entourage
//
//  Created by Jerome on 16/03/2022.
//

import Foundation

struct WebLinkManager {
    
    static func openUrl(url:URL?, openInApp:Bool, presenterViewController:UIViewController?) {
        if openInApp {
            openUrlInApp(url: url?.checkAndAddScheme, presenterViewController: presenterViewController)
        }
        else {
            openUrl(url: url?.checkAndAddScheme)
        }
    }

    private static func openUrlInApp(url:URL?, presenterViewController:UIViewController?) {
        guard let url = url else {
            return
        }
        SafariWebManager.launchUrlInApp(url: url, viewController: presenterViewController)
    }
    
    private static func openUrl(url:URL?) {
        guard let url = url else { return }
        
        UIApplication.shared.open(url)
    }
}
