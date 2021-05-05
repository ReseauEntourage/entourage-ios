//
//  OTMenuProfileViewController.swift
//  entourage
//
//  Created by Jr on 22/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class OTMenuProfileViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    var uuidInfo = "*****"
    
    var currentUser:OTUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = UserDefaults.standard.currentUser
        loadUser()
        if let _info = Bundle.currentVersion(){
            self.uuidInfo = "v\(_info)"
        }
        
        let isStaging = OTAppConfiguration.sharedInstance()?.environmentConfiguration.runsOnStaging ?? false
        
        if isStaging {
            Messaging.messaging().token { token, error in
              if let _token = token, let _info = Bundle.fullCurrentVersion() {
                    self.uuidInfo = "v\(_info)\nFIId: \(_token)"
                    self.ui_tableview.reloadData()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUser), name: NSNotification.Name(rawValue: kNotificationProfilePictureUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUser), name: NSNotification.Name(rawValue: kNotificationSupportedPartnerUpdated), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        OTLogger.logEvent("View_Profile_Menu")
        currentUser = UserDefaults.standard.currentUser
        self.ui_tableview.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func loadUser() {
        SVProgressHUD.show()
        OTAuthService.init().getDetailsForUser(currentUser.uuid, success: { (user) in
            SVProgressHUD.dismiss()
            if let _user = user {
                self.currentUser = _user
                DispatchQueue.main.async {
                    self.ui_tableview.reloadData()
                }
            }
        }) { (error) in
            SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "user_profile_error"))
            DispatchQueue.main.async {
                self.ui_tableview.reloadData()
            }
        }
    }
    
    //MARK: - Notification -
    @objc func updateUser() {
        self.currentUser = UserDefaults.standard.currentUser
        let indexPath = IndexPath(row: 0, section: 0)
        self.ui_tableview.reloadRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - IBActions -
    @IBAction func action_tap_good_waves(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_goodWaves)
        
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, GOOD_WAVES_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    @IBAction func action_tap_conseil(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_SCBonjour)
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, SCB_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    @IBAction func action_tap_ideas(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_Actions)
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, GOAL_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    
    @IBAction func action_tap_ambassador(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_Ambassador)
        OTSafariService.launchInAppBrowser(withUrlString: JOIN_URL, viewController: self.navigationController)
    }
    @IBAction func action_tap_gift(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_Donate)
        let token = UserDefaults.standard.currentUser.token!
        
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, DONATE_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            // OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
            if let _url = URL.init(string: url) {
                UIApplication.shared.openURL(_url)
            }
        }
    }
    @IBAction func action_tap_follow(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_Follow)
        let storyb = UIStoryboard.init(name: "Social", bundle: nil)
        if let vc = storyb.instantiateInitialViewController() {
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        
    }
    @IBAction func action_tap_charte(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_Ethic)
        let token = self.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, CHARTE_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    @IBAction func action_tap_help(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_About)
        let storyb = UIStoryboard.init(name: "About", bundle: nil)
        if let vc = storyb.instantiateInitialViewController() {
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func action_tap_logout(_ sender: Any) {
        OTLogger.logEvent(Action_Profile_Logout)
        OTOngoingTourService.sharedInstance()?.isOngoing = false
        NotificationCenter.default.post(name: NSNotification.Name.loginFailure, object: self)
    }
    @IBAction func action_tap_uuid(_ sender: Any) {
        Logger.print("uuid")
        Messaging.messaging().token { token, error in
           if let _token = token {
                UIPasteboard.general.string = _token
                SVProgressHUD.showInfo(withStatus: "Information copiée dans le presse-papier")
           }
        }
    }
    
    @IBAction func action_tap_linkedout(_ sender: Any) {
        if let url = URL(string: ABOUT_LINKEDOUT) {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func action_tap_share(_ sender: Any) {
        let textShare = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "menu_info_text_share"), ENTOURAGE_BITLY_LINK)
        
        
        let activityVC = UIActivityViewController.init(activityItems: [textShare], applicationActivities: nil)
        
        if #available(iOS 11.0, *) {
            activityVC.excludedActivityTypes = [.print,.airDrop,.markupAsPDF,.postToVimeo,.openInIBooks,.postToFlickr,.assignToContact,.saveToCameraRoll,.postToTencentWeibo]
        } else {
            activityVC.excludedActivityTypes = [.print,.airDrop,.postToVimeo,.openInIBooks,.postToFlickr,.assignToContact,.saveToCameraRoll,.postToTencentWeibo]
        }
        
        OTAppConfiguration.configureActivityControllerAppearance(nil, color: ApplicationTheme.shared().primaryNavigationBarTintColor)
        
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            OTAppConfiguration.configureActivityControllerAppearance(nil, color: ApplicationTheme.shared().secondaryNavigationBarTintColor)
        }
        activityVC.navigationController?.navigationBar.tintColor = ApplicationTheme.shared().primaryNavigationBarTintColor
        self.navigationController?.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func action_tap_blog(_ sender: Any) {
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, BLOG_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    
    @IBAction func action_facebook(_ sender: Any) {
        if let url = URL(string: ABOUT_FACEBOOK_URL) {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func action_insta(_ sender: Any) {
        if let url = URL(string: ABOUT_INSTAGRAM_URL) {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func action_twit(_ sender: Any) {
        if let url = URL(string: ABOUT_TWITTER_URL) {
            UIApplication.shared.openURL(url)
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource -
extension OTMenuProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath) as! OTSettingsUserTableViewCell
            cell.populateCell(currentUser: self.currentUser,delegate: self)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFirst", for: indexPath) as! OTSettingsMenuFirstTableViewCell
            let hasSignedChart = self.currentUser.hasSignedEthicsChart()
            cell.populateCell(hasSignedChart: hasSignedChart)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSecond", for: indexPath) as! OTSettingsMenuSecondTableViewCell
            let hasGoodWaves = self.currentUser.isGoodWavesValidated
            cell.populateCell(alreadyGoodWaves: hasGoodWaves)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellThird", for: indexPath)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHelpEnd", for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell", for: indexPath) as! OTSettingsDebugTableViewCell
            cell.populateCell(info: uuidInfo)
            return cell
        }
    }
}

//MARK: - TapMenuProfileDelegate -
extension OTMenuProfileViewController: TapMenuProfileDelegate {
    func showProfile() {
        OTLogger.logEvent(Action_Profile_ShowProfil)
        
        let storyB = UIStoryboard.init(name: "UserProfile", bundle: nil)
        if let vc = storyB.instantiateInitialViewController() {
            if let _navVc = vc as? UINavigationController, let _vc = _navVc.topViewController as? OTUserViewController {
                _vc.user = currentUser
            }
            
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func editProfile() {
        OTLogger.logEvent(Action_Profile_ModProfil)
        let storyB = UIStoryboard.init(name: "UserProfileEditor", bundle: nil)
        if let vc = storyB.instantiateInitialViewController() {
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func showEvents() {
        OTLogger.logEvent(Action_Menu_EventsCount)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showEvents"), object: nil)
    }
    
    func showAll() {
        OTLogger.logEvent(Action_Menu_ActionsCount)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlls"), object: nil)
    }
}
