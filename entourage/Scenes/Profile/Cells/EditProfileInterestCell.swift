//
//  EditProfileInterestCell.swift
//  entourage
//
//  Created by Jerome on 07/04/2022.
//

import UIKit

class EditProfileInterestCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.text = "editProfileInterest_title".localized
    }
}
