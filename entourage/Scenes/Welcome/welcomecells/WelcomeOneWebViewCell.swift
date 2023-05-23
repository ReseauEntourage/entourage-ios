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
    
    
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        ui_webview.layer.cornerRadius = 15
        let videoURL = URL(string: "https://www.youtube.com/embed/IYUo5WAZxXs")
        let request = URLRequest(url: videoURL!)
        ui_webview.load(request)
    }
}
