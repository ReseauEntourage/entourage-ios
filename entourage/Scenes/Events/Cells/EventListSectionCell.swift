//
//  EventListSectionCell.swift
//  entourage
//
//  Created by Jerome on 07/07/2022.
//

import UIKit

class EventListSectionCell: UITableViewCell {

    static let neighborhoodHeaderIdentifier = "NeighborhoodListHeaderCell"
    
    class var identifier: String {
        return String(describing: self)
    }
    
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
