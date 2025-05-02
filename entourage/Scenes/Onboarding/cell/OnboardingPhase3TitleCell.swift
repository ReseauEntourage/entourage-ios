//
//  OnboardingPhase3TitleCell.swift
//  entourage
//
//  Created by Clement entourage on 20/03/2025.
//

import Foundation
import UIKit

class OnboardingPhase3TitleCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_label_title: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.ui_label_title.text = "onboarding_phase_three_question_contribution".localized
        self.ui_label_title.setFontBody(size: 15)
    }
    
}
