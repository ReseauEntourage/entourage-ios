//
//  HomeCellPedago.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit
import SDWebImage

class HomeCellPedago:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_label_pedago: UILabel!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_label_duration: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.clipsToBounds = true
    }
    
    func configure(pedago:PedagogicResource){
        ui_label_title.text = pedago.title
        if let imageUrl = pedago.imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage:UIImage(named: "placeholder_action"))
        }
        else {
            ui_image.image = UIImage(named: "placeholder_action")
        }
        switch pedago.tag{
        case .All:
            ui_label_pedago.text = "home_v2_pedago_item_tag_all".localized
        case .Understand:
            ui_label_pedago.text = "home_v2_pedago_item_tag_understand".localized
        case .Act:
            ui_label_pedago.text = "home_v2_pedago_item_tag_act".localized
        case .Inspire:
            ui_label_pedago.text = "home_v2_pedago_item_tag_inspire".localized
        case .None:
            ui_label_title.text = "Autre"
        }
        if let _duration = pedago.duration{
            if _duration > 0 {
                ui_label_duration.text = String(format: "home_v2_pedag_item_lenght_title".localized, _duration)
            }else{
                ui_label_duration.isHidden = true
            }
        }else{
            ui_label_duration.isHidden = true

        }
    }
}
