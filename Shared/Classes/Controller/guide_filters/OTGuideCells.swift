//
//  OTGuideCells.swift
//  entourage
//
//  Created by Jr on 18/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit


class OTGuideFilterCell: UITableViewCell {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_switch: UISwitch!
    
    weak var delegate:ChangeFilterGDSDelegate? = nil
    
    func populateCell(item:OTGuideFilterItem,position:Int,delegate:ChangeFilterGDSDelegate) {
        ui_label_title.text = item.title
        ui_image.image = UIImage.init(named: item.image)
        ui_switch.setOn(item.active, animated: true)
        ui_switch.tag = position
        self.delegate = delegate
    }
    
    @IBAction func action_change(_ sender: UISwitch) {
        delegate?.changeAtPosition(sender.tag, isActive: sender.isOn)
    }
}

class OTGuideTopFilterCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_doante: UIView!
    @IBOutlet weak var ui_view_volunteer: UIView!
    @IBOutlet weak var ui_image_partner: UIImageView!
    @IBOutlet weak var ui_label_title_partner: UILabel!
    @IBOutlet weak var ui_switch_partner: UISwitch!
    
    @IBOutlet weak var ui_label_title_donated: UILabel!
    @IBOutlet weak var ui_switch_donated: UISwitch!
    @IBOutlet weak var ui_label_title_volunteer: UILabel!
    @IBOutlet weak var ui_switch_volunteer: UISwitch!
    
    weak var delegate:ChangeFilterGDSDelegate? = nil
    
    func populateCell(isPartnerOn:Bool, isDonatedOn:Bool, isVolunteerOn:Bool, delegate:ChangeFilterGDSDelegate) {
        
        ui_label_title_partner.text = OTLocalisationService.getLocalizedValue(forKey: "guide_display_partners")
        ui_image_partner.image = UIImage.init(named: "pin_partners_without_shadow")
        ui_switch_partner.setOn(isPartnerOn, animated: true)
        ui_switch_partner.tag = 1
        
        ui_label_title_donated.text = OTLocalisationService.getLocalizedValue(forKey: "guide_display_donate")
        ui_switch_donated.setOn(isDonatedOn, animated: true)
        ui_switch_donated.tag = 2
        
        ui_label_title_volunteer.text = OTLocalisationService.getLocalizedValue(forKey: "guide_display_volunteer")
        ui_switch_volunteer.setOn(isVolunteerOn, animated: true)
        ui_switch_volunteer.tag = 3
        
        self.delegate = delegate
        checkPartnerOn()
    }
    
    func checkPartnerOn() {
        if ui_switch_partner.isOn {
            ui_view_doante.isHidden = false
            ui_view_volunteer.isHidden = false
        }
        else {
            ui_view_doante.isHidden = true
            ui_view_volunteer.isHidden = true
        }
    }
    
    @IBAction func action_change(_ sender: UISwitch) {
        delegate?.changeTop(sender.tag, isActive: sender.isOn)
        checkPartnerOn()
        delegate?.updateTable()
    }
}
