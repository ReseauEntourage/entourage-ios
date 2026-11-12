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
        if url.absoluteString.contains("charte-ethique"){
            isOurPattern = false
        }
        return isOurPattern
    }
    
    /// Hôtes de visioconférence à confier au système (lien universel → app dédiée, sinon Safari),
    /// jamais à un navigateur embarqué : pas de session Google, pas de lancement de l'app Meet.
    /// Pour en ajouter (zoom.us, teams.microsoft.com…), compléter cet ensemble.
    static let systemOpenedHosts: Set<String> = ["meet.google.com"]

    /// Vrai si l'hôte de l'URL est exactement l'un de `systemOpenedHosts`.
    /// Accepte une URL sans schéma, en majuscules, avec un chemin (`/meet/…`) ou une query (`?authuser=0`).
    static func isSystemOpenedLink(_ urlString: String?) -> Bool {
        guard let normalized = normalizedWebString(urlString),
              let components = URLComponents(string: normalized),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = components.host?.lowercased() else {
            return false
        }
        return systemOpenedHosts.contains(host)
    }

    static func isSystemOpenedLink(url: URL) -> Bool {
        isSystemOpenedLink(url.absoluteString)
    }

    /// Ajoute `https://` quand le schéma manque (l'URL elle-même n'est jamais réécrite autrement).
    private static func normalizedWebString(_ urlString: String?) -> String? {
        guard let trimmed = urlString?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed.contains("://") ? trimmed : "https://" + trimmed
    }

    /// Confie un lien de visio au système. Faux si l'URL n'est pas concernée.
    @discardableResult
    private static func openSystemOpenedLink(_ url: URL) -> Bool {
        guard isSystemOpenedLink(url: url),
              let normalized = normalizedWebString(url.absoluteString),
              let systemURL = URL(string: normalized) else {
            return false
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(systemURL)
        }
        return true
    }

    static func openUrl(url: URL?, openInApp: Bool, presenterViewController: UIViewController?, safariDelegate: SFSafariViewControllerDelegate? = nil) {
        guard let _url = url else {
            print("[WebLinkManager] URL is nil.")
            return
        }
        // Visio (Google Meet…) : toujours par le système, quel que soit `openInApp`.
        if openSystemOpenedLink(_url) { return }
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
        // Visio (Google Meet…) : jamais dans le navigateur embarqué.
        if openSystemOpenedLink(_url) { return }

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
