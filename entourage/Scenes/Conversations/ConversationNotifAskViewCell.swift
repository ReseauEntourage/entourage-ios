import Foundation
import UIKit

class ConversationNotifAskViewCell: UITableViewCell {
    
    // OUTLET
    @IBOutlet weak var ui_text_view: UILabel!
    
    // Fonction pour configurer le texte avec attributs
    func configureText() {
        // Récupérer le texte localisé
        let fullText = "conversation_notif_text".localized

        // Attributs pour le texte normal
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NunitoSans-Regular", size: 15)!,
            .foregroundColor: UIColor.black
        ]

        // Attributs pour la partie en gras et soulignée
        let highlightedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NunitoSans-Bold", size: 15)!,
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        // Identifier la partie "Activez-les pour ne rien manquer"
        let highlightedText = "conversation_notif_highlight".localized

        // Création de l'AttributedString
        let attributedString = NSMutableAttributedString(string: fullText, attributes: normalAttributes)

        // Application des attributs pour la partie en gras et soulignée
        if let range = fullText.range(of: highlightedText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes(highlightedAttributes, range: nsRange)
        }

        // Assigner le texte stylisé au UILabel
        ui_text_view.attributedText = attributedString
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Appeler configureText ici si nécessaire
        configureText()
    }
}
