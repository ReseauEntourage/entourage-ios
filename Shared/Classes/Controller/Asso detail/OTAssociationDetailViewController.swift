//
//  OTAssociationDetailViewController.swift
//  entourage
//
//  Created by Jr on 29/06/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import MessageUI

class OTAssociationDetailViewController: UIViewController {

    @objc var association:OTAssociation? = nil
    @IBOutlet weak var ui_tableview: UITableView!
    
    var hasNeeds = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "title_association")
        self.setupCloseModal()
        
        if association?.donations_needs?.count != 0 || association?.volunteers_needs?.count != 0 {
            hasNeeds = true
        }
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
            
            cell.populateCell(name: association?.name, subname: nil, assoDescription: association?.descr, imageUrl: association?.largeLogoUrl, hasDonation: hasDonation, hasVolunteer: hasVolunteer)
            
            return cell
        }
        else if indexPath.section == 1 && hasNeeds {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNeedsAsso", for: indexPath) as! OTAssoNeedsTableViewCell
            
            cell.populateCell(donationsDescription: association?.donations_needs, volunteersDesription: association?.volunteers_needs)
            
            return cell
        }
        else {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cellContactAsso", for: indexPath) as! OTAssoContactTableViewCell
            
            cell.populateCell(website: association?.websiteUrl, phone: association?.phone, address: association?.address,delegate: self)
            
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
    
    func sendMessage(phone: String?) {
        if let _phone = phone, MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [_phone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
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
