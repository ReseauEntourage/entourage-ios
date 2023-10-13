//
//  EmptyListCell.swift
//  entourage
//
//  Created by Clement entourage on 19/09/2023.
//

import Foundation
import UIKit

class EmptyListCell:UITableViewCell{
    
    //OUTLET
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        //TO DO : add text config for translation
    }
}
