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
    @IBOutlet weak var ui_divider_left: UIView?
    @IBOutlet weak var ui_divider_right: UIView?

    func populateCell(title:String,isTopHeader:Bool) {
        if isTopHeader {
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        }
        else {
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        }
        ui_title.text = title
    }

    /// - Parameter useWhiteDivider: quand `true`, les lignes de séparation sont blanches plutôt
    ///   qu'orange — utilisé dans la conversation pour éviter l'effet de "rayures" (EN-9558).
    func populateMessageSectionCell(title:String, useWhiteDivider: Bool = false) {
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontChampDefault())
        ui_title.text = title

        let dividerColor: UIColor = useWhiteDivider ? .white : .appOrangeLight
        ui_divider_left?.backgroundColor = dividerColor
        ui_divider_right?.backgroundColor = dividerColor
    }

}
