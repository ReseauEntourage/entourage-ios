//
//  NeighborhoodChoosePhotoCell.swift
//  entourage
//
//  Created by Jerome on 13/04/2022.
//

import UIKit

class NeighborhoodChoosePhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_contentview: UIView!
    
    override func awakeFromNib() {
        super .awakeFromNib()
        ui_contentview.layer.cornerRadius = 14
        ui_image.layer.cornerRadius = 14
        ui_contentview.layer.borderWidth = 0
        ui_contentview.layer.borderColor = UIColor.appOrangeLight_50.cgColor
    }
    
    func populateCell(imageUrl:String, isSelected:Bool) {
        if let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_photo_group"))
        }
        
        if isSelected {
            ui_contentview.layer.borderWidth = 3
        }
        else {
            ui_contentview.layer.borderWidth = 0
        }
    }
}
