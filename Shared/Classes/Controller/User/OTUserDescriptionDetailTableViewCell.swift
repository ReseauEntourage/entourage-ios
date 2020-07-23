//
//  OTUserDescriptionDetailTableViewCell.swift
//  entourage
//
//  Created by Jr on 23/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

@objc class OTUserDescriptionDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_constraint_view_bio_heigh: NSLayoutConstraint!
    @IBOutlet weak var ui_view_bio: UIView!
    @IBOutlet weak var ui_iv_user: UIImageView!
    @IBOutlet weak var ui_view_bg_top: UIView!
    @IBOutlet weak var ui_iv_badge: UIImageView!
    @IBOutlet weak var ui_stack_tag: UIStackView!
    @IBOutlet weak var ui_label_name: UILabel!
    @IBOutlet weak var ui_label_bio: UILabel!
    @IBOutlet weak var ui_view_avatar_shadow: UIView!
    
    @IBOutlet weak var ui_label_good_waves: UILabel!
    @IBOutlet weak var ui_label_activity: UILabel!
    @IBOutlet weak var ui_label_event_count: UILabel!
    @IBOutlet weak var ui_label_event_title: UILabel!
    @IBOutlet weak var ui_label_action_count: UILabel!
    @IBOutlet weak var ui_label_action_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_iv_user.layer.cornerRadius = ui_iv_user.frame.width / 2
        ui_view_avatar_shadow.layer.cornerRadius = ui_view_avatar_shadow.frame.width / 2
        ui_label_event_title.text = OTLocalisationService.getLocalizedValue(forKey: "event_title")
        ui_label_action_title.text = OTLocalisationService.getLocalizedValue(forKey: "action_title")
        ui_label_activity.text = OTLocalisationService.getLocalizedValue(forKey: "activity_title")
    }
    
    @objc func populateCell(user:OTUser) {
        
        if user.partner != nil {
            ui_iv_badge.isHidden = false
            ui_iv_badge.setup(fromUrl: user.partner.smallLogoUrl, withPlaceholder: "badgeDefault")
        }
        else {
            ui_iv_badge.isHidden = true
        }
        
        ui_view_bg_top.backgroundColor = UIColor.white
        //View Shadow
        ui_view_avatar_shadow.layer.shadowColor = UIColor.black.cgColor
        ui_view_avatar_shadow.layer.shadowOpacity = 0.5
        ui_view_avatar_shadow.layer.shadowRadius = 4.0
        ui_view_avatar_shadow.layer.shadowOffset = CGSize.init(width: 0, height: 1)
        
        ui_iv_user.layer.borderColor = UIColor.white.cgColor
        
        ui_iv_user.setup(fromUrl: user.avatarURL, withPlaceholder: "user")
        
        ui_label_name.text = user.displayName
        if let _bio = user.about, _bio.count > 0 {
            ui_label_bio.text = user.about
            ui_view_bio.isHidden = false
        }
        else {
            ui_view_bio.isHidden = true
            ui_constraint_view_bio_heigh.constant = 0
        }
        
        if user.isGoodWavesValidated {
            ui_label_good_waves.text = OTLocalisationService.getLocalizedValue(forKey: "good_waves_member")
        }
        else {
            ui_label_good_waves.text = ""
        }
        
        ui_label_event_count.text = "\(user.eventsCount)"
        ui_label_action_count.text = "\(user.actionsCount)"
        
        
        //stackview horizontal
        for view in ui_stack_tag.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for role in user.roles {
            if let _role = role as? String {
                let tag = OTRoleTag.init(name: _role)
                if tag.visible() {
                    let tagView = OTPillLabelView.create(with: tag)
                    ui_stack_tag.addArrangedSubview(tagView)
                }
            }
        }
        
        ui_stack_tag.isHidden = ui_stack_tag.arrangedSubviews.count == 0
    }

}
