//
//  OTSharingEntourageTableViewCell.swift
//  entourage
//
//  Created by Jr on 08/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class SharingEntourageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_iv_selector: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_image.layer.cornerRadius = ui_image.frame.width / 2
    }
    
    func populateCell(title:String,imageUrl:String?,type:String?, isSelected:Bool) {
        ui_title.text = title
        
        if isSelected {
            ui_iv_selector.image = UIImage.init(named: "24HSelected")
            let font = UIFont(name: "SFUIText-Bold", size: 16)
            ui_title.font = font
        }
        else {
            ui_iv_selector.image = UIImage.init(named: "24HInactive")
            let font = UIFont(name: "SFUIText-Regular", size: 16)
            ui_title.font = font
        }
        
        if let type = type {
            ui_image.image = UIImage.init(named: type)
            ui_image.contentMode = .center
            ui_image.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            ui_image.layer.borderWidth = 1
            ui_image.layer.cornerRadius = ui_image.frame.width / 2
        }
        else if let _imageUrl = imageUrl {
            ui_image.sd_setImage(with: URL(string: _imageUrl), placeholderImage: UIImage.init(named: "userSmall"))
            ui_image.contentMode = .scaleAspectFit
        }
        else {
            ui_image.image = UIImage.init(named: "chatActive")
            ui_image.contentMode = .center
        }
    }
}
