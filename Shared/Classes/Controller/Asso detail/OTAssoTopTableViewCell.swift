//
//  OTAssoTopTableViewCell.swift
//  entourage
//
//  Created by Jr on 30/06/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTAssoTopTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_iv_bg_top: UIImageView!
    @IBOutlet weak var ui_iv_logo: UIImageView!
    
    @IBOutlet weak var ui_tv_title_asso: UILabel!
    @IBOutlet weak var ui_tv_subtitle_asso: UILabel!
    @IBOutlet weak var ui_tv_volunteer: UILabel!
    @IBOutlet weak var ui_view_volunteer: UIView!
    @IBOutlet weak var ui_tv_donation: UILabel!
    @IBOutlet weak var ui_view_donation: UIView!
    @IBOutlet weak var ui_tv_asso_description: UILabel!
    @IBOutlet weak var ui_tv_title_information: UILabel!
    
    @IBOutlet weak var ui_title_button_follow: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_tv_donation.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_donation")
        ui_tv_volunteer.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_volunteer")
        ui_tv_title_information.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_information")
    }
    
    func populateCell(name:String?,subname:String?,assoDescription:String? ,imageUrl:String?,hasDonation:Bool,hasVolunteer:Bool,isFollowing:Bool) {
        
        ui_tv_subtitle_asso.isHidden = true
        ui_tv_title_asso.text = name
        ui_tv_subtitle_asso.text = subname
        ui_tv_asso_description.text = assoDescription
        
        ui_view_donation.isHidden = !hasDonation
        ui_view_volunteer.isHidden = !hasVolunteer
        
        if let _url = imageUrl {
            ui_iv_logo.setup(fromUrl: _url, withPlaceholder: "badgeDefault")
        }
        else {
            ui_iv_logo?.image = UIImage.init(named: "badgeDefault")
        }
        
        if isFollowing {
            ui_title_button_follow.text = OTLocalisationService.getLocalizedValue(forKey:"buttonFollowOnPartner")
        }
        else {
            ui_title_button_follow.text = OTLocalisationService.getLocalizedValue(forKey:"buttonFollowOffPartner")
        }
    }

}
