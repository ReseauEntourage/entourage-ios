//
//  NeighborhoodCreatePhotoCell.swift
//  entourage
//
//  Created by Jerome on 13/04/2022.
//

import UIKit

class NeighborhoodCreatePhotoCell: UITableViewCell {
    
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
        let attrStr = Utils.formatString(messageTxt: "addPhotoCreateTitle".localized, messageTxtHighlight: "addPhotoCreateTitleHighlight".localized, fontColorType: style, fontColorTypeHighlight: styleHighlight)
        
        ui_title.attributedText = attrStr
        
        ui_description?.textColor = ApplicationTheme.getFontLegend().color
        ui_description?.font = ApplicationTheme.getFontLegend().font
        ui_description?.text = "addPhotoCreateDescription".localized
        
        if ApplicationTheme.iPhoneHasNotch() {
            ui_image_bottom_constraint?.constant = 80
        }
        else {
            ui_image_bottom_constraint?.constant = 120
        }
    }
    
    func populateCell(urlImg:String?, isEdit:Bool = false, isEvent:Bool = false) {
        if let urlImg = urlImg, !urlImg.isEmpty, let mainUrl = URL(string: urlImg) {
            ui_photo.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_photo_group"))
            ui_picto_photo.isHidden = true
        }
        else {
            ui_photo.image = nil
            ui_picto_photo.isHidden = false
        }
        
        if isEdit {
            ui_title.text = "neighborhoodEditPhotoTitle".localized
        }
        
        if isEvent {
            let style = ApplicationTheme.getFontH2Noir()
            let styleHighlight = ApplicationTheme.getFontLegend()
            let attrStr = Utils.formatString(messageTxt: "event_create_phase_1_photo".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: style, fontColorTypeHighlight: styleHighlight)
            ui_title.attributedText = attrStr
            ui_description?.text = "event_create_phase_1_photo_desc".localized
        }
    }
}
