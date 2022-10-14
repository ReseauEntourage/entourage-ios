//
//  ActionCreatePhotoCell.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit
import SDWebImage

class ActionCreatePhotoCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_image: UIView!
    
    @IBOutlet weak var ui_image_bottom_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_picto_photo: UIImageView!
    @IBOutlet weak var ui_photo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_image.layer.cornerRadius = 14
        ui_photo.layer.cornerRadius = 14
        
        let style = ApplicationTheme.getFontH2Noir()
        let styleHighlight = ApplicationTheme.getFontLegend()
        let attrStr = Utils.formatString(messageTxt: "action_PhotoCreateTitle".localized, messageTxtHighlight: "action_PhotoCreateTitleHighlight".localized, fontColorType: style, fontColorTypeHighlight: styleHighlight)
        
        ui_title.attributedText = attrStr
        
        ui_description?.textColor = ApplicationTheme.getFontLegend().color
        ui_description?.font = ApplicationTheme.getFontLegend().font
        ui_description?.text = "action_PhotoCreateDescription".localized
        
        if ApplicationTheme.iPhoneHasNotch() {
            ui_image_bottom_constraint?.constant = 80
        }
        else {
            ui_image_bottom_constraint?.constant = 120
        }
    }
    
    func populateCell(image:UIImage?, imageUrl:String?) {
        
        self.ui_photo.image = image
        
        if image != nil {
            self.ui_picto_photo.isHidden = true
            return
        }
        
        if imageUrl != nil {
            self.ui_picto_photo.isHidden = true
            
            if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
                ui_photo.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                    if error != nil {
                        self?.ui_photo.backgroundColor = .appBeige
                        self?.ui_picto_photo.isHidden = false
                    }
                })
                return
            }
        }
        self.ui_photo.backgroundColor = .appBeige
        self.ui_picto_photo.isHidden = false
    }
}
