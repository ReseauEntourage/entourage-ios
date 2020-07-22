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
    var isStaging = false
    var uuidInfo = "*****"
    
    var currentUser:OTUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OTLogger.logEvent("OpenMenu")
        
        currentUser = UserDefaults.standard.currentUser
        loadUser()
        
        isStaging = OTAppConfiguration.sharedInstance()?.environmentConfiguration.runsOnStaging ?? false
        
        if isStaging {
            InstanceID.instanceID().getID { (token, error) in
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
        OTLogger.logEvent("GoodWavesClick")
        
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, GOOD_WAVES_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    @IBAction func action_tap_conseil(_ sender: Any) {
        OTLogger.logEvent("SimpleCommeBonjourClick")
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, SCB_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    @IBAction func action_tap_ideas(_ sender: Any) {
        OTLogger.logEvent("WhatActionsClick")
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, GOAL_LINK_ID,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    @IBAction func action_tap_ambassador(_ sender: Any) {
        OTLogger.logEvent("AmbassadorProgramClick")
        OTSafariService.launchInAppBrowser(withUrlString: JOIN_URL, viewController: self.navigationController)
    }
    @IBAction func action_tap_gift(_ sender: Any) {
        //  OTLogger.logEvent("LogOut")
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
        OTLogger.logEvent("ATDPartnershipView")
        let storyb = UIStoryboard.init(name: "Social", bundle: nil)
        if let vc = storyb.instantiateInitialViewController() {
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        
    }
    @IBAction func action_tap_charte(_ sender: Any) {
        OTLogger.logEvent("ViewEthicsChartClick")
        let userId = self.currentUser.sid.stringValue
        var url = String.init(format: CHARTE_LINK_FORMAT_PUBLIC, userId)
        if self.currentUser.isPro() {
            url = String.init(format: CHARTE_LINK_FORMAT_PRO, userId)
        }
        OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
    }
    @IBAction func action_tap_help(_ sender: Any) {
        OTLogger.logEvent("AboutClick")
        let storyb = UIStoryboard.init(name: "About", bundle: nil)
        if let vc = storyb.instantiateInitialViewController() {
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func action_tap_logout(_ sender: Any) {
        OTLogger.logEvent("LogOut")
        OTOngoingTourService.sharedInstance()?.isOngoing = false
        NotificationCenter.default.post(name: NSNotification.Name.loginFailure, object: self)
    }
    @IBAction func action_tap_uuid(_ sender: Any) {
        Logger.print("uuid")
        
        InstanceID.instanceID().getID { (token, error) in
            if let _token = token {
                UIPasteboard.general.string = _token
                SVProgressHUD.showInfo(withStatus: "Information copiée dans le presse-papier")
            }
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource -
extension OTMenuProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isStaging ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath) as! OTSettingsUserTableViewCell
            
            cell.populateCell(currentUser: self.currentUser,delegate: self)
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath) as! OTSettingsMenuTableViewCell
            let hasSignedChart = self.currentUser.hasSignedEthicsChart()
            let hasGoodWaves = self.currentUser.isGoodWavesValidated
            cell.populateCell(alreadyGoodWaves: hasGoodWaves, hasSignedChart: hasSignedChart)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell", for: indexPath) as! OTSettingsDebugTableViewCell
            cell.populateCell(info: uuidInfo)
            return cell
        }
    }
}

//MARK: - TapMenuProfileDelegate -
extension OTMenuProfileViewController: TapMenuProfileDelegate {
    func showProfile() {
        OTLogger.logEvent("TapMyProfilePhoto")
        
        let storyB = UIStoryboard.init(name: "UserProfile", bundle: nil)
        if let vc = storyB.instantiateInitialViewController() {
            if let _navVc = vc as? UINavigationController, let _vc = _navVc.topViewController as? OTUserViewController {
                _vc.user = currentUser
            }
            
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func editProfile() {
        //TODO:
        Logger.print("***** Edit profile")
        let storyB = UIStoryboard.init(name: "UserProfileEditor", bundle: nil)
        if let vc = storyB.instantiateInitialViewController() {
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func showEvents() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showEvents"), object: nil)
    }
    
    func showAll() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlls"), object: nil)
    }
}
