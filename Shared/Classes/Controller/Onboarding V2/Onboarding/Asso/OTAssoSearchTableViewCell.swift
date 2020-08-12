//
//  OTAssoSearchTableViewCell.swift
//  entourage
//
//  Created by Jr on 26/05/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTAssoSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_image_selected: UIImageView!
    @IBOutlet weak var ui_label_name: UILabel!
    
    func populateCell(asso:OTAssociation,isSelected:Bool) {
        let assoName = asso.name != nil ? asso.name! : "Null"
        let name = asso.isCreation ? String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_search_creation"), assoName) : asso.name
        ui_label_name.text = name
        ui_image_selected.image = isSelected ? UIImage.init(named: "24HSelected") : UIImage.init(named: "24HActive")
    }
}
