//
//  OTGuideDetailPoiViewController.swift
//  entourage
//
//  Created by Jr on 02/10/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

@objc class OTGuideDetailPoiViewController: UIViewController {
    
    @IBOutlet weak var ui_bt_sendmail: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    @objc var poi:OTPoi!
    
    var hasPublicRow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "guideTitle")
        
        self.navigationController?.isNavigationBarHidden = false
        self.setupCloseModalWithoutTint(withTint: UIColor.appOrange())
        
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController, withMainColor: .white, andSecondaryColor: UIColor.appOrange())
        
        getDetailPoi()
        
        ui_bt_sendmail.layer.borderColor = UIColor.white.cgColor
    }
    
    func getDetailPoi() {
        OTPoiService.init().getDateilpoiWithId(Int32(self.poi.sid.intValue)) { (poiResponse) in
            if let _poi = poiResponse {
                self.poi = _poi
                self.setupUI()
            }
        } failure: { (error) in
            Logger.print("error get detail poi : \(String(describing: error?.localizedDescription))")
        }
    }
    
    func setupUI() {
        if self.poi.audience != nil && self.poi.audience.count > 0 {
            hasPublicRow = true
        }
        else {
            hasPublicRow = false
        }
        self.ui_tableview.reloadData()
    }
    
    //MARK: - IBACTIONS -
    @IBAction func action_phone(_ sender: Any) {
        var component = URLComponents.init()
        component.path = self.poi.phone
        component.scheme = "tel"
        if let _url = component.url {
            UIApplication.shared.openURL(_url)
        }
    }
    
    @IBAction func action_mail(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "about_email_notavailable"))
            return
        }
        
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([self.poi.email])
        composeVC.setSubject("")
        composeVC.setMessageBody("", isHTML: true)
        
        OTAppConfiguration.configureMailControllerAppearance(composeVC)
        composeVC.navigationBar.tintColor = UIColor.appOrange()
        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func action_web(_ sender: Any) {
        var urlReal = ""
        if let url = self.poi.website {
            urlReal = url
            if !url.contains("http") {
                urlReal = String.init(format: "http://%@", url)
            }
        }
        if let url = URL.init(string: urlReal) {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func action_location(_ sender: Any) {
        if let _address = self.poi.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let mapString = String.init(format: "http://maps.apple.com/?address=%@", _address)
            
            if let url = URL(string: mapString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func action_send_update_poi(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "about_email_notavailable"))
            return
        }
        
        let subject = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "structure_subject"), self.poi.name!,self.poi.sid)
        let recipeint = OTAppAppearance.reportActionToRecepient()!
        
        //  OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([recipeint])
        composeVC.setSubject(subject)
        composeVC.setMessageBody("", isHTML: true)
        
        //  OTAppConfiguration.configureMailControllerAppearance(composeVC)
        
        composeVC.navigationBar.tintColor = UIColor.appOrange()
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func action_share(_ sender: Any) {
        let name = self.poi.name == nil || self.poi.name.count == 0 ? "" : self.poi.name!
        let address = (self.poi.address == nil || self.poi.address.count == 0) ? "" : "Adresse: \(self.poi.address!)"
        let phone = (self.poi.phone == nil  || self.poi.phone.count == 0) ? "" : "Tel: \(self.poi.phone!)"
        
        let url = ENTOURAGE_BITLY_LINK
        let message = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "info_share_sms_poi"), name,address,phone,url)
        
        let activityVC = UIActivityViewController.init(activityItems: [message], applicationActivities: nil)
        
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
}

//MARK: - MFMailComposeViewControllerDelegate -
extension OTGuideDetailPoiViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource,UITableViewDelegate -
extension OTGuideDetailPoiViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasPublicRow {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! OTGuideDetailTopTableViewCell
            
            cell.populateCell(poi: poi)
            return cell
        }
        
        if index == 1 && hasPublicRow {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPublic", for: indexPath) as! OTGuideDetailPublicTableViewCell
            
            cell.populateCell(description: poi.audience)
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellContact", for: indexPath) as! OTGuideDetailContactTableViewCell
        
        cell.populateCell(poi: poi)
        
        return cell
    }
}
