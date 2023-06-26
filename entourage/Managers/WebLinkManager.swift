//
//  WebLinkManager.swift
//  entourage
//
//  Created by Jerome on 16/03/2022.
//

import Foundation
import SafariServices

struct WebLinkManager {
    static let prodURL = "app.entourage.social"
    static let prodURL2 = "www.entourage.social"
    static let stagingURL2 = "preprod.entourage.social"
    static let stagingURL = "entourage-webapp-preprod.herokuapp.com"
    
    static func openUrl(url:URL?, openInApp:Bool, presenterViewController:UIViewController?, safariDelegate:SFSafariViewControllerDelegate? = nil) {
        if let _url = url {
            var isOurPattern = _url.absoluteString.contains(prodURL) || _url.absoluteString.contains(prodURL2) || _url.absoluteString.contains(stagingURL) || _url.absoluteString.contains(stagingURL2)
            if _url.absoluteString.contains("action"){
               isOurPattern = false
            }
            if isOurPattern {
                let components = URLComponents(url: _url, resolvingAgainstBaseURL: false)!
                UniversalLinkManager.handleUniversalLink(components:components)
                return
            }
        }
        if openInApp {
            openUrlInApp(url: url?.checkAndAddScheme, presenterViewController: presenterViewController,safariDelegate: safariDelegate)
            return
        }
        else {
            openUrl(url: url?.checkAndAddScheme)
            return
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
