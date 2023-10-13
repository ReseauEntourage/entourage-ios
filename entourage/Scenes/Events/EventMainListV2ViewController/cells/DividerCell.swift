//
//  DividerCell.swift
//  entourage
//
//  Created by Clement entourage on 19/09/2023.
//

import Foundation
import UIKit

class DividerCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_title_label: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
    }
    
    func configure(title:String){
        self.ui_title_label.text = title
    }
    
}
