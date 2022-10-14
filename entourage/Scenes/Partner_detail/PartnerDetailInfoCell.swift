//
//  PartnerDetailInfoCell.swift
//  entourage
//
//  Created by Jerome on 25/03/2022.
//

import UIKit

class PartnerDetailInfoCell: UITableViewCell {
    
    @IBOutlet weak var ui_title_infos: UILabel!
    @IBOutlet weak var ui_view_phone: UIView!
    @IBOutlet weak var ui_title_phone: UILabel!
    @IBOutlet weak var ui_phone: UILabel!
    
    @IBOutlet weak var ui_view_email: UIView!
    @IBOutlet weak var ui_title_email: UILabel!
    @IBOutlet weak var ui_email: UILabel!
    
    @IBOutlet weak var ui_view_web: UIView!
    @IBOutlet weak var ui_title_web: UILabel!
    @IBOutlet weak var ui_web: UILabel!
    
    @IBOutlet weak var ui_view_postal: UIView!
    @IBOutlet weak var ui_title_postal: UILabel!
    @IBOutlet weak var ui_postal: UILabel!
    
    @IBOutlet var titles: [UILabel]!
    @IBOutlet var infos: [UILabel]!
    
    weak var delegate:PartnerDetailInfoCellDelegate? = nil
    var phone:String? = nil
    var address:String? = nil
    var website:String? = nil
    var email:String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title_phone.text = "title_asso_phone_light".localized
        ui_title_email.text = "title_asso_email_light".localized
        ui_title_web.text = "title_asso_website".localized
        ui_title_postal.text = "title_asso_address_big".localized
        ui_title_infos.text = "title_asso_information".localized
        ui_title_infos.font = ApplicationTheme.getFontH2Noir().font
        ui_title_infos.textColor = ApplicationTheme.getFontH2Noir().color
        
        setupInfoLabel()
        setupTitleLabel()
    }
    
    private func setupTitleLabel() {
        for label in titles {
            label.font = ApplicationTheme.getFontNunitoRegular(size: 13)
            label.textColor = .appOrange
        }
    }
    
    private func setupInfoLabel() {
        for label in infos {
            label.font = ApplicationTheme.getFontCourantRegularNoir().font
            label.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        }
    }
    
    func populateCell(partner:Partner?,delegate:PartnerDetailInfoCellDelegate) {
        self.address = partner?.address
        self.phone = partner?.phone
        self.website = partner?.websiteUrl
        self.email = partner?.email
        
        ui_phone.text = partner?.phone
        ui_web.text = partner?.websiteUrl
        ui_email.text = partner?.email
        ui_postal.text = partner?.address
        
        ui_view_web?.isHidden = partner?.websiteUrl?.count ?? 0 == 0
        ui_view_email?.isHidden = partner?.email?.count ?? 0 == 0
        ui_view_phone?.isHidden = partner?.phone?.count ?? 0 == 0
        ui_view_postal?.isHidden = partner?.address?.count ?? 0 == 0
        
        self.delegate = delegate
    }
    
    //MARK: - IBActions -
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

//MARK: - Protocol -
protocol PartnerDetailInfoCellDelegate: AnyObject {
    func showAddress(address:String?)
    func showWebsite(website:String?)
    func sendCall(phone:String?)
    func sendEmail(email:String?)
    func followUnfollow()
}
