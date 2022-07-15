//
//  EventDetailFullGroupTitleCell.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import UIKit

class EventDetailFullGroupTitleCell: UITableViewCell {

    class var identifier:String {return String(describing: self) }

    @IBOutlet weak var ui_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title?.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_title?.text = "event_detail_groups_title".localized
    }
    
    func populate(nbOfGroups:Int) {
        if nbOfGroups > 1 {
            ui_title?.text = "event_detail_groups_title".localized
        }
        else {
            ui_title?.text = "event_detail_group_title".localized
        }
    }
}
