//
//  PedagogicSectionCell.swift
//  entourage
//
//  Created by Jerome on 09/06/2022.
//

import UIKit

class PedagogicSectionCell: UITableViewCell {

    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        addShadowAndRadius(customView: ui_view_container, radius: ApplicationTheme.bigCornerRadius)
    }

    private func addShadowAndRadius(customView:UIView,radius:CGFloat) {
        customView.addRadiusTopOnly(radius: radius)
        customView.layer.cornerRadius = radius
        customView.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.35).cgColor
        customView.layer.shadowOpacity = 0.3
        customView.layer.shadowOffset = CGSize.init(width: 1, height: -1)
        customView.layer.shadowRadius = 2
        
        customView.layer.rasterizationScale = UIScreen.main.scale
        customView.layer.shouldRasterize = true
    }
    
    func populateCell(title:String) {
        ui_title.text = title
    }
}
