//
//  NotifInAppCell.swift
//  entourage
//
//  Created by - on 22/11/2022.
//

import UIKit

class NotifInAppCell: UITableViewCell {

    @IBOutlet weak var ui_view_main: UIView!
    @IBOutlet weak var ui_view_separator: UIView!
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title.numberOfLines = 3
        ui_date.numberOfLines = 2
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_image.layer.cornerRadius = ui_image.frame.width / 2
    }

    func populateCell(title: String, content: String, date: String, imageUrl: String?, isUnread: Bool, instanceString: InstanceType) {
        var titleText = title
        var contentText = ""
        
        if instanceString == .solicitations || instanceString == .contributions {
            contentText = "\"\(content)\""
        } else {
            contentText = content
        }

        // Crée un objet NSMutableAttributedString pour construire le texte final
        let attributedString = NSMutableAttributedString(string: "\(titleText) \(contentText)")

        // Définit le style du texte en gras pour le titre
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: ApplicationTheme.getFontQuickSandBold(size: 15)
        ]

        // Définit le style du texte normal pour le contenu
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: ApplicationTheme.getFontCourantRegularNoir(size: 15)
        ]

        // Applique le style gras à la plage de texte du titre
        if let titleRange = titleText.range(of: titleText) {
            let nsRange = NSRange(titleRange, in: titleText)
            attributedString.addAttributes(boldAttributes, range: nsRange)
        }

        // Affiche le texte dans le UILabel
        ui_title.attributedText = attributedString
        ui_date.text = date

        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage: UIImage(named: DeepLinkManager.setImage(notificationInstanceType: instanceString)))
        } else {
            ui_image.image = UIImage(named: DeepLinkManager.setImage(notificationInstanceType: instanceString))
        }

        if !isUnread {
            ui_view_main.backgroundColor = UIColor.appBeige
            ui_view_separator.backgroundColor = UIColor.white
        } else {
            ui_view_main.backgroundColor = .clear
            ui_view_separator.backgroundColor = UIColor.appBeige
        }
    }

}
