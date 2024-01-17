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
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_desc: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        //TO DO : add text config for translation
    }
    
    func configureForGroup(){
        ui_label_title.text = "neighborhood_group_discover_empty_title".localized
        ui_label_desc.text = "neighborhood_group_discover_empty_subtitle".localized
    }
}
