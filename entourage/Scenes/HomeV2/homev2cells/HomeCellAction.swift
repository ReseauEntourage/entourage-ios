//
//  HomeCellAction.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit
import SDWebImage


class HomeCellAction:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_tag: UILabel!
    @IBOutlet weak var ui_image_tag: UIImageView!
    @IBOutlet weak var ui_label_distance: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")

        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.clipsToBounds = true
    }
    
    func configure(action:Action){
        ui_label_title.text = action.title
        
        if let _distance = action.distance {
            ui_label_distance.text = _distance.displayDistance()
        }else{
            let displayAddress = action.metadata?.displayAddress ?? ""
            ui_label_distance.text = "\(String.init(format: "AtKm".localized, "xx")) - \(displayAddress)"
        }
    
                
        if let imageUrl = action.author?.avatarURL, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.ui_image.image = UIImage.init(named: "ic_placeholder_action")
                }
            })
        }
        else {
            ui_image.image = UIImage.init(named: "ic_placeholder_action")
        }
        
        if let _sectionName = action.sectionName{
            switch _sectionName{
            case "social":
                ui_image_tag.image = UIImage.init(named: "ic_action_social")?.sd_tintedImage(with: .appOrangeLight)
                ui_label_tag.text = "home_v2_action_type_social".localized
            case "clothes":
                ui_image_tag.image = UIImage.init(named: "ic_action_clothes")?.sd_tintedImage(with: .appOrangeLight)
                ui_label_tag.text = "home_v2_action_type_clothes".localized

            case "equipment":
                ui_image_tag.image = UIImage.init(named: "ic_action_equipment")?.sd_tintedImage(with: .appOrangeLight)
                ui_label_tag.text = "home_v2_action_type_equipment".localized

            case "hygiene":
                ui_image_tag.image = UIImage.init(named: "ic_action_hygiene")?.sd_tintedImage(with: .appOrangeLight)
                ui_label_tag.text = "home_v2_action_type_hygiène".localized

            case "services":
                ui_image_tag.image = UIImage.init(named: "ic_action_services")?.sd_tintedImage(with: .appOrangeLight)
                ui_label_tag.text = "home_v2_action_type_services".localized

            default:
                ui_image_tag.image = UIImage.init(named: "ic_action_services")?.sd_tintedImage(with: .appOrangeLight)
                ui_label_tag.text = "home_v2_action_type_other".localized
            }
        }
    }
}
