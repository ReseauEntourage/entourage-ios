//
//  MainFilterTitleCell.swift
//  entourage
//
//  Created by Clement entourage on 20/06/2024.
//

import Foundation
import UIKit

class MainFilterTitleCell:UITableViewCell {
    
    //Outlet
    @IBOutlet weak var ui_title_label: UILabel!
    
    //Variable
    
    override func awakeFromNib() {
        
    }
    
    func configure(title:String){
        self.ui_title_label.text = title
    }
    
}
