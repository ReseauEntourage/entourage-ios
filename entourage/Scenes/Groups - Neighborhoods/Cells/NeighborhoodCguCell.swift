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
    @IBOutlet weak var ui_number: UILabel!
    @IBOutlet weak var ui_separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_number.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
    }
    
    func populateCell(title:String,description:String, position:Int) {
        ui_number.text = position < 10 ? "0\(position)." : "\(position)."
        ui_title.text = title
        ui_description.text = description
    }
}
