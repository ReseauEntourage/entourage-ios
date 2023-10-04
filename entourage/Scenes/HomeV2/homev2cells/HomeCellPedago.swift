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
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_label_pedago: UILabel!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_label_duration: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
    }
    
    func configure(pedago:PedagogicResource){

        ui_label_title.text = pedago.title
        if let imageUrl = pedago.imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage:UIImage(named: "placeholder_action"))
        }
        else {
            ui_image.image = UIImage(named: "placeholder_action")
        }
        //ui_label_duration = pedago.
        print("eho " , pedago.bodyHtml)
        print("eho " , pedago.description)
    }
    
    
}
