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
    
    func populateCell(title:String,isChecked:Bool,imageName:String? = nil, hideSeparator:Bool = false, subtitle:String? = nil, isSingleSelection:Bool = false) {
        ui_title.text = title
        ui_subtitle?.text = subtitle
        
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
        
        ui_view_separator?.isHidden = hideSeparator
        
        if isChecked {
            ui_title.font = ApplicationTheme.getFontCourantBoldNoir().font
        }
        else {
            ui_title.font = ApplicationTheme.getFontCourantRegularNoir().font
        }
    }
}
