//
//  WelcomeOneWebViewCell.swift
//  entourage
//
//  Created by Clement entourage on 22/05/2023.
//

import Foundation
import WebKit

class WelcomeOneWebViewCell:UITableViewCell{
    
    @IBOutlet weak var ui_webview: WKWebView!
    
    @IBOutlet weak var ui_spinner: UIActivityIndicatorView!
    
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        ui_spinner.startAnimating()
        ui_webview.navigationDelegate = self
        ui_webview.layer.cornerRadius = 15
        let videoURL = URL(string: "https://www.youtube.com/embed/IYUo5WAZxXs")
        let request = URLRequest(url: videoURL!)
        ui_webview.load(request)
    }
}

extension WelcomeOneWebViewCell:WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ui_spinner.isHidden = true
    }
}
