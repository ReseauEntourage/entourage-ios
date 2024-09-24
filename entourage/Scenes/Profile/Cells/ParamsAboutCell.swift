//
//  ParamsAboutCell.swift
//  entourage
//
//  Created by Jerome on 16/03/2022.
//

import UIKit

class ParamsAboutCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.font = ApplicationTheme.getFontCourantRegularNoir().font
        ui_title.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        ui_title.textAlignment = .natural

    }
    
    func populateCell(title:String, isSeparatorHidden:Bool) {
        ui_title.text = title
        ui_view_separator.isHidden = isSeparatorHidden
        self.contentView.semanticContentAttribute = .unspecified
    }
}
