//
//  TitleOnlyCell.swift
//  entourage
//
//  Created by Jerome on 15/04/2022.
//

import UIKit

class TitleOnlyCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    func populateCell(title:String? = nil, styleType:MJTextFontColorStyle? = nil, attributedStr:NSAttributedString? = nil) {
        if let attributedStr = attributedStr {
            ui_title.attributedText = attributedStr
            return
        }
        
        ui_title.text = title
        ui_title.font = styleType?.font
        ui_title.textColor = styleType?.color
    }
}
