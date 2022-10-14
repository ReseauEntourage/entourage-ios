//
//  ActionFilterValidateCell.swift
//  entourage
//
//  Created by Jerome on 11/08/2022.
//

import UIKit

class ActionFilterValidateCell: UITableViewCell {

    @IBOutlet weak var ui_bt_validate: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_bt_validate.setTitle("validate".localized, for: .normal)
        ui_bt_validate.layer.cornerRadius = ui_bt_validate.frame.height / 2
        ui_bt_validate.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
    }

}
