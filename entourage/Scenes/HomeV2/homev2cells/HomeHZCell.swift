//
//  HomeHZCell.swift
//  entourage
//
//  Created by Clement entourage on 11/10/2023.
//

import Foundation
import UIKit

protocol HomeHZCellDelegate{
    func onCLickGoBuffet()
}

class HomeHZCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_image_hz: UIImageView!
    @IBOutlet weak var ui_label_title_hz: UILabel!
    @IBOutlet weak var ui_label_subtitle_hz: UILabel!
    @IBOutlet weak var ui_button_hz: UIButton!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    var delegate:HomeHZCellDelegate?
    
    override func awakeFromNib() {
        self.ui_label_title_hz.text = "home_v2_hz_item_title".localized
        self.ui_label_subtitle_hz.text = "home_v2_hz_item_subtitle".localized
        self.ui_button_hz.setTitle("home_v2_hz_item_button".localized, for: .normal)
        self.ui_button_hz.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
    }
    
    @objc func onButtonClick(){
        delegate?.onCLickGoBuffet()
    }
}
