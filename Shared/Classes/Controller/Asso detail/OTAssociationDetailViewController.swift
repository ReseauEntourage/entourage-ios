//
//  OTAssociationDetailViewController.swift
//  entourage
//
//  Created by Jr on 29/06/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import MessageUI
import SVProgressHUD

class OTAssociationDetailViewController: UIViewController,ClosePopDelegate {

    @objc var association:OTAssociation? = nil
    @objc var associationId:Int = -1
    @IBOutlet weak var ui_tableview: UITableView!
    
    var hasNeeds = false
    var changeColor = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "title_association")
        
        if changeColor {
            addCloseButtonLeftWithWhiteColorBar()
        }
        else {
            self.setupCloseModal()
        }
        
        if association == nil {
            getAssociationInfos()
            return
        }
        
        if association?.donations_needs?.count != 0 || association?.volunteers_needs?.count != 0 {
            hasNeeds = true
        }
    }
    
    func getAssociationInfos() {
        OTAssociationsService.init().getAssociationDetail(withId: Int32(associationId), withSuccess: { (asso) in
            if asso != nil {
                self.association = asso
                if self.association?.donations_needs?.count != 0 || self.association?.volunteers_needs?.count != 0 {
                    self.hasNeeds = true
                }
                DispatchQueue.main.async {
                    self.ui_tableview.reloadData()
                }
            }
        }) { (error) in
            Logger.print("Erreur get asso id : \(self.associationId) err: -> \(error)")
        }
    }
    
    func updateFollowing(isFollowing:Bool) {
        guard let _asso = association else {
            return
        }
        
        OTUserService.init().updateUserPartner(_asso.aid.stringValue, isFollowing: isFollowing) { (user) in
            self.association?.isFollowing = isFollowing
            self.ui_tableview.reloadData()
        } failure: { (error) in }
    }
    
    @IBAction func action_tap_follow(_ sender: Any) {
        if association?.isFollowing ?? false {
            let title =  String.init(format: OTLocalisationService.getLocalizedValue(forKey: "partnerFollowTitle"), self.association!.name)
            let message = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "partnerFollowMessage"), self.association!.name)
            let alertvc = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            
            let actionOK = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "partnerFollowButtonValid"), style: .default) { (action) in
                self.updateFollowing(isFollowing: false)
            }
            let actionCancel = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "partnerFollowButtonCancel"), style: .cancel) { (action) in
                alertvc.dismiss(animated: true, completion: nil)
            }
            alertvc.addAction(actionCancel)
            alertvc.addAction(actionOK)
            self.present(alertvc, animated: true, completion: nil)
        }
        else {
            self.updateFollowing(isFollowing: true)
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource -
extension OTAssociationDetailViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasNeeds ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTopAsso", for: indexPath) as! OTAssoTopTableViewCell
            
            let hasDonation = association?.donations_needs?.count != 0 ? true : false
            let hasVolunteer = association?.volunteers_needs?.count != 0 ? true : false
            
            cell.populateCell(name: association?.name, subname: nil, assoDescription: association?.descr, imageUrl: association?.largeLogoUrl, hasDonation: hasDonation, hasVolunteer: hasVolunteer,isFollowing: association?.isFollowing ?? false)
            
            return cell
        }
        else if indexPath.section == 1 && hasNeeds {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNeedsAsso", for: indexPath) as! OTAssoNeedsTableViewCell
            
            cell.populateCell(donationsDescription: association?.donations_needs, volunteersDesription: association?.volunteers_needs)
            
            return cell
        }
        else {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cellContactAsso", for: indexPath) as! OTAssoContactTableViewCell
            
            cell.populateCell(website: association?.websiteUrl, phone: association?.phone, address: association?.address,email: association?.email,delegate: self)
            
            return cell
        }
        
    }
}

//MARK: - ShowInfoAssoDelegate -
extension OTAssociationDetailViewController: ShowInfoAssoDelegate {
    func showAddress(address: String?) {
        if let _address = address,let _addressEncoded = "http://maps.apple.com/?address=\(_address)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),  let url = URL(string: _addressEncoded) {
            sendAction(url: url)
        }
    }
    
    func showWebsite(website: String?) {
       if let _website = website, let url = URL(string: _website) {
            sendAction(url: url)
        }
    }
    
    func sendCall(phone: String?) {
        if let _phone = phone, let url = URL(string: "tel://\(_phone)") {
            sendAction(url: url)
        }
    }
    
    func sendEmail(email: String?) {
        if let _email = email, MFMailComposeViewController.canSendMail()  {
            let controller = MFMailComposeViewController()
            controller.setMessageBody("", isHTML: true)
            controller.setToRecipients([_email])
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "about_email_notavailable"))
        }
    }
    
    func sendAction(url:URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

//MARK: - MFMessageComposeViewControllerDelegate -
extension OTAssociationDetailViewController: MFMessageComposeViewControllerDelegate {

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
         self.dismiss(animated: true, completion: nil)
    }
}

extension OTAssociationDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
