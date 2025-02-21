//
//  MentionCell.swift
//  entourage
//
//  Created by Clement entourage on 21/02/2025.
//

import Foundation
import UIKit

class MentionCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_img_avatar: UIImageView!
    @IBOutlet weak var ui_labe_name: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        ui_labe_name.setFontTitle(size: 15)
    }
    
    func configure(igm:String , name:String){
        self.ui_labe_name.text = name
        if let _url = URL(string: igm){
            self.ui_img_avatar.sd_setImage(with: _url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
    }
}
