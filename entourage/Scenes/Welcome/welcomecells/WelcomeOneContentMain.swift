//
//  WelcomeOneContentMain.swift
//  entourage
//
//  Created by Clement entourage on 22/05/2023.
//

import Foundation

class WelcomeOneContentMain:UITableViewCell {
    
    @IBOutlet weak var ui_label_content_main: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        ui_label_content_main.font = ApplicationTheme.getFontNunitoRegular(size: 15)
        ui_label_content_main.text = "welcomeone_content_main".localized
        
    }
    
}
