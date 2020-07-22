//
//  OTSettingsDebugTableViewCell.swift
//  entourage
//
//  Created by Jr on 22/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTSettingsDebugTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_label_info: UILabel!
   
    func populateCell(info:String) {
        ui_label_info.text = info
    }
}
