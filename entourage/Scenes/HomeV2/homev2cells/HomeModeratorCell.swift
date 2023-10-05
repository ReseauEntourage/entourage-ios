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
    @IBOutlet weak var ui_image: UIImageView!
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.bounds

        // Convertir les valeurs hexadécimales en UIColor
        let color1 = UIColor(hexString: "#F55F24")
        let color2 = UIColor(hexString: "#FF9C5D")

        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        containerView.layer.insertSublayer(gradientLayer, at: 0)

    }
    
    func configure(title:String, imageUrl:String){
        self.ui_label_title.text = "home_v2_help_title_three".localized + " " + title
        if let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }else {
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
