//
//  PartnerDetailTopCellTableViewCell.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class PartnerDetailTopCell: UITableViewCell {
    
    @IBOutlet weak var ui_partner_name: UILabel!
    @IBOutlet weak var ui_view_bt_follow: UIView!
    @IBOutlet weak var ui_bt_follow: UIButton!
    @IBOutlet weak var ui_iv_bt_partner_follow: UIImageView!
    @IBOutlet weak var ui_partner_description: UILabel!
    
    weak var delegate:PartnerDetailInfoCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_bt_follow.layer.cornerRadius = ui_view_bt_follow.frame.height / 2
        ui_view_bt_follow.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_bt_follow.layer.borderWidth = 1
        
        ui_bt_follow.setTitleColor(.white, for: .normal)
        ui_bt_follow.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        
        ui_partner_description.textColor = ApplicationTheme.getFontTextItalic().color
        ui_partner_description.font = ApplicationTheme.getFontTextItalic().font
        
        ui_partner_name.textColor = .black
        ui_partner_name.font = ApplicationTheme.getFontQuickSandBold(size: 18)
    }
    
    func populateCell(partner:Partner?,delegate:PartnerDetailInfoCellDelegate) {
        self.delegate = delegate
        ui_partner_name.text = partner?.name
        ui_partner_description.text = partner?.descr
        
        if partner?.isFollowing ?? false {
            ui_bt_follow.setTitleColor(.appOrange, for: .normal)
            
            ui_bt_follow.setTitle("buttonFollowOnPartner".localized, for: .normal)
            ui_view_bt_follow.backgroundColor = .white
            ui_iv_bt_partner_follow.image = UIImage.init(named: "ic_partner_follow_on")
        }
        else {
            ui_bt_follow.setTitleColor(.white, for: .normal)
            
            ui_bt_follow.setTitle("buttonFollowOffPartner".localized, for: .normal)
            ui_view_bt_follow.backgroundColor = .appOrange
            ui_iv_bt_partner_follow.image = UIImage.init(named: "ic_partner_follow_off")
        }
    }
    
    @IBAction func action_follow_unfollow(_ sender: Any) {
        delegate?.followUnfollow()
    }
}
