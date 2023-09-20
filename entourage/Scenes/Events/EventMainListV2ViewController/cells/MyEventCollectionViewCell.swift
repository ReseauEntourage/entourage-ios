//
//  MyEventCollectionViewCell.swift
//  entourage
//
//  Created by Clement entourage on 18/09/2023.
//

import Foundation
import UIKit
import SDWebImage


class MyEventCollectionViewCell:UICollectionViewCell{
    
    //Outlet
    @IBOutlet weak var ui_iv_event: UIImageView!
    
    @IBOutlet weak var ui_date_event: UILabel!
    @IBOutlet weak var ui_place_event: UILabel!
    @IBOutlet weak var ui_title_event: UILabel!
    //Var
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.layer.borderWidth = 1.0 // Set the width of the border
        self.layer.borderColor = UIColor.appBeige.cgColor
        self.layer.cornerRadius = 14
        self.roundCorners([.topLeft, .topRight], radius: 14)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        ui_iv_event.layer.mask = mask
    }
    
    func configure(event:Event){

        ui_title_event.text = event.title + "\n"
        
        if let imageUrl = event.metadata?.portrait_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else  if let imageUrl = event.metadata?.landscape_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else {
            ui_iv_event.image = UIImage.init(named: "ic_placeholder_event")
        }
            
        ui_date_event.text = event.startDateFormatted
        ui_place_event.text = event.addressName
    }
    
    func setPassed(){
        ui_title_event.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGris())
    }
    
    func setIncoming(){
        ui_title_event.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
    }
    
    private func updateImage(mainUrl:URL) {
        ui_iv_event.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            if error != nil {
                self?.ui_iv_event.image = UIImage.init(named: "ic_placeholder_event")
            }
        })
    }
    
}


