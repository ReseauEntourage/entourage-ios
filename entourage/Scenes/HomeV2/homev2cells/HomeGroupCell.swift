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
    
    @IBOutlet weak var ui_view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_news: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        ui_view.layer.cornerRadius = 15
        ui_view.layer.borderWidth = 1
        ui_view.layer.borderColor = UIColor.appBeige.cgColor
        ui_view.clipsToBounds = true
    }
    
    func configure(group:Neighborhood){
        ui_label_title.text = group.name
        if let _unreadPostCount = group.unreadPostCount {
            var numberOfPost = ""
            if _unreadPostCount > 0 {
                self.ui_label_news.isHidden = false
                if _unreadPostCount > 9 {
                    numberOfPost = "+9"
                }else{
                    numberOfPost = String(_unreadPostCount)
                    self.ui_label_news.text = numberOfPost
                }
            }else{
                self.ui_label_news.isHidden = true
            }
        }else{
            self.ui_label_news.isHidden = true
        }
        if let imageUrl = group.image_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_photo_group"))
        }
        else {
            ui_image.image = UIImage.init(named: "placeholder_photo_group")
        }
    }
}
