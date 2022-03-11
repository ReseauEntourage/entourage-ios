//
//  OTAssociationDetailViewController.swift
//  entourage
//
//  Created by Jr on 29/06/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import MessageUI
import IHProgressHUD

class AssociationDetailViewController: UIViewController,ClosePopDelegate {

    var association:Association? = nil
    @objc var associationId:Int = -1
    @IBOutlet weak var ui_tableview: UITableView!
    
    var hasNeeds = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "title_association".localized
        
        addCloseButtonLeftWithWhiteColorBar()
        
        if association == nil {
            getAssociationInfos()
            return
        }
       
        if association?.donations_needs?.count != 0 || association?.volunteers_needs?.count != 0 {
            hasNeeds = true
        }
    }
    
    func getAssociationInfos() {
        AssociationService.getAssociationDetail(id: associationId) { [weak self] association, error in
            if association != nil {
                self?.association = association
                
                if self?.association?.donations_needs?.count != 0 || self?.association?.volunteers_needs?.count != 0 {
                    self?.hasNeeds = true
                }
                DispatchQueue.main.async {
                    self?.ui_tableview.reloadData()
                }
            }
            else {
                Logger.print("Erreur get asso id : \(self?.associationId) err: -> \(String(describing: error?.error?.localizedDescription))")
            }
        }
    }
    
    func updateFollowing(isFollowing:Bool) {
        guard let _asso = association else {
            return
        }
        UserService.updateUserPartnerFollow(partnerId: _asso.aid!, isFollowing: isFollowing) { [weak self] error in
            if error == nil {
                self?.association?.isFollowing = isFollowing
                self?.ui_tableview.reloadData()
            }
        }
    }
    
    @IBAction func action_tap_follow(_ sender: Any) {
        if association?.isFollowing ?? false {
            let title =  String.init(format: "partnerFollowTitle".localized, self.association!.name)
            let message = String.init(format: "partnerFollowMessage".localized, self.association!.name)
            let alertvc = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

            let actionOK = UIAlertAction.init(title:"partnerFollowButtonValid".localized, style: .default) { (action) in
                self.updateFollowing(isFollowing: false)
            }
            let actionCancel = UIAlertAction.init(title:"partnerFollowButtonCancel".localized, style: .cancel) { (action) in
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
extension AssociationDetailViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasNeeds ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTopAsso", for: indexPath) as! AssoTopTableViewCell
            
            let hasDonation = association?.donations_needs?.count != 0 ? true : false
            let hasVolunteer = association?.volunteers_needs?.count != 0 ? true : false

            cell.populateCell(name: association?.name, subname: nil, assoDescription: association?.descr, imageUrl: association?.largeLogoUrl, hasDonation: hasDonation, hasVolunteer: hasVolunteer,isFollowing: association?.isFollowing ?? false)
            
            return cell
        }
        else if indexPath.section == 1 && hasNeeds {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNeedsAsso", for: indexPath) as! AssoNeedsTableViewCell
            
            cell.populateCell(donationsDescription: association?.donations_needs, volunteersDesription: association?.volunteers_needs)
            
            return cell
        }
        else {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cellContactAsso", for: indexPath) as! AssoContactTableViewCell
            
            cell.populateCell(website: association?.websiteUrl, phone: association?.phone, address: association?.address,email: association?.email,delegate: self)
            
            return cell
        }
    }
}

//MARK: - ShowInfoAssoDelegate -
extension AssociationDetailViewController: ShowInfoAssoDelegate {
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
            IHProgressHUD.showError(withStatus: "about_email_notavailable".localized)
        }
    }
    
    func sendAction(url:URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

//MARK: - MFMessageComposeViewControllerDelegate -
extension AssociationDetailViewController: MFMessageComposeViewControllerDelegate {

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
         self.dismiss(animated: true, completion: nil)
    }
}

extension AssociationDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
