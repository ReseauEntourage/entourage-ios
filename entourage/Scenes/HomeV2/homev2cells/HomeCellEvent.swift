//
//  HomeCellEvent.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit
import SDWebImage


class HomeCellEvent:UICollectionViewCell{
    
    //OUTLET
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_label_place: UILabel!
    
    @IBOutlet weak var ui_label_date: UILabel!
    @IBOutlet weak var ui_label_interest: UILabel!
    @IBOutlet weak var ui_image_event: UIImageView!
    
    @IBOutlet weak var ui_image_interest: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ic_entoutou: UIImageView!
    
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

    
    func configure(event:Event){
        ui_label_title.text = event.title + "\n"
        
        if let imageUrl = event.metadata?.portrait_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else  if let imageUrl = event.metadata?.landscape_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else {
            ui_image_event.image = UIImage.init(named: "ic_placeholder_event")
        }
        if let _author = event.author {
            if let _roles = _author.communityRoles{
                if _roles.contains("Équipe Entourage") || _roles.contains("Ambassadeur") {
                    self.ic_entoutou.isHidden = false
                }else {
                    self.ic_entoutou.isHidden = true
                }
            }else{
                self.ic_entoutou.isHidden = true
            }
        }
        
        ui_label_date.text = event.startDateFormatted
        let addressComponents = event.addressName?.split(separator: ",")
        if let lastComponent = addressComponents?.last {
            ui_label_place.text = String(lastComponent).trimmingCharacters(in: .whitespaces)
            
        } else {
            ui_label_place.text = event.addressName
        }
        if let _interests = event.interests{
            if _interests.count > 0{
                if let _interest = event.interests?[0]{
                    ui_label_interest.text = TagsUtils.showTagTranslated(_interest)
                    switch _interest {
                    case "activites":
                        ui_image_interest.image = UIImage(named: "interest_activities")
                    case "animaux":
                        ui_image_interest.image = UIImage(named: "interest_animals")
                    case "bien-etre":
                        ui_image_interest.image = UIImage(named: "interest_wellness")
                    case "cuisine":
                        ui_image_interest.image = UIImage(named: "interest_cooking")
                    case "culture":
                        ui_image_interest.image = UIImage(named: "interest_art")
                    case "jeux":
                        ui_image_interest.image = UIImage(named: "interest_game")
                    case "sport":
                        ui_image_interest.image = UIImage(named: "interest_sport")
                    case "nature":
                        ui_image_interest.image = UIImage(named: "interest_nature")
                    case "marauding":
                        ui_image_interest.image = UIImage(named: "interest_nomad")
                    default:
                        ui_image_interest.image = UIImage(named: "interest_others")
                    }
                }
            }else{
                ui_label_interest.text = "Autre"
                ui_image_interest.image = UIImage(named: "interest_others")
            }
        }
    }
    
    private func updateImage(mainUrl:URL) {
        ui_image_event.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            if error != nil {
                self?.ui_image_event.image = UIImage.init(named: "ic_placeholder_event")
            }
        })
    }
}
