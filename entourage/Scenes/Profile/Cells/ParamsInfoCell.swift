//
//  ParamStagingInfoCell.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import UIKit

class ParamsInfoCell: UITableViewCell {

    @IBOutlet weak var ui_build_nb: UILabel!
    @IBOutlet weak var ui_token_info: UILabel!
    
    func populateCell(info:String, token:String) {
        ui_build_nb.text = info
        ui_token_info.text = token
    }
}
