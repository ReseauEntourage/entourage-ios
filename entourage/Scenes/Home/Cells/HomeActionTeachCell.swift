//
//  HomeActionTeachCell.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import UIKit

class HomeActionTeachCell: UITableViewCell {

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
        
        ui_view_container.layer.cornerRadius = 20
        ui_image.layer.cornerRadius = 8
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_image.image = UIImage(named: "ic_action_pedago")
    }
    
    func populateCell(title:String, imageIdentifier:String? = nil, bottomMargin:CGFloat? = nil ) {
        ui_title.text = title
        if let imageIdentifier = imageIdentifier {
            ui_image.image = UIImage.init(named: imageIdentifier)
            ui_image.contentMode = .scaleAspectFill
        }
        
        if let bottomMargin = bottomMargin {
            ui_constraint_bottom_margin.constant = bottomMargin
        }
    }
}
