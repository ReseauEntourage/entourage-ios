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
    @IBOutlet weak var ui_iv_check: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.textColor = ApplicationTheme.getFontCourantBoldNoir().color
        ui_title.font = ApplicationTheme.getFontCourantBoldNoir().font
    }
    
    func populateCell(title:String,isChecked:Bool,imageName:String? = nil, hideSeparator:Bool = false) {
        ui_title.text = title
        ui_iv_check.image = isChecked ? UIImage.init(named: "checkbox_checked") : UIImage.init(named: "checkbox_unchecked")
        if let imageName = imageName {
            ui_picto?.image = UIImage.init(named: imageName)
        }
        else {
            ui_picto?.image = UIImage.init(named: "others")
        }
        
        ui_view_separator?.isHidden = hideSeparator
    }
}
