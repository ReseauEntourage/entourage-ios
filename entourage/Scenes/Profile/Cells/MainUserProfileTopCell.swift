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
    
    @IBOutlet weak var ui_view_button_message: UIView?
    @IBOutlet weak var ui_button_message: UIButton?
   
    let topConstraintStack:CGFloat = 16
    
    weak var delegate:MainUserProfileTopCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_role_bubble.layer.cornerRadius = ui_view_role_bubble.frame.height / 2
        ui_view_partner_bubble.layer.cornerRadius = ui_view_partner_bubble.frame.height / 2
        ui_iv_partner.layer.cornerRadius = ui_iv_partner.frame.height / 2
        ui_iv_partner.layer.borderWidth = 1
        ui_iv_partner.layer.borderColor = UIColor.appOrange.cgColor
        
        ui_label_role.font = ApplicationTheme.getFontRegular13Orange().font
        ui_label_partner.font = ApplicationTheme.getFontRegular13Orange().font
        ui_label_role.textColor = ApplicationTheme.getFontRegular13Orange().color
        ui_label_partner.textColor = ApplicationTheme.getFontRegular13Orange().color
        
        ui_bio.font = ApplicationTheme.getFontCourantItalicNoir().font
        ui_bio.textColor = ApplicationTheme.getFontCourantItalicNoir().color
        
        ui_username?.font = ApplicationTheme.getFontH1Noir().font
        ui_username?.textColor = ApplicationTheme.getFontH1Noir().color
        
        
        ui_view_button_message?.layer.cornerRadius = (ui_view_button_message?.frame.height ?? 0 ) / 2
        
        ui_button_message?.setTitle("detail_user_send_message".localized, for: .normal)
        ui_button_message?.setTitleColor(.white, for: .normal)
        ui_button_message?.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
    }
    
    func populateCell(username:String, role:String?, partner:Partner?, bio:String?, delegate:MainUserProfileTopCellDelegate? = nil) {
        ui_username?.text = username
        
        self.delegate = delegate
        
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
            ui_bio.text = ""//"mainUserBioPlaceholder".localized
        }
    }
    
    @IBAction func action_show_partner(_ sender: Any) {
        delegate?.showPartner()
    }
    
    @IBAction func action_send_message(_ sender: Any) {
        delegate?.sendMessage()
    }
}

//MARK: - Protocol MainUserProfileTopCellDelegate -
protocol MainUserProfileTopCellDelegate: AnyObject {
    func showPartner()
    func sendMessage()
}
