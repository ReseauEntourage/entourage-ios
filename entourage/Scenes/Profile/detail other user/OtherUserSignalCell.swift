//
//  OtherUserSignalCell.swift
//  entourage
//
//  Created by Jerome on 11/04/2022.
//

import UIKit

class OtherUserSignalCell: UITableViewCell {
    @IBOutlet weak var ui_title_bt_signal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title_bt_signal.text = "detail_user_button_signal".localized
        ui_title_bt_signal.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_title_bt_signal.textColor = .appOrangeLight
    }
}
