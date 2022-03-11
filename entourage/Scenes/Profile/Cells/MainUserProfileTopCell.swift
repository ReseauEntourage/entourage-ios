//
//  MainUserProfileTopCell.swift
//  entourage
//
//  Created by Jerome on 08/03/2022.
//

import UIKit

class MainUserProfileTopCell: UITableViewCell {
    
    
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_bio: UILabel!
    
    @IBOutlet weak var ui_constraint_top_stack_members: NSLayoutConstraint!
    @IBOutlet weak var ui_stack_user_members: UIStackView!
    @IBOutlet weak var ui_view_role: UIView!
    @IBOutlet weak var ui_view_role_bubble: UIView!
    @IBOutlet weak var ui_label_role: UILabel!
    
    @IBOutlet weak var ui_view_partner: UIView!
    @IBOutlet weak var ui_view_partner_bubble: UIView!
    @IBOutlet weak var ui_label_partner: UILabel!
    @IBOutlet weak var ui_iv_partner: UIImageView!
    
    let topConstraintStack:CGFloat = 16
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_role_bubble.layer.cornerRadius = ui_view_role_bubble.frame.height / 2
        ui_view_partner_bubble.layer.cornerRadius = ui_view_partner_bubble.frame.height / 2
        ui_iv_partner.layer.cornerRadius = ui_iv_partner.frame.height / 2
        ui_iv_partner.layer.borderWidth = 1
        ui_iv_partner.layer.borderColor = UIColor.appOrange.cgColor
        
        ui_label_role.font = ApplicationTheme.getFontH5().font
        ui_label_partner.font = ApplicationTheme.getFontH5().font
        
        ui_bio.font = ApplicationTheme.getFontTextItalic().font
        ui_bio.textColor = ApplicationTheme.getFontTextItalic().color
        ui_username.font = ApplicationTheme.getFontSubtitle().font
        ui_username.textColor = ApplicationTheme.getFontSubtitle().color
        
    }
    
    func populateCell(username:String,role:String?,partner:Association?,bio:String?) {
        ui_username.text = username
        
        if let role = role {
            ui_view_role.isHidden = false
            ui_label_role.text = role
        }
        else {
            ui_view_role.isHidden = true
        }
        
        if let partner = partner {
            ui_view_partner.isHidden = false
            ui_label_partner.text = partner.name
            if let _url = partner.smallLogoUrl, let url = URL(string: _url) {
                ui_iv_partner.sd_setImage(with: url, placeholderImage:UIImage.init(named: "logo_entourage")) //TODO: avoir un placeholder pour les assos ?
            }
        }
        else {
            ui_view_partner.isHidden = true
        }
        
        if ui_view_role.isHidden && ui_view_partner.isHidden {
            ui_constraint_top_stack_members.constant = 0
        }
        else {
            ui_constraint_top_stack_members.constant = topConstraintStack
        }
        
        if let bio = bio, !bio.isEmpty {
            ui_bio.text = "« \(bio) »"
        }
        else {
            ui_bio.text = "mainUserBioPlaceholder".localized
        }
    }
}
