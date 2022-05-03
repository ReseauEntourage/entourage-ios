//
//  NeighborhoodParamSignalCell.swift
//  entourage
//
//  Created by Jerome on 02/05/2022.
//

import UIKit

class NeighborhoodParamSignalCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_title.text = "neighborhood_params_signal".localized
    }
}
