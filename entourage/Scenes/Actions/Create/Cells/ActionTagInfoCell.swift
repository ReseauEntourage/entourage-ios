//
//  ActionTagInfoCell.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit

class ActionTagInfoCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populateCell(title:String,titleColored:String,color:UIColor = .black,colored:UIColor = .appOrange,font:UIFont) {
        ui_title.text = title
      
        let attr = Utils.formatStringUnderline(textString: title, textUnderlineString: titleColored, textColor: color, underlinedColor: colored, font: font)
        ui_title.attributedText = attr
    }
}
