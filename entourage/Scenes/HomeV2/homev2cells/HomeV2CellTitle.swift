//
//  HomeV2CellTitle.swift
//  entourage
//
//  Created by Clement entourage on 26/09/2023.
//

import Foundation
import UIKit

class HomeV2CellTitle:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_label_subtitle: UILabel!
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
    }
    
    func configure(title:String, subtitle:String){
        self.ui_label_title.text = title
        self.ui_label_subtitle.text = subtitle
    }
}
