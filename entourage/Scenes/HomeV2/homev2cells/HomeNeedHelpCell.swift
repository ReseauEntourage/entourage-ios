//
//  HomeNeedHelpCell.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit

enum HomeNeedHelpType {
    case createEvent
    case createGroup
}

class HomeNeedHelpCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var ui_label_title: UILabel!
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.clipsToBounds = true
    }
    
    func configure(homeNeedHelpType:HomeNeedHelpType){
        switch homeNeedHelpType {
        case .createEvent:
            ui_label_title.text = "home_v2_help_title_two".localized
            ui_image.image = UIImage(named: "ic_calendar_home_v2")
        case .createGroup:
            ui_label_title.text = "home_v2_help_title_one".localized
            ui_image.image = UIImage(named: "ic_people_home_v2")
        }
    }
}
