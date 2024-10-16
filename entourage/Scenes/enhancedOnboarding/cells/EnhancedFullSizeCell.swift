import Foundation
import UIKit

class EnhancedFullSizeCell: UITableViewCell {
    
    // Outlet
    @IBOutlet weak var ui_image_choice: UIImageView!
    @IBOutlet weak var ui_image_check: UIImageView!
    @IBOutlet weak var ui_title_choice_label: UILabel!
    
    @IBOutlet weak var ui_contraintbottom: NSLayoutConstraint!
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
        
        if choice.title == "Proposition de services" {
            self.ui_contraintbottom.constant = 45
            let attributedString = NSMutableAttributedString(string: "Propositions de services\n", attributes: [
                .font: UIFont(name: "Quicksand-Bold", size: 14)!
            ])
            let detailsString = NSAttributedString(string: "(lessive, impression de documents, aide administrative...)", attributes: [
                .font: UIFont(name: "NunitoSans-Regular", size: 14)!
            ])
            attributedString.append(detailsString)
            self.ui_title_choice_label.attributedText = attributedString
        } else if choice.title == "Temps de partage" {
            self.ui_contraintbottom.constant = 5
            let attributedString = NSMutableAttributedString(string: "Temps de partage\n", attributes: [
                .font: UIFont(name: "Quicksand-Bold", size: 14)!
            ])
            let detailsString = NSAttributedString(string: "(café, activité, rencontre…)", attributes: [
                .font: UIFont(name: "NunitoSans-Regular", size: 14)!
            ])
            attributedString.append(detailsString)
            self.ui_title_choice_label.attributedText = attributedString
        } else {
            self.ui_title_choice_label.text = choice.title
            self.ui_contraintbottom.constant = 5
        }
        
        if isSelected {
            ui_image_check.image = UIImage(named: "ic_onboarding_checked")
            ui_view_container.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 235/255, alpha: 0.7)
            self.ui_view_container.layer.borderColor = UIColor.appOrangeLight.cgColor
        } else {
            ui_image_check.image = UIImage(named: "ic_onboarding_unchecked")
            ui_view_container.backgroundColor = .clear
            self.ui_view_container.layer.borderColor = UIColor.appGrey151.cgColor
        }
    }

}
