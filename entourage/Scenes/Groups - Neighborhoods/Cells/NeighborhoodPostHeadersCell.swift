//
//  NeighborhoodPostHeadersCell.swift
//  entourage
//
//  Created by Jerome on 13/05/2022.
//

import UIKit

class NeighborhoodPostHeadersCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    func populateCell(title:String,isTopHeader:Bool) {
        if isTopHeader {
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        }
        else {
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        }
        ui_title.text = title
    }
}
