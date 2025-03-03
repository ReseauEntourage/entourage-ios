//
//  ParamsAboutViewController.swift
//  entourage
//
//  Created by Jerome on 16/03/2022.
//

import UIKit
import MessageUI
import IHProgressHUD
import Lottie

class ParamsAboutViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    //MARK: - Constants for menu -
    let arrayMenuItems = [
        MenuItemInfos(title:"params_about_charte",url:CHARTE_URL),
        MenuItemInfos(title:"params_about_partner",url:PARTNER_URL, openInApp: false),
        MenuItemInfos(title:"params_about_faq",slug:MENU_ABOUT_SLUG_FAQ),
        MenuItemInfos(title:"params_about_email",url:emailContact),
        MenuItemInfos(title:"params_about_gift",slug:MENU_ABOUT_SLUG_GIFT),
        MenuItemInfos(title:"params_about_ambassador",url:AMBASSADOR_URL),
        MenuItemInfos(title:"params_about_rate_app",url:APPSTORE_URL, openInApp: false),
        MenuItemInfos(title:"params_about_cgu",slug:MENU_ABOUT_SLUG_CGU),
        MenuItemInfos(title: "params_about_privacy",slug: MENU_ABOUT_SLUG_PRIVACY),
        MenuItemInfos(title: "params_about_child_rule",slug: MENU_ABOUT_CHILD_RULES),
        MenuItemInfos(title:"params_about_licences",url:MENU_LICENSES_URL, openInApp: false)
        
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_top_view.populateView(title: "params_about_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        self.ui_tableview.dataSource = self
        self.ui_tableview.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
      }

}

//MARK: - UITableViewDataSource, UITableViewDelegate -
extension ParamsAboutViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = arrayMenuItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ParamsAboutCell
        
        let isLast = indexPath.row == arrayMenuItems.count - 1
        
        cell.populateCell(title: item.title.localized, isSeparatorHidden: isLast)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrayMenuItems[indexPath.row]
        
        if let _email = item.email {
            showEmail(email: _email)
            return
        }
        
        
        var webUrl:URL?
        
        if let _slug = item.slug, let token = UserDefaults.currentUser?.token {
            let relativeUrlStr = String.init(format: BASE_MENU_ABOUT, _slug,token)
            let _urlStr = "\(NetworkManager.sharedInstance.getBaseUrl())\(relativeUrlStr)"
            webUrl = URL(string: _urlStr)
        }
        else if let _urlStr = item.url {
            webUrl = URL(string: _urlStr)
        }
        WebLinkManager.openUrlInApp(url: webUrl, presenterViewController: self)
    }
    
    private func showEmail(email:String) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([email])
            composeVC.setSubject("")
            composeVC.setMessageBody("", isHTML: true)
            composeVC.navigationBar.tintColor = ApplicationTheme.getDefaultTintBarColor()
            composeVC.navigationBar.barTintColor  = ApplicationTheme.getDefaultBackgroundBarColor()
            self.present(composeVC, animated: true, completion: nil)
        }
        else {
            IHProgressHUD.showError(withStatus:  "about_email_notavailable".localized)
        }
    }
}

//MARK: - MFMailComposeViewControllerDelegate -
extension ParamsAboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - MainUserProfileTopCellDelegate -
extension ParamsAboutViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
