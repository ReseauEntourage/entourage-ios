import Foundation
import UIKit

class MainFilterTagCell: UITableViewCell {
    
    // Outlet
    @IBOutlet weak var ui_content_view: UIView!
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_image_checked: UIImageView!
    
    // Variable
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Any additional setup if needed
        self.ui_content_view.layer.borderWidth = 1
        self.ui_content_view.layer.borderColor = UIColor.appGreyOff.cgColor
    }
    
    func configure(choice: MainFilterTagItem, isSelected: Bool) {
        // Creating the attributed string for title and subtitle
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: ui_title_label.font.pointSize)
        ]
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: ui_title_label.font.pointSize)
        ]
        
        let attributedText = NSMutableAttributedString(string: choice.title, attributes: titleAttributes)
        if !choice.subtitle.isEmpty {
            let subtitleString = NSAttributedString(string: choice.subtitle, attributes: subtitleAttributes)
            attributedText.append(subtitleString)
        }
        
        ui_title_label.attributedText = attributedText
        
        // Configure the cell appearance based on selection state
        if isSelected {
            ui_image_checked.image = UIImage(named: "ic_onboarding_checked")
            ui_content_view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 235/255, alpha: 0.7)
            self.ui_content_view.layer.borderColor = UIColor.appOrangeLight.cgColor
        } else {
            ui_image_checked.image = UIImage(named: "ic_onboarding_unchecked")
            ui_content_view.backgroundColor = .clear
            self.ui_content_view.layer.borderColor = UIColor.appGreyOff.cgColor
        }
    }
}
