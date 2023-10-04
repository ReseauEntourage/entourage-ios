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
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
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
