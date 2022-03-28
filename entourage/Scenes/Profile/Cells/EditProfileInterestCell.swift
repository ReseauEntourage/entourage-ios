//
//  EditProfileInterestCell.swift
//  entourage
//
//  Created by Jerome on 24/03/2022.
//

import UIKit

class EditProfileInterestCell: UITableViewCell {

    @IBOutlet weak var ui_picto: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_iv_check: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.textColor = ApplicationTheme.getFontPopTitle().color
        ui_title.font = ApplicationTheme.getFontPopTitle().font
    }
    
    func populateCell(title:String,isChecked:Bool,imageName:String?) {
        ui_title.text = title
        ui_iv_check.image = isChecked ? UIImage.init(named: "checkbox_checked") : UIImage.init(named: "checkbox_unchecked")
        if let imageName = imageName {
            //TODO: get image from name ?
            ui_picto.image = UIImage.init(named: imageName)
        }
        else {
            ui_picto.image = UIImage.init(named: "others")
        }
    }
}
