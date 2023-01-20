//
//  NeighborhoodEditInterestTitleCell.swift
//  entourage
//
//  Created by Jerome on 27/04/2022.
//

import UIKit

class NeighborhoodEditInterestTitleCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_error_view: MJErrorInputTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_error_view.isHidden = true
        ui_error_view.setupView(title: "neighborhoodCreatePhase2_error".localized)
        ui_error_view.backgroundColor = .appBeigeClair
    }
    
    func populateCell(title:String? = nil, styleType:MJTextFontColorStyle? = nil, attributedStr:NSAttributedString? = nil, hasTagSelected:Bool) {
        if let attributedStr = attributedStr {
            ui_title.attributedText = attributedStr
        }
        else {
            ui_title.text = title
            ui_title.font = styleType?.font
            ui_title.textColor = styleType?.color
        }
        
        if hasTagSelected {
            ui_error_view.isHidden = true
        }
        else {
            ui_error_view.isHidden = false
        }
    }
}
