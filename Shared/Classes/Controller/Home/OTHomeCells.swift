//
//  OTHomeNeoCells.swift
//  entourage
//
//  Created by Jr on 09/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation



class OTHomeInfoCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    
    @IBOutlet weak var ui_button: UIButton!
    weak var delegate:HomeInfoDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_button.accessibilityLabel = "Vers profil"
    }
    
    func populate(delegate:HomeInfoDelegate) {
        let title = OTLocalisationService.getLocalizedValue(forKey: "home_expert_cell_info_title")
        let subtitle = OTLocalisationService.getLocalizedValue(forKey: "home_expert_cell_info_subtitle")
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
