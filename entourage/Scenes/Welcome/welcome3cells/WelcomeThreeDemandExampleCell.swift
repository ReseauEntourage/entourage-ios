//
//  WelcomeThreeDemandExampleCell.swift
//  entourage
//
//  Created by Clement entourage on 15/06/2023.
//

import Foundation
import UIKit
import SDWebImage


class WelcomeThreeDemandExampleCell:UITableViewCell{
    
    @IBOutlet weak var ui_iv_user: UIImageView!
    @IBOutlet weak var ui_iv_section: UIImageView!
    @IBOutlet weak var ui_section: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_location: UILabel!
    @IBOutlet weak var ui_username: UILabel!
    
    @IBOutlet weak var ui_shadow_view: UIView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setShadow()
        ui_section.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 15, color: .appOrangeLight))
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_location.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        
        ui_iv_user.layer.cornerRadius = ui_iv_user.frame.height / 2
    }
    
    func setShadow(){
        ui_shadow_view.layer.borderWidth = 1
        ui_shadow_view.layer.borderColor = UIColor(red: 0xE8 / 255, green: 0xE5 / 255, blue: 0xE3 / 255, alpha: 1).cgColor
//        ui_shadow_view.layer.cornerRadius = 20
//        ui_shadow_view.layer.shadowOffset = CGSize(width: 0, height: 2) // Ombre décalée d'un point vers le bas
//        ui_shadow_view.layer.shadowRadius = 0.5 // Ombre avec un rayon de 1 pour une ombre plus nette
//        ui_shadow_view.layer.shadowOpacity = 0.1 // Ombre plus légère avec une opacité de 0.1
//            ui_shadow_view.layer.shadowColor = UIColor.black.cgColor
//            ui_shadow_view.layer.masksToBounds = false
//        ui_shadow_view.layer.shadowPath = UIBezierPath(roundedRect: ui_shadow_view.bounds, cornerRadius: 20).cgPath
    }
    
    func populateCell(action:Action, hideSeparator:Bool) {
        
        ui_title.text = action.title
        ui_date.text = action.getCreatedDate()
        
        if let _distance = action.distance {
            ui_location.text = _distance.displayDistance()
        }else{
            let displayAddress = action.metadata?.displayAddress ?? ""
            ui_location.text = "\(String.init(format: "AtKm".localized, "xx")) - \(displayAddress)"
        }
    
        
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
        
        ui_section.text = Metadatas.sharedInstance.getTagSectionName(key: sectionName)?.name
        
        if let imgStr = Metadatas.sharedInstance.getTagSectionImageName(key: sectionName) {
            ui_iv_section.image = UIImage.init(named: imgStr)?.sd_tintedImage(with: .appOrangeLight)
        }
        else {
            ui_iv_section.image = nil
        }
    }
    
}
    
    

