//
//  PedagogicCell.swift
//  entourage
//
//  Created by Jerome on 09/06/2022.
//

import UIKit

class PedagogicCell: UITableViewCell {

    @IBOutlet weak var ui_container: UIView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_image: UIImageView!

    @IBOutlet weak var ui_picto_check: UIImageView!
    @IBOutlet weak var ui_view_test: UIView!
    var isAlreadyRead = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        setBackgroundView(isRead: false)
        ui_container.layer.cornerRadius = 20
        
        
        ui_view_test?.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.35).cgColor
        ui_view_test?.layer.shadowOpacity = 1
        ui_view_test?.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        ui_view_test?.layer.shadowRadius = 4
        
        ui_view_test?.layer.rasterizationScale = UIScreen.main.scale
        ui_view_test?.layer.shouldRasterize = true
    }
    
    func populateCell(title:String,imageUrl:String?, isRead:Bool) {
        self.isAlreadyRead = isRead
        
        ui_title.text = title
        
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage:UIImage(named: "placeholder_action"))
        }
        else {
            ui_image.image = UIImage(named: "placeholder_action")
        }
        setBackgroundView(isRead: isRead)
    }
    
    func setBackgroundView(isRead:Bool) {
        if isRead {
            ui_container.layer.borderColor = UIColor.appOrange.cgColor
            ui_container.layer.borderWidth = 1
            ui_container.backgroundColor = .white
            ui_picto_check.isHidden = false
        }
        else {
            ui_container.layer.borderWidth = 0
            ui_container.backgroundColor = .appBeige
            ui_picto_check.isHidden = true
        }
    }
}

class PedagogicEndCell: PedagogicCell {
    @IBOutlet weak var ui_view_container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
        addShadowAndRadius(customView: ui_view_container, radius: ApplicationTheme.bigCornerRadius)
    }
    
    private func addShadowAndRadius(customView:UIView,radius:CGFloat) {
        customView.addRadiusBottomOnly(radius: radius)
        customView.layer.cornerRadius = radius
        customView.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.35).cgColor
        customView.layer.shadowOpacity = 1
        customView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        customView.layer.shadowRadius = 4
        
        customView.layer.rasterizationScale = UIScreen.main.scale
        customView.layer.shouldRasterize = true
    }
}
