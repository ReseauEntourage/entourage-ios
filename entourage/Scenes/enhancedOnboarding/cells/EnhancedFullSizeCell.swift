import Foundation
import UIKit

class EnhancedFullSizeCell: UITableViewCell {
    
    // Outlet
    @IBOutlet weak var ui_image_choice: UIImageView!
    @IBOutlet weak var ui_image_check: UIImageView!
    @IBOutlet weak var ui_title_choice_label: UILabel!
    @IBOutlet weak var ui_label_title_phase_3: UILabel!
    
    @IBOutlet weak var ui_constraint_image_width: NSLayoutConstraint!
    @IBOutlet weak var ui_contraintbottom: NSLayoutConstraint!
    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_label_desc_phase_3: UILabel!
    @IBOutlet weak var ui_top_subtitle: NSLayoutConstraint!
    // Variable
    class var identifier: String {
        return String(describing: self)
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ui_image_choice.backgroundColor = UIColor.appBeige
        self.ui_image_choice.layer.cornerRadius = 30
        self.ui_view_container.layer.borderWidth = 1
        
    }
    
    func configure(choice: OnboardingChoice,
                   isSelected: Bool,
                   subtitleProvider: (() -> String?)? = nil)
    {
        // 1. Titre et image
        // -----------------
        // On définit le texte (ou attributedText) du titre
        if choice.title == "Proposition de services" {
            // Exemple de double-ligne pour "Proposition de services"
            let attributedString = NSMutableAttributedString(
                string: "Propositions de services\n",
                attributes: [
                    .font: UIFont(name: "Quicksand-Bold", size: 14)!
                ]
            )
            let detailsString = NSAttributedString(
                string: "(Lessive, impression de documents, aide administrative…)",
                attributes: [
                    .font: UIFont(name: "NunitoSans-Regular", size: 14)!
                ]
            )
            attributedString.append(detailsString)
            ui_title_choice_label.attributedText = attributedString
        }
        else if choice.title == "Temps de partage" {
            // Exemple de double-ligne pour "Temps de partage"
            let attributedString = NSMutableAttributedString(
                string: "Temps de partage\n",
                attributes: [
                    .font: UIFont(name: "Quicksand-Bold", size: 14)!
                ]
            )
            let detailsString = NSAttributedString(
                string: "(Café, activité, rencontre…)",
                attributes: [
                    .font: UIFont(name: "NunitoSans-Regular", size: 14)!
                ]
            )
            attributedString.append(detailsString)
            ui_title_choice_label.attributedText = attributedString
        }
        else {
            // Cas "normal" : titre sur une seule ligne (ou 2 si ça déborde)
            ui_title_choice_label.text = choice.title
            ui_title_choice_label.font = UIFont(name: "Quicksand-Bold", size: 14)
        }

        // On affiche ou masque l'image et ajuste la contrainte de largeur
        if choice.img.isEmpty {
            ui_image_choice.image = nil
            ui_constraint_image_width.constant = 0
        } else {
            ui_image_choice.image = UIImage(named: choice.img)
            ui_constraint_image_width.constant = 60
        }

        // 2. Calcul du nombre de lignes du titre pour ajuster la contrainte top du sous-titre
        // ------------------------------------------------------------------------------------
        // Force le layout pour obtenir la bonne largeur du label
        ui_title_choice_label.layoutIfNeeded()

        // Récupère le texte à mesurer et la font correspondante
        let measuredText: NSString
        let measuredFont: UIFont

        if let attributed = ui_title_choice_label.attributedText, attributed.length > 0 {
            measuredText = attributed.string as NSString
            measuredFont = (attributed.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)
                           ?? ui_title_choice_label.font!
        } else if let plain = ui_title_choice_label.text {
            measuredText = plain as NSString
            measuredFont = ui_title_choice_label.font!
        } else {
            measuredText = ""
            measuredFont = ui_title_choice_label.font!
        }

        // Calcule la hauteur totale du texte selon la largeur disponible
        let maxWidth = ui_title_choice_label.frame.width
        let bounding = measuredText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: measuredFont],
            context: nil
        )
        let textHeight = bounding.height
        let lineHeight = measuredFont.lineHeight
        let numberOfLines = Int(ceil(textHeight / lineHeight))

        // Ajuste la constante : si 1 ligne => 0, si 2+ lignes => 5
        ui_top_subtitle.constant = (numberOfLines > 1) ? 5 : -10

        // Force la mise à jour du layout pour que la cellule se redessine correctement
        self.contentView.layoutIfNeeded()

        // 3. Sous-titre (phase 3)
        // -----------------------
        // Si on a un subtitleProvider et qu'il renvoie une chaîne non vide, on l'affiche
        if let subtitle = subtitleProvider?(), !subtitle.isEmpty {
            ui_label_desc_phase_3.text = subtitle
            ui_label_desc_phase_3.isHidden = false
        } else {
            ui_label_desc_phase_3.isHidden = true
            ui_label_desc_phase_3.text = nil
        }

        // 4. Ajuste le bottom de la cellule si cas spéciaux
        // ------------------------------------------------
        if choice.title == "Proposition de services" {
            ui_contraintbottom.constant = 45
        }
        else if choice.title == "Temps de partage" {
            ui_contraintbottom.constant = 5
        }
        else {
            ui_contraintbottom.constant = 5
        }

        // 5. État sélectionné / non sélectionné
        // -------------------------------------
        ui_image_check.image = UIImage(
            named: isSelected
                ? "ic_onboarding_checked"
                : "ic_onboarding_unchecked"
        )

        if isSelected {
            ui_view_container.backgroundColor = UIColor(
                red: 255/255, green: 245/255, blue: 235/255, alpha: 0.7
            )
            ui_view_container.layer.borderColor = UIColor.appOrangeLight.cgColor
        } else {
            ui_view_container.backgroundColor = .clear
            ui_view_container.layer.borderColor = UIColor.appGreyOff.cgColor
        }
    }


    
    func configureAComment(title:String, comment:String){
        ui_title_choice_label.isHidden = true
        
        ui_label_title_phase_3.isHidden = false
        ui_label_title_phase_3.setFontTitle(size: 15)
        ui_label_title_phase_3.text = title
        
        ui_label_desc_phase_3.isHidden = false
        ui_label_desc_phase_3.setFontBody(size: 13)
        ui_label_desc_phase_3.text = comment
    
    }

}
