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
            ui_view_goodWaves.isHidden = true
        }
        
        ui_label_charte.text = hasSignedChart ? OTLocalisationService.getLocalizedValue(forKey: "menu_read_chart") : OTLocalisationService.getLocalizedValue(forKey: "menu_sign_chart")
        
    }
}


class OTSettingsMenuFirstTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_label_guide: UILabel!
    @IBOutlet weak var ui_label_prog: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_first_title")
        ui_label_guide.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_first_guide")
        ui_label_prog.text = OTLocalisationService.getLocalizedValue(forKey: "menu_sign_chart")
    }
    
    func populateCell(hasSignedChart:Bool) {
        ui_label_prog.text = OTLocalisationService.getLocalizedValue(forKey: "menu_read_chart")
    }
}

class OTSettingsMenuSecondTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_goodWaves: UIView!
    @IBOutlet weak var ui_label_goodWaves: UILabel!
    @IBOutlet weak var ui_label_ambassador: UILabel!
    @IBOutlet weak var ui_label_help: UILabel!
    @IBOutlet weak var ui_label_gift: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_second_title")
        ui_label_goodWaves.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_second_good")
        ui_label_ambassador.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_second_ambassador")
        ui_label_help.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_second_help")
        ui_label_gift.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_second_gift")
    }
    
    func populateCell(alreadyGoodWaves:Bool) {
        
        if alreadyGoodWaves {
            ui_view_goodWaves.isHidden = true
        }
        else {
            ui_view_goodWaves.isHidden = true
        }
    }
}

class OTSettingsMenuThirdTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_label_share: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_third_title")
        ui_label_share.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_third_share")
        ui_label_info.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_third_info")
    }
}

class OTSettingsMenuHelpEndTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_label_help: UILabel!
    @IBOutlet weak var ui_label_logout: UILabel!
    @IBOutlet weak var ui_label_info_social: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_label_help.text = OTLocalisationService.getLocalizedValue(forKey: "menu_about")
        ui_label_logout.text = OTLocalisationService.getLocalizedValue(forKey: "menu_disconnect_title")
        
        let attStr = Utilitaires.formatString(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "menu_info_social"), coloredTxt: OTLocalisationService.getLocalizedValue(forKey: "menu_info_social_bold"), color: UIColor.appGreyishBrown(), colorHighlight: UIColor.appGreyishBrown(), fontSize: 15, fontWeight: .regular, fontColoredWeight: .bold)
        ui_label_info_social.attributedText = attStr
    }
}
