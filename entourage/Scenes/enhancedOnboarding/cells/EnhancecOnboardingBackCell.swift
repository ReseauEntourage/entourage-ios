//
//  EnhancecOnboardingBackCell.swift
//  entourage
//
//  Created by Clement entourage on 03/06/2024.
//

import Foundation
import UIKit

class EnhancecOnboardingBackCell:UITableViewCell{
    
    //Outlet
    @IBOutlet weak var ui_label: UILabel!
    
    //Variable
    
    override func awakeFromNib() {
        ui_label.setFontTitle(size: 13)
    }
    
    func configure(isFromSettings:Bool) {
        if isFromSettings {
            ui_label.text = "settings_back_subtitle".localized
        }else{
            ui_label.text = ""
        }
    }
    
}
