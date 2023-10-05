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
            
        ui_label_date.text = event.startDateFormatted
        ui_label_place.text = event.addressName
    }
    
    private func updateImage(mainUrl:URL) {
        ui_image_event.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            if error != nil {
                self?.ui_image_event.image = UIImage.init(named: "ic_placeholder_event")
            }
        })
    }
}
