//
//  VersionAppCell.swift
//  entourage
//
//  Created by Clement entourage on 11/02/2025.
//

import Foundation
import UIKit

class VersionAppCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_label_version: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        ui_label_version.setFontBody(size: 10)
    }
    
    func configure(version:String){
        self.ui_label_version.text = version
    }
}
