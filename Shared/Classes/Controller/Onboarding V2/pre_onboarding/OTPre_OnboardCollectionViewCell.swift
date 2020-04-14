//
//  OTPre_OnboardCollectionViewCell.swift
//  entourage
//
//  Created by Jr on 10/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTPre_OnboardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ui_constrait_image_width: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image.layer.cornerRadius = 8
    }
    
    func populateCell(imageName:String,width:CGFloat) {
        ui_image.image = UIImage.init(named: imageName)
        ui_constrait_image_width.constant = width
        ui_image.layoutIfNeeded()
    }
}
