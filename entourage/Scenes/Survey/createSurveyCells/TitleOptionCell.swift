//
//  TitleOptionCell.swift
//  entourage
//
//  Created by Clement entourage on 14/03/2024.
//

import Foundation
import UIKit

protocol TitleOptionCellDelegate{
    
}
class TitleOptionCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_label_title: UILabel!
    
    //VAR
    var delegate:TitleOptionCellDelegate? = nil
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
    }
    
    func configure(){
        
    }
    
}
