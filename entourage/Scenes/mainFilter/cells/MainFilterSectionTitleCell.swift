//
//  MainFilterSectionTitleCell.swift
//  entourage
//
//  Created by Clement entourage on 20/06/2024.
//

import Foundation
import UIKit

class MainFilterSectionTitleCell:UITableViewCell {
    
    //Outlet
    
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var ui_label_number_items: UILabel!
    @IBOutlet weak var constraint_top: NSLayoutConstraint!
    //Variable
    
    override func awakeFromNib() {
        
    }
    
    func configure(content:String, numberOfItem:Int){
        self.ui_label_subtitle.text = content
        self.ui_label_number_items.text = String(numberOfItem)
        if content.contains("loca") {
            self.constraint_top.constant = 45
        }else{
            self.constraint_top.constant = 16
        }
        if numberOfItem == 0 {
            self.ui_label_number_items.isHidden = true
        }else{
            self.ui_label_number_items.isHidden = false
        }
    }
    
}
