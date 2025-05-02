//
//  CreateAction4HeaderCell.swift
//  entourage
//
//  Created by Clement entourage on 28/10/2024.
//

import Foundation
import UIKit

class CreateAction4HeaderCell: UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
    // Outlet
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_subtitle_label: UILabel!
    
    // Variable
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Configure function to set up labels with localized strings
    func configure(cityGroup: String,actionType:String) {
        ui_label_title.text = String(format: "share_request_title".localized,actionType, cityGroup)
        ui_subtitle_label.text = String(format: "share_request_description".localized,actionType)
    }
}
