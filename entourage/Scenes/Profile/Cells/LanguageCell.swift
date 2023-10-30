//
//  LanguageCell.swift
//  entourage
//
//  Created by Clement entourage on 27/10/2023.
//

import Foundation
import UIKit

class LanguageCell:UITableViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_image_drapeau: UIImageView!
    
    @IBOutlet weak var ui_tv_lang: UILabel!
    
    @IBOutlet weak var ui_tv_translated_lang: UILabel!
    @IBOutlet weak var ui_image_check: UIImageView!
    override func awakeFromNib() {
        
    }
    
    func configure(lang:String, isSelected:Bool){
        switch(lang){
        case "fr":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_fr")
            ui_tv_translated_lang.text = "lang_fr".localized
            ui_tv_lang.text = "Français"
        case "en":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_en")
            ui_tv_translated_lang.text = "lang_en".localized
            ui_tv_lang.text = "English"
        case "es":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_es")
            ui_tv_translated_lang.text = "lang_es".localized
            ui_tv_lang.text = "Español"
        case "ar":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_ar")
            ui_tv_translated_lang.text = "lang_ar".localized
            ui_tv_lang.text = "العربية"
        case "uk":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_uk")
            ui_tv_translated_lang.text = "lang_uk".localized
            ui_tv_lang.text = "Українська"
        case "de":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_de")
            ui_tv_translated_lang.text = "lang_de".localized
            ui_tv_lang.text = "Deutsch"
        case "ro":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_ro")
            ui_tv_translated_lang.text = "lang_ro".localized
            ui_tv_lang.text = "Română"
        case "pl":
            //
            ui_image_drapeau.image = UIImage(named: "drapeau_pl")
            ui_tv_translated_lang.text = "lang_pl".localized
            ui_tv_lang.text = "Polski"
        default:
            ui_image_drapeau.image = UIImage(named: "drapeau_fr")
            ui_tv_translated_lang.text = "lang_fr".localized
            ui_tv_lang.text = "Français"
        }
        if isSelected {
            self.ui_view_container.backgroundColor = UIColor.appBeige
            self.ui_tv_translated_lang.isHidden = true
            self.ui_image_check.isHidden = false
        }else{
            self.ui_view_container.backgroundColor = UIColor.white
            self.ui_tv_translated_lang.isHidden = false
            self.ui_image_check.isHidden = true
        }
    }
    
}
