//
//  WelcomeOneTitleCell.swift
//  entourage
//
//  Created by Clement entourage on 22/05/2023.
//

import Foundation

class WelcomeOneTitleCell:UITableViewCell{
    
    @IBOutlet weak var ui_label_title: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        initTitle()
    }
    
    func initTitle() {
        ui_label_title.font = ApplicationTheme.getFontNunitoRegular(size: 24)
        let baseString = "welcomeone_title".localized
        let targetString = "vraiment"
        let attributedString = NSMutableAttributedString(string: baseString)
        let range = (baseString as NSString).range(of: targetString)
        let fontSize = ui_label_title.font.pointSize

        attributedString.addAttribute(NSAttributedString.Key.font, value: ApplicationTheme.getFontQuickSandBold(size: 24), range: range)
        ui_label_title.attributedText = attributedString
    }
    
    func initForWelcomeThreeIfEvent(){
        self.ui_label_title.text = "welcome_three_title_event".localized
    }
    
    func initForWelcomeThreeIfDemand(){
        self.ui_label_title.text = "welcome_three_title_demand".localized

    }
    
    func initForWelcomeThreeIfContrib(){
        self.ui_label_title.text = "welcome_three_title_contrib".localized

    }
    
    func initForWelcomeFour(){
        self.ui_label_title.text = "welcome_four_title".localized
    }
    
    func initForWelcomeFive(){
        self.ui_label_title.text = "welcome_five_title".localized
    }
    
}
