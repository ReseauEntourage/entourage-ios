//
//  ConversationParamCell.swift
//  entourage
//
//  Created by Jerome on 26/08/2022.
//

import UIKit

class ConversationParamCell: UITableViewCell {

    @IBOutlet weak var ui_picto: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel?
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_subtitle?.setupFontAndColor(style: ApplicationTheme.getFontChampDefault())
    }
    
    func populateCell(title:String,subtitle:String?, isTitleOrange:Bool, pictoStr:String, hideSeparator:Bool = false) {
        ui_title.textColor = isTitleOrange ? .appOrange : .black
        ui_title.text = title
        ui_subtitle?.text = subtitle
        ui_picto.image = UIImage.init(named: pictoStr)
        ui_separator.isHidden = hideSeparator
    }
}
