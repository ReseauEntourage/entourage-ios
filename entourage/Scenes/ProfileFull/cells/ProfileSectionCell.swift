//
//  ProfileSectionCell.swift
//  entourage
//
//  Created by Clement entourage on 20/01/2025.
//

import Foundation
import UIKit

class ProfileSectionCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_title: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    
    override func awakeFromNib() {
        
    }
    
    func configure(title:String) {
        ui_title.text = title
    }
    
}
