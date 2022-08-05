//
//  ActionContribDetailHomeCell.swift
//  entourage
//
//  Created by Jerome on 03/08/2022.
//

import UIKit
import SDWebImage

class ActionContribDetailHomeCell: UITableViewCell {

    @IBOutlet weak var ui_placeholder: UIImageView!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_location: UILabel!
    @IBOutlet weak var ui_distance: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_location.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_distance.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        
        ui_image.layer.cornerRadius = 20
    }
    
    func populateCell(action:Action, hideSeparator:Bool) {
        
        ui_title.text = action.title
        
        self.ui_placeholder.image = nil
        if let imageUrl = action.imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image?.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.ui_image.image = nil
                    self?.ui_placeholder.image = UIImage.init(named: "ic_placeholder_action")
                }
            })
        }
        else {
            self.ui_image.image = nil
            self.ui_placeholder.image = UIImage.init(named: "ic_placeholder_action")
        }
    
        ui_view_separator.isHidden = hideSeparator
        
        ui_date.text = action.getCreatedDate()
        ui_location.text = action.metadata?.displayAddress
        ui_distance?.text = "À xx km".localized
    }
    
}
