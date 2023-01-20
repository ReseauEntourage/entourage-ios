//
//  ActionFullTopCell.swift
//  entourage
//
//  Created by Jerome on 05/08/2022.
//

import UIKit
import SDWebImage

class ActionFullTopCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_cancel_opacity: UIView!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_cancel: UIView!
    @IBOutlet weak var ui_title_cancel: UILabel!
    
    @IBOutlet weak var ui_view_contrib: UIView!
    @IBOutlet weak var ui_view_solicitation: UIView!
    
    @IBOutlet weak var ui_img_contrib: UIImageView!
    
    @IBOutlet weak var ui_title_main: UILabel!
    
    @IBOutlet var ui_view_tags: [UIView]!
    @IBOutlet var ui_title_tags: [UILabel]!
    @IBOutlet var ui_img_tags: [UIImageView]!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_cancel.isHidden = true
        ui_view_contrib.isHidden = true
        ui_view_solicitation.isHidden = true
        
        ui_img_contrib.layer.cornerRadius = 14
        
        ui_view_cancel.layer.cornerRadius = 8
        ui_title_cancel.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldBlanc())
        ui_title_cancel.text = "action_cancel".localized
        
        ui_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        for _v in ui_view_tags {
            _v.layer.cornerRadius = _v.frame.height / 2
            _v.layer.borderColor = UIColor.appOrange.cgColor
            _v.layer.borderWidth = 1
        }
        
        for _t in ui_title_tags {
            _t.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: .appOrange))
        }
        
        ui_title_main.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontQuickSandBold(size: 15), color: .black))
    }
    
    func populateCell(action:Action) {
        if action.isCanceled() {
            ui_view_cancel.isHidden = false
            ui_view_cancel_opacity.isHidden = false
        }
        else {
            ui_view_cancel.isHidden = true
            ui_view_cancel_opacity.isHidden = true
        }
        
        ui_title_main.text = action.title
        
        ui_description.text = action.description
        if action.isContrib() {
            ui_view_contrib.isHidden = false
            ui_view_solicitation.isHidden = true
            if let imageUrl = action.imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
                ui_img_contrib.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                    if error != nil {
                        self?.ui_img_contrib.image = UIImage.init(named: "ic_placeholder_action")
                    }
                })
            }
            else {
                ui_img_contrib.image = UIImage.init(named: "ic_placeholder_action")
            }
        }
        else {
            ui_view_contrib.isHidden = true
            ui_view_solicitation.isHidden = false
        }
        
        guard let sectionName = action.sectionName else {
            for _t in ui_title_tags {
                _t.text = nil
            }
            for _iv in ui_img_tags {
                _iv.image = nil
            }
            return
        }
        
        for _t in ui_title_tags {
            _t.text = Metadatas.sharedInstance.getTagSectionName(key: sectionName)?.name
        }
        
        for _iv in ui_img_tags {
            if let imgStr = Metadatas.sharedInstance.getTagSectionImageName(key: sectionName) {
                _iv.image = UIImage.init(named: imgStr)
            }
            else {
                _iv.image = nil
            }
        }
    }
}
