//
//  NeighborhoodCguCell.swift
//  entourage
//
//  Created by Jerome on 03/05/2022.
//

import UIKit

class NeighborhoodCguCell: UITableViewCell {

    @IBOutlet weak var ui_description: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
    }
    
    func populateCell(title:String,description:String) {
        ui_title.text = title
        ui_description.text = description
    }
}
