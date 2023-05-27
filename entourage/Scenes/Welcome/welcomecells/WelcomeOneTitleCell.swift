//
//  WelcomeOneTitleCell.swift
//  entourage
//
//  Created by Clement entourage on 22/05/2023.
//

import Foundation

class WelcomeOneTitleCell:UITableViewCell{
    
    @IBOutlet weak var ui_label_title: UILabel!
    
    override func awakeFromNib() {
        
        ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: 24)
        ui_label_title.text = "welcomeone_title".localized
        
    }
    
    
    
}
