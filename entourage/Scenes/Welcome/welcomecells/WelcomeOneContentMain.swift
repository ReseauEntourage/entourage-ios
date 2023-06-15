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
        ui_label_content_main.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_label_content_main.text = "welcomeone_content_main".localized
        
    }
    
    func initForWelcomeThreeIfEvent(){
        ui_label_content_main.text = "welcome_three_maintext_event".localized
    }
    
    func initForWelcomeThreeIfDemand(){
        ui_label_content_main.text = "welcome_three_maintext_demand".localized
    }
    
    func initForWelcomeThreeIfContrib(){
        ui_label_content_main.text = "welcome_three_maintext_contrib".localized
    }
    func initForWelcomeFour(){
        ui_label_content_main.text = "welcome_four_main_text".localized
    }
    
    func initForWelcomeFive(){
        ui_label_content_main.text = "welcome_five_main_text_title".localized
    }
    
}
