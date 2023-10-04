//
//  HomeSeeAllCell.swift
//  entourage
//
//  Created by Clement entourage on 26/09/2023.
//

import Foundation
import UIKit

class HomeSeeAllCell: UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_image_arrow: UIImageView!
    @IBOutlet weak var ui_label_see_all: UILabel!
    
    //VAR
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
    }
    
    func configure(type:seeAllCellType){
        switch type{
        case .seeAllDemand:
            self.ui_label_see_all.text = "home_v2_btn_more_action".localized
        case .seeAllEvent:
            self.ui_label_see_all.text = "home_v2_btn_more_event".localized
        case .seeAllGroup:
            self.ui_label_see_all.text = "home_v2_btn_more_group".localized
        case .seeAllPedago:
            self.ui_label_see_all.text = "home_v2_btn_more_pedago".localized
        }
    }
}
