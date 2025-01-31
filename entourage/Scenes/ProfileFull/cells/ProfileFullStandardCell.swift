//
//  ProfileFullStandardCell.swift
//  entourage
//
//  Created by Clement entourage on 20/01/2025.
//

import Foundation
import UIKit

class ProfileFullStandardCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    
    override func awakeFromNib() {
        ui_title.setFontTitle(size: 15)
        ui_subtitle.setFontBody(size: 13)
        ui_subtitle.textColor = UIColor.appGreyOff
    }
    
    func configure(image:String, title:String, subtitle:String){
        ui_title.text = title
        ui_subtitle.text = subtitle
        ui_image.image = UIImage(named: image)
        
        if title == "logout_button".localized || title == "delete_account_button".localized {
            ui_title.textColor = UIColor.orange
        }else{
            ui_title.textColor = UIColor.black

        }
    }
    
}
