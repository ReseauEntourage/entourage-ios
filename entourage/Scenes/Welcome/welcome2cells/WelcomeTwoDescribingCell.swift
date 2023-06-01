//
//  WelcomeTwoDescribingCell.swift
//  entourage
//
//  Created by Clement entourage on 30/05/2023.
//

import Foundation
import UIKit


class WelcomeTwoDescribingCell:UITableViewCell {
    
    @IBOutlet weak var ui_title_group: UILabel!
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
    }
    func configure(title:String){
        self.ui_title_group.text = title
    }
    
}
