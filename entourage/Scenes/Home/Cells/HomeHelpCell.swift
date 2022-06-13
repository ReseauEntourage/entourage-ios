//
//  HomeHelpCell.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import UIKit

class HomeHelpCell: UITableViewCell {

    @IBOutlet weak var ui_view_container: UIView!
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_subtitle.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        addShadowAndRadius(customView: ui_view_container, radius: 20)
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
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

    func populateCell(name:String, subtitle:String) {
        ui_title.text = name
        ui_subtitle.text = subtitle
    }
    
}