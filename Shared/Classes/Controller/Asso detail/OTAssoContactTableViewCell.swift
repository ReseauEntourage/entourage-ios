//
//  OTAssoContactTableViewCell.swift
//  entourage
//
//  Created by Jr on 30/06/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTAssoContactTableViewCell: UITableViewCell {

    let fontSizeIphoneSE:CGFloat = 13
    @IBOutlet weak var ui_tv_contact: UILabel!
    @IBOutlet weak var ui_tv_website: UILabel!
    @IBOutlet weak var ui_tv_phone: UILabel!
    @IBOutlet weak var ui_tv_address: UILabel!
    @IBOutlet weak var ui_tv_website_desc: UILabel!
    @IBOutlet weak var ui_tv_phone_desc: UILabel!
    @IBOutlet weak var ui_tv_address_desc: UILabel!
    
    @IBOutlet weak var ui_view_message: UIView!
    @IBOutlet weak var ui_view_phone: UIView!
    weak var delegate:ShowInfoAssoDelegate? = nil
    
    var phone:String? = nil
    var address:String? = nil
    var website:String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_tv_contact.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_contact")
        ui_tv_phone.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_phone")
        ui_tv_website.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_website")
        ui_tv_address.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_address")
        ui_view_phone.layer.cornerRadius = 8.0
        ui_view_message.layer.cornerRadius = 8.0
        
        if UIScreen.main.bounds.height <= 568 {
            ui_tv_phone.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_phone_light")
            ui_tv_phone.font = ui_tv_phone.font.withSize(fontSizeIphoneSE)
            ui_tv_address.font = ui_tv_address.font.withSize(fontSizeIphoneSE)
            ui_tv_website.font = ui_tv_website.font.withSize(fontSizeIphoneSE)
            
            ui_tv_website_desc.font = ui_tv_website_desc.font.withSize(fontSizeIphoneSE)
            ui_tv_phone_desc.font = ui_tv_phone_desc.font.withSize(fontSizeIphoneSE)
            ui_tv_address_desc.font = ui_tv_address_desc.font.withSize(fontSizeIphoneSE)
        }
    }

    func populateCell(website:String?,phone:String?,address:String?,delegate:ShowInfoAssoDelegate) {
        ui_tv_website_desc.text = website
        ui_tv_phone_desc.text = phone
        ui_tv_address_desc.text = address
        
        self.address = address
        self.phone = phone
        self.website = website
        self.delegate = delegate
    }

    @IBAction func action_send_phone(_ sender: Any) {
        delegate?.sendCall(phone: phone)
    }
    @IBAction func action_send_message(_ sender: Any) {
        delegate?.sendMessage(phone: phone)
    }
    @IBAction func action_show_website(_ sender: Any) {
        delegate?.showWebsite(website: website)
    }
    @IBAction func action_show_addess(_ sender: Any) {
        delegate?.showAddress(address: address)
    }
}

protocol ShowInfoAssoDelegate: class {
    func showAddress(address:String?)
    func showWebsite(website:String?)
    func sendCall(phone:String?)
    func sendMessage(phone:String?)
}
