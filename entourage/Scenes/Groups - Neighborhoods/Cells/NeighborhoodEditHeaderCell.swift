//
//  NeighborhoodEditHeaderCell.swift
//  entourage
//
//  Created by Jerome on 14/04/2022.
//

import UIKit

class NeighborhoodEditHeaderCell: UITableViewCell {

    @IBOutlet weak var ui_constraint_top: NSLayoutConstraint!
    @IBOutlet weak var ui_number: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.text = "neighborhood_create_title_phase".localized
        ui_title.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_title.textColor = .black
        ui_number.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_number.textColor = .appOrangeLight
    }
    
    func populateCell(position:Int) {
        ui_number.text = String.init(format: "neighborhood_create_title_phase_nb".localized, position)
        
        ui_constraint_top.constant = position == 0 ? 30 : 40
    }
}
