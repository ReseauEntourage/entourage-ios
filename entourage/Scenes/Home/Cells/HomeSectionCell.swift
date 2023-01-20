//
//  HomeSectionCell.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import UIKit

class HomeSectionCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!

    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
      
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
    }
    
    func populateCell(title:String) {
        ui_title.text = title
    }
    
}
