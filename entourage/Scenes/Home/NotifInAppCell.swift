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
        ui_title.numberOfLines = 2
        ui_date.numberOfLines = 2
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_image.layer.cornerRadius = ui_image.frame.width / 2
    }

    func populateCell(title:String ,content:String ,date:String ,imageUrl:String?, isUnread:Bool, instanceString : InstanceType) {
         
        var titleText = title
        var contentText = content
        if instanceString == .contributions {
            titleText = "notif_contrib_title".localized
            contentText = title
        }else if instanceString == .solicitations{
            contentText = title
        }

        // Crée un objet NSMutableAttributedString pour construire le texte final
        let attributedString = NSMutableAttributedString(string: "\(titleText) \(contentText)")

        // Définit le style du texte en gras
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 15)
        ]

        // Applique le style gras à la plage de texte sélectionnée
        attributedString.addAttributes(boldAttributes, range: NSRange(location: 0, length: titleText.count))
       
        let finalAttributedString = NSAttributedString(attributedString: attributedString)

        // Affiche le texte dans le UILabel
        ui_title.attributedText = attributedString
        //ui_title.text = title
        ui_date.text = date
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage:UIImage(named: DeepLinkManager.setImage(notificationInstanceType: instanceString)))
        }else{
            ui_image.image = UIImage(named: DeepLinkManager.setImage(notificationInstanceType: instanceString))
        }
        
        if !isUnread {
            ui_view_main.backgroundColor = UIColor.appBeige
            ui_view_separator.backgroundColor = UIColor.white
        }
        else {
            ui_view_main.backgroundColor = .clear
            ui_view_separator.backgroundColor = UIColor.appBeige
        }
    }
}
