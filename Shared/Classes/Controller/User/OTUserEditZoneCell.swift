//
//  OTUserEditZoneCell.swift
//  entourage
//
//  Created by Jr on 19/06/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

@objc class OTUserEditZoneCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_zone_primary: UIView!
    @IBOutlet weak var ui_zone_primary_title: UILabel!
    
    @IBOutlet weak var ui_zone_primary_info: UILabel!
    
    @IBOutlet weak var ui_zone_primary_button_edit: UIButton!
    
    @IBOutlet weak var ui_view_zone_secondary: UIView!
    @IBOutlet weak var ui_zone_secondary_title: UILabel!
    
    
    @IBOutlet weak var ui_zone_secondary_button_edit: UIButton!
    @IBOutlet weak var ui_zone_secondary_button_delete: UIButton!
    
    @IBOutlet weak var ui_view_button_add: UIView!
    
    @IBOutlet weak var ui_button_add_zone: UIButton!
    
    //Type action
    @IBOutlet weak var ui_type_title: UILabel!
    @IBOutlet weak var ui_type_description: UILabel!
    
    @IBOutlet weak var ui_type_selected_title: UILabel!
    @IBOutlet weak var ui_type_button: UIButton!
    
    @objc func populateCell(user:OTUser) {
        
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "profile_my_zones")
        ui_description.text = OTLocalisationService.getLocalizedValue(forKey: "profile_my_zones_description")
        
        if let zonePri = user.addressPrimary {
            ui_zone_primary_title.text = zonePri.displayAddress
        }
        else {
            ui_zone_primary_title.text = " - "
        }
        
        ui_view_button_add.isHidden = true
        ui_view_zone_secondary.isHidden = true
        
        ui_zone_primary_button_edit.layer.cornerRadius = 8
        ui_zone_primary_button_edit.layer.borderWidth = 1
        ui_zone_primary_button_edit.layer.borderColor = UIColor.appOrange()?.cgColor
        
        ui_zone_secondary_button_edit.layer.cornerRadius = 8
        ui_zone_secondary_button_edit.layer.borderWidth = 1
        ui_zone_secondary_button_edit.layer.borderColor = UIColor.appOrange()?.cgColor
        
        ui_zone_secondary_button_delete.layer.cornerRadius = 8
        ui_zone_secondary_button_delete.layer.borderWidth = 1
        ui_zone_secondary_button_delete.layer.borderColor = UIColor.appOrange()?.cgColor
        
        ui_button_add_zone.layer.cornerRadius = 8
        ui_button_add_zone.layer.borderWidth = 1
        ui_button_add_zone.layer.borderColor = UIColor.appOrange()?.cgColor
        
        var buttonTxt = OTLocalisationService.getLocalizedValue(forKey: "profile_button_add2nd_zone")
        if UIScreen.main.bounds.width <= 375 {
            if UIScreen.main.bounds.width <= 320 {
                buttonTxt = OTLocalisationService.getLocalizedValue(forKey: "profile_button_add2nd_zone_lite")
            }
            else {
                buttonTxt = OTLocalisationService.getLocalizedValue(forKey: "profile_button_add2nd_zone_lite2")
            }
        }
        
        ui_button_add_zone.setTitle(buttonTxt, for: .normal)
        
        //Type action
        ui_type_button.layer.cornerRadius = 8
        ui_type_button.layer.borderWidth = 1
        ui_type_button.layer.borderColor = UIColor.appOrange()?.cgColor
        
        ui_type_title.text = OTLocalisationService.getLocalizedValue(forKey: "profile_title_action_mode")
        
        if let _goal = user.goal {
            var _message = ""
            switch _goal {
            case "ask_for_help":
                _message = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice2")
            case "offer_help":
                _message = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice1")
            case "organization":
                _message = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice3")
            default:
                _message = OTLocalisationService.getLocalizedValue(forKey: "profile_action_not_selected")
            }
            ui_type_description.text = _message
        }
        else {
            ui_type_description.text = OTLocalisationService.getLocalizedValue(forKey: "profile_action_not_selected")
        }
        
        if let _ = user.interests  {
            let _interests = user.getInterestsFormated()
            ui_type_selected_title.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "profile_activities"), _interests)
        }
        else {
            ui_type_selected_title.text = OTLocalisationService.getLocalizedValue(forKey: "profile_activity_not_selected")
        }
    }
}
