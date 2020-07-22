//
//  OTSettingsMenuTableViewCell.swift
//  entourage
//
//  Created by Jr on 22/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTSettingsMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_goodWaves: UIView!
    @IBOutlet weak var ui_label_goodWaves: UILabel!
    @IBOutlet weak var ui_label_conseils: UILabel!
    @IBOutlet weak var ui_label_ideas: UILabel!
    @IBOutlet weak var ui_label_ambassador: UILabel!
    @IBOutlet weak var ui_label_gift: UILabel!
    @IBOutlet weak var ui_label_follow: UILabel!
    @IBOutlet weak var ui_label_charte: UILabel!
    @IBOutlet weak var ui_label_help: UILabel!
    @IBOutlet weak var ui_label_logout: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_label_goodWaves.text = OTLocalisationService.getLocalizedValue(forKey: "join_good_waves")
        ui_label_conseils.text = OTLocalisationService.getLocalizedValue(forKey: "menu_scb")
        ui_label_ideas.text = OTLocalisationService.getLocalizedValue(forKey: "menu_entourage_actions")
        ui_label_ambassador.text = OTLocalisationService.getLocalizedValue(forKey: "menu_join")
        ui_label_gift.text = OTLocalisationService.getLocalizedValue(forKey: "menu_make_donation")
        ui_label_follow.text = OTLocalisationService.getLocalizedValue(forKey: "menu_atd_partner")
        ui_label_charte.text = OTLocalisationService.getLocalizedValue(forKey: "menu_read_chart")
        ui_label_help.text = OTLocalisationService.getLocalizedValue(forKey: "menu_about")
        ui_label_logout.text = OTLocalisationService.getLocalizedValue(forKey: "menu_disconnect_title")
    }
    
    func populateCell(alreadyGoodWaves:Bool,hasSignedChart:Bool) {
        
        if alreadyGoodWaves {
            ui_view_goodWaves.isHidden = true
        }
        else {
            ui_view_goodWaves.isHidden = false
        }
        
        ui_label_charte.text = hasSignedChart ? OTLocalisationService.getLocalizedValue(forKey: "menu_read_chart") : OTLocalisationService.getLocalizedValue(forKey: "menu_sign_chart")
        
    }
}
