//
//  ActionSolicitationDetailHomeCell.swift
//  entourage
//
//  Created by Jerome on 03/08/2022.
//

import UIKit
import SDWebImage

class ActionSolicitationDetailHomeCell: UITableViewCell {

    @IBOutlet weak var ui_iv_user: UIImageView!
    @IBOutlet weak var ui_iv_section: UIImageView!
    @IBOutlet weak var ui_section: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_location: UILabel!
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_section.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 15, color: .appOrangeLight))
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_location.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        
        ui_iv_user.layer.cornerRadius = ui_iv_user.frame.height / 2
    }
    
    func populateCell(action:Action, hideSeparator:Bool) {
        
        ui_title.text = action.title
        ui_date.text = action.getCreatedDate()
        
        let displayAddress = action.metadata?.displayAddress ?? ""
        ui_location.text = "\(String.init(format: "AtKm".localized, "xx")) - \(displayAddress)"
    
        ui_view_separator.isHidden = hideSeparator
        
        ui_username.text = action.author?.displayName
        
        if let imageUrl = action.author?.avatarURL, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_iv_user.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.ui_iv_user.image = UIImage.init(named: "placeholder_user")
                }
            })
        }
        else {
            ui_iv_user.image = UIImage.init(named: "placeholder_user")
        }
    
        guard let sectionName = action.sectionName else {
            ui_section.text = nil
            ui_iv_section.image = nil
            return
        }
        
        ui_section.text = Metadatas.sharedInstance.tagsSections?.getSectionNameFrom(key:sectionName).name
        
        if let imgStr = Metadatas.sharedInstance.tagsSections?.getSectionFrom(key: sectionName)?.getImageName() {
            ui_iv_section.image = UIImage.init(named: imgStr)?.sd_tintedImage(with: .appOrangeLight)
        }
        else {
            ui_iv_section.image = nil
        }
    }
    
}
