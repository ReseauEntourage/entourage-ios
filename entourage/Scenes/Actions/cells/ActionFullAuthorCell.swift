//
//  ActionFullAuthorCell.swift
//  entourage
//
//  Created by Jerome on 05/08/2022.
//

import UIKit

class ActionFullAuthorCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var ui_title_charte: UILabel!
    weak var delegate:ActionFullAuthorCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_subtitle.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        
        ui_title_charte.attributedText = Utils.formatStringUnderline(textString: "action_charte_title".localized, textColor: .appOrange, underlinedColor: .appOrange, font: ApplicationTheme.getFontQuickSandBold(size: 15))
    }
    
    func populateCell(action:Action,delegate:ActionFullAuthorCellDelegate) {
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        self.delegate = delegate
        ui_username.text = action.author?.displayName
        
        if let _url = action.author?.avatarURL, let url = URL(string: _url) {
            ui_image.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_image.image = UIImage.init(named: "placeholder_user")
        }
        
        ui_title.text = String.init(format: "action_created_at".localized, action.getCreatedDate(capitalizeFirst: false))
        if let date = action.author?.creationDate {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale.getPreferredLocale()
            dateFormat.dateFormat = "MM/YYYY"
            let dateFormated = dateFormat.string(from: date)
            ui_subtitle.text = String.init(format: "action_member_since".localized, dateFormated)
        }
        else {
            ui_subtitle.text = String.init(format: "action_member_since".localized, "")
        }
        
    }

    @IBAction func action_show_charte(_ sender: Any) {
        delegate?.showCharte()
    }
    
    @IBAction func action_signal(_ sender: Any) {
        delegate?.goSignal()
    }
    
}

protocol ActionFullAuthorCellDelegate:AnyObject {
    func showCharte()
    func goSignal()
}
