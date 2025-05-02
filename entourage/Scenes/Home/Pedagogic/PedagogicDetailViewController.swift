import UIKit
import WebKit

class PedagogicDetailViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_webview: WKWebView!
    
    @IBOutlet weak var ui_indicator: UIActivityIndicatorView!
    var urlWebview: String? = ""
    var resourceId: Int? = nil
    var hashdResourceId: String? = ""
    var isRead = false
    var htmlBody: String? = nil
    
    weak var delegate: PedagogicReadDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_indicator.hidesWhenStopped = true
        ui_indicator.color = .appOrange
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "home_resource_title".localized, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)

        ui_webview.uiDelegate = self
        ui_webview.navigationDelegate = self
        
        if let htmlBody = htmlBody {
            ui_webview.loadHTMLString(htmlBody, baseURL: nil)
        }
        self.getDetailResource()
    }
    
    func getDetailResource() {
        var _resourceId = ""
        if self.resourceId != nil {
            _resourceId = String(resourceId!)
        } else if hashdResourceId != "" {
            _resourceId = hashdResourceId ?? ""
        }
        
        delegate?.markReadPedogicResource(id: resourceId ?? 0)
        HomeService.getResourceWithId(_resourceId) { resource, error in
            if let htmlBody = resource?.bodyHtml {
                DispatchQueue.main.async {
                    self.ui_webview.loadHTMLString(htmlBody, baseURL: nil)
                }
            }
        }
    }
}

//MARK: - WKNavigationDelegate -
extension PedagogicDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ui_indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ui_indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            if components.host == UniversalLinkManager.prodURL ||
               components.host == UniversalLinkManager.prodURL2 ||
               components.host == UniversalLinkManager.stagingURL ||
               components.host == UniversalLinkManager.stagingURL2 {
                
                // Utiliser la fonction UniversalLinkManager.handleUniversalLink pour gérer le lien
                UniversalLinkManager.handleUniversalLink(components: components)
                decisionHandler(.cancel) // Annuler la navigation par défaut
                return
            }
        }
        decisionHandler(.allow) // Autoriser la navigation par défaut
    }
}

//MARK: - PedagogicReadDelegate -
protocol PedagogicReadDelegate: AnyObject {
    func markReadPedogicResource(id: Int)
}

//MARK: - MJNavBackViewDelegate -
extension PedagogicDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    func didTapEvent() {
        //Nothing yet
    }
}
