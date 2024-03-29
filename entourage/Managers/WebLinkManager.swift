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
    
    static func isOurPatternURL(_ url: URL) -> Bool {
        var isOurPattern =  url.absoluteString.contains(prodURL) ||
               url.absoluteString.contains(prodURL2) ||
               url.absoluteString.contains(stagingURL) ||
               url.absoluteString.contains(stagingURL2)
        if url.absoluteString.contains("action") {
            isOurPattern = false
        }
        if url.absoluteString.contains("charte-ethique-grand-public"){
            isOurPattern = false
        }
        return isOurPattern
    }
    
    static func openUrl(url: URL?, openInApp: Bool, presenterViewController: UIViewController?, safariDelegate: SFSafariViewControllerDelegate? = nil) {
        guard let _url = url else {
            print("[WebLinkManager] URL is nil.")
            return
        }
        var _openInApp = openInApp
        var isOurPattern = _url.absoluteString.contains(prodURL) ||
            _url.absoluteString.contains(prodURL2) ||
            _url.absoluteString.contains(stagingURL) ||
            _url.absoluteString.contains(stagingURL2)
        
        if _url.absoluteString.contains("action") {
            isOurPattern = false
            _openInApp = true
        }
        if _url.absoluteString.contains("charte-ethique-grand-public"){
            isOurPattern = false
            _openInApp = true
        }
        
        if isOurPattern {
            guard let components = URLComponents(url: _url, resolvingAgainstBaseURL: false) else {
                print("[WebLinkManager] Failed to create URLComponents from \(_url.absoluteString).")
                return
            }
            UniversalLinkManager.handleUniversalLink(components: components)
        } else if _openInApp {
            openUrlInApp(url: _url.checkAndAddScheme, presenterViewController: presenterViewController, safariDelegate: safariDelegate)
        } else {
            openUrl(url: _url.checkAndAddScheme)
        }
    }

    static func openUrlInApp(url: URL?, presenterViewController: UIViewController?, safariDelegate: SFSafariViewControllerDelegate? = nil) {
        guard let _url = url, let viewController = presenterViewController else {
            print("[WebLinkManager] URL or presenterViewController is nil.")
            return
        }
        
        DispatchQueue.main.async {
            SafariWebManager.launchUrlInApp(url: _url, viewController: viewController, safariDelegate: safariDelegate)
        }
    }
    
    private static func openUrl(url: URL?) {
        guard let _url = url else {
            print("[WebLinkManager] URL is nil.")
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(_url)
        }
    }
}
