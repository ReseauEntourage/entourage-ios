//
//  PedagogicDetailViewController.swift
//  entourage
//
//  Created by Jerome on 10/06/2022.
//

import UIKit
import WebKit

class PedagogicDetailViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_webview: WKWebView!
    
    @IBOutlet weak var ui_indicator: UIActivityIndicatorView!
    var urlWebview:String? = ""
    var resourceId:Int? = nil
    var isRead = false
    
    weak var delegate:PedagogicReadDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_indicator.hidesWhenStopped = true
        ui_indicator.color = .appOrange
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "home_resource_title".localized, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        guard let urlWebview = urlWebview, let url = URL(string: urlWebview) else {
            goBack()
            return
        }
        
        ui_webview.uiDelegate = self
        ui_webview.navigationDelegate = self
        ui_webview.load(URLRequest(url: url))
        
        if let id = resourceId, !isRead {
            ui_indicator.startAnimating()
            HomeService.postResourceRead(resourceId: id) { [weak self] error in
                if error == nil {
                    self?.delegate?.markReadPedogicResource(id: id)
                }
            }
        }
    }
}

//MARK: - WKNavigationDelegate -
extension PedagogicDetailViewController:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ui_indicator.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ui_indicator.stopAnimating()
    }
}

//MARK: - PedagogicReadDelegate -
protocol PedagogicReadDelegate:AnyObject {
    func markReadPedogicResource(id:Int)
}

//MARK: - MJNavBackViewDelegate -
extension PedagogicDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
