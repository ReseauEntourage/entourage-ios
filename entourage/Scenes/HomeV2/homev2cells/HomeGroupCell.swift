//
//  HomeGroupCell.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit
import SDWebImage

class HomeGroupCell:UICollectionViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_label_title: UILabel!
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.clipsToBounds = true
    }
    
    func configure(group:Neighborhood){
        ui_label_title.text = group.name
        
        if let imageUrl = group.image_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_photo_group"))
        }
        else {
            ui_image.image = UIImage.init(named: "placeholder_photo_group")
        }
    }
}
