//
//  HomeActionCell.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import UIKit

class HomeActionCell: UITableViewCell {
    @IBOutlet weak var ui_constraint_width_iv: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_bottom_margin: NSLayoutConstraint!
    
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
    
    func populateCell(title:String,imageUrl:String?, imageIdentifier:String?,bottomMargin:CGFloat? = nil) {
        ui_title.text = title
        changeTypeCell(hasIdentifier: false)
        if let imageIdentifier = imageIdentifier {
            ui_image.image = UIImage.init(named: imageIdentifier)
            changeTypeCell(hasIdentifier: true)
        }
        else if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage:UIImage(named: "placeholder_action"))
        }
        else {
            ui_image.image = UIImage(named: "placeholder_action")
        }
        
        if let bottomMargin = bottomMargin {
            ui_constraint_bottom_margin.constant = bottomMargin
        }
        else {
            ui_constraint_bottom_margin.constant = 12
        }
    }
    
    private func changeTypeCell(hasIdentifier:Bool) {
        if hasIdentifier {
            ui_constraint_width_iv.constant = 44
            ui_image.backgroundColor = .clear
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        }
        else {
            ui_constraint_width_iv.constant = 77
            ui_image.backgroundColor = .appBeige
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        }
    }
}
