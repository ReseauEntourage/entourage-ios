//
//  OnboardingPhase3MapCell.swift
//  entourage
//
//  Created by Clement entourage on 20/03/2025.
//

import Foundation
import UIKit

class OnboardingPhase3MapCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_label_adress: UILabel!
    @IBOutlet weak var ui_label_restriction: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        
    }
    
    func configure(adress:String?){
        if let _adress = adress{
            ui_label_adress.text = _adress
        }else{
            ui_label_adress.text = "onboard_place_infos_placeholder".localized
        }
        ui_title.text = "onboard_place_title_new".localized
        ui_label_restriction.text = "onboard_place_desc".localized
        
        ui_title.setFontTitle(size: 15)
        ui_label_adress.setFontBody(size: 15)
        ui_label_restriction.setFontBody(size: 13)
    }
    
    
    
}
