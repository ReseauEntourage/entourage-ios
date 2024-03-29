//
//  SelectTagCell.swift
//  entourage
//
//  Created by Jerome on 24/03/2022.
//

import UIKit

class SelectTagCell: UITableViewCell {

    @IBOutlet weak var ui_view_separator: UIView!
    @IBOutlet weak var ui_picto: UIImageView?
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_iv_check: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        ui_title.font = ApplicationTheme.getFontCourantRegularNoir().font
        
        ui_subtitle?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 11, color: .black))
    }
    
    func populateCell(title:String,isChecked:Bool,imageName:String? = nil, hideSeparator:Bool = false, subtitle:String? = nil, isSingleSelection:Bool = false, imageUrl:String? = nil, isUser:Bool = false) {
        ui_title.text = TagsUtils.showTagTranslated(title)
        if let _subtitle = subtitle{
            ui_subtitle?.text = TagsUtils.showSubTagTranslated(_subtitle)
        }
        if isSingleSelection {
            ui_iv_check.image = isChecked ? UIImage.init(named: "ic_section_on") : UIImage.init(named: "ic_section_off")
        }
        else {
            ui_iv_check.image = isChecked ? UIImage.init(named: "checkbox_checked") : UIImage.init(named: "checkbox_unchecked")
        }
        
        if let imageName = imageName {
            ui_picto?.image = UIImage.init(named: imageName)
        }
        else {
            ui_picto?.image = UIImage.init(named: "others")
        }
        if isUser {
            ui_picto?.layer.cornerRadius = (ui_picto?.frame.height ?? 0) / 2
            let placeholder = UIImage.init(named: "placeholder_user")
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                ui_picto?.sd_setImage(with: url, placeholderImage: placeholder)
            }
            else {
                ui_picto?.image = placeholder
            }
        }
        
        ui_view_separator?.isHidden = hideSeparator
        
        if isChecked {
            ui_title.font = ApplicationTheme.getFontCourantBoldNoir().font
        }
        else {
            ui_title.font = ApplicationTheme.getFontCourantRegularNoir().font
        }
    }
}
