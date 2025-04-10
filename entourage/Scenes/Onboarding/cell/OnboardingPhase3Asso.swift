//
//  OnboardingPhase3Asso.swift
//  entourage
//
//  Created by Clement entourage on 09/04/2025.
//

import Foundation
import UIKit

class OnboardingPhase3Asso:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ic_checked: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        ui_label_title.text = "onboard_info_asso".localized
    }
    
    func configure(isAsso:Bool){
        if isAsso {
            ic_checked.image = UIImage(named: "ic_selection_on")
        }else {
            ic_checked.image = UIImage(named: "ic_selection_off")
        }
    }
}
