//
//  SecondaryTextWelcomeCell.swift
//  entourage
//
//  Created by Clement entourage on 09/06/2023.
//

import Foundation
import UIKit

class SecondaryTextWelcomeCell:UITableViewCell{
    
    @IBOutlet weak var ui_label: UILabel!
    
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
    }
    
    func initForWelcomeFour(){
        ui_label.text = "welcome_four_second_text".localized
    }
    
}
