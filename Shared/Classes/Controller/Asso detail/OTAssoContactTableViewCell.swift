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
    
    @IBOutlet weak var ui_bt_phone: UIButton!
    @IBOutlet weak var ui_bt_mail: UIButton!
    @IBOutlet weak var ui_bt_address: UIButton!
    @IBOutlet weak var ui_bt_web: UIButton!
    
    @IBOutlet weak var ui_view_main_address: UIView!
    @IBOutlet weak var ui_view_main_phone: UIView!
    @IBOutlet weak var ui_view_main_website: UIView!
    @IBOutlet weak var ui_view_main_email: UIView!
    
    weak var delegate:ShowInfoAssoDelegate? = nil
    
    var phone:String? = nil
    var address:String? = nil
    var website:String? = nil
    var email:String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIScreen.main.bounds.height <= 568 {
            ui_bt_phone.titleLabel?.font = ui_bt_phone.titleLabel?.font.withSize(fontSizeIphoneSE)
            ui_bt_mail.titleLabel?.font = ui_bt_mail.titleLabel?.font.withSize(fontSizeIphoneSE)
            ui_bt_web.titleLabel?.font = ui_bt_web.titleLabel?.font.withSize(fontSizeIphoneSE)
            
            ui_bt_address.titleLabel?.font = ui_bt_address.titleLabel?.font.withSize(fontSizeIphoneSE)
        }
        
        ui_bt_mail.titleLabel?.numberOfLines = 1
        ui_bt_phone.titleLabel?.numberOfLines = 1
        ui_bt_web.titleLabel?.numberOfLines = 1
        ui_bt_address.titleLabel?.numberOfLines = 2
        ui_bt_address.titleLabel?.lineBreakMode = .byTruncatingTail
        ui_bt_phone.titleLabel?.lineBreakMode = .byTruncatingTail
        ui_bt_web.titleLabel?.lineBreakMode = .byTruncatingTail
        ui_bt_mail.titleLabel?.lineBreakMode = .byTruncatingTail
    }

    func populateCell(website:String?,phone:String?,address:String?,email:String?,delegate:ShowInfoAssoDelegate) {
        
        ui_bt_phone.setTitle(phone, for: .normal)
        ui_bt_mail.setTitle(email, for: .normal)
        ui_bt_web.setTitle(website, for: .normal)
        ui_bt_address.setTitle(address, for: .normal)
        
        ui_view_main_phone?.isHidden = phone?.count ?? 0 == 0
        ui_view_main_email?.isHidden = email?.count ?? 0 == 0
        ui_view_main_address?.isHidden = address?.count ?? 0 == 0
        ui_view_main_website?.isHidden = website?.count ?? 0 == 0
        
        self.address = address
        self.phone = phone
        self.website = website
        self.email = email
        self.delegate = delegate
    }

    @IBAction func action_send_phone(_ sender: Any) {
        delegate?.sendCall(phone: phone)
    }
    @IBAction func action_send_email(_ sender: Any) {
        delegate?.sendEmail(email: email)
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
    func sendEmail(email:String?)
}
