import Foundation
import UIKit

class EnhancedFullSizeCell: UITableViewCell {
    
    // Outlet
    @IBOutlet weak var ui_image_choice: UIImageView!
    @IBOutlet weak var ui_image_check: UIImageView!
    @IBOutlet weak var ui_title_choice_label: UILabel!
    
    @IBOutlet weak var ui_view_container: UIView!
    // Variable
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ui_image_choice.backgroundColor = UIColor.appBeige
        self.ui_image_choice.layer.cornerRadius = 30
        self.ui_view_container.layer.borderWidth = 1
        
    }
    
    func configure(choice: OnboardingChoice, isSelected: Bool) {
        self.ui_title_choice_label.text = choice.title
        self.ui_image_choice.image = UIImage(named: choice.img)
        if isSelected {
            ui_image_check.image = UIImage(named: "ic_onboarding_checked")
            ui_view_container.backgroundColor = UIColor(red: 255/255, green: 156/255, blue: 93/255, alpha: 0.5)
            self.ui_view_container.layer.borderColor = UIColor.appOrangeLight.cgColor

        } else {
            ui_image_check.image = UIImage(named: "ic_onboarding_unchecked")
            ui_view_container.backgroundColor = .clear
            self.ui_view_container.layer.borderColor = UIColor.appGrey151.cgColor

        }
    }
}
