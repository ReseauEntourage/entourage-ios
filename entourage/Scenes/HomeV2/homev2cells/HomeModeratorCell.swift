//
//  HomeModeratorCell.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit
import SDWebImage

class HomeModeratorCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")

        // Remove old gradient layer
        containerView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        // Apply shadow/card style
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.shadowColor = UIColor.clear.cgColor
        containerView.layer.shadowOpacity = 0

        ui_label_title.font = UIFont(name: "Quicksand-Bold", size: 14)
        ui_label_title.textColor = UIColor(named: "black_app")

        ui_label_description.font = UIFont(name: "Quicksand-Regular", size: 13)
        ui_label_description.textColor = UIColor(named: "black_app")

        ui_image.layer.borderColor = UIColor.appOrangeLight.cgColor
        ui_image.layer.borderWidth = 1
        ui_image.layer.cornerRadius = 23
        ui_image.clipsToBounds = true
    }
    
    func configure(title:String, imageUrl:String? = nil){
        let titleFormat = "home_v2_moderator_title_format".localized
        self.ui_label_title.text = String(format: titleFormat, title)
        self.ui_label_description.text = "home_v2_moderator_subtitle".localized

        if let _urlImageString = imageUrl{
            if let mainUrl = URL(string: _urlImageString) {
                self.updateImage(mainUrl: mainUrl)
            }else {
                ui_image.image = UIImage.init(named: "placeholder_user")
            }
        }else{
            ui_image.image = UIImage.init(named: "placeholder_user")
        }
    }
    private func updateImage(mainUrl:URL) {
        ui_image.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            if error != nil {
                self?.ui_image.image = UIImage.init(named: "placeholder_user")
            }
        })
    }
}
