//
//  OTAssoTopTableViewCell.swift
//  entourage
//
//  Created by Jr on 30/06/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import Nantes

class AssoTopTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_iv_bg_top: UIImageView!
    @IBOutlet weak var ui_iv_logo: UIImageView!
    
    @IBOutlet weak var ui_tv_title_asso: UILabel!
    @IBOutlet weak var ui_tv_subtitle_asso: UILabel!
    @IBOutlet weak var ui_tv_volunteer: UILabel!//TTTAttributedLabel!
    @IBOutlet weak var ui_view_volunteer: UIView!
    @IBOutlet weak var ui_tv_donation: UILabel!//TTTAttributedLabel!
    @IBOutlet weak var ui_view_donation: UIView!
    
    @IBOutlet weak var ui_view_asso_detail: UIView!
    @IBOutlet weak var ui_tv_asso_description: NantesLabel!
    @IBOutlet weak var ui_tv_title_information: UILabel!
    @IBOutlet weak var ui_view_button: UIView!
    
    @IBOutlet weak var ui_title_button_follow: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_tv_donation.text = "title_asso_donation".localized
        ui_tv_volunteer.text = "title_asso_volunteer".localized
        ui_tv_title_information.text = "title_asso_information".localized
    }
    
    func populateCell(name:String?,subname:String?,assoDescription:String? ,imageUrl:String?,hasDonation:Bool,hasVolunteer:Bool,isFollowing:Bool) {
        
        ui_tv_subtitle_asso.isHidden = true
        ui_tv_title_asso.text = name
        ui_tv_subtitle_asso.text = subname
        
        setupLinksForLabel(_label: ui_tv_asso_description)
        ui_tv_asso_description.text = assoDescription
        
        ui_view_asso_detail.isHidden = assoDescription?.count == 0
        
        ui_view_donation.isHidden = !hasDonation
        ui_view_volunteer.isHidden = !hasVolunteer
        
        if let _url = imageUrl {
            if let mainUrl = URL(string: _url) {
                ui_iv_logo.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "badgeDefault"))
            }
        }
        else {
            ui_iv_logo?.image = UIImage.init(named: "badgeDefault")
        }
        
        if isFollowing {
            ui_title_button_follow.text = "buttonFollowOnPartner".localized
            ui_view_button.backgroundColor = UIColor.appOrange
            ui_title_button_follow.textColor = .white
        }
        else {
            ui_title_button_follow.text = "buttonFollowOffPartner".localized
            ui_view_button.backgroundColor = UIColor.white
            ui_view_button.layer.borderColor = UIColor.appOrange.cgColor
            ui_view_button.layer.borderWidth = 1
            ui_title_button_follow.textColor = UIColor.appOrange
        }
    }
    
    func setupLinksForLabel(_label: NantesLabel) {
        _label.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link
        _label.linkAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appOrange as Any]
        _label.delegate = self
    }
}

extension AssoTopTableViewCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        UIApplication.shared.open(link, options: [:], completionHandler: nil)
    }
}
