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
    var htmlBody:String? = nil
    
    weak var delegate:PedagogicReadDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_indicator.hidesWhenStopped = true
        ui_indicator.color = .appOrange
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "home_resource_title".localized, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)

        ui_webview.uiDelegate = self
        ui_webview.navigationDelegate = self
        
        guard let htmlBody = htmlBody else {
            self.getDetailResource()
            return
        }
       
        ui_webview.loadHTMLString(htmlBody, baseURL: nil)
        
        if let id = resourceId, !isRead {
            ui_indicator.startAnimating()
            HomeService.postResourceRead(resourceId: id) { [weak self] error in
                if error == nil {
                    self?.delegate?.markReadPedogicResource(id: id)
                }
            }
        }
    }
    
    func getDetailResource() {
        guard let resourceId = resourceId else {
            return
        }

        HomeService.getResourceWithId(resourceId) { resource, error in
            if let htmlBody = resource?.bodyHtml {
                DispatchQueue.main.async {
                    self.ui_webview.loadHTMLString(htmlBody, baseURL: nil)
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
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
        
    }
}
