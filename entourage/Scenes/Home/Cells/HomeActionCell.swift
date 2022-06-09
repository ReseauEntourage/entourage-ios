//
//  HomeActionCell.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import UIKit

class HomeActionCell: UITableViewCell {

    @IBOutlet weak var ui_view_container: UIView!
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        addShadowAndRadius(customView: ui_view_container, radius: 20)
        ui_image.layer.cornerRadius = 8
    }

    private func addShadowAndRadius(customView:UIView,radius:CGFloat) {
        customView.layer.cornerRadius = radius
        customView.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.35).cgColor
        customView.layer.shadowOpacity = 1
        customView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        customView.layer.shadowRadius = 4
        
        customView.layer.rasterizationScale = UIScreen.main.scale
        customView.layer.shouldRasterize = true
    }
    
    func populateCell(title:String,imageUrl:String?) {
        ui_title.text = title
        
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage:UIImage(named: "placeholder_action"))
        }
        else {
            ui_image.image = UIImage(named: "placeholder_action")
        }
        
    }
}
