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
        ui_placeholder.image = nil
        ui_placeholder.isHidden = true
    }
    
    func populateCellForExample(image:UIImage, name:String, date:String, location:String, distance:String){
        self.ui_image.image = image
        self.ui_date.text = date
        self.ui_title.text = name
        self.ui_location.text = location
        self.ui_distance.text = distance
        
    }
    
    func hideSeparator(){
        self.ui_view_separator.isHidden = true
    }
    
    func populateCell(action:Action, hideSeparator:Bool) {
        
        ui_title.text = action.title
        self.ui_image.image = UIImage()
        ui_placeholder.isHidden = true
        
        if let imageUrl = action.imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image?.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if let _err = error as? SDWebImageError, _err.errorCode != SDWebImageError.cancelled.rawValue {
                    self?.ui_image.image = UIImage()
                    self?.ui_placeholder.image = UIImage.init(named: "ic_placeholder_action")
                    self?.ui_placeholder.isHidden = false
                }
                else {
                    self?.ui_placeholder.isHidden = true
                }
            })
        }
        else {
            self.ui_placeholder.isHidden = false
            self.ui_image.image = UIImage()
            self.ui_placeholder.image = UIImage.init(named: "ic_placeholder_action")
        }
    
        ui_view_separator.isHidden = hideSeparator
        
        ui_date.text = action.getCreatedDate()
        ui_location.text = action.metadata?.displayAddress
        if let _distance = action.distance {
            ui_distance?.text = _distance.displayDistance()
        }else{
            ui_distance?.text = String.init(format: "AtKm".localized, "xx") //TODO: a changer plus tard
        }
        
    }
}
