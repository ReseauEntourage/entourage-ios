//
//  OTGuideDetailPoiViewController.swift
//  entourage
//
//  Created by Jr on 02/10/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import IHProgressHUD
import MessageUI

@objc class GuideDetailPoiViewController: UIViewController {
    
    @IBOutlet weak var ui_bt_sendmail: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_view_parent_info_poi: UIView!
    @IBOutlet weak var ui_tableview_infos_poi: UITableView!
    
    @IBOutlet weak var ui_constraint_height_view_update: NSLayoutConstraint!
    var poi:MapPoi!
    var isFromDeeplink = false
    
    var hasPublicRow = false
    
    var filters = GuideFilters()
    
    var popupViewController:UIViewController? = nil
    
    var isSoliguide = false
    
    
    var filtersSelectedFromMap = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "guideTitle".localized
        
        self.navigationController?.isNavigationBarHidden = false

        setupNavigationBarColor()
        
        var img:UIImage?
        if #available(iOS 13.0, *) {
            img = (UIImage.init(named: "close_new_orange")?.withTintColor(UIColor.appOrange, renderingMode: .alwaysTemplate))
        } else {
            img = UIImage.init(named: "close_new_orange")
            img = img?.withRenderingMode(.alwaysTemplate)
        }
        
        let closeButton = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(dismissSelf))
        self.navigationItem.setLeftBarButton(closeButton, animated: false)
        closeButton.tintColor = UIColor.appOrange
        
        getDetailPoi()
        
        ui_bt_sendmail.layer.borderColor = UIColor.white.cgColor
        
        if self.isFromDeeplink {
            self.navigationItem.leftBarButtonItem?.action = #selector(dismissSelf)
        }
    }
    
    @objc func dismissSelf() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDetailPoi() {
        //Actually WS return id and not uuid for entourage poi 
        let uuid = (self.poi.uuid?.count ?? 0 > 0) ? self.poi.uuid! : "\(self.poi.sid)"
        
        PoiService.getDetailPoiWith(poiId: uuid) { [weak self] poi, error in
            if let _poi = poi {
                self?.poi = _poi
                self?.isSoliguide = _poi.isSoliguide()
                self?.setupUI()
            }
        }
    }
    
    func setupUI() {
        if self.poi.audience?.count ?? 0 > 0 {
            hasPublicRow = true
        }
        else {
            hasPublicRow = false
        }
        
        if isSoliguide {
            ui_constraint_height_view_update.constant = 0
        }
        
        self.ui_tableview.reloadData()
        
        //TODO: a faire Analytics
//        if isSoliguide, let _poiId = poi.soliguideId, let _poiUid = poi.uuid {
//           // let _str = String.init(format: Soliguide_Show_Poi, _poiId,_poiUid,filtersSelectedFromMap)
//           // OTLogger.logEvent(_str)
//        }
    }
    
    //MARK: - IBACTIONS -
    @IBAction func action_show_soliguide(_ sender: Any) {
        //TODO: - In App ou pas ?
        if let _url = poi.soliguideUrl, let url = URL.init(string: _url), let _poiUid = poi.uuid {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //TODO: a faire Analytics
//            if let _poiId = poi.soliguideId {
//                let _str = String.init(format:Soliguide_Click, _poiId,_poiUid,filtersSelectedFromMap)
//                OTLogger.logEvent(_str)
//            }
        }
    }
    
    @IBAction func action_phone(_ sender: Any) {
        var component = URLComponents.init()
        component.path = self.poi.phone!
        component.scheme = "tel"
        if let _url = component.url {
            UIApplication.shared.open(_url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func action_mail(_ sender: Any) {
        
        if !MFMailComposeViewController.canSendMail() {
            IHProgressHUD.showError(withStatus: "about_email_notavailable".localized)
            return
        }
//
//       //TODO: a faire mail OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([self.poi.email!])
        composeVC.setSubject("")
        composeVC.setMessageBody("", isHTML: true)

      //  OTAppConfiguration.configureMailControllerAppearance(composeVC)
        composeVC.navigationBar.tintColor = UIColor.appOrange
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
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func action_location(_ sender: Any) {
        if let _address = self.poi.address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let mapString = String.init(format: "http://maps.apple.com/?address=%@", _address)
            
            if let url = URL(string: mapString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func action_send_update_poi(_ sender: Any) {

        if !MFMailComposeViewController.canSendMail() {
            IHProgressHUD.showError(withStatus: "about_email_notavailable".localized)
            return
        }

        let uuid : String! = (self.poi.uuid != nil && self.poi.uuid!.count > 0) ? self.poi.uuid! : "\(self.poi.sid!)"
        let subject = String.init(format: "structure_subject".localized, self.poi.name,uuid)

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([emailContact])
        composeVC.setSubject(subject)
        composeVC.setMessageBody("", isHTML: true)

        composeVC.navigationBar.tintColor = UIColor.appOrange

        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func action_share(_ sender: Any) {
        if let _vc = storyboard?.instantiateViewController(withIdentifier: "shareVC"), let vc = _vc as? InviteSourceViewController  {
            vc.delegate = self
            self.popupViewController = vc
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func action_close_legend(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        self.ui_view_parent_info_poi.alpha = 1
        
        UIView.animate(withDuration: 0.3) {
            self.ui_view_parent_info_poi.alpha = 0
        } completion: { (isok) in
            self.ui_view_parent_info_poi.isHidden = true
        }
    }
    
    @IBAction func action_show_legend(_ sender: Any) {
        
        self.ui_view_parent_info_poi.alpha = 0
        self.ui_view_parent_info_poi.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.ui_view_parent_info_poi.alpha = 1
        } completion: { (isok) in
            self.navigationController?.isNavigationBarHidden = true
        }
    }
}

//MARK: - InviteSourceDelegate -
//TODO: a faire
extension GuideDetailPoiViewController: InviteSourceDelegate {
    func shareEntourage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            OTLogger.logEvent(Action_guideMap_SharePOI)

//            let storyB = UIStoryboard.activeFeeds()
//            if let vc = storyB?.instantiateViewController(withIdentifier: "OTShareListEntouragesVC") as? OTShareEntourageViewController {
//                vc.feedItem = nil
//                //vc.delegate = self
//                vc.isSharePoi = true
//                vc.poiId = (self.poi.sid != nil) ? self.poi.sid.intValue : (Int(self.poi.uuid) ?? 0)
//
//                if #available(iOS 13.0, *) {
//                    vc.isModalInPresentation = true
//                }
//                self.navigationController?.present(vc, animated: true, completion: nil)
//            }
        }
    }

    func share() {
        popupViewController?.dismiss(animated: false, completion: {
            self.popupViewController = nil
        })

//        OTLogger.logEvent(Action_guideMap_SharePOI) //TODO: A faire anayltics

        let name = self.poi.name.count == 0 ? "" : self.poi.name
        let address = (self.poi.address == nil || self.poi.address?.count ?? 0 == 0) ? "" : "Adresse: \(self.poi.address!)"
        let phone = (self.poi.phone == nil  || self.poi.phone?.count ?? 0 == 0) ? "" : "Tel: \(self.poi.phone!)"

        let url = ENTOURAGE_BITLY_LINK
        let message = String.init(format: "info_share_sms_poi".localized, name,address,phone,url)

        let activityVC = UIActivityViewController.init(activityItems: [message], applicationActivities: nil)

        activityVC.excludedActivityTypes = [.print,.airDrop,.markupAsPDF,.postToVimeo,.openInIBooks,.postToFlickr,.assignToContact,.saveToCameraRoll,.postToTencentWeibo]
    
        self.navigationController?.present(activityVC, animated: true, completion: nil)
    }
}

//MARK: - MFMailComposeViewControllerDelegate -
//TODO: a faire
extension GuideDetailPoiViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource,UITableViewDelegate -
extension GuideDetailPoiViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == ui_tableview_infos_poi {
            return filters.arrayFilters.count
        }
        
        if isSoliguide {
            return 4
        }
        else {
            if hasPublicRow {
                return 3
            }
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        if tableView == ui_tableview_infos_poi {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFiter", for: indexPath) as! GuideFilterCell
            
            cell.populateCell(item: filters.arrayFilters[index])
            
            return cell
        }
        
        if isSoliguide {
            switch index {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellTopSoliguide", for: indexPath)
                return cell
            case 1:
                return setupTopCell(indexPath: indexPath)
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSoliguide", for: indexPath) as! OTGuideDetailSoliguideTableViewCell
                
                cell.populateCell(publicTxt: poi.audience, openTimeTxt: poi.openTimeTxt, languageTxt: poi.languageTxt)
                
                return cell
            default:
                return setupContactCell(indexPath: indexPath)
            }
        }
        
        if index == 0 {
            return setupTopCell(indexPath: indexPath)
        }
        
        if index == 1 && hasPublicRow {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPublic", for: indexPath) as! OTGuideDetailPublicTableViewCell
            
            cell.populateCell(description: poi.audience ?? "")
            return cell
        }
        
        return setupContactCell(indexPath: indexPath)
    }
    
    func setupContactCell(indexPath:IndexPath) -> UITableViewCell {
        let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellContact", for: indexPath) as! OTGuideDetailContactTableViewCell
        
        cell.populateCell(poi: poi)
        
        return cell
    }
    
    func setupTopCell(indexPath:IndexPath) -> UITableViewCell {
        let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! OTGuideDetailTopTableViewCell
        
        cell.populateCell(poi: poi)
        return cell
    }
}
