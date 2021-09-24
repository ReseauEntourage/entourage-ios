//
//  OTHomeNeoCells.swift
//  entourage
//
//  Created by Jr on 09/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation


class OTHomeNeoCell: UITableViewCell {
    @IBOutlet weak var ui_view_bg: UIView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    @IBOutlet weak var ui_picto: UIImageView!
    
    @IBOutlet weak var ui_view_button: UIView?
    @IBOutlet weak var ui_title_button: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_view_bg.layer.cornerRadius = 4.0
        ui_view_button?.layer.cornerRadius = 4.0
    }
    
    func populateAction() {
        ui_view_bg.backgroundColor = UIColor.white
        ui_view_bg.layer.borderColor = UIColor.appOrange().cgColor
        ui_view_bg.layer.borderWidth = 1
        
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_bottom_title")
        ui_description.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_bottom_description")
        ui_title_button.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_bottom_button")
    }
    
    func populateCell(cellType:CellType, title:String, description:String, imageNamed:String, buttonTitle:String) {
        
        switch cellType {
        case .Orange:
            ui_view_bg.backgroundColor = UIColor.appLightPink()
            ui_view_bg.layer.borderWidth = 0
            
            ui_view_button?.backgroundColor = UIColor.appOrange()
            ui_view_button?.layer.borderWidth = 0
            
            ui_title_button.textColor = UIColor.white
        case .White:
            ui_view_bg.backgroundColor = UIColor.white
            ui_view_bg.layer.borderColor = UIColor.appOrange().cgColor
            ui_view_bg.layer.borderWidth = 1
            
            ui_view_button?.backgroundColor = UIColor.white
            ui_view_button?.layer.borderWidth = 2.0
            ui_view_button?.layer.borderColor = UIColor.appOrange()?.cgColor
            ui_title_button.textColor = UIColor.appOrange()
        case .Grey:
            ui_view_bg.backgroundColor = UIColor.appLightGrey246()
            ui_view_bg.layer.borderColor = UIColor.black.cgColor
            ui_view_bg.layer.borderWidth = 1
            
            ui_view_button?.backgroundColor = UIColor.white
            ui_view_button?.layer.borderWidth = 2.0
            ui_view_button?.layer.borderColor = UIColor.appOrange()?.cgColor
            ui_title_button.textColor = UIColor.appOrange()
        }
        
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: title)
        ui_description.text = OTLocalisationService.getLocalizedValue(forKey: description)
        ui_picto.image = UIImage.init(named: imageNamed)
        ui_title_button.text = OTLocalisationService.getLocalizedValue(forKey: buttonTitle)?.uppercased()
    }
    
    enum CellType {
        case Orange
        case White
        case Grey
    }
}


class OTHomeInfoCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    
    weak var delegate:HomeInfoDelegate? = nil
    
    func populate(isNeo:Bool, delegate:HomeInfoDelegate) {
        let title = isNeo ? OTLocalisationService.getLocalizedValue(forKey: "home_neo_cell_info_title") : OTLocalisationService.getLocalizedValue(forKey: "home_expert_cell_info_title")
        let subtitle = isNeo ? OTLocalisationService.getLocalizedValue(forKey: "home_neo_cell_info_subtitle") : OTLocalisationService.getLocalizedValue(forKey: "home_expert_cell_info_subtitle")
        ui_title.text = title
        ui_subtitle.text = subtitle
        self.delegate = delegate
    }
    
    @IBAction func action_show(_ sender: Any) {
        delegate?.showProfile()
    }
}

protocol HomeInfoDelegate:AnyObject {
    func showProfile()
}
