//
//  WelcomeOneContentLast.swift
//  entourage
//
//  Created by Clement entourage on 22/05/2023.
//

import Foundation

protocol WelcomeOneLastCellDelegate {
    func onLinkClicked()
}

class WelcomeOneContentLast:UITableViewCell{
    
    @IBOutlet weak var ui_label_content: UILabel!
    var delegate:WelcomeOneLastCellDelegate?
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        initTitle()
        ui_label_content.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        ui_label_content.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func initTitle(){
        ui_label_content.font = ApplicationTheme.getFontNunitoRegular(size: 15)
        let baseString = "welcomeone_content".localized
        let targetString = "içi"
        let attributedString = NSMutableAttributedString(string: baseString)
        let range = (baseString as NSString).range(of: targetString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange, range: range)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        // Utilisez `attributedString` pour définir le texte de votre UILabel ou autre.
        ui_label_content.attributedText = attributedString
    }
    
    @objc func labelTapped() {
        delegate?.onLinkClicked()
    }
}
